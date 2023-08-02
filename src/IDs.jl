"""
"""
function read_ids(exo::ExodusDatabase{M, I, B, F}, type::Type{S}) where {M, I, B, F, S <: AbstractSet}
  if type <: NodeSet
    num_entries = exo.init.num_node_sets
    type = EX_NODE_SET
  elseif type <: SideSet
    num_entries = exo.init.num_side_sets
    type = EX_SIDE_SET
  end
  ids = Vector{B}(undef, num_entries)
  ids = Vector{B}(undef, num_entries)
  error_code = @ccall libexodus.ex_get_ids(
    get_file_id(exo)::Cint, type::ex_entity_type, ids::Ptr{B}
  )::Cint
  exodus_error_check(error_code, "Exodus.read_set_ids -> libexodus.ex_get_ids")
  return ids
end

