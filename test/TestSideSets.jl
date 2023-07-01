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
    @test sset.side_set_id == sset_id
    @test sset.num_elements == number_of_side_set_elements
  end
  ssets = read_side_sets(exo, sset_ids)
  for (n, sset_id) in enumerate(sset_ids)
    sset = ssets[n]
    @test sset.side_set_id == sset_id
    @test sset.num_elements == number_of_side_set_elements
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
    @test sset_1.side_set_id  == sset_2.side_set_id
    @test sset_1.num_elements == sset_2.num_elements
    @test sset_1.elements     == sset_2.elements
    @test sset_1.sides        == sset_2.sides
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
    @test length(a) == sset.num_elements
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
  ssets_new = read_side_sets(exo_new, read_side_set_ids(exo_new))
  close(exo_new)

  @test init_old == exo_new.init
  @test coords_old == coords_new
  for n in eachindex(ssets_old)
    @test ssets_old[n].side_set_id == ssets_new[n].side_set_id
    @test ssets_old[n].num_elements == ssets_new[n].num_elements
    @test ssets_old[n].elements == ssets_new[n].elements
    @test ssets_old[n].sides == ssets_new[n].sides
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
  ssets_new = read_side_sets(exo_new, read_side_set_ids(exo_new))
  close(exo_new)

  @test init_old == exo_new.init
  @test coords_old == coords_new
  for n in eachindex(ssets_old)
    @test ssets_old[n].side_set_id == ssets_new[n].side_set_id
    @test ssets_old[n].num_elements == ssets_new[n].num_elements
    @test ssets_old[n].elements == ssets_new[n].elements
    @test ssets_old[n].sides == ssets_new[n].sides
  end
  Base.Filesystem.rm("./test_output_sidesets.e")
end
