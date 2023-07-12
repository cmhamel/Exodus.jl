@testset ExtendedTestSet "ParallelExodusDatabase" begin
  exo = ParallelExodusDatabase("mesh/square_meshes/mesh_test.g", 4)

  close(exo)
end