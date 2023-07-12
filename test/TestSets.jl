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
    @test nset.id == id
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
    @test nset_1.id    == nset_2.id
    @test nset_1.nodes == nset_2.nodes
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
    @test nsets_old[n].id == nsets_new[n].id
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
    @test nsets_old[n].id == nsets_new[n].id
    @test nsets_old[n].nodes == nsets_new[n].nodes
    @test nsets_names_old[n] == nsets_names_new[n]
  end
  Base.Filesystem.rm("./test_output_nodesets.e")
end

mesh_file_name = "./mesh/square_meshes/mesh_test.g"
number_of_nodes = 16641
number_of_elements = 128^2
number_of_side_set_elements = 128

function test_read_side_set_ids_on_square_meshes()
  exo = ExodusDatabase(abspath(mesh_file_name), "r")
  sset_ids = read_side_set_ids(exo)
  @test length(sset_ids) == 4
  @test sset_ids == [1, 2, 3, 4]
  close(exo)
end

function test_read_side_set_elements_and_sides_on_square_meshes()
  exo = ExodusDatabase(abspath(mesh_file_name), "r")
  sset_ids = read_side_set_ids(exo)
  for sset_id in sset_ids
    sset = SideSet(exo, sset_id)
    @test sset.id == sset_id
    @test length(sset.elements) == number_of_side_set_elements
  end
  ssets = read_side_sets(exo, sset_ids)
  for (n, sset_id) in enumerate(sset_ids)
    sset = ssets[n]
    @test sset.id == sset_id
    @test length(sset.elements) == number_of_side_set_elements
  end
  close(exo)
end

@exodus_unit_test_set "SideSets.jl - Read" begin
  test_read_side_set_ids_on_square_meshes()
  test_read_side_set_elements_and_sides_on_square_meshes()
end

@exodus_unit_test_set "Initialize side set from name" begin
  exo = ExodusDatabase(mesh_file_name, "r")
  for n in [1, 2, 3, 4]
    sset_1 = SideSet(exo, "sset_$n")
    sset_2 = SideSet(exo, n)
    @test sset_1.id  == sset_2.id
    @test sset_1.elements == sset_2.elements
    @test sset_1.sides    == sset_2.sides
  end
  close(exo)
end

@exodus_unit_test_set "Show sideset" begin
  exo = ExodusDatabase(mesh_file_name, "r")
  sset = SideSet(exo, 1)
  @show sset
  close(exo)
end

@exodus_unit_test_set "read sideset node list" begin
  exo = ExodusDatabase(mesh_file_name, "r")

  for id in [1, 2, 3, 4]
    nset = NodeSet(exo, id)
    sset = SideSet(exo, id)
    a, b = read_side_set_node_list(exo, id)
    @test length(a) == length(sset.elements)
    unique_ids = unique(b) |> sort
    @test sort(nset.nodes) == unique_ids
  end
  close(exo)
end

@exodus_unit_test_set "Write SideSet" begin
  exo_old = ExodusDatabase(abspath(mesh_file_name_2D), "r")
  init_old = Initialization(exo_old)
  coords_old = read_coordinates(exo_old)
  ssets_old = read_side_sets(exo_old, read_side_set_ids(exo_old))
  close(exo_old)

  exo_new = ExodusDatabase("./test_output_sidesets.e", init_old)
  write_coordinates(exo_new, coords_old)
  coords_new = read_coordinates(exo_new)
  for sset in ssets_old
    write_side_set(exo_new, sset)
  end
  ssets_names_old = read_side_set_names(exo_old)
  for (n, sset) in enumerate(ssets_old)
    write_side_set_name(exo_new, sset, ssets_names_old[n])
  end
  ssets_new = read_side_sets(exo_new, read_side_set_ids(exo_new))
  ssets_names_new = read_side_set_names(exo_new)
  close(exo_new)

  @test init_old == exo_new.init
  @test coords_old == coords_new
  for n in eachindex(ssets_old)
    @test ssets_old[n].id == ssets_new[n].id
    @test ssets_old[n].elements == ssets_new[n].elements
    @test ssets_old[n].sides == ssets_new[n].sides
    @test ssets_names_old[n] == ssets_names_new[n]
  end
  Base.Filesystem.rm("./test_output_sidesets.e")
end

@exodus_unit_test_set "Write SideSets" begin
  exo_old = ExodusDatabase(abspath(mesh_file_name_2D), "r")
  init_old = Initialization(exo_old)
  coords_old = read_coordinates(exo_old)
  ssets_old = read_side_sets(exo_old, read_side_set_ids(exo_old))
  close(exo_old)

  exo_new = ExodusDatabase("./test_output_sidesets.e", init_old)
  write_coordinates(exo_new, coords_old)
  coords_new = read_coordinates(exo_new)
  write_side_sets(exo_new, ssets_old)
  ssets_names_old = read_side_set_names(exo_old)
  write_side_set_names(exo_new, ssets_names_old)
  ssets_new = read_side_sets(exo_new, read_side_set_ids(exo_new))
  ssets_names_new = read_side_set_names(exo_new)
  ssets_new = read_side_sets(exo_new, read_side_set_ids(exo_new))
  close(exo_new)

  @test init_old == exo_new.init
  @test coords_old == coords_new
  for n in eachindex(ssets_old)
    @test ssets_old[n].id == ssets_new[n].id
    @test ssets_old[n].elements == ssets_new[n].elements
    @test ssets_old[n].sides == ssets_new[n].sides
    @test ssets_names_old[n] == ssets_names_new[n]
  end
  Base.Filesystem.rm("./test_output_sidesets.e")
end

@exodus_unit_test_set "Test nonsense nodeset and sideset names" begin
  exo = ExodusDatabase(mesh_file_name_2D, "r")
  @test_throws BoundsError NodeSet(exo, "nonsense_nset_name")
  @test_throws BoundsError SideSet(exo, "nonsense_sset_name")
  close(exo)
end

@exodus_unit_test_set "throw Incompatable type error" begin
  exo_old = ExodusDatabase(abspath(mesh_file_name_2D), "r")
  init_old = Initialization(exo_old)
  coords_old = read_coordinates(exo_old)
  close(exo_old)

  exo_new = ExodusDatabase("./test_output_sidesets.e", init_old)
  write_coordinates(exo_new, coords_old)
  dummy_nset = NodeSet{Float32, Float32}(1, [])
  dummy_sset = SideSet{Float32, Float32}(1, [], [])
  @test_throws ErrorException write_node_set(exo_new, dummy_nset)
  @test_throws ErrorException write_side_set(exo_new, dummy_sset)
  close(exo_new)
end
