@exodus_unit_test_set "Test Read/Write ExodusDatabase - 2D Mesh" begin
  exo_old = ExodusDatabase(abspath(mesh_file_name_2D), "r")
  
  M, I, B, F = Exodus.int_and_float_modes(exo_old.exo)

  init_old = Initialization(exo_old)
  block_old = Block(exo_old, 1)
  coords_old = read_coordinates(exo_old)
  coord_names_old = Exodus.read_coordinate_names(exo_old)
  nsets = read_sets(exo_old, NodeSet)
  nset_names = read_names(exo_old, NodeSet)
  ssets = read_sets(exo_old, SideSet)
  sset_names = read_names(exo_old, SideSet)
  qa_old = read_qa(exo_old)
  close(exo_old)

  exo_new = ExodusDatabase(
    "./test_output_2D_Mesh.e", "w", init_old,
    M, I, B, F
  )

  # info
  info = ["info entry 1", "info entry 2", "info entry 3"]
  write_info(exo_new, info)
  new_info = read_info(exo_new)
  for n in eachindex(info)
    @test info[n] == new_info[n]
  end

  @test Exodus.get_mode(exo_new) == "w"

  # init
  @test init_old == exo_new.init

  # time
  write_time(exo_new, 1, 0.0)

  # block
  write_block(exo_new, block_old)
  block_new = Block(exo_new, block_old.id)
  @show block_new
  @test block_old.id == block_new.id
  @test block_old.num_elem == block_new.num_elem
  @test block_old.num_nodes_per_elem == block_new.num_nodes_per_elem
  @test block_old.elem_type == block_new.elem_type
  @test block_old.conn == block_new.conn

  write_blocks(exo_new, [block_old])
  block_new = Block(exo_new, block_old.id)
  @show block_new
  @test block_old.id == block_new.id
  @test block_old.num_elem == block_new.num_elem
  @test block_old.num_nodes_per_elem == block_new.num_nodes_per_elem
  @test block_old.elem_type == block_new.elem_type
  @test block_old.conn == block_new.conn

  conn = Exodus.read_block_connectivity(exo_new, 1, block_new.num_nodes_per_elem * block_new.num_elem)
  conn = copy(conn)
  conn = reshape(conn, block_new.num_nodes_per_elem, block_new.num_elem)
  partial_conn = Exodus.read_partial_block_connectivity(exo_new, 1, 10, 100)
  partial_conn = reshape(partial_conn, block_new.num_nodes_per_elem, 100)
  @test conn[:, 10:110 - 1] ≈ partial_conn

  write_name(exo_new, Block, 1, "block_1")
  @test read_name(exo_new, Block, 1) == "block_1"

  # coordinate values
  write_coordinates(exo_new, coords_old)
  coords_new = read_coordinates(exo_new)
  @test coords_old == coords_new

  # coordinate names
  Exodus.write_coordinate_names(exo_new, coord_names_old)
  coord_names_new = Exodus.read_coordinate_names(exo_new)
  @test coord_names_new == coord_names_old
  @test coord_names_new[1] == "x"
  @test coord_names_new[2] == "y"

  # element variables
  write_number_of_variables(exo_new, Element, 3)
  n_vars = read_number_of_variables(exo_new, Element)
  @test n_vars == 3

  write_names(exo_new, Element, ["stress_xx", "stress_yy", "stress_xy"])
  var_names = read_names(exo_new, Element)
  @test var_names == ["stress_xx", "stress_yy", "stress_xy"] 
  @test read_name(exo_new, Element, 1) == "stress_xx"
  @test read_name(exo_new, Element, 2) == "stress_yy"
  @test read_name(exo_new, Element, 3) == "stress_xy"

  # block = Block(exo_new, 1)
  block = Block(exo_new, "block_1")

  stress_xx = randn(block.num_elem)
  stress_yy = randn(block.num_elem)
  stress_xy = randn(block.num_elem)

  write_values(exo_new, Element, 1, 1, 1, stress_xx)
  write_values(exo_new, Element, 1, 1, 2, stress_yy)
  write_values(exo_new, Element, 1, 1, 3, stress_xy)

  stress_xx_read = read_values(exo_new, Element, 1, 1, 1)
  stress_yy_read = read_values(exo_new, Element, 1, 1, 2)
  stress_xy_read = read_values(exo_new, Element, 1, 1, 3)

  @test stress_xx ≈ stress_xx_read
  @test stress_yy ≈ stress_yy_read
  @test stress_xy ≈ stress_xy_read

  stress_xx = randn(block.num_elem)
  stress_yy = randn(block.num_elem)
  stress_xy = randn(block.num_elem)

  write_values(exo_new, Element, 1, 1, "stress_xx", stress_xx)
  write_values(exo_new, Element, 1, 1, "stress_yy", stress_yy)
  write_values(exo_new, Element, 1, 1, "stress_xy", stress_xy)

  
  stress_xx_read = read_values(exo_new, Element, 1, 1, "stress_xx")
  stress_yy_read = read_values(exo_new, Element, 1, 1, "stress_yy")
  stress_xy_read = read_values(exo_new, Element, 1, 1, "stress_xy")

  @test stress_xx ≈ stress_xx_read
  @test stress_yy ≈ stress_yy_read
  @test stress_xy ≈ stress_xy_read

  @test_throws Exodus.SetIDException read_values(exo_new, Element, 1, 2, 1)
  @test_throws Exodus.SetNameException read_values(exo_new, Element, 1, "fake", "stress_xx")
  @test_throws Exodus.VariableIDException read_values(exo_new, Element, 1, 1, 6)
  @test_throws Exodus.VariableNameException read_values(exo_new, Element, 1, 1, "fake_variable")

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

  write_values(exo_new, Global, 1, 1, 1, [100.0, 200.0, 300.0, 400.0, 500.0])
  global_vars = read_values(exo_new, Global, 1, 1, 1)
  @test global_vars[1] ≈ 100.0
  @test global_vars[2] ≈ 200.0
  @test global_vars[3] ≈ 300.0
  @test global_vars[4] ≈ 400.0
  @test global_vars[5] ≈ 500.0

  write_values(exo_new, Global, 1, [10.0, 20.0, 30.0, 40.0, 50.0])
  global_vars = read_values(exo_new, Global, 1)
  @test global_vars[1] ≈ 10.0
  @test global_vars[2] ≈ 20.0
  @test global_vars[3] ≈ 30.0
  @test global_vars[4] ≈ 40.0
  @test global_vars[5] ≈ 50.0

  # nodal variables
  write_number_of_variables(exo_new, Nodal, 2)
  @test read_number_of_variables(exo_new, Nodal) == 2

  write_names(exo_new, Nodal, ["displ_x_temp", "displ_y_temp"])
  @test read_names(exo_new, Nodal) == ["displ_x_temp", "displ_y_temp"]

  write_name(exo_new, Nodal, 1, "displ_x")
  write_name(exo_new, Nodal, 2, "displ_y")
  @test read_name(exo_new, Nodal, 1) == "displ_x"
  @test read_name(exo_new, Nodal, 2) == "displ_y"

  u_x = randn(exo_new.init.num_nodes)
  u_y = randn(exo_new.init.num_nodes)

  write_values(exo_new, Nodal, 1, 1, 1, u_x)
  write_values(exo_new, Nodal, 1, 1, 2, u_y)
  @test read_values(exo_new, Nodal, 1, 1, 1) == u_x
  @test read_values(exo_new, Nodal, 1, 1, 2) == u_y

  u_x = randn(exo_new.init.num_nodes)
  u_y = randn(exo_new.init.num_nodes)

  write_values(exo_new, Nodal, 1, 1, "displ_x", u_x)
  write_values(exo_new, Nodal, 1, 1, "displ_y", u_y)
  @test read_values(exo_new, Nodal, 1, 1, "displ_x") == u_x
  @test read_values(exo_new, Nodal, 1, 1, "displ_y") == u_y

  @test_throws Exodus.VariableIDException read_values(exo_new, Nodal, 1, 1, 4)
  @test_throws Exodus.VariableNameException read_values(exo_new, Nodal, 1, 1, "fake_variable")

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

  nset_names = read_names(exo_new, NodeSet)
  for nset_name in nset_names
    nset = NodeSet(exo_new, nset_name)
    @show nset
  end

  # nodeset variables
  write_number_of_variables(exo_new, NodeSetVariable, 2)
  @test read_number_of_variables(exo_new, NodeSetVariable) == 2

  write_names(exo_new, NodeSetVariable, ["nset_displ_x_temp", "nset_displ_y_temp"])
  @test read_names(exo_new, NodeSetVariable) == ["nset_displ_x_temp", "nset_displ_y_temp"]

  write_name(exo_new, NodeSetVariable, 1, "nset_displ_x")
  write_name(exo_new, NodeSetVariable, 2, "nset_displ_y")
  @test read_name(exo_new, NodeSetVariable, 1) == "nset_displ_x"
  @test read_name(exo_new, NodeSetVariable, 2) == "nset_displ_y"

  nsets = read_sets(exo_new, NodeSet)
  for nset in nsets
    u_x = randn(length(nset.nodes))
    u_y = randn(length(nset.nodes))
    write_values(exo_new, NodeSetVariable, 1, nset.id, 1, u_x)
    write_values(exo_new, NodeSetVariable, 1, nset.id, 2, u_y)
    @test read_values(exo_new, NodeSetVariable, 1, nset.id, 1) == u_x
    @test read_values(exo_new, NodeSetVariable, 1, nset.id, 2) == u_y
  end

  nset_names = read_names(exo_new, NodeSet)
  for nset_name in nset_names
    nset = NodeSet(exo_new, nset_name)
    u_x = randn(length(nset.nodes))
    u_y = randn(length(nset.nodes))
    write_values(exo_new, NodeSetVariable, 1, nset.id, 1, u_x)
    write_values(exo_new, NodeSetVariable, 1, nset.id, 2, u_y)
    @test read_values(exo_new, NodeSetVariable, 1, nset_name, "nset_displ_x") == u_x
    @test read_values(exo_new, NodeSetVariable, 1, nset_name, "nset_displ_y") == u_y
  end

  nset_names = read_names(exo_new, NodeSet)
  for nset_name in nset_names
    nset = NodeSet(exo_new, nset_name)
    u_x = randn(length(nset.nodes))
    u_y = randn(length(nset.nodes))
    write_values(exo_new, NodeSetVariable, 1, nset_name, "nset_displ_x", u_x)
    write_values(exo_new, NodeSetVariable, 1, nset_name, "nset_displ_y", u_y)
    @test read_values(exo_new, NodeSetVariable, 1, nset_name, "nset_displ_x") == u_x
    @test read_values(exo_new, NodeSetVariable, 1, nset_name, "nset_displ_y") == u_y
  end

  @test_throws Exodus.SetIDException read_values(exo_new, NodeSetVariable, 1, 6, 1)
  @test_throws Exodus.SetNameException read_values(exo_new, NodeSetVariable, 1, "fake", "nset_displ_x")
  @test_throws Exodus.VariableIDException read_values(exo_new, NodeSetVariable, 1, 1, 6)
  @test_throws Exodus.VariableNameException read_values(exo_new, NodeSetVariable, 1, 1, "fake_variable")

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

  sset_names = read_names(exo_new, SideSet)
  for sset_name in sset_names
    sset = SideSet(exo_new, sset_name)
    @show sset
  end

  # sideset variables
  write_number_of_variables(exo_new, SideSetVariable, 3)
  @test read_number_of_variables(exo_new, SideSetVariable) == 3

  write_names(exo_new, SideSetVariable, ["stress_xx_temp", "stress_yy_temp", "stress_xy_temp"])
  @test read_names(exo_new, SideSetVariable) == ["stress_xx_temp", "stress_yy_temp", "stress_xy_temp"]

  write_name(exo_new, SideSetVariable, 1, "stress_xx")
  write_name(exo_new, SideSetVariable, 2, "stress_yy")
  write_name(exo_new, SideSetVariable, 3, "stress_xy")

  @test read_name(exo_new, SideSetVariable, 1) == "stress_xx"
  @test read_name(exo_new, SideSetVariable, 2) == "stress_yy"
  @test read_name(exo_new, SideSetVariable, 3) == "stress_xy"

  ssets = read_sets(exo_new, SideSet)

  for sset in ssets
    stress_xx = randn(length(sset.elements))
    stress_yy = randn(length(sset.elements))
    stress_xy = randn(length(sset.elements))

    write_values(exo_new, SideSetVariable, 1, sset.id, 1, stress_xx)
    write_values(exo_new, SideSetVariable, 1, sset.id, 2, stress_yy)
    write_values(exo_new, SideSetVariable, 1, sset.id, 3, stress_xy)

    @test read_values(exo_new, SideSetVariable, 1, sset.id, 1) == stress_xx
    @test read_values(exo_new, SideSetVariable, 1, sset.id, 2) == stress_yy
    @test read_values(exo_new, SideSetVariable, 1, sset.id, 3) == stress_xy
  end

  for sset in ssets
    stress_xx = randn(length(sset.elements))
    stress_yy = randn(length(sset.elements))
    stress_xy = randn(length(sset.elements))

    write_values(exo_new, SideSetVariable, 1, sset.id, "stress_xx", stress_xx)
    write_values(exo_new, SideSetVariable, 1, sset.id, "stress_yy", stress_yy)
    write_values(exo_new, SideSetVariable, 1, sset.id, "stress_xy", stress_xy)

    @test read_values(exo_new, SideSetVariable, 1, sset.id, "stress_xx") == stress_xx
    @test read_values(exo_new, SideSetVariable, 1, sset.id, "stress_yy") == stress_yy
    @test read_values(exo_new, SideSetVariable, 1, sset.id, "stress_xy") == stress_xy
  end

  for sset in ssets
    stress_xx = randn(length(sset.elements))
    stress_yy = randn(length(sset.elements))
    stress_xy = randn(length(sset.elements))

    name = read_name(exo_new, SideSet, sset.id)

    write_values(exo_new, SideSetVariable, 1, name, "stress_xx", stress_xx)
    write_values(exo_new, SideSetVariable, 1, name, "stress_yy", stress_yy)
    write_values(exo_new, SideSetVariable, 1, name, "stress_xy", stress_xy)

    @test read_values(exo_new, SideSetVariable, 1, name, "stress_xx") == stress_xx
    @test read_values(exo_new, SideSetVariable, 1, name, "stress_yy") == stress_yy
    @test read_values(exo_new, SideSetVariable, 1, name, "stress_xy") == stress_xy
  end

  @test_throws Exodus.SetIDException read_values(exo_new, SideSetVariable, 1, 6, 1)
  @test_throws Exodus.SetNameException read_values(exo_new, SideSetVariable, 1, "fake", "stress_xx")
  @test_throws Exodus.VariableIDException read_values(exo_new, SideSetVariable, 1, 1, 6)
  @test_throws Exodus.VariableNameException read_values(exo_new, SideSetVariable, 1, 1, "fake_variable")

  # times
  write_time(exo_new, 1, 0.)
  write_time(exo_new, 2, 1.)
  n_steps = read_number_of_time_steps(exo_new)
  times = read_times(exo_new)
  @test n_steps == 2
  @test times == [0., 1.]
  @test read_time(exo_new, 1) == 0.
  @test read_time(exo_new, 2) == 1.

  # variable throw error
  @test_throws Exodus.VariableNameException read_values(exo_new, Nodal, 1, 1, "fake_variable")

  close(exo_new)

  Base.Filesystem.rm("./test_output_2D_Mesh.e")
end

@exodus_unit_test_set "Test Read/Write ExodusDatabase - 3D Mesh" begin
  exo_old = ExodusDatabase(abspath(mesh_file_name_3D), "r")
  M, I, B, F = Exodus.int_and_float_modes(exo_old.exo)
  init_old = Initialization(exo_old)
  coords_old = read_coordinates(exo_old)
  coord_names_old = Exodus.read_coordinate_names(exo_old)
  close(exo_old)

  # init
  exo_new = ExodusDatabase(
    "./test_output_3D_Mesh.e", "w", init_old,
    M, I, B, F
  )
  @test init_old == exo_new.init

  # coordinate values
  write_coordinates(exo_new, coords_old)
  coords_new = read_coordinates(exo_new)
  @test coords_old == coords_new

  # coordinate names
  Exodus.write_coordinate_names(exo_new, coord_names_old)
  coord_names_new = Exodus.read_coordinate_names(exo_new)
  @test coord_names_new == coord_names_old
  @test coord_names_new[1] == "x"
  @test coord_names_new[2] == "y"
  @test coord_names_new[3] == "z"

  close(exo_new)

  Base.Filesystem.rm("./test_output_3D_Mesh.e")
end