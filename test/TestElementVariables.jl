@testset "ElementVariables.jl - write_element_variable_names 2D" begin
  exo_old = ExodusDatabase("./mesh/square_meshes/mesh_test.g", "r")
  copy(exo_old, "./temp_element_variables.e")
  close(exo_old)
  exo = ExodusDatabase("./temp_element_variables.e", "rw")

  write_time(exo, 1, 0.0)
  write_number_of_element_variables(exo, 4)
  n_vars = read_number_of_element_variables(exo)
  @test n_vars == 4
  close(exo)
  rm("./temp_element_variables.e", force=true)
end

@testset "ElementVariables.jl - write_element_variable_names 3D" begin
  exo_old = ExodusDatabase("./mesh/cube_meshes/mesh_test.g", "r")
  copy(exo_old, "./temp_element_variables.e")
  close(exo_old)
  exo = ExodusDatabase("./temp_element_variables.e", "rw")

  write_time(exo, 1, 0.0)
  write_number_of_element_variables(exo, 4)
  n_vars = read_number_of_element_variables(exo)
  @test n_vars == 4
  close(exo)
  rm("./temp_element_variables.e", force=true)
end

@testset "ElementVariables.jl - write element variable names 2D" begin
  exo_old = ExodusDatabase("./mesh/square_meshes/mesh_test.g", "r")
  copy(exo_old, "./temp_element_variables.e")
  close(exo_old)
  exo = ExodusDatabase("./temp_element_variables.e", "rw")

  write_time(exo, 1, 0.0)
  write_number_of_element_variables(exo, 3)
  write_element_variable_names(exo, [1, 2, 3], ["stress_xx", "stress_yy", "stress_xy"])
  var_names = read_element_variable_names(exo)
  @test var_names == ["stress_xx", "stress_yy", "stress_xy"]
  close(exo)
  rm("./temp_element_variables.e", force=true)
end

@testset "ElementVariables.jl - write element variable names 3D" begin
  exo_old = ExodusDatabase("./mesh/cube_meshes/mesh_test.g", "r")
  copy(exo_old, "./temp_element_variables.e")
  close(exo_old)
  exo = ExodusDatabase("./temp_element_variables.e", "rw")

  write_time(exo, 1, 0.0)
  write_number_of_element_variables(exo, 3)
  write_element_variable_names(exo, [1, 2, 3], ["stress_xx", "stress_yy", "stress_xy"])
  var_names = read_element_variable_names(exo)
  @test var_names == ["stress_xx", "stress_yy", "stress_xy"]
  close(exo)
  rm("./temp_element_variables.e", force=true)
end

@testset "ElementVariables.jl - write element variable names by index 2D" begin
  exo_old = ExodusDatabase("./mesh/square_meshes/mesh_test.g", "r")
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
  rm("./temp_element_variables_index.e", force=true)
end

@testset "ElementVariables.jl - write element variable names by index 3D" begin
  exo_old = ExodusDatabase("./mesh/cube_meshes/mesh_test.g", "r")
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
  rm("./temp_element_variables_index.e", force=true)
end

@testset "ElementVariables.jl - write element variable values 2D" begin
  exo_old = ExodusDatabase("./mesh/square_meshes/mesh_test.g", "r")
  copy(exo_old, "./temp_element_variables_index.e")
  close(exo_old)
  exo = ExodusDatabase("./temp_element_variables_index.e", "rw")
  block = Block(exo, 1)
  write_time(exo, 1, 0.0)
  write_number_of_element_variables(exo, 3)

  stress_xx = randn(block.num_elem)
  stress_yy = randn(block.num_elem)
  stress_xy = randn(block.num_elem)

  write_element_variable_values(exo, 1, 1, 1, stress_xx)
  write_element_variable_values(exo, 1, 1, 2, stress_yy)
  write_element_variable_values(exo, 1, 1, 3, stress_xy)

  stress_xx_read = read_element_variable_values(exo, 1, 1, 1)
  stress_yy_read = read_element_variable_values(exo, 1, 1, 2)
  stress_xy_read = read_element_variable_values(exo, 1, 1, 3)

  @test stress_xx ≈ stress_xx_read
  @test stress_yy ≈ stress_yy_read
  @test stress_xy ≈ stress_xy_read

  close(exo)
  rm("./temp_element_variables_index.e", force=true)
end

@testset "ElementVariables.jl - write element variable values 3D" begin
  exo_old = ExodusDatabase("./mesh/cube_meshes/mesh_test.g", "r")
  copy(exo_old, "./temp_element_variables_index.e")
  close(exo_old)
  exo = ExodusDatabase("./temp_element_variables_index.e", "rw")
  block = Block(exo, 1)
  write_time(exo, 1, 0.0)
  write_number_of_element_variables(exo, 3)

  stress_xx = randn(block.num_elem)
  stress_yy = randn(block.num_elem)
  stress_xy = randn(block.num_elem)

  write_element_variable_values(exo, 1, 1, 1, stress_xx)
  write_element_variable_values(exo, 1, 1, 2, stress_yy)
  write_element_variable_values(exo, 1, 1, 3, stress_xy)

  stress_xx_read = read_element_variable_values(exo, 1, 1, 1)
  stress_yy_read = read_element_variable_values(exo, 1, 1, 2)
  stress_xy_read = read_element_variable_values(exo, 1, 1, 3)

  @test stress_xx ≈ stress_xx_read
  @test stress_yy ≈ stress_yy_read
  @test stress_xy ≈ stress_xy_read

  close(exo)
  rm("./temp_element_variables_index.e", force=true)
end

@testset "ElementVariables.jl - write element variable values with names 2D" begin
  exo_old = ExodusDatabase("./mesh/square_meshes/mesh_test.g", "r")
  copy(exo_old, "./temp_element_variables_index.e")
  close(exo_old)
  exo = ExodusDatabase("./temp_element_variables_index.e", "rw")
  block = Block(exo, 1)
  write_time(exo, 1, 0.0)
  write_number_of_element_variables(exo, 3)
  write_element_variable_name(exo, 1, "stress_xx")
  write_element_variable_name(exo, 2, "stress_yy")
  write_element_variable_name(exo, 3, "stress_xy")

  stress_xx = randn(block.num_elem)
  stress_yy = randn(block.num_elem)
  stress_xy = randn(block.num_elem)

  write_element_variable_values(exo, 1, 1, "stress_xx", stress_xx)
  write_element_variable_values(exo, 1, 1, "stress_yy", stress_yy)
  write_element_variable_values(exo, 1, 1, "stress_xy", stress_xy)

  stress_xx_read = read_element_variable_values(exo, 1, 1, "stress_xx")
  stress_yy_read = read_element_variable_values(exo, 1, 1, "stress_yy")
  stress_xy_read = read_element_variable_values(exo, 1, 1, "stress_xy")

  @test stress_xx ≈ stress_xx_read
  @test stress_yy ≈ stress_yy_read
  @test stress_xy ≈ stress_xy_read

  close(exo)
  rm("./temp_element_variables_index.e", force=true)
end

@testset "ElementVariables.jl - write element variable values with names 3D" begin
  exo_old = ExodusDatabase("./mesh/cube_meshes/mesh_test.g", "r")
  copy(exo_old, "./temp_element_variables_index.e")
  close(exo_old)
  exo = ExodusDatabase("./temp_element_variables_index.e", "rw")
  block = Block(exo, 1)
  write_time(exo, 1, 0.0)
  write_number_of_element_variables(exo, 3)
  write_element_variable_name(exo, 1, "stress_xx")
  write_element_variable_name(exo, 2, "stress_yy")
  write_element_variable_name(exo, 3, "stress_xy")

  stress_xx = randn(block.num_elem)
  stress_yy = randn(block.num_elem)
  stress_xy = randn(block.num_elem)

  write_element_variable_values(exo, 1, 1, "stress_xx", stress_xx)
  write_element_variable_values(exo, 1, 1, "stress_yy", stress_yy)
  write_element_variable_values(exo, 1, 1, "stress_xy", stress_xy)

  stress_xx_read = read_element_variable_values(exo, 1, 1, "stress_xx")
  stress_yy_read = read_element_variable_values(exo, 1, 1, "stress_yy")
  stress_xy_read = read_element_variable_values(exo, 1, 1, "stress_xy")

  @test stress_xx ≈ stress_xx_read
  @test stress_yy ≈ stress_yy_read
  @test stress_xy ≈ stress_xy_read

  close(exo)
  rm("./temp_element_variables_index.e", force=true)
end
