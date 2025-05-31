@exodus_unit_test_set "Test Read/Write unitful" begin
    exo_old = ExodusDatabase(abspath(mesh_file_name_2D), "rw")
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

    # read coords with units
    coords = read_coordinates(exo_old, u"m")
    @test_throws MethodError read_coordinates(exo_old, u"s")
    @test unit(coords[1]) == u"m"
    @test ustrip(coords) ≈ read_coordinates(exo_old)

    # read/write times with units
    write_time(exo_old, 1, 0.0u"s")
    write_time(exo_old, 2, 1.0u"s")
    times = read_times(exo_old, u"s")
    @test unit(times[1]) == u"s"
    @test ustrip(times) == read_times(exo_old)
    times = read_times(exo_old, u"Hz")
    @test unit(times[1]) == u"Hz"
    @test ustrip(times) == read_times(exo_old)
    @test_throws MethodError read_times(exo_old, u"m")
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

    # time again
    write_time(exo_new, 1, 0.0u"s")

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

    block = Block(exo_new, "block_1")

    stress_xx = randn(block.num_elem)u"MPa"
    stress_yy = randn(block.num_elem)u"MPa"
    stress_xy = randn(block.num_elem)u"MPa"

    write_values(exo_new, ElementVariable, 1, 1, 1, stress_xx)
    write_values(exo_new, ElementVariable, 1, 1, 2, stress_yy)
    write_values(exo_new, ElementVariable, 1, 1, 3, stress_xy)

    stress_xx_read = read_values(exo_new, ElementVariable, 1, 1, 1, u"MPa")
    stress_yy_read = read_values(exo_new, ElementVariable, 1, 1, 2, u"MPa")
    stress_xy_read = read_values(exo_new, ElementVariable, 1, 1, 3, u"MPa")

    @test stress_xx ≈ stress_xx_read
    @test stress_yy ≈ stress_yy_read
    @test stress_xy ≈ stress_xy_read

    stress_xx = randn(block.num_elem)u"MPa"
    stress_yy = randn(block.num_elem)u"MPa"
    stress_xy = randn(block.num_elem)u"MPa"

    write_values(exo_new, ElementVariable, 1, 1, "stress_xx", stress_xx)
    write_values(exo_new, ElementVariable, 1, 1, "stress_yy", stress_yy)
    write_values(exo_new, ElementVariable, 1, 1, "stress_xy", stress_xy)

    stress_xx_read = read_values(exo_new, ElementVariable, 1, 1, "stress_xx", u"MPa")
    stress_yy_read = read_values(exo_new, ElementVariable, 1, 1, "stress_yy", u"MPa")
    stress_xy_read = read_values(exo_new, ElementVariable, 1, 1, "stress_xy", u"MPa")

    @test stress_xx ≈ stress_xx_read
    @test stress_yy ≈ stress_yy_read
    @test stress_xy ≈ stress_xy_read

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

    # TODO
    # write_values(exo_new, GlobalVariable, 1, 1, 1, [100.0u"s", 200.0u"Pa", 300.0u"MPa", 400.0u"Hz", 500.0u"m"])
    # global_vars = read_values(exo_new, GlobalVariable, 1, 1, 1)
    # @test global_vars[1] ≈ 100.0
    # @test global_vars[2] ≈ 200.0
    # @test global_vars[3] ≈ 300.0
    # @test global_vars[4] ≈ 400.0
    # @test global_vars[5] ≈ 500.0

    # write_values(exo_new, GlobalVariable, 1, [10.0u"s", 20.0u"Pa", 30.0u"MPa", 40.0u"Hz", 50.0u"m"])
    # global_vars = read_values(exo_new, GlobalVariable, 1)
    # @test global_vars[1] ≈ 10.0
    # @test global_vars[2] ≈ 20.0
    # @test global_vars[3] ≈ 30.0
    # @test global_vars[4] ≈ 40.0
    # @test global_vars[5] ≈ 50.0

      # nodal variables
    # write_number_of_variables(exo_new, NodalVariable, 2)
    # @test read_number_of_variables(exo_new, NodalVariable) == 2
    write_names(exo_new, NodalVariable, ["displ_x_temp", "displ_y_temp"])
    @test read_names(exo_new, NodalVariable) == ["displ_x_temp", "displ_y_temp"]

    write_name(exo_new, NodalVariable, 1, "displ_x")
    write_name(exo_new, NodalVariable, 2, "displ_y")
    @test read_name(exo_new, NodalVariable, 1) == "displ_x"
    @test read_name(exo_new, NodalVariable, 2) == "displ_y"

    u_x = randn(Exodus.num_nodes(exo_new.init))u"mm"
    u_y = randn(Exodus.num_nodes(exo_new.init))u"mm"

    write_values(exo_new, NodalVariable, 1, 1, 1, u_x)
    write_values(exo_new, NodalVariable, 1, 1, 2, u_y)
    @test read_values(exo_new, NodalVariable, 1, 1, 1, u"mm") == u_x
    @test read_values(exo_new, NodalVariable, 1, 1, 2, u"mm") == u_y
    @test unit(read_values(exo_new, NodalVariable, 1, 1, 1, u"mm")[1]) == u"mm"
    @test unit(read_values(exo_new, NodalVariable, 1, 1, 2, u"mm")[1]) == u"mm"

    u_x = randn(Exodus.num_nodes(exo_new.init))u"mm"
    u_y = randn(Exodus.num_nodes(exo_new.init))u"mm"

    write_values(exo_new, NodalVariable, 1, 1, "displ_x", u_x)
    write_values(exo_new, NodalVariable, 1, 1, "displ_y", u_y)
    @test read_values(exo_new, NodalVariable, 1, 1, "displ_x", u"mm") == u_x
    @test read_values(exo_new, NodalVariable, 1, 1, "displ_y", u"mm") == u_y
    @test unit(read_values(exo_new, NodalVariable, 1, 1, 1, u"mm")[1]) == u"mm"
    @test unit(read_values(exo_new, NodalVariable, 1, 1, 2, u"mm")[1]) == u"mm"

    @test_throws Exodus.VariableIDException read_values(exo_new, NodalVariable, 1, 1, 4, u"mm")
    @test_throws Exodus.VariableNameException read_values(exo_new, NodalVariable, 1, 1, "fake_variable", u"mm")

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
        u_x = randn(length(nset.nodes))u"mm"
        u_y = randn(length(nset.nodes))u"mm"
        write_values(exo_new, NodeSetVariable, 1, nset.id, 1, u_x)
        write_values(exo_new, NodeSetVariable, 1, nset.id, 2, u_y)
        @test read_values(exo_new, NodeSetVariable, 1, nset.id, 1, u"mm") == u_x
        @test read_values(exo_new, NodeSetVariable, 1, nset.id, 2, u"mm") == u_y
        @test unit(read_values(exo_new, NodeSetVariable, 1, nset.id, 1, u"mm")[1]) == u"mm"
        @test unit(read_values(exo_new, NodeSetVariable, 1, nset.id, 2, u"mm")[1]) == u"mm"
    end

    nset_names = read_names(exo_new, NodeSet)
    for nset_name in nset_names
        nset = NodeSet(exo_new, nset_name)
        u_x = randn(length(nset.nodes))u"mm"
        u_y = randn(length(nset.nodes))u"mm"
        write_values(exo_new, NodeSetVariable, 1, nset.id, 1, u_x)
        write_values(exo_new, NodeSetVariable, 1, nset.id, 2, u_y)
        @test read_values(exo_new, NodeSetVariable, 1, nset_name, "nset_displ_x", u"mm") == u_x
        @test read_values(exo_new, NodeSetVariable, 1, nset_name, "nset_displ_y", u"mm") == u_y
    end

    nset_names = read_names(exo_new, NodeSet)
    for nset_name in nset_names
        nset = NodeSet(exo_new, nset_name)
        u_x = randn(length(nset.nodes))u"mm"
        u_y = randn(length(nset.nodes))u"mm"
        write_values(exo_new, NodeSetVariable, 1, nset_name, "nset_displ_x", u_x)
        write_values(exo_new, NodeSetVariable, 1, nset_name, "nset_displ_y", u_y)
        @test read_values(exo_new, NodeSetVariable, 1, nset_name, "nset_displ_x", u"mm") == u_x
        @test read_values(exo_new, NodeSetVariable, 1, nset_name, "nset_displ_y", u"mm") == u_y
    end

    @test_throws Exodus.SetIDException read_values(exo_new, NodeSetVariable, 1, 6, 1, u"mm")
    @test_throws Exodus.SetNameException read_values(exo_new, NodeSetVariable, 1, "fake", "nset_displ_x", u"mm")
    @test_throws Exodus.VariableIDException read_values(exo_new, NodeSetVariable, 1, 1, 6, u"mm")
    @test_throws Exodus.VariableNameException read_values(exo_new, NodeSetVariable, 1, 1, "fake_variable", u"mm")

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
        stress_xx = randn(length(sset.elements))u"MPa"
        stress_yy = randn(length(sset.elements))u"MPa"
        stress_xy = randn(length(sset.elements))u"MPa"

        write_values(exo_new, SideSetVariable, 1, sset.id, 1, stress_xx)
        write_values(exo_new, SideSetVariable, 1, sset.id, 2, stress_yy)
        write_values(exo_new, SideSetVariable, 1, sset.id, 3, stress_xy)

        @test read_values(exo_new, SideSetVariable, 1, sset.id, 1, u"MPa") == stress_xx
        @test read_values(exo_new, SideSetVariable, 1, sset.id, 2, u"MPa") == stress_yy
        @test read_values(exo_new, SideSetVariable, 1, sset.id, 3, u"MPa") == stress_xy
        @test unit(read_values(exo_new, SideSetVariable, 1, sset.id, 1, u"MPa")[1]) == u"MPa"
        @test unit(read_values(exo_new, SideSetVariable, 1, sset.id, 2, u"MPa")[1]) == u"MPa"
        @test unit(read_values(exo_new, SideSetVariable, 1, sset.id, 3, u"MPa")[1]) == u"MPa"
    end

    for sset in ssets
        stress_xx = randn(length(sset.elements))u"MPa"
        stress_yy = randn(length(sset.elements))u"MPa"
        stress_xy = randn(length(sset.elements))u"MPa"

        write_values(exo_new, SideSetVariable, 1, sset.id, "stress_xx", stress_xx)
        write_values(exo_new, SideSetVariable, 1, sset.id, "stress_yy", stress_yy)
        write_values(exo_new, SideSetVariable, 1, sset.id, "stress_xy", stress_xy)

        @test read_values(exo_new, SideSetVariable, 1, sset.id, "stress_xx", u"MPa") == stress_xx
        @test read_values(exo_new, SideSetVariable, 1, sset.id, "stress_yy", u"MPa") == stress_yy
        @test read_values(exo_new, SideSetVariable, 1, sset.id, "stress_xy", u"MPa") == stress_xy
    end

    for sset in ssets
        stress_xx = randn(length(sset.elements))u"MPa"
        stress_yy = randn(length(sset.elements))u"MPa"
        stress_xy = randn(length(sset.elements))u"MPa"

        name = read_name(exo_new, SideSet, sset.id)

        write_values(exo_new, SideSetVariable, 1, name, "stress_xx", stress_xx)
        write_values(exo_new, SideSetVariable, 1, name, "stress_yy", stress_yy)
        write_values(exo_new, SideSetVariable, 1, name, "stress_xy", stress_xy)

        @test read_values(exo_new, SideSetVariable, 1, name, "stress_xx", u"MPa") == stress_xx
        @test read_values(exo_new, SideSetVariable, 1, name, "stress_yy", u"MPa") == stress_yy
        @test read_values(exo_new, SideSetVariable, 1, name, "stress_xy", u"MPa") == stress_xy
    end

    @test_throws Exodus.SetIDException read_values(exo_new, SideSetVariable, 1, 6, 1, u"MPa")
    @test_throws Exodus.SetNameException read_values(exo_new, SideSetVariable, 1, "fake", "stress_xx", u"MPa")
    @test_throws Exodus.VariableIDException read_values(exo_new, SideSetVariable, 1, 1, 6, u"MPa")
    @test_throws Exodus.VariableNameException read_values(exo_new, SideSetVariable, 1, 1, "fake_variable", u"MPa")
end