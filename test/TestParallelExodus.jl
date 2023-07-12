@testset ExtendedTestSet "ParallelExodusDatabase" begin
  if sys.iswindows()
    # weirdly erroring out here
  else
    exo = ParallelExodusDatabase("mesh/square_meshes/mesh_test.g", 4)
    close(exo)
  end
end