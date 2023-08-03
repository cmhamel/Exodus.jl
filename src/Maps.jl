"""
"""
function read_map(exo::ExodusDatabase)
  elem_map = Vector{get_map_int_type(exo)}(undef, exo.init.num_elems)
  error_code = @ccall libexodus.ex_get_map(get_file_id(exo)::Cint, elem_map::Ptr{void_int})::Cint
  exodus_error_check(error_code, "Exodus.read_element_map -> libexodus.ex_get_map")
  return elem_map
end
