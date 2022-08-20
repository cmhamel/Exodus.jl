function read_element_map(exo::ExodusDatabase{M, I, B, F}, init::Initialization) where {M <: ExoInt, I <: ExoInt,
                                                                                        B <: ExoInt, F <: ExoFloat}
    elem_map = Vector{M}(undef, init.num_elems)
    ex_get_map!(exo.exo, elem_map)
    return elem_map
end