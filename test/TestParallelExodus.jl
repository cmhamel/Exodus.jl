@testset ExtendedTestSet "ParallelExodusDatabase" begin
  decomp("mesh/square_meshes/mesh_test.g", 4)
  exo = Exodus.ParallelExodusDatabase("mesh/square_meshes/mesh_test.g", 4)
  @show exo
  coords = read_coordinates(exo)

  block_ids = read_ids(exo, Block)
  for n in 1:4
    @test block_ids[n] == [1]
  end

  nset_ids = read_ids(exo, NodeSet)
  for n in 1:4
    @test nset_ids[n] == [1, 2, 3, 4]
  end

  sset_ids = read_ids(exo, SideSet)
  for n in 1:4
    @test sset_ids[n] == [1, 2, 3, 4]
  end

  blocks = read_sets(exo, Block)
  nsets  = read_sets(exo, NodeSet)
  ssets  = read_sets(exo, SideSet)

  close(exo)

  for n in 1:4
    rm("mesh/square_meshes/mesh_test.g.4.$(n - 1)"; force=true)
  end
  rm("mesh/square_meshes/mesh_test.g.nem"; force=true)
  rm("mesh/square_meshes/mesh_test.g.pex"; force=true)
  rm("mesh/square_meshes/decomp.log"; force=true)
end
