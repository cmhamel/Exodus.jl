using Exodus
using PartitionedArrays

ranks = distribute_with_mpi(LinearIndices((8,)))
# exos, inits = ExodusDatabase(ranks, "test/mesh/cube_meshes/mesh_test.g")
parts = uniform_partition(ranks, "mesh/cube_meshes/mesh_test.g")
parts = uniform_partition(ranks, "mesh/cube_meshes/mesh_test.g", 2)
