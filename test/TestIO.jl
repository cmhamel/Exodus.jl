@exodus_unit_test_set "Test ExodusDatabase Read Mode" begin
  exo = ExodusDatabase("./example_output/output.gold", "r")
  @test typeof(exo) == ExodusDatabase{Int32, Int32, Int32, Float64}
  @test Exodus.get_map_int_type(exo) == Int32
  @test Exodus.get_id_int_type(exo) == Int32
  @test Exodus.get_bulk_int_type(exo) == Int32
  @test Exodus.get_float_type(exo) == Float64
  close(exo)
end

@exodus_unit_test_set "Test ExodusDatabase Write Mode - Defaults" begin
  exo = ExodusDatabase("./test_write.e")
  @test typeof(exo) == ExodusDatabase{Int32, Int32, Int32, Float64}
  @test Exodus.get_map_int_type(exo) == Int32
  @test Exodus.get_id_int_type(exo) == Int32
  @test Exodus.get_bulk_int_type(exo) == Int32
  @test Exodus.get_float_type(exo) == Float64
  close(exo)
  Base.Filesystem.rm("./test_write.e")
end

@exodus_unit_test_set "Test ExodusDatabase Write Mode - Meaningful 2D" begin
  exo = ExodusDatabase(
    "./test_write_meaningful.e",
    num_dim = 2, num_nodes = 16641, num_elems = 16384,
    num_elem_blks = 1, num_node_sets = 4, num_side_sets = 4
  )
  @test typeof(exo) == ExodusDatabase{Int32, Int32, Int32, Float64}
  @test Exodus.get_map_int_type(exo) == Int32
  @test Exodus.get_id_int_type(exo) == Int32
  @test Exodus.get_bulk_int_type(exo) == Int32
  @test Exodus.get_float_type(exo) == Float64
  close(exo)
  Base.rm("./test_write_meaningful.e")
end

@exodus_unit_test_set "Test ExodusDatabase Write Mode - Meaningful 3D" begin
  exo = ExodusDatabase(
    "./test_write_meaningful.e",
    num_dim = 3, num_nodes = 729, num_elems = 512,
    num_elem_blks = 1, num_node_sets = 6, num_side_sets = 6
  )
  @test typeof(exo) == ExodusDatabase{Int32, Int32, Int32, Float64}
  @test Exodus.get_map_int_type(exo) == Int32
  @test Exodus.get_id_int_type(exo) == Int32
  @test Exodus.get_bulk_int_type(exo) == Int32
  @test Exodus.get_float_type(exo) == Float64
  close(exo)
  Base.rm("./test_write_meaningful.e")
end

@exodus_unit_test_set "Test ExodusDatabase with Init" begin
  exo_temp = ExodusDatabase("./mesh/square_meshes/mesh_test_0.0078125.g", "r")
  init = exo_temp.init
  close(exo_temp)
  exo = ExodusDatabase("./test_with_init.e", init)
  close(exo)
  Base.rm("./test_with_init.e")
end

@exodus_unit_test_set "Test ExodusDatabase Copy Mode" begin
  exo_old = ExodusDatabase("./mesh/square_meshes/mesh_test_0.0078125.g", "r")
  copy(exo_old, "./test_output.e")
  exo_new = ExodusDatabase("./test_output.e", "r")
  # @exodiff "./mesh/square_meshes/mesh_test_0.0078125.g" "./test_output.e"
  close(exo_old)
  close(exo_new)
  Base.rm("./test_output.e")
end
