mesh_file_names = "./mesh/square_meshes/mesh_test_0.0078125.g"

number_of_nodes = 16641
number_of_elements = 128^2
number_of_node_set_nodes = 128 + 1

function test_read_node_set_ids_on_square_meshes()
  exo = ExodusDatabase(abspath(mesh_file_name), "r")
  nset_ids = read_node_set_ids(exo)
  @test length(nset_ids) == 4
  @test nset_ids == [1, 2, 3, 4]
  close(exo)
end

function test_read_node_set_nodes_on_square_meshes()
  exo = ExodusDatabase(abspath(mesh_file_name), "r")
  nset_ids = read_node_set_ids(exo)
  for (id, nset_id) in enumerate(nset_ids)
    nset = NodeSet(exo, nset_id)
    @test nset.node_set_id == id
    @test nset.num_nodes == number_of_node_set_nodes
    @test length(nset.nodes) == number_of_node_set_nodes
  end
  close(exo)
end

function test_read_node_sets_on_square_meshes()
  exo = ExodusDatabase(abspath(mesh_file_name), "r")
  nset_ids = read_node_set_ids(exo)
  nsets = read_node_sets(exo, nset_ids)
  @test length(nsets) == 4
  for i = 1:4
    @test length(nsets[i]) == number_of_node_set_nodes
  end
  close(exo)
end

@exodus_unit_test_set "NodeSets.jl - Read" begin
  test_read_node_set_ids_on_square_meshes()
  test_read_node_set_nodes_on_square_meshes()
  test_read_node_sets_on_square_meshes()
end