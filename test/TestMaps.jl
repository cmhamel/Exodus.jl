@exodus_unit_test_set "Test Maps.jl - read element map" begin
    exo = ExodusDatabase("../example_output/output.gold", "r")
    init = Initialization(exo)
    elem_map = Exodus.read_element_map(exo, init)
    @test length(elem_map) == init.num_elems
end