mesh_file_name_2D = "./mesh/square_meshes/mesh_test.g"
number_of_nodes_2D = 16641
number_of_elements_2D = 128^2

mesh_file_name_3D = "./mesh/cube_meshes/mesh_test.g"
number_of_nodes_3D = 729
number_of_elements_3D = 512

function test_read_coordinates_on_square_mesh()
  exo = ExodusDatabase(abspath(mesh_file_name_2D), "r")
  coords = read_coordinates(exo)
  @test size(coords) == (2, number_of_nodes_2D)
  close(exo)
end

function test_read_partial_coordinates_on_square_mesh()
  exo = ExodusDatabase(abspath(mesh_file_name_2D), "r")
  coords = read_coordinates(exo)
  partial_coords = read_partial_coordinates(exo, 10, 100)
  @test coords[:, 10:110 - 1] ≈ partial_coords
  close(exo)
end

function test_read_partial_coordinates_component_on_square_mesh()
  exo = ExodusDatabase(abspath(mesh_file_name_2D), "r")
  coords = read_coordinates(exo)
  partial_coords_x = read_partial_coordinates_component(exo, 10, 100, 1)
  partial_coords_y = read_partial_coordinates_component(exo, 10, 100, 2)
  @test coords[1, 10:110 - 1] ≈ partial_coords_x
  @test coords[2, 10:110 - 1] ≈ partial_coords_y

  partial_coords_x = read_partial_coordinates_component(exo, 10, 100, "x")
  partial_coords_y = read_partial_coordinates_component(exo, 10, 100, "y")
  @test coords[1, 10:110 - 1] ≈ partial_coords_x
  @test coords[2, 10:110 - 1] ≈ partial_coords_y
  close(exo)
end

function test_read_coordinate_names_on_square_mesh()
  exo = ExodusDatabase(abspath(mesh_file_name_2D), "r")
  coord_names = read_coordinate_names(exo)
  @test coord_names == ["x", "y"]
  close(exo)
end

function test_read_coordinates_on_cube_mesh()
  exo = ExodusDatabase(abspath(mesh_file_name_3D), "r")
  coords = read_coordinates(exo)
  @test size(coords) == (3, number_of_nodes_3D)
  close(exo)
end

function test_read_partial_coordinates_on_cube_mesh()
  exo = ExodusDatabase(abspath(mesh_file_name_3D), "r")
  coords = read_coordinates(exo)
  partial_coords = read_partial_coordinates(exo, 10, 100)
  @test coords[:, 10:110 - 1] ≈ partial_coords
  close(exo)
end

function test_read_partial_coordinates_component_on_cube_mesh()
  exo = ExodusDatabase(abspath(mesh_file_name_3D), "r")
  coords = read_coordinates(exo)
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
  close(exo)
end

function test_read_coordinate_names_on_cube_mesh()
  exo = ExodusDatabase(abspath(mesh_file_name_3D), "r")
  coord_names = read_coordinate_names(exo)
  @test coord_names == ["x", "y", "z"]
  close(exo)
end

@exodus_unit_test_set "Coorinates.jl - Read" begin
  test_read_coordinates_on_square_mesh()
  test_read_partial_coordinates_on_square_mesh()
  test_read_partial_coordinates_component_on_square_mesh()
  test_read_coordinate_names_on_square_mesh()
  test_read_coordinates_on_cube_mesh()
  test_read_partial_coordinates_on_cube_mesh()
  test_read_partial_coordinates_component_on_cube_mesh()
  test_read_coordinate_names_on_cube_mesh()
end

function test_write_coordinates_on_square_mesh()
  exo_old = ExodusDatabase(abspath(mesh_file_name_2D), "r")
  init_old = Initialization(exo_old)
  coords_old = read_coordinates(exo_old)
  close(exo_old)

  exo_new = ExodusDatabase("./test_output_coords.e", init_old)
  write_coordinates(exo_new, coords_old)
  coords_new = read_coordinates(exo_new)
  close(exo_new)

  @test init_old == exo_new.init
  @test coords_old == coords_new

  Base.Filesystem.rm("./test_output_coords.e")
end

function test_write_coordinate_names_on_square_mesh()
  exo_old = ExodusDatabase(abspath(mesh_file_name_2D), "r")
  init_old = exo_old.init
  coord_names_old = read_coordinate_names(exo_old)
  close(exo_old)

  exo_new = ExodusDatabase("./test_output_coordinate_names.e", init_old)
  write_coordinate_names(exo_new, coord_names_old)
  coord_names_new = read_coordinate_names(exo_new)
  close(exo_new)

  @test coord_names_new == coord_names_old
  @test coord_names_new[1] == "x"
  @test coord_names_new[2] == "y"

  Base.Filesystem.rm("./test_output_coordinate_names.e")
end

function test_write_coordinates_on_cube_mesh()
  exo_old = ExodusDatabase(abspath(mesh_file_name_3D), "r")
  init_old = Initialization(exo_old)
  coords_old = read_coordinates(exo_old)
  close(exo_old)

  exo_new = ExodusDatabase("./test_output_coords.e", init_old)
  write_coordinates(exo_new, coords_old)
  coords_new = read_coordinates(exo_new)
  close(exo_new)

  @test init_old == exo_new.init
  @test coords_old == coords_new

  Base.Filesystem.rm("./test_output_coords.e")
end

function test_write_coordinate_names_on_cube_mesh()
  exo_old = ExodusDatabase(abspath(mesh_file_name_3D), "r")
  init_old = exo_old.init
  coord_names_old = read_coordinate_names(exo_old)
  close(exo_old)

  exo_new = ExodusDatabase("./test_output_coordinate_names.e", init_old)
  write_coordinate_names(exo_new, coord_names_old)
  coord_names_new = read_coordinate_names(exo_new)
  close(exo_new)

  @test coord_names_new == coord_names_old
  @test coord_names_new[1] == "x"
  @test coord_names_new[2] == "y"
  @test coord_names_new[3] == "z"

  Base.Filesystem.rm("./test_output_coordinate_names.e")
end

@exodus_unit_test_set "Coordinates.jl - Write" begin
  test_write_coordinates_on_square_mesh()
  test_write_coordinate_names_on_square_mesh()
  test_write_coordinates_on_cube_mesh()
  test_write_coordinate_names_on_cube_mesh()
end