[![Build Status](https://github.com/cmhamel/Exodus.jl/workflows/CI/badge.svg)](https://github.com/cmhamel/Exodus.jl/actions?query=workflow%3ACI)
[![Aqua QA](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)
[![Coverage](https://codecov.io/gh/cmhamel/Exodus.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/cmhamel/Exodus.jl)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://cmhamel.github.io/Exodus.jl/dev/)

# Exodus.jl

A Julia interface to the [ExodusII](https://github.com/sandialabs/seacas) data format used for large-scale finite element simulations. The underlying C library (`libexodus`) is accessed through a pre-built binary (`Exodus_jll`) via `@ccall`, so no separate ExodusII/SEACAS installation is required.

Several helper utilities from [SEACAS](https://github.com/sandialabs/seacas) are also bundled to ease working with ExodusII files in parallel environments (`decomp`, `epu`) and for diffing files (`exodiff`).

📖 **Full documentation:** https://cmhamel.github.io/Exodus.jl/dev/

## Contents

1. [Installation](#installation)
2. [Package Extensions](#package-extensions)
3. [Core Concepts](#core-concepts)
4. [Opening and Closing Files](#opening-and-closing-files)
5. [Reading Data](#reading-data)
6. [Writing Data (Read-Write Mode)](#writing-data-read-write-mode)
7. [Writing Data (Write Mode, From Scratch)](#writing-data-write-mode-from-scratch)
8. [Parallel / Decomposed Meshes](#parallel--decomposed-meshes)
9. [Use With MPI.jl](#use-with-mpijl)
10. [Use with MPI and `juliac --experimental --trim`](#use-with-mpi-and-juliac---experimental---trim-requires-julia-112-or-later)
11. [Documentation](#documentation)

## Installation

From the package manager:

```julia
pkg> add Exodus
```

Or from the REPL:

```julia
julia> using Pkg
julia> Pkg.add("Exodus")
```

## Package Extensions

Several (still experimental) package extensions are provided:

- `ExodusMeshesExt.jl` — a simple interface to `SimpleMesh` in [Meshes.jl](https://github.com/JuliaGeometry/Meshes.jl).
- `ExodusUnitfulExt.jl` — additional read/write methods for working with [Unitful.jl](https://github.com/PainterQubits/Unitful.jl) `Quantity`s.

## Core Concepts

Everything in `Exodus.jl` revolves around a handful of types:

- **`ExodusDatabase{M, I, B, F}`** — the open file handle. The four type parameters track the integer/float storage modes Exodus negotiated for the file: `M` (map ints), `I` (set/variable IDs), `B` (bulk data, e.g. connectivity), and `F` (field data, `Float32`/`Float64`). It also caches an `Initialization` header (dimension/node/element/block/set counts) and name→ID lookup tables for fast by-name access.
- **Sets** — `Block`, `NodeSet`, and `SideSet` (all `AbstractExodusSet`) represent element blocks, node sets, and side sets, and share a common ID/name interface (`read_ids`, `read_names`, `write_name`, ...).
- **Variables** — `GlobalVariable`, `NodalVariable` (alias `NodalScalarVariable`), `NodalVectorVariable`, `ElementVariable`, `NodeSetVariable`, and `SideSetVariable` (all `AbstractExodusVariable`) are dispatch-only marker types used with `read_values`/`write_values` to select which kind of time-dependent field you're reading or writing.
- **Maps** — `NodeMap`, `ElementMap`, `FaceMap`, `EdgeMap` (all `AbstractExodusMap`) identify the various local↔global numbering maps Exodus stores.

See the [API reference](https://cmhamel.github.io/Exodus.jl/dev/) for the complete type hierarchy and function list.

## Opening and Closing Files

The simplest way to open a file:

```julia
mode = "r" # "r" (read), "rw" (read-write), or "w" (write/create)
exo = ExodusDatabase("/path/to/file.e", mode)
```

This is convenient but type-unstable, since the storage types aren't known until the file is actually opened. If you know your file's storage types ahead of time (commonly 32-bit integers for IDs and 64-bit floats for values), use the explicit, type-stable constructor instead:

```julia
exo = ExodusDatabase{Int32, Int32, Int32, Float64}("/path/to/file.e", mode)
```

Either constructor returns an `ExodusDatabase`, which also carries metadata about the names of sets and variables present in the file, enabling a clean by-name API. Always `close(exo)` when finished, or use the do-block form which closes automatically (even on error):

```julia
ExodusDatabase("/path/to/file.e", "r") do exo
    coords = read_coordinates(exo)
end
```

## Reading Data

```julia
using Exodus

exo = ExodusDatabase("../path-to-file/file.e", "r") # read-only

coords          = read_coordinates(exo)             # num_dim x num_nodes matrix
blocks          = read_sets(exo, Block)              # element blocks (connectivity)
nsets           = read_sets(exo, NodeSet)            # node sets (e.g. boundary nodes)
ssets           = read_sets(exo, SideSet)            # side sets
nodal_var_names = read_names(exo, NodalVariable)
elem_var_names  = read_names(exo, ElementVariable)

displ_x = read_values(exo, NodalVariable, 1, "displ_x")        # time step 1
stress  = read_values(exo, ElementVariable, 1, 1, "stress_xx") # block 1, time step 1

close(exo) # always clean up
```

Individual blocks/sets can also be fetched directly by ID or name:

```julia
block = read_block(exo, 1)
block = read_block(exo, "block_1")
nset  = NodeSet(exo, "nset_1")
```

## Writing Data (Read-Write Mode)

A common workflow: copy an existing mesh, then open it in `"rw"` mode to append time steps and field data.

```julia
using Exodus

copy_mesh("./mesh.g", "./temp_element_variables.e")
exo = ExodusDatabase("./temp_element_variables.e", "rw")

write_time(exo, 1, 0.0)

write_names(exo, NodalVariable, ["displ_x", "displ_y"])
write_names(exo, ElementVariable, ["stress_xx", "stress_yy", "stress_xy"])

write_values(exo, NodalVariable, 1, "displ_x", randn(num_nodes(exo.init)))
# ... and so on

close(exo)
```

## Writing Data (Write Mode, From Scratch)

To build a brand-new Exodus file entirely from scratch:

```julia
using Exodus

# data to write
coords = [
  1.0 0.5 0.5 1.0 0.0 0.0 0.5 1.0 0.0
  1.0 1.0 0.5 0.5 1.0 0.5 0.0 0.0 0.0
]

conn = [
  1 2 4 3
  2 5 3 6
  3 6 7 9
  4 3 8 7
]

v_nodal_1 = rand(9)
v_nodal_2 = rand(9)
v_elem_1  = rand(4)
v_elem_2  = rand(4)

# storage types
maps_int_type = Int32
ids_int_type  = Int32
bulk_int_type = Int32
float_type    = Float64

# initialization (mesh sizing) header
num_dim, num_nodes = size(coords)
num_elems          = size(conn, 2)
num_elem_blks      = 1
num_node_sets      = 0
num_side_sets      = 0

init = Initialization{bulk_int_type}(
  num_dim, num_nodes, num_elems,
  num_elem_blks, num_node_sets, num_side_sets
)

exo = ExodusDatabase{maps_int_type, ids_int_type, bulk_int_type, float_type}(
  "test_write.e", "w", init
)

write_coordinates(exo, coords)
write_block(exo, 1, "QUAD4", conn)

# at least one time step is required before writing variable values
write_time(exo, 1, 0.0)

write_names(exo, NodalVariable, ["v_nodal_1", "v_nodal_2"])
write_names(exo, ElementVariable, ["v_elem_1", "v_elem_2"])

write_values(exo, NodalVariable, 1, "v_nodal_1", v_nodal_1)
write_values(exo, NodalVariable, 1, "v_nodal_2", v_nodal_2)
# first 1 = time step, second 1 = block ID
write_values(exo, ElementVariable, 1, 1, "v_elem_1", v_elem_1)
write_values(exo, ElementVariable, 1, 1, "v_elem_2", v_elem_2)

close(exo) # don't skip this — the file can be corrupted otherwise
```

## Parallel / Decomposed Meshes

`Exodus.jl` wraps the SEACAS command-line tools for mesh decomposition and recombination, and can read the per-rank metadata (load-balance parameters, communication maps, processor-local node/element maps) embedded in decomposed files — all without requiring an MPI build:

```julia
decomp("mesh.exo", 4)               # partition into 4 per-processor files
epu("output.exo")                   # recombine per-processor results
exodiff("a.exo", "b.exo")           # numerically diff two databases
```

For lower-level access to a given shard's parallel metadata:

```julia
exo = ExodusDatabase("mesh.exo.4.0", "r")
lb         = LoadBalanceParameters(exo, 1)
cmap       = CommunicationMapParameters(exo, lb, 1)
node_cmap  = NodeCommunicationMap(exo, cmap.node_cmap_ids[1], cmap.node_cmap_node_cnts[1], 1)
node_maps  = ProcessorNodeMaps(exo, 1)
```

## Use With MPI.jl

```julia
using Exodus
using MPI

MPI.Init()
comm = MPI.COMM_WORLD

# First decompose mesh into n parts
if MPI.Comm_rank(comm) == 0
    decomp("hole_array.exo", MPI.Comm_size(comm))
end
MPI.Barrier(comm)

# Now read the shard for this rank
file_name = "hole_array.exo.$(MPI.Comm_size(comm)).$(MPI.Comm_rank(comm))"
exo = ExodusDatabase(file_name, "r")
@show exo
MPI.Barrier(comm)

# Copy this rank's mesh shard
new_file_name = "output.exo.$(MPI.Comm_size(comm)).$(MPI.Comm_rank(comm))"
copy_mesh(file_name, new_file_name)
MPI.Barrier(comm)

# Stitch the output shards back together
if MPI.Comm_rank(comm) == 0
    epu("output.exo")
end
MPI.Barrier(comm)

MPI.Finalize()
```

## Use with MPI and `juliac --experimental --trim` (requires Julia 1.12 or later)

`juliac --experimental --trim` is an experimental Julia 1.12 feature for compiling small, statically-typed standalone binaries. `Exodus.jl` has been updated to work in this setting. As of now, [MPI.jl](https://github.com/JuliaParallel/MPI.jl) does not play nicely with `--trim`, so the example below calls the system-installed MPI library directly via `ccall`. Paths and library names will likely differ on your system; this was tested on Ubuntu 24.04 with 4 MPI ranks.

First, decompose the mesh offline, outside the trimmed executable:

```julia
using Exodus
decomp("hole_array.exo", 4)
```

Then write a `@ccallable` entry point:

```julia
using Exodus

const libmpi = "/usr/lib/x86_64-linux-gnu/libmpi.so.12"
const MPI_Comm = Ptr{Cvoid}
const MPI_COMM_WORLD = Cint(0x44000000)

Base.@ccallable function main()::Cint
    ccall((:MPI_Init, libmpi), Cint, (Ptr{Cvoid}, Ptr{Cvoid}), C_NULL, C_NULL)

    rank = Ref{Cint}()
    size = Ref{Cint}()
    ccall((:MPI_Comm_rank, libmpi), Cint, (Cint, Ptr{Cint}), MPI_COMM_WORLD, rank)
    ccall((:MPI_Comm_size, libmpi), Cint, (Cint, Ptr{Cint}), MPI_COMM_WORLD, size)

    println(Core.stdout, "Hello from rank $(rank[]) of $(size[])")

    file_name = "hole_array.exo.$(size[]).$(rank[])"
    exo = ExodusDatabase{Int32, Int32, Int32, Float64}(file_name, "r")
    println(Core.stdout, "$exo")

    new_file_name = "output.exo.$(size[]).$(rank[])"
    copy(exo, new_file_name)

    # ... do some work ...

    ccall((:MPI_Finalize, libmpi), Cint, ())
    return 0
end
```

Compile it with `juliac`:

```sh
julia +1.12 --project=@. ~/.julia/juliaup/julia-1.12.0-beta4+0.x64.linux.gnu/share/julia/juliac.jl \
  --output-exe a.out --compile-ccallable --experimental --trim script.jl
```

This produces a ~3.7MB executable, runnable as:

```sh
mpirun -n 4 ./a.out
```

> **Note:** this workflow is experimental and not every part of the package has been exercised under `--trim`. Please open an issue if you run into trouble.

## Documentation

This README covers the common workflows. For the complete manual — including the full type hierarchy, every read/write function, and the parallel/communication-map API — see the [documentation site](https://cmhamel.github.io/Exodus.jl/dev/), which includes:

- **Core Types** — `ExodusDatabase`, `Initialization`, the `AbstractExodusMap`/`AbstractExodusSet`/`AbstractExodusVariable` hierarchies, parallel metadata structs, and exception types
- **The `ExodusDatabase`** — opening, closing, copying, and inspecting databases
- **Element Blocks**, **Node Sets & Side Sets** — reading and writing mesh topology
- **Coordinates** — nodal coordinate read/write, including partial/component access
- **Maps** — node/element/face/edge maps and ID maps
- **Variables** — global, nodal, element, node set, and side set field data
- **Time Steps**, **Info & QA Records**
- **Parallel / Decomposed Databases** — load-balance and communication-map access, `decomp`/`epu`/`exodiff`
- **Helper Utilities** — connectivity-graph builders (element, node-to-element, element-to-element)
- **API Reference** — full auto-generated docstring index
