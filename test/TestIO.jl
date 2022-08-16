@exodus_unit_test_set "Test ExodusDatabase Read Mode" begin
    exo_db = Exodus.ExodusDatabase("../example_output/output.e", "r")
    @test typeof(exo_db) == Exodus.ExodusDatabase{Int32, Int32, Int32, Float64}
    Exodus.close_exodus_database(exo_db)
end

@exodus_unit_test_set "Test Create Exodus Database" begin
    exo_old = Exodus.open_exodus_database("../example_output/output.e")
    init = Exodus.Initialization(exo_old)
    coords = Exodus.read_coordinates(exo_old, init.num_dim, init.num_nodes)
    Exodus.close_exodus_database(exo_old)

    exo = Exodus.create_exodus_database("./test_output.e")
    Exodus.put(exo, init)
    Exodus.put_coordinates(exo, coords)
    @test Exodus.Initialization(exo) == init
    @test Exodus.read_coordinates(exo, init.num_dim, init.num_nodes) == coords

    Exodus.close_exodus_database(exo)
    Base.Filesystem.rm("./test_output.e")
    # TODO need to figure out something to test here
end

@exodus_unit_test_set "Test Copy Exodus Database Single Block Mesh" begin
    exo_old = Exodus.open_exodus_database("../example_output/output.e")
    exo_new = Exodus.copy_exodus_database(exo_old, "./test_output.e")

    init_old = Exodus.Initialization(exo_old)
    init_new = Exodus.Initialization(exo_new)
    coords_old = Exodus.read_coordinates(exo_old, init_old.num_dim, init_old.num_nodes)
    coords_new = Exodus.read_coordinates(exo_new, init_new.num_dim, init_new.num_nodes)
    block_ids_old = Exodus.read_block_ids(exo_old, init_old.num_elem_blks)
    block_ids_new = Exodus.read_block_ids(exo_new, init_new.num_elem_blks)
    blocks_old = Exodus.read_blocks(exo_old, block_ids_old)
    blocks_new = Exodus.read_blocks(exo_new, block_ids_new)

    @test init_old == init_new
    @test coords_old == coords_new
    @test block_ids_old == block_ids_new
    @test blocks_old[1].block_id == blocks_new[1].block_id
    @test blocks_old[1].num_elem == blocks_new[1].num_elem
    @test blocks_old[1].num_nodes_per_elem == blocks_new[1].num_nodes_per_elem
    @test blocks_old[1].elem_type == blocks_new[1].elem_type
    @test blocks_old[1].conn == blocks_new[1].conn

    # TODO add more checks once you flesh out the library a little more

    Exodus.close_exodus_database(exo_old)
    Exodus.close_exodus_database(exo_new)

    Base.Filesystem.rm("./test_output.e")
end