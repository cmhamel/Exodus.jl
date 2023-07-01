mesh_file_name_2D = "./mesh/square_meshes/mesh_test.g"

number_of_nodes_2D = 16641
number_of_elements_2D = 128^2
number_of_node_set_nodes_2D = 128 + 1

function test_read_node_set_ids_on_square_meshes()
  exo = ExodusDatabase(abspath(mesh_file_name_2D), "r")
  nset_ids = read_node_set_ids(exo)
  @test length(nset_ids) == 4
  @test nset_ids == [1, 2, 3, 4]
  close(exo)
end

function test_read_node_set_nodes_on_square_meshes()
  exo = ExodusDatabase(abspath(mesh_file_name_2D), "r")
  nset_ids = read_node_set_ids(exo)
  for (id, nset_id) in enumerate(nset_ids)
    nset = NodeSet(exo, nset_id)
    @test nset.node_set_id == id
    @test nset.num_nodes == number_of_node_set_nodes_2D
    @test length(nset.nodes) == number_of_node_set_nodes_2D
  end
  close(exo)
end

function test_read_node_sets_on_square_meshes()
  exo = ExodusDatabase(abspath(mesh_file_name_2D), "r")
  nset_ids = read_node_set_ids(exo)
  nsets = read_node_sets(exo, nset_ids)
  @test length(nsets) == 4
  for i = 1:4
    @test length(nsets[i]) == number_of_node_set_nodes_2D
  end
  close(exo)
end

@exodus_unit_test_set "NodeSets.jl - Read" begin
  test_read_node_set_ids_on_square_meshes()
  test_read_node_set_nodes_on_square_meshes()
  test_read_node_sets_on_square_meshes()
end

@exodus_unit_test_set "Test read nodeset names" begin
  exo = ExodusDatabase(mesh_file_name_2D, "r")
  nset_names = read_node_set_names(exo)
  @test nset_names == ["nset_1", "nset_2", "nset_3", "nset_4"]
  close(exo)
end

@exodus_unit_test_set "Initialize node set from name" begin
  exo = ExodusDatabase(mesh_file_name_2D, "r")
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
  exo = ExodusDatabase(mesh_file_name_2D, "r")
  nset = NodeSet(exo, 1)
  @show nset
  close(exo)
end

@exodus_unit_test_set "Write nodeset" begin
  exo_old = ExodusDatabase(abspath(mesh_file_name_2D), "r")
  init_old = Initialization(exo_old)
  coords_old = read_coordinates(exo_old)
  nsets_old = read_node_sets(exo_old, read_node_set_ids(exo_old))
  close(exo_old)

  exo_new = ExodusDatabase("./test_output_nodesets.e", init_old)
  write_coordinates(exo_new, coords_old)
  coords_new = read_coordinates(exo_new)
  for nset in nsets_old
    write_node_set(exo_new, nset)
  end
  nsets_names_old = read_node_set_names(exo_old)
  for (n, nset) in enumerate(nsets_old)
    write_node_set_name(exo_new, nset, nsets_names_old[n])
  end
  nsets_new = read_node_sets(exo_new, read_node_set_ids(exo_new))
  nsets_names_new = read_node_set_names(exo_new)
  close(exo_new)

  @test init_old == exo_new.init
  @test coords_old == coords_new
  for n in eachindex(nsets_old)
    @test nsets_old[n].node_set_id == nsets_new[n].node_set_id
    @test nsets_old[n].num_nodes == nsets_new[n].num_nodes
    @test nsets_old[n].nodes == nsets_new[n].nodes
    @test nsets_names_old[n] == nsets_names_new[n]
  end
  Base.Filesystem.rm("./test_output_nodesets.e")
end

@exodus_unit_test_set "Write nodesets" begin
  exo_old = ExodusDatabase(abspath(mesh_file_name_2D), "r")
  init_old = Initialization(exo_old)
  coords_old = read_coordinates(exo_old)
  nsets_old = read_node_sets(exo_old, read_node_set_ids(exo_old))
  close(exo_old)

  exo_new = ExodusDatabase("./test_output_nodesets.e", init_old)
  write_coordinates(exo_new, coords_old)
  coords_new = read_coordinates(exo_new)
  write_node_sets(exo_new, nsets_old)
  nsets_names_old = read_node_set_names(exo_old)
  write_node_set_names(exo_new, nsets_names_old)
  nsets_new = read_node_sets(exo_new, read_node_set_ids(exo_new))
  nsets_names_new = read_node_set_names(exo_new)  
  close(exo_new)

  @test init_old == exo_new.init
  @test coords_old == coords_new
  for n in eachindex(nsets_old)
    @test nsets_old[n].node_set_id == nsets_new[n].node_set_id
    @test nsets_old[n].num_nodes == nsets_new[n].num_nodes
    @test nsets_old[n].nodes == nsets_new[n].nodes
    @test nsets_names_old[n] == nsets_names_new[n]
  end
  Base.Filesystem.rm("./test_output_nodesets.e")
end
