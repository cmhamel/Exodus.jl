function ex_get_map!(exoid::Cint, elem_map::Vector{T}) where {T <: Integer}
  error_code = ccall(
    (:ex_get_map, libexodus), Cint,
    (Cint, Ptr{void_int}),
    exoid, elem_map
  )
  exodus_error_check(error_code, "ex_get_map!")
end

"""
"""
function read_element_map(exo::ExodusDatabase{M, I, B, F}, init::Initialization) where {M <: Integer, I <: Integer,
                                            B <: Integer, F <: Real}
  elem_map = Vector{M}(undef, init.num_elems)
  ex_get_map!(exo.exo, elem_map)
  return elem_map
end

# local exports
export read_element_map
