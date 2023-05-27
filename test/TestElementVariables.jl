@testset "ElementVariables.jl - write_element_variable_names" begin
  exo_old = ExodusDatabase("./mesh/square_meshes/mesh_test_0.0078125.g", "r")
  copy(exo_old, "./temp_element_variables.e")
  close(exo_old)
  exo = ExodusDatabase("./temp_element_variables.e", "rw")

  write_time(exo, 1, 0.0)
  write_number_of_element_variables(exo, 4)
  n_vars = read_number_of_element_variables(exo)
  @test n_vars == 4
  close(exo)
  run(`rm -f ./temp_element_variables.e`)
end

@testset "ElementVariables.jl - write element variable names" begin
  exo_old = ExodusDatabase("./mesh/square_meshes/mesh_test_0.0078125.g", "r")
  copy(exo_old, "./temp_element_variables.e")
  close(exo_old)
  exo = ExodusDatabase("./temp_element_variables.e", "rw")

  write_time(exo, 1, 0.0)
  write_number_of_element_variables(exo, 3)
  write_element_variable_names(exo, [1, 2, 3], ["stress_xx", "stress_yy", "stress_xy"])
  var_names = read_element_variable_names(exo)
  @test var_names == ["stress_xx", "stress_yy", "stress_xy"]
  close(exo)
  run(`rm -f ./temp_element_variables.e`)
end

@testset "ElementVariables.jl - write element variable names by index" begin
  exo_old = ExodusDatabase("./mesh/square_meshes/mesh_test_0.0078125.g", "r")
  copy(exo_old, "./temp_element_variables_index.e")
  close(exo_old)
  exo = ExodusDatabase("./temp_element_variables_index.e", "rw")

  write_time(exo, 1, 0.0)
  write_number_of_element_variables(exo, 3)
  write_element_variable_name(exo, 1, "stress_xx")
  write_element_variable_name(exo, 2, "stress_yy")
  write_element_variable_name(exo, 3, "stress_xy")
  var_1 = read_element_variable_name(exo, 1)
  var_2 = read_element_variable_name(exo, 2)
  var_3 = read_element_variable_name(exo, 3)
  @test var_1 == "stress_xx"
  @test var_2 == "stress_yy"
  @test var_3 == "stress_xy"
  close(exo)
  run(`rm -f ./temp_element_variables_index.e`)
end