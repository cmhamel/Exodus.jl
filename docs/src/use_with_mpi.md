# Use with MPI

## Use With MPI.jl
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

## Use with MPI and juliac --experimental --trim (requires julia 1.12 or later and system MPI)
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
