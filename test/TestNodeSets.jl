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

@exodus_unit_test_set "Test read nodeset names" begin
  exo = ExodusDatabase(mesh_file_name, "r")
  nset_names = read_node_set_names(exo)
  @test nset_names == ["nset_1", "nset_2", "nset_3", "nset_4"]
  close(exo)
end

@exodus_unit_test_set "Initialize node set from name" begin
  exo = ExodusDatabase(mesh_file_name, "r")
  for n in [1, 2, 3, 4]
    nset_1 = NodeSet(exo, "nset_$n")
    nset_2 = NodeSet(exo, n)
    @test nset_1.node_set_id == nset_2.node_set_id
    @test nset_1.num_nodes   == nset_2.num_nodes
    @test nset_1.nodes       == nset_2.nodes
  end
  close(exo)
end

@exodus_unit_test_set "Show nodeset" begin
  exo = ExodusDatabase(mesh_file_name, "r")
  nset = NodeSet(exo, 1)
  @show nset
  close(exo)
end

# @exodus_unit_test_set "Test write nodeset names" begin
#   exo_old = ExodusDatabase("./mesh/square_meshes/mesh_test_0.0078125.g", "r")
#   copy(exo_old, "./temp_nodesets.e")
#   close(exo_old)
#   exo = ExodusDatabase("./temp_nodesets.e", "rw")

#   write_node_set_names(exo, ["nset_1", "nset_2"])

#   close(exo)
#   rm("./temp_nodesets.e", force=true)
# end

