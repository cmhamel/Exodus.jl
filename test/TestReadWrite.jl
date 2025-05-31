@exodus_unit_test_set "Test Read/Write ExodusDatabase - 2D Mesh" begin
  exo_old = ExodusDatabase(abspath(mesh_file_name_2D), "r")
  
  M = Exodus.map_int_mode(exo_old.exo)
  I = Exodus.id_int_mode(exo_old.exo)
  B = Exodus.bulk_int_mode(exo_old.exo)
  F = Exodus.float_mode(exo_old.exo)

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

  exo_new = ExodusDatabase{M, I, B, F}(
    "./test_output_2D_Mesh.e", "w", init_old
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
  write_number_of_variables(exo_new, ElementVariable, 3)
  n_vars = read_number_of_variables(exo_new, ElementVariable)
  @test n_vars == 3

  write_names(exo_new, ElementVariable, ["stress_xx", "stress_yy", "stress_xy"])
  var_names = read_names(exo_new, ElementVariable)
  @test var_names == ["stress_xx", "stress_yy", "stress_xy"] 
  @test read_name(exo_new, ElementVariable, 1) == "stress_xx"
  @test read_name(exo_new, ElementVariable, 2) == "stress_yy"
  @test read_name(exo_new, ElementVariable, 3) == "stress_xy"

  # block = Block(exo_new, 1)
  block = Block(exo_new, "block_1")

  stress_xx = randn(block.num_elem)
  stress_yy = randn(block.num_elem)
  stress_xy = randn(block.num_elem)

  write_values(exo_new, ElementVariable, 1, 1, 1, stress_xx)
  write_values(exo_new, ElementVariable, 1, 1, 2, stress_yy)
  write_values(exo_new, ElementVariable, 1, 1, 3, stress_xy)

  stress_xx_read = read_values(exo_new, ElementVariable, 1, 1, 1)
  stress_yy_read = read_values(exo_new, ElementVariable, 1, 1, 2)
  stress_xy_read = read_values(exo_new, ElementVariable, 1, 1, 3)

  @test stress_xx ≈ stress_xx_read
  @test stress_yy ≈ stress_yy_read
  @test stress_xy ≈ stress_xy_read

  stress_xx = randn(block.num_elem)
  stress_yy = randn(block.num_elem)
  stress_xy = randn(block.num_elem)

  write_values(exo_new, ElementVariable, 1, 1, "stress_xx", stress_xx)
  write_values(exo_new, ElementVariable, 1, 1, "stress_yy", stress_yy)
  write_values(exo_new, ElementVariable, 1, 1, "stress_xy", stress_xy)

  stress_xx_read = read_values(exo_new, ElementVariable, 1, 1, "stress_xx")
  stress_yy_read = read_values(exo_new, ElementVariable, 1, 1, "stress_yy")
  stress_xy_read = read_values(exo_new, ElementVariable, 1, 1, "stress_xy")

  @test stress_xx ≈ stress_xx_read
  @test stress_yy ≈ stress_yy_read
  @test stress_xy ≈ stress_xy_read

  @test_throws Exodus.SetIDException read_values(exo_new, ElementVariable, 1, 2, 1)
  @test_throws Exodus.SetNameException read_values(exo_new, ElementVariable, 1, "fake", "stress_xx")
  @test_throws Exodus.VariableIDException read_values(exo_new, ElementVariable, 1, 1, 6)
  @test_throws Exodus.VariableNameException read_values(exo_new, ElementVariable, 1, 1, "fake_variable")

  # global variables
  write_number_of_variables(exo_new, GlobalVariable, 5)
  @test read_number_of_variables(exo_new, GlobalVariable) == 5

  write_name(exo_new, GlobalVariable, 1, "global_var_1")
  write_name(exo_new, GlobalVariable, 2, "global_var_2")
  write_name(exo_new, GlobalVariable, 3, "global_var_3")
  write_name(exo_new, GlobalVariable, 4, "global_var_4")
  write_name(exo_new, GlobalVariable, 5, "global_var_5")

  @test read_name(exo_new, GlobalVariable, 1) == "global_var_1"
  @test read_name(exo_new, GlobalVariable, 2) == "global_var_2"
  @test read_name(exo_new, GlobalVariable, 3) == "global_var_3"
  @test read_name(exo_new, GlobalVariable, 4) == "global_var_4"
  @test read_name(exo_new, GlobalVariable, 5) == "global_var_5"

  write_names(
    exo_new, GlobalVariable,
    ["global_var_1", "global_var_2", "global_var_3", "global_var_4", "global_var_5"]
  )
  global_vars = read_names(exo_new, GlobalVariable)

  @test global_vars[1] == "global_var_1"
  @test global_vars[2] == "global_var_2"
  @test global_vars[3] == "global_var_3"
  @test global_vars[4] == "global_var_4"
  @test global_vars[5] == "global_var_5"

  write_values(exo_new, GlobalVariable, 1, 1, 1, [100.0, 200.0, 300.0, 400.0, 500.0])
  global_vars = read_values(exo_new, GlobalVariable, 1, 1, 1)
  @test global_vars[1] ≈ 100.0
  @test global_vars[2] ≈ 200.0
  @test global_vars[3] ≈ 300.0
  @test global_vars[4] ≈ 400.0
  @test global_vars[5] ≈ 500.0

  write_values(exo_new, GlobalVariable, 1, [10.0, 20.0, 30.0, 40.0, 50.0])
  global_vars = read_values(exo_new, GlobalVariable, 1)
  @test global_vars[1] ≈ 10.0
  @test global_vars[2] ≈ 20.0
  @test global_vars[3] ≈ 30.0
  @test global_vars[4] ≈ 40.0
  @test global_vars[5] ≈ 50.0

  # nodal variables
  # write_number_of_variables(exo_new, NodalVariable, 2)
  # @test read_number_of_variables(exo_new, NodalVariable) == 2
  write_names(exo_new, NodalVariable, ["displ_x_temp", "displ_y_temp"])
  @test read_names(exo_new, NodalVariable) == ["displ_x_temp", "displ_y_temp"]

  write_name(exo_new, NodalVariable, 1, "displ_x")
  write_name(exo_new, NodalVariable, 2, "displ_y")
  @test read_name(exo_new, NodalVariable, 1) == "displ_x"
  @test read_name(exo_new, NodalVariable, 2) == "displ_y"

  u_x = randn(Exodus.num_nodes(exo_new.init))
  u_y = randn(Exodus.num_nodes(exo_new.init))

  write_values(exo_new, NodalVariable, 1, 1, 1, u_x)
  write_values(exo_new, NodalVariable, 1, 1, 2, u_y)
  @test read_values(exo_new, NodalVariable, 1, 1, 1) == u_x
  @test read_values(exo_new, NodalVariable, 1, 1, 2) == u_y

  u_x = randn(Exodus.num_nodes(exo_new.init))
  u_y = randn(Exodus.num_nodes(exo_new.init))

  write_values(exo_new, NodalVariable, 1, 1, "displ_x", u_x)
  write_values(exo_new, NodalVariable, 1, 1, "displ_y", u_y)
  @test read_values(exo_new, NodalVariable, 1, 1, "displ_x") == u_x
  @test read_values(exo_new, NodalVariable, 1, 1, "displ_y") == u_y

  @test_throws Exodus.VariableIDException read_values(exo_new, NodalVariable, 1, 1, 4)
  @test_throws Exodus.VariableNameException read_values(exo_new, NodalVariable, 1, 1, "fake_variable")

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
  @test_throws Exodus.VariableNameException read_values(exo_new, NodalVariable, 1, 1, "fake_variable")

  @show exo_new

  close(exo_new)

  Base.Filesystem.rm("./test_output_2D_Mesh.e")
end

@exodus_unit_test_set "Test Read/Write ExodusDatabase - 3D Mesh" begin
  exo_old = ExodusDatabase(abspath(mesh_file_name_3D), "r")
  M = Exodus.map_int_mode(exo_old.exo)
  I = Exodus.id_int_mode(exo_old.exo)
  B = Exodus.bulk_int_mode(exo_old.exo)
  F = Exodus.float_mode(exo_old.exo)

  init_old = Initialization(exo_old)
  coords_old = read_coordinates(exo_old)
  coord_names_old = Exodus.read_coordinate_names(exo_old)
  close(exo_old)

  copy_mesh(mesh_file_name_3D, "./test_output_3D_Mesh.e")
  exo_new = ExodusDatabase("./test_output_3D_Mesh.e", "rw")
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

  write_names(exo_new, NodalVariable, ["u"])
  @test read_number_of_variables(exo_new, NodalVariable) == 1
  @test read_names(exo_new, NodalVariable) == ["u"]
  @test_throws Exodus.VariableNameException write_names(exo_new, NodalVariable, ["u", "v"])
  close(exo_new)

  Base.Filesystem.rm("./test_output_3D_Mesh.e")
end

@exodus_unit_test_set "Test Read/Write ExodusDatabase - 3D id maps" begin
  exo_old = ExodusDatabase(abspath(mesh_file_name_3D), "r")
  M = Exodus.map_int_mode(exo_old.exo)
  I = Exodus.id_int_mode(exo_old.exo)
  B = Exodus.bulk_int_mode(exo_old.exo)
  F = Exodus.float_mode(exo_old.exo)
  copy_mesh(mesh_file_name_3D, "./test_output_3D_id_maps_Mesh.e")
  exo_new = ExodusDatabase("./test_output_3D_id_maps_Mesh.e", "rw")

  node_map = read_id_map(exo_old, NodeMap)

  new_node_map = node_map .+ M(10000)
  write_id_map(exo_new, NodeMap, new_node_map)

  @test read_id_map(exo_new, NodeMap) == new_node_map

  elem_map = read_id_map(exo_old, ElementMap)

  new_elem_map = elem_map .+ M(10000)
  write_id_map(exo_new, ElementMap, new_elem_map)

  @test read_id_map(exo_new, ElementMap) == new_elem_map

  close(exo_old)
  close(exo_new)

  Base.Filesystem.rm("./test_output_3D_id_maps_Mesh.e")
end

@exodus_unit_test_set "EPU test for issue #156" begin

  if !Sys.iswindows()
    # data to write
    coords1 = [
      1.0 0.5 0.5 1.0 0.0 0.0 0.5 1.0 0.0
      1.0 1.0 0.5 0.5 1.0 0.5 0.0 0.0 0.0
    ]
    coords2 = [
      2.0 1.5 1.5 2.0 1.0 1.0 1.5 2.0 1.0
      1.0 1.0 0.5 0.5 1.0 0.5 0.0 0.0 0.0
    ]

    conn = [
      1 2 4 3
      2 5 3 6
      3 6 7 9
      4 3 8 7
    ]

    node_map_1 = Int32[1, 2, 3, 4, 5, 6, 7, 8, 9]
    node_map_2 = node_map_1 .+ Int32(1000)
    elem_map_1 = Int32[1, 2, 3, 4]
    elem_map_2 = Int32[1000, 1001, 1002, 1003]

    # make some hack variables to write
    v_nodal_1 = rand(9)
    v_nodal_2 = rand(9)

    v_elem_1 = rand(4)
    v_elem_2 = rand(4)

    # set the types
    maps_int_type = Int32
    ids_int_type = Int32
    bulk_int_type = Int32
    float_type = Float64

    # initialization parameters
    n_dim, n_nodes = size(coords1)
    n_elems = size(conn, 2)
    n_elem_blks = 1
    n_side_sets = 0
    n_node_sets = 0

    # make init
    init = Initialization{
      bulk_int_type(n_dim), bulk_int_type(n_nodes), bulk_int_type(n_elems),
      bulk_int_type(n_elem_blks), bulk_int_type(n_side_sets), bulk_int_type(n_node_sets)
    }()

    # finally make empty exo database
    exo1 = ExodusDatabase{maps_int_type, ids_int_type, bulk_int_type, float_type}(
      "test_write.e.2.0", "w", init
    )
    exo2 = ExodusDatabase{maps_int_type, ids_int_type, bulk_int_type, float_type}(
      "test_write.e.2.1", "w", init
    )

    # how to write coordinates
    write_coordinates(exo1, coords1)
    write_coordinates(exo2, coords2)
    # how to write a block
    write_block(exo1, 1, "QUAD4", conn)
    write_block(exo2, 1, "QUAD4", conn)
    # write element id map
    write_id_map(exo1, NodeMap, node_map_1)
    write_id_map(exo2, NodeMap, node_map_2)
    write_id_map(exo1, ElementMap, elem_map_1)
    write_id_map(exo2, ElementMap, elem_map_2)
    # need at least one timestep to output variables
    write_time(exo1, 1, 0.0)
    write_time(exo2, 1, 0.0)
    # write number of variables and their names
    write_names(exo1, NodalVariable, ["v_nodal_1"])
    write_names(exo2, NodalVariable, ["v_nodal_1"])
    write_names(exo1, ElementVariable, ["v_elem_1"])
    write_names(exo2, ElementVariable, ["v_elem_1"])
    # write variable values the 1 is for the time step
    write_values(exo1, NodalVariable, 1, "v_nodal_1", v_nodal_1)
    write_values(exo2, NodalVariable, 1, "v_nodal_1", v_nodal_1)
    # the first 1 is for the time step 
    # and the second 1 is for the block number
    write_values(exo1, ElementVariable, 1, 1, "v_elem_1", v_elem_1)
    write_values(exo2, ElementVariable, 1, 1, "v_elem_1", v_elem_1)
    # don't forget to close the exodusdatabase, it can get corrupted otherwise if you're writing
    close(exo1)
    close(exo2)

    epu("test_write.e.2.0")

    # cleanup
    rm("test_write.e", force=true)
    rm("test_write.e.2.0", force=true)
    rm("test_write.e.2.1", force=true)
    rm("epu.log")
    rm("epu_err.log")
  end
end
