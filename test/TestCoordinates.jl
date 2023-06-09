mesh_file_name = "./mesh/square_meshes/mesh_test_0.0078125.g"
number_of_nodes = 16641
number_of_elements = 128^2

function test_read_coordinates_on_square_mesh()
  exo = ExodusDatabase(abspath(mesh_file_name), "r")
  coords = read_coordinates(exo)
  @test size(coords) == (2, number_of_nodes)
  # @test size(coords) == (number_of_nodes, 2)
  close(exo)
end

function test_read_coordinate_names_on_square_mesh()
  exo = ExodusDatabase(abspath(mesh_file_name), "r")
  coord_names = read_coordinate_names(exo)
  @test coord_names == ["x", "y"]
  close(exo)
end

@exodus_unit_test_set "Coorinates.jl - Read" begin
  test_read_coordinates_on_square_mesh()
  test_read_coordinate_names_on_square_mesh()
end

function test_write_coordinates_on_square_mesh()
  exo_old = ExodusDatabase(abspath(mesh_file_name), "r")
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
  exo_old = ExodusDatabase(abspath(mesh_file_name), "r")
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

@exodus_unit_test_set "Coordinates.jl - Write" begin
  test_write_coordinates_on_square_mesh()
  test_write_coordinate_names_on_square_mesh()
end