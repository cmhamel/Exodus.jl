[![Build Status](https://github.com/cmhamel/Exodus.jl/workflows/CI/badge.svg)](https://github.com/cmhamel/Exodus.jl/actions?query=workflow%3ACI)
[![Aqua QA](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)
[![Coverage](https://codecov.io/gh/cmhamel/Exodus.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/cmhamel/Exodus.jl) 
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://cmhamel.github.io/Exodus.jl/dev/) 


# Exodus.jl
1. [Description](#description)
2. [Installation](#installation)
3. [Package Extensions](#package-extensions)
4. [Opening Exodus Files]()
5. [Reading Data](#reading-data)
6. [Writing Data (Read-Write Mode)](#writing-data-read-write-mode)
7. [Writing Data](#writing-data-write-mode)
8. [Use With MPI.jl](#use-with-mpijl)
9. [Use with MPI and juliac --experimental --trim](#use-with-mpi-and-juliac---experimental---trim-requires-julia-112-or-later)

# Description
A julia interface for accessing the ExodusII data format for large scale finite element simulations. The C library is accessed via a pre-built julia linked library through julia ccalls.

Several helper utilies from [SEACAS](https://github.com/sandialabs/seacas) are also included to aid in using exodusII files in parallel environments and diffing files. 

# Installation
From the package manager simply type
```julia
pkg> add Exodus
```

Or from the REPL
```julia
julia> using Pkg
julia> Pkg.add("Exodus") 
```

# Package Extensions
Several package extensions are provided with ```Exodus.jl```. Please note, many of these are still experimental.

The following extensions are provided
- ```ExodusMeshesExt.jl``` - Provides a simple interface to ```SimpleMesh``` in ```Meshes.jl```.
- ```ExodusPartitionedArrayExt.jl``` - Provides a lightweight interface to ```PartitionedArrays.jl```. Currently inefficient.
- ```ExodusUnitfulExt.jl``` - Provides additional read/write methods to work with ```Unitful.jl``` ```Quantity```s

# Opening Exodus Files
The simplest way to open an exodusII file is to call the following method
```julia
mode = "r" # can be "r" for read, "rw" for read write
           # or "w" for write modes
exo = ExodusDatabase("/path/to/file/file.e", mode)
```
this howewer introduces a type stability however since the storage types different data types are not known until runtime. 

If ahead of time you know the types your data are stored as (typeically 32 bit integers for ids and 64 bit floats for values) you can call this constructor which is type stable (important if you keep reading)
```julia
mode = "r" # can be "r" for read, "rw" for read write
           # or "w" for write modes
exo = ExodusDatabase{Int32, Int32, Int32, Float64}("/path/to/file/file.e", mode)
```
Either way, these constructors return an ```ExodusDatabase``` container which has a field "exo" that is a file id for this now opened exodusII database in "mode" i.e. read/read-write/write format.

The container also contains additional meta-data for the current names of sets, variables, etc. present in the file to allow for a clean and efficient user facing interface.

# Reading Data
To read in an exodusII file (typically has a .e or .exo extension) simply do the following

```julia
exo = ExodusDatabase("/path-to-file/file.e", "r")
```


For more useful methods, one can fetch the blocks of elements as follows which contains connectivity information for different blocks of elements useful for grouping materials
```julia
blocks = read_sets(exo, Block)
```
For boundary conditions one can grab the nodes with the following commands
```julia
nsets = read_sets(exo, NodeSet)
```

Full code example:
```julia
using Exodus
exo = ExodusDatabase("../path-to-file/file.e", "r") # read only format
coords          = read_coordinates(exo) # matrix of n_nodes x n_dim
blocks          = read_sets(exo, Block) # contains connectivity information
nsets           = read_sets(exo, NodeSet) # contains nodes on boundaries
nodal_var_names = read_names(exo, NodalVariable)
elem_var_names  = read_names(exo, ElementVariable)
close(exo) # cleanup
```

# Writing Data (Read-Write Mode)
To write data in read-write mode, it's often common to take a mesh used as input to a simulation, copy it, and then write data to that copied mesh.

Below is an example which first copies a mesh using the ```copy_mesh``` method, then opens the mesh, writes a t time step, writes variable names, and nodal field data.
```julia
using Exodus
copy_mesh("./mesh.g", "./temp_element_variables.e")
exo = ExodusDatabase("./temp_element_variables.e", "rw")

write_time(exo, 1, 0.0)

write_names(exo, NodalVariable, ["displ_x", "displ_y"])
write_names(exo, ElementVariable, ["stress_xx", "stress_yy", "stress_xy"])

write_values(exo, NodalVariable, 1, 1, randn(...))
... # and so on.

close(exo)
```

# Writing Data (Write Mode)
To completely write an exodusII file from a scratch, the following example can be used as a template.
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

# make some hack variables to write
v_nodal_1 = rand(9)
v_nodal_2 = rand(9)

v_elem_1 = rand(4)
v_elem_2 = rand(4)

# set the types
maps_int_type = Int32
ids_int_type  = Int32
bulk_int_type = Int32
float_type    = Float64

# initialization parameters
num_dim, num_nodes = size(coords)
num_elems          = size(conn, 2)
num_elem_blks      = 1
num_side_sets      = 0
num_node_sets      = 0

# make init
init = Initialization{bulk_int_type}(
  num_dim, num_nodes, num_elems,
  num_elem_blks, num_side_sets, num_node_sets
)

# finally make empty exo database
exo = ExodusDatabase(
  "test_write.e", "w", init,
  maps_int_type, ids_int_type, bulk_int_type, float_type
)

# how to write coordinates
write_coordinates(exo, coords)
# how to write a block
write_block(exo, 1, "QUAD4", conn)
# need at least one timestep to output variables
write_time(exo, 1, 0.0)
# write number of variables and their names
write_names(exo, NodalVariable, ["v_nodal_1", "v_nodal_2"])
write_names(exo, ElementVariable, ["v_elem_1", "v_elem_2"])
# write variable values the 1 is for the time step
write_values(exo, NodalVariable, 1, "v_nodal_1", v_nodal_1)
write_values(exo, NodalVariable, 1, "v_nodal_2", v_nodal_2)
# the first 1 is for the time step 
# and the second 1 is for the block number
write_values(exo, ElementVariable, 1, 1, "v_elem_1", v_elem_1)
write_values(exo, ElementVariable, 1, 1, "v_elem_2", v_elem_2)
# don't forget to close the exodusdatabase, it can get corrupted otherwise if you're writing
close(exo)
```

# Use With MPI.jl
To use ```Exodus.jl``` with [MPI.jl](https://github.com/JuliaParallel/MPI.jl), it is quite simple. The following can be used as a recipe for more complex use cases.
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

# Now read the shard for this comm
file_name = "hole_array.exo.$(MPI.Comm_size(comm)).$(MPI.Comm_rank(comm))"
exo = ExodusDatabase(file_name, "r")
@show exo
MPI.Barrier(comm)

# Now we can copy a mesh
new_file_name = "output.exo.$(MPI.Comm_size(comm)).$(MPI.Comm_rank(comm))"
copy_mesh(file_name, new_file_name)
MPI.Barrier(comm)

# Now stich the output shards together
if MPI.Comm_rank(comm) == 0
    epu("output.exo")
end
MPI.Barrier(comm)

MPI.Finalize()
```

# Use with MPI and juliac --experimental --trim (requires julia 1.12 or later)
```juliac --experimental --trim``` is an exciting new experimental development in julia 1.12 that allows for small binaries to be compiled. It code to have strict static typing to achieve this. ```Exodus.jl``` has recently been updated to work in this setting and the below example shows how this can work with MPI. Currently [MPI.jl](https://github.com/JuliaParallel/MPI.jl) has not played nice ```juliac --experimental --trim``` so the below example uses the system installed MPI and julia ```ccall```s. This may (and probably will) differ on your system. This example was tested on Ubuntu 24.04 with 4 MPI ranks as an example.

First we must decompose the mesh offline from the executable we wish to generate. We can do this as follows
```julia
using Exodus
decomp("hole_array.exo", 4)
```

```julia
using Exodus

const libmpi = "/usr/lib/x86_64-linux-gnu/libmpi.so.12"
const MPI_Comm = Ptr{Cvoid}
const MPI_COMM_WORLD = Cint(0x44000000)

Base.@ccallable function main()::Cint
    # Initialize MPI
    ccall((:MPI_Init, libmpi), Cint, (Ptr{Cvoid}, Ptr{Cvoid}), C_NULL, C_NULL)

    # get rank and total number of ranks
    rank = Ref{Cint}()
    size = Ref{Cint}()
    ccall((:MPI_Comm_rank, libmpi), Cint, (Cint, Ptr{Cint}), MPI_COMM_WORLD, rank)
    ccall((:MPI_Comm_size, libmpi), Cint, (Cint, Ptr{Cint}), MPI_COMM_WORLD, size)

    println(Core.stdout, "Hello from rank $(rank[]) of $(size[])")

    # open mesh file
    file_name = "hole_array.exo.$(size[]).$(rank[])"
    exo = ExodusDatabase{Int32, Int32, Int32, Float64}(file_name, "r")
    println(Core.stdout, "$exo")

    new_file_name = "output.exo.$(size[]).$(rank[])"
    copy(exo, new_file_name)

    # then do some stuff ...

    # Finalize MPI
    ccall((:MPI_Finalize, libmpi), Cint, ())

    return 0
end
```

This can then be compiled with ```juliac``` as follows
```
julia +1.12 --project=@. ~/.julia/juliaup/julia-1.12.0-beta4+0.x64.linux.gnu/share/julia
/juliac.jl --output-exe a.out --compile-ccallable --experimental --trim script.jl
```
and produces and executable that is 3.7Mb. It then be run as follows
```
mpirun -n 4 ./a.out
```

Note: this is experimental. Not every piece of the package has been tested here. If you run into bugs, please open an issue.
