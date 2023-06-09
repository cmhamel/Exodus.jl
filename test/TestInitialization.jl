mesh_file_name_2D = "./mesh/square_meshes/mesh_test_0.0078125.g"
number_of_nodes_2D = 16641
number_of_elements_2D = 128^2

mesh_file_name_3D = "./mesh/cube_meshes/mesh_test_0.125.g"
number_of_nodes_3D = 729
number_of_elements_3D = 512

function test_read_initialization_2D()
  exo = ExodusDatabase(abspath(mesh_file_name_2D), "r")
  @test exo.init.num_dim       == 2
  @test exo.init.num_nodes     == number_of_nodes_2D
  @test exo.init.num_elems     == number_of_elements_2D
  @test exo.init.num_elem_blks == 1
  @test exo.init.num_node_sets == 4
  @test exo.init.num_side_sets == 4
  close(exo)
end

function test_read_initialization_3D()
  exo = ExodusDatabase(abspath(mesh_file_name_3D), "r")
  @test exo.init.num_dim       == 3
  @test exo.init.num_nodes     == number_of_nodes_3D
  @test exo.init.num_elems     == number_of_elements_3D
  @test exo.init.num_elem_blks == 1
  @test exo.init.num_node_sets == 6
  @test exo.init.num_side_sets == 6
  close(exo)
end

@exodus_unit_test_set "Initialization - read" begin
  test_read_initialization_2D()
  test_read_initialization_3D()
end
