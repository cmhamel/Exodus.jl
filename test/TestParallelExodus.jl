if sys.iswindows()
  # weirdly not working here
else
  @testset ExtendedTestSet "ParallelExodusDatabase" begin
    exo = ParallelExodusDatabase("mesh/square_meshes/mesh_test.g", 4)
    close(exo)
  end
end
