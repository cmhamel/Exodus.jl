using Exodus
using MPI

info = MPI.Info()

MPI.Init()

comm = MPI.COMM_WORLD
print("Hello world, I am rank $(MPI.Comm_rank(comm) + 1) of $(MPI.Comm_size(comm))\n")

base_file_name = "mesh_test.g"
file_name = base_file_name * ".$(MPI.Comm_size(comm)).$(MPI.Comm_rank(comm))"
println("File name = $file_name")
println("Attepting to open file name = $file_name")

# exo = ExodusDatabase("mesh_test.g", "r", comm, info)

exo = ExodusDatabase("mesh_test.g", "r")
display(exo)
MPI.Barrier(comm)
