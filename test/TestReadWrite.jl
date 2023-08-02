@exodus_unit_test_set "Test Read/Write ExodusDatabase - 2D Mesh" begin
  exo_old = ExodusDatabase(abspath(mesh_file_name_2D), "r")
  
  init_old = Initialization(exo_old)
  coords_old = read_coordinates(exo_old)
  coord_names_old = read_coordinate_names(exo_old)
  qa_old = read_qa(exo_old)
  close(exo_old)

  exo_new = ExodusDatabase("./test_output_2D_Mesh.e", init_old)

  # info
  info = ["info entry 1", "info entry 2", "info entry 3"]
  write_info(exo_new, info)
  new_info = read_info(exo_new)
  for n in eachindex(info)
    @test info[n] == new_info[n]
  end

  # init
  @test init_old == exo_new.init

  # coordinate values
  write_coordinates(exo_new, coords_old)
  coords_new = read_coordinates(exo_new)
  @test coords_old == coords_new

  # coordinate names
  write_coordinate_names(exo_new, coord_names_old)
  coord_names_new = read_coordinate_names(exo_new)
  @test coord_names_new == coord_names_old
  @test coord_names_new[1] == "x"
  @test coord_names_new[2] == "y"

  # qa
  write_qa(exo_new, qa_old)
  qa_new = read_qa(exo_new)
  for n in eachindex(qa_old)
    @test qa_old[n] == qa_new[n]
  end

  close(exo_new)

  Base.Filesystem.rm("./test_output_2D_Mesh.e")
end

@exodus_unit_test_set "Test Read/Write ExodusDatabase - 3D Mesh" begin
  exo_old = ExodusDatabase(abspath(mesh_file_name_3D), "r")

  init_old = Initialization(exo_old)
  coords_old = read_coordinates(exo_old)
  coord_names_old = read_coordinate_names(exo_old)
  
  close(exo_old)

  # init
  exo_new = ExodusDatabase("./test_output_3D_Mesh.e", init_old)
  @test init_old == exo_new.init

  # coordinate values
  write_coordinates(exo_new, coords_old)
  coords_new = read_coordinates(exo_new)
  @test coords_old == coords_new

  # coordinate names
  write_coordinate_names(exo_new, coord_names_old)
  coord_names_new = read_coordinate_names(exo_new)
  @test coord_names_new == coord_names_old
  @test coord_names_new[1] == "x"
  @test coord_names_new[2] == "y"
  @test coord_names_new[3] == "z"

  close(exo_new)

  Base.Filesystem.rm("./test_output_3D_Mesh.e")
end