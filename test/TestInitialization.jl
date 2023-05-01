mesh_file_name = "./mesh/square_meshes/mesh_test_0.0078125.g"
number_of_nodes = 16641
number_of_elements = 128^2

function test_read_initialization()
  exo = ExodusDatabase(abspath(mesh_file_name), "r")
  @test exo.init.num_dim       == 2
  @test exo.init.num_nodes     == number_of_nodes
  @test exo.init.num_elems     == number_of_elements
  @test exo.init.num_elem_blks == 1
  @test exo.init.num_node_sets == 4
  @test exo.init.num_side_sets == 4
  close(exo)
end

@exodus_unit_test_set "Initialization - read" begin
  test_read_initialization()
end

# function test_write_initialization_on_square_mesh(n::Int64)
#   exo_old = ExodusDatabase(abspath(mesh_file_names[n]), "r")
#   exo = ExodusDatabase("./test_output.e", "w") # using Defaults

#   init_old = Initialization(exo_old)
#   write_initialization!(exo, init_old)

#   # init = Initialization(exo)
#   init = exo.init
#   @test init.num_dim       == init_old.num_dim
#   @test init.num_nodes     == init_old.num_nodes
#   @test init.num_elems     == init_old.num_elems
#   @test init.num_elem_blks == init_old.num_elem_blks
#   @test init.num_node_sets == init_old.num_node_sets
#   @test init.num_side_sets == init_old.num_side_sets

#   close(exo_old)
#   close(exo)
#   Base.Filesystem.rm("./test_output.e")
# end