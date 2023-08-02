mesh_file_name_2D = "./mesh/square_meshes/mesh_test.g"
number_of_nodes_2D = 16641
number_of_elements_2D = 128^2

mesh_file_name_3D = "./mesh/cube_meshes/mesh_test.g"
number_of_nodes_3D = 729
number_of_elements_3D = 512

@exodus_unit_test_set "Test Read ExodusDatabase - 2D Mesh" begin
  exo = ExodusDatabase(mesh_file_name_2D, "r")

  # coordinate values
  coords = read_coordinates(exo)
  @test size(coords) == (2, number_of_nodes_2D)

  # parital coordiantes values
  partial_coords = read_partial_coordinates(exo, 10, 100)
  @test coords[:, 10:110 - 1] ≈ partial_coords

  partial_coords_x = read_partial_coordinates_component(exo, 10, 100, 1)
  partial_coords_y = read_partial_coordinates_component(exo, 10, 100, 2)
  @test coords[1, 10:110 - 1] ≈ partial_coords_x
  @test coords[2, 10:110 - 1] ≈ partial_coords_y

  partial_coords_x = read_partial_coordinates_component(exo, 10, 100, "x")
  partial_coords_y = read_partial_coordinates_component(exo, 10, 100, "y")
  @test coords[1, 10:110 - 1] ≈ partial_coords_x
  @test coords[2, 10:110 - 1] ≈ partial_coords_y

  # coordinate names
  coord_names = read_coordinate_names(exo)
  @test coord_names == ["x", "y"]

  # init
  @test exo.init.num_dim       == 2
  @test exo.init.num_nodes     == number_of_nodes_2D
  @test exo.init.num_elems     == number_of_elements_2D
  @test exo.init.num_elem_blks == 1
  @test exo.init.num_node_sets == 4
  @test exo.init.num_side_sets == 4

  # qa
  qa = read_qa(exo)
  @test qa[1, 1] == "CUBIT"
  @test qa[1, 2] == "2021.5"     # may change
  @test qa[1, 3] == "06/29/2023" # may change
  @test qa[1, 4] == "19:34:08"   # may change

  close(exo)
end

@exodus_unit_test_set "Test Read ExodusDatabase - 3D Mesh" begin
  exo = ExodusDatabase(mesh_file_name_3D, "r")

  # coordinate values
  coords = read_coordinates(exo)
  @test size(coords) == (3, number_of_nodes_3D)

  # partial coordinate values
  partial_coords = read_partial_coordinates(exo, 10, 100)
  @test coords[:, 10:110 - 1] ≈ partial_coords

  partial_coords_x = read_partial_coordinates_component(exo, 10, 100, 1)
  partial_coords_y = read_partial_coordinates_component(exo, 10, 100, 2)
  partial_coords_z = read_partial_coordinates_component(exo, 10, 100, 3)
  @test coords[1, 10:110 - 1] ≈ partial_coords_x
  @test coords[2, 10:110 - 1] ≈ partial_coords_y
  @test coords[3, 10:110 - 1] ≈ partial_coords_z

  partial_coords_x = read_partial_coordinates_component(exo, 10, 100, "x")
  partial_coords_y = read_partial_coordinates_component(exo, 10, 100, "y")
  partial_coords_z = read_partial_coordinates_component(exo, 10, 100, "z")
  @test coords[1, 10:110 - 1] ≈ partial_coords_x
  @test coords[2, 10:110 - 1] ≈ partial_coords_y
  @test coords[3, 10:110 - 1] ≈ partial_coords_z

  # coordinate names
  coord_names = read_coordinate_names(exo)
  @test coord_names == ["x", "y", "z"]

  # init
  @test exo.init.num_dim       == 3
  @test exo.init.num_nodes     == number_of_nodes_3D
  @test exo.init.num_elems     == number_of_elements_3D
  @test exo.init.num_elem_blks == 1
  @test exo.init.num_node_sets == 6
  @test exo.init.num_side_sets == 6

  close(exo)
end
