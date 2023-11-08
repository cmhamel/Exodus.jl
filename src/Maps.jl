"""
"""
function read_map(exo::ExodusDatabase)
  elem_map = exo.cache_M
  resize!(elem_map, exo.init.num_elems)
  
  if !exo.use_cache_arrays
    elem_map = copy(elem_map)
  end

  error_code = @ccall libexodus.ex_get_map(get_file_id(exo)::Cint, elem_map::Ptr{void_int})::Cint
  exodus_error_check(error_code, "Exodus.read_element_map -> libexodus.ex_get_map")
  return elem_map
end

"""
"""
function read_id_map(
  exo::ExodusDatabase{M, I, B, F}, type::Type{MAP}
) where {M, I, B, F, MAP <: AbstractExodusMap}

  if type <: NodeMap
    num_ids = exo.init.num_nodes
  elseif type <: ElementMap
    num_ids = exo.init.num_elems
  end

  map = Vector{M}(undef, num_ids)

  error = @ccall libexodus.ex_get_id_map(
    exo.exo::Cint, entity_type(type)::ex_entity_type, map::Ptr{M}
  )::Cint
  exodus_error_check(error, "read_id_map -> ex_get_id_map")

  return map
end

"""
"""
function write_id_map(
  exo::ExodusDatabase{M, I, B, F}, type::Type{MAP}, map::Vector{M}
) where {M, I, B, F, MAP <: AbstractExodusMap}

  if type <: NodeMap
    @assert length(map) == exo.init.num_nodes
  elseif type <: ElementMap
    @assert length(map) == exo.init.num_elems
  end

  error = @ccall libexodus.ex_put_id_map(
    exo.exo::Cint, entity_type(type)::ex_entity_type, map::Ptr{M}
  )::Cint
  exodus_error_check(error, "write_id_map -> ex_put_id_map")
end

# TODO implement this, it might be useful
# function read_id_map(exo::ExodusDatabase{M, I, B, F}) where {M, I, B, F}

#   # map = Vector{M}(undef, exo.init.num_elems)
#   # error = @ccall libexodus.ex_get_id_map(
#   #   exo.exo::Cint, EX_ELEM_MAP::ex_entity_type, map::Ptr{M}
#   # )::Cint
#   # exodus_error_check(error, "read_id_map -> ex_get_id_map")
#   # return map

#   map = Vector{M}(undef, exo.init.num_nodes)
#   error = @ccall libexodus.ex_get_id_map(
#     exo.exo::Cint, EX_NODE::ex_entity_type, map::Ptr{M}
#   )::Cint
#   exodus_error_check(error, "read_id_map -> ex_get_id_map")
#   return map
# end