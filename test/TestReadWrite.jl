@exodus_unit_test_set "Test Read/Write ExodusDatabase - 2D Mesh" begin
  exo_old = ExodusDatabase(abspath(mesh_file_name_2D), "r")
  
  init_old = Initialization(exo_old)
  coords_old = read_coordinates(exo_old)
  coord_names_old = read_coordinate_names(exo_old)
  nsets = read_sets(exo_old, NodeSet)
  nset_names = read_names(exo_old, NodeSet)
  ssets = read_sets(exo_old, SideSet)
  sset_names = read_names(exo_old, SideSet)
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

  # time
  write_time(exo_new, 1, 0.0)

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

  # global variables
  write_number_of_variables(exo_new, Global, 5)
  @test read_number_of_variables(exo_new, Global) == 5

  write_name(exo_new, Global, 1, "global_var_1")
  write_name(exo_new, Global, 2, "global_var_2")
  write_name(exo_new, Global, 3, "global_var_3")
  write_name(exo_new, Global, 4, "global_var_4")
  write_name(exo_new, Global, 5, "global_var_5")

  @test read_name(exo_new, Global, 1) == "global_var_1"
  @test read_name(exo_new, Global, 2) == "global_var_2"
  @test read_name(exo_new, Global, 3) == "global_var_3"
  @test read_name(exo_new, Global, 4) == "global_var_4"
  @test read_name(exo_new, Global, 5) == "global_var_5"

  write_names(
    exo_new, Global,
    ["global_var_1", "global_var_2", "global_var_3", "global_var_4", "global_var_5"]
  )
  global_vars = read_names(exo_new, Global)

  @test global_vars[1] == "global_var_1"
  @test global_vars[2] == "global_var_2"
  @test global_vars[3] == "global_var_3"
  @test global_vars[4] == "global_var_4"
  @test global_vars[5] == "global_var_5"

  write_values(exo_new, Global, 1, 1, 1, [10.0, 20.0, 30.0, 40.0, 50.0])
  global_vars = read_values(exo_new, Global, 1, 1, 1)
  @test global_vars[1] ≈ 10.0
  @test global_vars[2] ≈ 20.0
  @test global_vars[3] ≈ 30.0
  @test global_vars[4] ≈ 40.0
  @test global_vars[5] ≈ 50.0

  # nodesets
  for nset in nsets
    write_set(exo_new, nset)
    temp_nset = read_set(exo_new, NodeSet, nset.id)
    @test temp_nset.id == nset.id
    @test temp_nset.nodes == nset.nodes
  end

  write_sets(exo_new, nsets)
  for nset in nsets
    temp_nset = read_set(exo_new, NodeSet, nset.id)
    @test temp_nset.id == nset.id
    @test temp_nset.nodes == nset.nodes
  end

  nset_names_gold = ["nset_1", "nset_2", "nset_3", "nset_4"]
  write_names(exo_new, NodeSet, nset_names_gold)
  nset_names = read_names(exo_new, NodeSet)
  @test nset_names == nset_names_gold

  for (n, nset_name) in enumerate(nset_names_gold)
    write_name(exo_new, nsets[n], nset_name)
    temp_nset = read_set(exo_new, NodeSet, nsets[n].id)
    @test temp_nset.id == nsets[n].id
    @test temp_nset.nodes == nsets[n].nodes
  end

  # qa
  write_qa(exo_new, qa_old)
  qa_new = read_qa(exo_new)
  for n in eachindex(qa_old)
    @test qa_old[n] == qa_new[n]
  end

  # sideset
  for sset in ssets
    write_set(exo_new, sset)
    temp_sset = read_set(exo_new, SideSet, sset.id)
    @test temp_sset.id == sset.id
    @test temp_sset.elements == sset.elements
    @test temp_sset.sides == sset.sides
  end

  write_sets(exo_new, ssets)
  for sset in ssets
    temp_sset = read_set(exo_new, SideSet, sset.id)
    @test temp_sset.id == sset.id
    @test temp_sset.elements == sset.elements
    @test temp_sset.sides == sset.sides
  end

  sset_names_gold = ["sset_1", "sset_2", "sset_3", "sset_4"]
  write_names(exo_new, SideSet, sset_names_gold)
  sset_names = read_names(exo_new, SideSet)
  @test sset_names == sset_names_gold

  for (n, sset_name) in enumerate(sset_names_gold)
    write_name(exo_new, ssets[n], sset_name)
    temp_sset = read_set(exo_new, SideSet, ssets[n].id)
    @test temp_sset.id == ssets[n].id
    @test temp_sset.elements == ssets[n].elements
    @test temp_sset.sides == ssets[n].sides
  end

  # times
  write_time(exo_new, 1, 0.)
  write_time(exo_new, 2, 1.)
  n_steps = read_number_of_time_steps(exo_new)
  times = read_times(exo_new)
  @test n_steps == 2
  @test times == [0., 1.]
  @test read_time(exo_new, 1) == 0.
  @test read_time(exo_new, 2) == 1.

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