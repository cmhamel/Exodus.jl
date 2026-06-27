# The `ExodusDatabase`

The central type in `Exodus.jl` is [`ExodusDatabase`](@ref), a parametric wrapper around an open Exodus file handle (`exoid`) returned by the underlying C library.

```julia
struct ExodusDatabase{M, I, B, F}
    exo::Cint
    mode::String
    file_name::String
    init::Initialization{B}
    # ... internal name -> id lookup dictionaries
end
```

The four type parameters describe the integer/float storage modes used by the database, matching the modes that Exodus itself negotiates when a file is opened:

| Parameter | Meaning                                          |
|:---------:|:--------------------------------------------------|
| `M`       | Integer type used for **maps** (node/element/face/edge maps) |
| `I`       | Integer type used for **IDs** (block, set, and variable IDs) |
| `B`       | Integer type used for **bulk data** (connectivity, counts)   |
| `F`       | Floating point type used for **field data** (`Cfloat` or `Cdouble`) |

Each of `M`, `I`, and `B` is either `Cint` (32-bit) or `Clonglong` (64-bit), depending on how the file was created. `F` is either `Cfloat` or `Cdouble`, depending on the file's float word size.

## Opening and closing files

```julia
exo = ExodusDatabase(file_name, mode)
```

`mode` is one of:

- `"r"` — read-only. The file must already exist.
- `"w"` — write/create. If `file_name` does not exist, it is created (`ex_create`). If it does exist, it is overwritten (`EX_CLOBBER`).
- `"rw"` — open an existing file for both reading and writing.

There are several constructors:

- `ExodusDatabase(file_name, mode)` — type-unstable convenience constructor; infers `M`, `I`, `B`, `F` from the file itself. Recommended for interactive use; for performance-critical code, wrap this call in a barrier function or use the explicit parametric form below.
- `ExodusDatabase{M, I, B, F}(file_name, mode)` — explicit, type-stable constructor; throws a `TypeError` if the requested types do not match the file's actual storage modes.
- `ExodusDatabase{I, F}(file_name, mode)` — convenience form where `M = I = B = I`.
- `ExodusDatabase{M, I, B, F}(file_name, "w", init::Initialization)` — create a brand-new file and immediately write its [`Initialization`](@ref) header (number of dimensions, nodes, elements, blocks, node sets, and side sets).
- `ExodusDatabase(f::Function, file_name, mode)` — do-block form. Guarantees the file is closed (via `close`) even if `f` throws.

```julia
ExodusDatabase("mesh.g", "r") do exo
    # use exo here
end # file is automatically closed
```

To close a database manually:

```julia
close(exo)
```

## Initialization / mesh sizing

When a database is opened, `Exodus.jl` immediately reads the basic mesh sizing information into an [`Initialization`](@ref) struct, accessible via:

```julia
init = Exodus.initialization(exo)
num_dimensions(init)
num_nodes(init)
num_elements(init)
num_element_blocks(init)
num_node_sets(init)
num_side_sets(init)
```

When creating a new file, you construct an `Initialization` up front and pass it to the `ExodusDatabase` constructor:

```julia
init = Initialization(Int64) # zero-initialized; set fields after, or build directly
new_init = Exodus.Initialization{Int64}(2, num_nodes, num_elems, 1, 0, 0)
exo = ExodusDatabase{Int64, Int64, Int64, Float64}("out.e", "w", new_init)
```

## Copying databases

The most reliable way to set up an output database that mirrors an existing mesh (without manually re-writing every block/set/coordinate) is to copy it:

```julia
exo = ExodusDatabase("mesh.g", "r")
copy(exo, "mesh_copy.g"; mesh_only_flag=true)
close(exo)
```

Convenience wrappers are also provided:

```julia
copy_mesh("mesh.g", "mesh_copy.g")
copy_mesh(ExodusDatabase{Int32, Int32, Int32, Float64}, "mesh.g", "mesh_copy.g")
copy_transient("mesh.g", "mesh_copy.g")
```

## Inspecting a database

`ExodusDatabase` has a custom `Base.show` method, so simply displaying it at the REPL prints a readable summary of dimensions, counts, and the names of every block, set, and variable:

```julia
julia> exo
ExodusDatabase:
  File name                   = mesh.g
  Mode                        = r

Initialization:
  Number of dim       = 2
  Number of nodes     = 16641
  Number of elem      = 16384
  Number of blocks    = 1
  Number of node sets = 4
  Number of side sets = 4

Block:
  block_1

NodeSet:
  ...
```

## Errors

Most C calls are checked with `exodus_error_check`, which converts non-zero Exodus return codes into Julia exceptions. In addition, `Exodus.jl` defines several descriptive exception types for common usage errors:

- `ModeException` — an invalid `mode` string was passed to `ExodusDatabase`.
- `SetIDException` / `SetNameException` — a requested [`Block`](@ref), [`NodeSet`](@ref), or [`SideSet`](@ref) ID/name does not exist; the error message lists the valid IDs/names.
- `VariableIDException` / `VariableNameException` — a requested variable ID/name does not exist; the error message lists the valid names.
