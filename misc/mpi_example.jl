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
