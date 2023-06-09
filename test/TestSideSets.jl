mesh_file_name = "./mesh/square_meshes/mesh_test_0.0078125.g"
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
  for (id, sset_id) in enumerate(sset_ids)
    sset = SideSet(exo, sset_id)
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