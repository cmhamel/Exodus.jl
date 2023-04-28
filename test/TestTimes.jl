@exodus_unit_test_set "Test Get Number of Time Steps" begin
  exo = ExodusDatabase("./example_output/output.gold", "r")
  n_steps = read_number_of_time_steps(exo)
  @test n_steps == 2
  close(exo)
end

@exodus_unit_test_set "Test Read Times" begin
  exo = ExodusDatabase("./example_output/output.gold", "r")
  times = read_times(exo)
  @test times == [0.0, 1.0]
  close(exo)
end

@exodus_unit_test_set "Test Write Times" begin
  exo_old = ExodusDatabase("./example_output/output.gold", "r")
  exo_new = ExodusDatabase("./test_output.gold", "w") # using defaults
  init_old = Initialization(exo_old)
  put_initialization!(exo_new, init_old)
  init_new = Initialization(exo_new)

  write_time(exo_new, 1, 0.0)
  write_time(exo_new, 2, 1.0)

  times = read_times(exo_new)
  @test times == [0.0, 1.0]

  close(exo_old)
  close(exo_new)
  Base.Filesystem.rm("./test_output.gold")
end