@exodus_unit_test_set "Test Get Number of Time Steps" begin
  exo = ExodusDatabase("./example_output/output.gold", "r")
  n_steps = read_number_of_time_steps(exo)
  @test n_steps == 2
  close(exo)
end

@exodus_unit_test_set "Test Read Time" begin
  exo = ExodusDatabase("./example_output/output.gold", "r")
  @test read_time(exo, 1) == 0.0
  @test read_time(exo, 2) == 1.0
  close(exo)
end

@exodus_unit_test_set "Test Read Times" begin
  exo = ExodusDatabase("./example_output/output.gold", "r")
  times = read_times(exo)
  @test times == [0.0, 1.0]
  close(exo)
end

@exodus_unit_test_set "Test Write Times" begin
  exo = ExodusDatabase(
    "./example_output/times_temp.e", 
    Initialization(2, 1, 1, 1, 0, 0)
  )
  write_time(exo, 1, 0.)
  write_time(exo, 2, 1.)
  times = read_times(exo)
  @test times == [0., 1.]
  close(exo)
  rm("./example_output/times_temp.e", force=true)
end
