@testset "ElementVariables.jl - write_element_variable_names" begin
  exo_old = ExodusDatabase("./mesh/square_meshes/mesh_test_0.0078125.g", "r")
  copy(exo_old, "./temp.e")
  close(exo_old)
  exo = ExodusDatabase("./temp.e", "rw")

  write_time(exo, 1, 0.0)
  write_number_of_element_variables(exo, 4)
  n_vars = read_number_of_element_variables(exo)
  @test n_vars == 4
  close(exo)
end