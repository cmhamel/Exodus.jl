@exodus_unit_test_set "Test Maps.jl - read element map" begin
  exo = ExodusDatabase("./example_output/output.gold", "r")
  elem_map = read_element_map(exo)
  @test length(elem_map) == exo.init.num_elems
end