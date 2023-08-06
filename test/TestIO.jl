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
  # exo = ExodusDatabase("./test_write.e")
  exo = ExodusDatabase("./test_write.e", "w")
  @test typeof(exo) == ExodusDatabase{Int32, Int32, Int32, Float64}
  @test Exodus.get_map_int_type(exo) == Int32
  @test Exodus.get_id_int_type(exo) == Int32
  @test Exodus.get_bulk_int_type(exo) == Int32
  @test Exodus.get_float_type(exo) == Float64
  close(exo)
  Base.Filesystem.rm("./test_write.e")
end

@exodus_unit_test_set "Test ExodusDatabase Write Mode - Meaningful 2D" begin
  # exo = ExodusDatabase(
  #   "./test_write_meaningful.e",
  #   num_dim = 2, num_nodes = 16641, num_elems = 16384,
  #   num_elem_blks = 1, num_node_sets = 4, num_side_sets = 4
  # )
  init = Initialization(
    Int32(2), Int32(16641), Int32(16384),
    Int32(1), Int32(4), Int32(4)
  )
  exo = ExodusDatabase(
    "./test_write_meaningful.e", "w", init, 
    Int32, Int32, Int32, Float64
  )
  @test typeof(exo) == ExodusDatabase{Int32, Int32, Int32, Float64}
  @test Exodus.get_map_int_type(exo) == Int32
  @test Exodus.get_id_int_type(exo) == Int32
  @test Exodus.get_bulk_int_type(exo) == Int32
  @test Exodus.get_float_type(exo) == Float64

  @test Initialization(exo) == init
  close(exo)
  Base.rm("./test_write_meaningful.e")
end

@exodus_unit_test_set "Test ExodusDatabase Write Mode - Meaningful 3D" begin
  # exo = ExodusDatabase(
  #   "./test_write_meaningful.e",
  #   num_dim = 3, num_nodes = 729, num_elems = 512,
  #   num_elem_blks = 1, num_node_sets = 6, num_side_sets = 6
  # )
  init = Initialization(
    Int32(3), Int32(729), Int32(512),
    Int32(1), Int32(6), Int32(6)
  )
  exo = ExodusDatabase(
    "./test_write_meaningful.e", "w", init,
    Int32, Int32, Int32, Float64
  )
  @test typeof(exo) == ExodusDatabase{Int32, Int32, Int32, Float64}
  @test Exodus.get_map_int_type(exo) == Int32
  @test Exodus.get_id_int_type(exo) == Int32
  @test Exodus.get_bulk_int_type(exo) == Int32
  @test Exodus.get_float_type(exo) == Float64
  close(exo)
  Base.rm("./test_write_meaningful.e")
end

@exodus_unit_test_set "Test ExodusDatabase with Init - defaults" begin
  exo_temp = ExodusDatabase("./mesh/square_meshes/mesh_test.g", "r")
  init = exo_temp.init
  close(exo_temp)
  exo = ExodusDatabase(
    "./test_with_init.e", "w", init,
    Int32, Int32, Int32, Float64
  )
  close(exo)
  Base.rm("./test_with_init.e")
end

@exodus_unit_test_set "Test ExodusDatabase Copy Mode" begin
  exo_old = ExodusDatabase("./mesh/square_meshes/mesh_test.g", "r")
  copy(exo_old, "./test_output.e")
  exo_new = ExodusDatabase("./test_output.e", "r")
  # @exodiff "./mesh/square_meshes/mesh_test_0.0078125.g" "./test_output.e"
  close(exo_old)
  close(exo_new)
  Base.rm("./test_output.e")
end

@exodus_unit_test_set "Test different type combos" begin

  exo_old = ExodusDatabase("mesh/square_meshes/mesh_test.g", "r")
  coords_old = read_coordinates(exo_old)
  init_old = Initialization(exo_old)
  close(exo_old)

  Ms = [Int32, Int64]
  Is = [Int32, Int64]
  Bs = [Int32, Int64]
  Fs = [Float32, Float64]

  for M in Ms
    for I in Is
      for B in Bs
        for F in Fs
          init = Initialization{B}(
            init_old.num_dim, init_old.num_nodes, init_old.num_elems,
            init_old.num_elem_blks, init_old.num_node_sets, init_old.num_side_sets
          )
          exo = ExodusDatabase("./dummy_$(M)_$(I)_$(B)_$(F).e", "w", init, M, I, B, F)
          @test typeof(exo) == ExodusDatabase{M, I, B, F}

          close(exo)

          Base.Filesystem.rm("./dummy_$(M)_$(I)_$(B)_$(F).e")
        end
      end
    end
  end
end
