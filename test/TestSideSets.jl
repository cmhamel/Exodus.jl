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
