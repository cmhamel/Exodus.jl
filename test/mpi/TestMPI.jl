using Exodus
using PartitionedArrays

mesh_file = "mesh/cube_meshes/mesh_test.g"

global_to_color_1 = Exodus.collect_global_to_color(mesh_file, 8)
global_to_color_2 = Exodus.collect_global_to_color(mesh_file, 8, 2)

ranks = distribute_with_mpi(LinearIndices((8,)))
parts_1 = partition_from_color(ranks, mesh_file)
parts_2 = partition_from_color(ranks, mesh_file, 2)

a1 = pones(parts_1)
consistent!(a1)
assemble!(a1)

a2 = pones(parts_2)
consistent!(a2)
assemble!(a2)
