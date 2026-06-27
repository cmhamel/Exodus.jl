"""
$(TYPEDSIGNATURES)
TODO change to not use void_int
"""
function read_map(exo::ExodusDatabase{M, I, B, F}) where {M, I, B, F}
  elem_map = Vector{M}(undef, num_elements(exo.init))
  error_code = LibExodus.ex_get_map(get_file_id(exo), elem_map)
  exodus_error_check(exo, error_code, "Exodus.read_element_map -> LibExodus.ex_get_map")
  return elem_map
end

"""
$(TYPEDSIGNATURES)
"""
function read_id_map(
  exo::ExodusDatabase{M, I, B, F}, type::Type{MAP}
) where {M, I, B, F, MAP <: AbstractExodusMap}

  if type <: NodeMap
    num_ids = num_nodes(exo.init)
  elseif type <: ElementMap
    num_ids = num_elements(exo.init)
  end

  id_map = Vector{M}(undef, num_ids)
  error = LibExodus.ex_get_id_map(get_file_id(exo), entity_type(type), id_map)
  exodus_error_check(exo, error, "read_id_map -> ex_get_id_map")

  return id_map
end

"""
$(TYPEDSIGNATURES)
"""
function write_id_map(
  exo::ExodusDatabase{M, I, B, F}, type::Type{MAP}, id_map::Vector{M}
) where {M, I, B, F, MAP <: AbstractExodusMap}

  if type <: NodeMap
    @assert length(id_map) == num_nodes(exo.init)
  elseif type <: ElementMap
    @assert length(id_map) == num_elements(exo.init)
  end

  error = LibExodus.ex_put_id_map(get_file_id(exo), entity_type(type), id_map)
  exodus_error_check(exo, error, "write_id_map -> ex_put_id_map")
end

# this is not working as expected so disabling
# """
# $(TYPEDSIGNATURES)
# """
# function read_num_map(
#   exo::ExodusDatabase{M, I, B, F}, type::Type{MAP}, id
# ) where {M, I, B, F, MAP <: AbstractExodusMap}
#   if type <: NodeMap
#     num_vals = num_nodes(exo.init)
#     # id = 1
#   elseif type <: ElementMap
#     num_vals = num_elements(exo.init)
#     # id = -1
#   end
#   @show entity_type(type)
#   # map = Vector{M}(undef, 1)
#   map = Vector{Int64}(undef, num_vals)

#   error = @ccall LibExodus.ex_get_num_map(
#     exo.exo::Cint, entity_type(type)::ex_entity_type, id::ex_entity_id,
#     # map::Ptr{void_int}
#     map::Ptr{Int64}
#   )::Cint
#   exodus_error_check(exo, error, "read_num_map -> ex_get_num_map")

#   return map
# end
