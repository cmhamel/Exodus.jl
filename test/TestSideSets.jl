mesh_file_names = [
  "./mesh/square_meshes/mesh_test_1.g",
  "./mesh/square_meshes/mesh_test_0.5.g",
  "./mesh/square_meshes/mesh_test_0.25.g",
  "./mesh/square_meshes/mesh_test_0.125.g",
  "./mesh/square_meshes/mesh_test_0.0625.g",
  "./mesh/square_meshes/mesh_test_0.03125.g",
  "./mesh/square_meshes/mesh_test_0.015625.g",
  "./mesh/square_meshes/mesh_test_0.0078125.g"
]

number_of_nodes = [4, 9, 25, 81, 289, 1089, 4225, 16641]
number_of_elements = [1, 2^2, 4^2, 8^2, 16^2, 32^2, 64^2, 128^2]
number_of_side_set_elements = [1, 2, 4, 8, 16, 32, 64, 128]

function test_read_side_set_ids_on_square_meshes(n::Int64)
  exo = ExodusDatabase(abspath(mesh_file_names[n]), "r")
  sset_ids = read_side_set_ids(exo)
  @test length(sset_ids) == 4
  @test sset_ids == [1, 2, 3, 4]
  close(exo)
end

function test_read_side_set_elements_and_sides_on_square_meshes(n::Int64)
  exo = ExodusDatabase(abspath(mesh_file_names[n]), "r")
  sset_ids = read_side_set_ids(exo)
  for (id, sset_id) in enumerate(sset_ids)
    sset = SideSet(exo, sset_id)
    @test sset.side_set_id == sset_id
    @test sset.num_elements == number_of_side_set_elements[n]
  end
  close(exo)
end

@exodus_unit_test_set "Test Sidesets - Read Side Set IDs" begin
  for (n, mesh) in enumerate(mesh_file_names)
    test_read_side_set_ids_on_square_meshes(n)
  end
end

@exodus_unit_test_set "Test Sidesets - Read Side Set Elements and Sides" begin
  for (n, mesh) in enumerate(mesh_file_names)
    test_read_side_set_elements_and_sides_on_square_meshes(n)
  end
end
