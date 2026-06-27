"""
$(TYPEDSIGNATURES)
"""
function read_ids(exo::ExodusDatabase{M, I, B, F}, ::Type{S}) where {M, I, B, F, S <: AbstractExodusSet}
  num_entries = num_sets(exo, S)::B
  ids = Vector{B}(undef, num_entries)
  error_code = LibExodus.ex_get_ids(get_file_id(exo), entity_type(S), ids)
  exodus_error_check(exo, error_code, "Exodus.read_set_ids -> LibExodus.ex_get_ids")
  return ids
end

"""
$(TYPEDSIGNATURES)
"""
function read_name(exo::ExodusDatabase, ::Type{S}, id::Integer) where S <: AbstractExodusSet
  name = Vector{Cchar}(undef, MAX_STR_LENGTH)
  error_code = LibExodus.ex_get_name(get_file_id(exo), entity_type(S), id, pointer(name))
  exodus_error_check(exo, error_code, "Exodus.read_name -> LibExodus.ex_get_name")
  return unsafe_string(pointer(name))
end

"""
$(TYPEDSIGNATURES)
"""
function read_names(exo::ExodusDatabase, ::Type{S}) where S <: AbstractExodusSet
  ids   = read_ids(exo, S)
  names = Vector{String}(undef, length(ids))

  for n in axes(names, 1)
    names[n] = read_name(exo, S, ids[n])
  end
  return names
end

"""
$(TYPEDSIGNATURES)
"""
function read_set_parameters(
  exo::ExodusDatabase{M, I, B, F}, 
  set_id::Integer, 
  ::Type{S}
) where {M, I, B, F, S <: Union{NodeSet, SideSet}} # TODO there's other sets this method can support
  num_entries = Base.RefValue{I}(0)
  num_df = Base.RefValue{I}(0)
  error_code = LibExodus.ex_get_set_param(
    get_file_id(exo), entity_type(S),
    set_id, num_entries, num_df
  )
  exodus_error_check(exo, error_code, "Exodus.read_set_parameters -> LibExodus.ex_get_set_param")
  return num_entries[], num_df[]
end

"""
$(TYPEDSIGNATURES)
"""
function read_node_set_nodes(exo::ExodusDatabase{M, I, B, F}, set_id::Integer) where {M, I, B, F}
  num_entries, _ = read_set_parameters(exo, set_id, NodeSet)
  entries = Vector{B}(undef, num_entries)
  extras = C_NULL
  error_code = LibExodus.ex_get_set(
    get_file_id(exo), EX_NODE_SET, set_id,
    entries, extras
  )
  exodus_error_check(exo, error_code, "Exodus.read_node_set_nodes -> LibExodus.ex_get_set")
  return entries
end

"""
$(TYPEDSIGNATURES)
"""
function read_side_set_elements_and_sides(exo::ExodusDatabase{M, I, B, F}, set_id::Integer) where {M, I, B, F}
  num_entries, _ = read_set_parameters(exo, set_id, SideSet)
  entries = Vector{B}(undef, num_entries)
  extras  = Vector{B}(undef, num_entries)
  error_code = LibExodus.ex_get_set(
    get_file_id(exo), EX_SIDE_SET, set_id,
    entries, extras
  )
  exodus_error_check(exo, error_code, "Exodus.read_side_set_elements_and_sides -> LibExodus.ex_get_set")
  return entries, extras
end

"""
$(TYPEDSIGNATURES)
UNTESTED
"""
function read_side_set_node_list(exo::ExodusDatabase{M, I, B, F}, side_set_id::Integer) where {M, I, B, F}
  side_set_node_list_len = Base.RefValue{Cint}(0)
  error_code = LibExodus.ex_get_side_set_node_list_len(
    get_file_id(exo), side_set_id, side_set_node_list_len
  )
  exodus_error_check(exo, error_code, "Exodus.read_side_set_node_list -> LibExodus.ex_get_side_set_node_list_len")
  
  num_sides, _ = read_set_parameters(exo, side_set_id, SideSet)
  side_set_node_cnt_list = Vector{B}(undef, num_sides)
  side_set_node_list     = Vector{B}(undef, side_set_node_list_len[])

  error_code = LibExodus.ex_get_side_set_node_list(
    get_file_id(exo), side_set_id,
    side_set_node_cnt_list, side_set_node_list
  )
  exodus_error_check(exo, error_code, "Exodus.read_side_set_node_list -> LibExodus.ex_get_side_set_node_list")
  return side_set_node_cnt_list, side_set_node_list
end

"""
$(TYPEDSIGNATURES)
"""
function read_set(exo::ExodusDatabase, type::Type{S}, set_id::I) where {S <: AbstractExodusSet, I}
  return type(exo, set_id)
end

"""
$(TYPEDSIGNATURES)
"""
function read_sets!(sets::Vector{T}, exo::ExodusDatabase, ids::Vector{I}) where {T <: AbstractExodusSet, I}
  if T <: Block
    type = Block
  elseif T <: NodeSet
    type = NodeSet
  elseif T <: SideSet
    type = SideSet
  end

  for n in eachindex(sets)
    sets[n] = type(exo, ids[n])
  end
end

"""
$(TYPEDSIGNATURES)
"""
function read_sets(exo::ExodusDatabase{M, I, B, F}, type::Type{S}) where {M, I, B, F, S <: AbstractExodusSet}
  set_ids = read_ids(exo, type)

  if S <: Block
    N = 2
  else
    N = 1
  end

  sets = Vector{S{I, Array{B, N}}}(undef, length(set_ids))
  read_sets!(sets, exo, set_ids)
  return sets
end

"""
$(TYPEDSIGNATURES)
WARNING:
currently doesn't support distance factors
"""
function write_set_parameters(exo::ExodusDatabase{M, I, B, F}, set::T) where {M, I, B, F, T <: AbstractExodusSet}
  num_dist_fact_in_set = 0 # TODO not using distance 
  error_code = LibExodus.ex_put_set_param(
    get_file_id(exo), entity_type(T), set.id,
    length(set), num_dist_fact_in_set
  )
  exodus_error_check(exo, error_code, "Exodus.write_node_set_parameters -> LibExodus.ex_put_set_param")
end

"""
$(TYPEDSIGNATURES)
Typing ensures we don't write a set with non-matching types
to the exodus file.
"""
function write_set(exo::ExodusDatabase{M, I, B, F}, set::T) where {T <: AbstractExodusSet, M, I, B, F}
  write_set_parameters(exo, set)
  error_code = LibExodus.ex_put_set(
    get_file_id(exo), entity_type(T), set.id,
    entries(set), extras(set)
  )
  exodus_error_check(exo, error_code, "Exodus.write_set -> LibExodus.ex_put_set")
end

"""
$(TYPEDSIGNATURES)
"""
function write_sets(exo::ExodusDatabase, sets::Vector{T}) where T <: AbstractExodusSet
  for set in sets
    write_set(exo, set)
  end
end

"""
$(TYPEDSIGNATURES)
"""
function write_name(exo::ExodusDatabase{M, I, B, F}, ::Type{S}, set_id::Integer, name::String) where {M, I, B, F, S <: AbstractExodusSet}
  
  if S <: Block
    exo.block_name_dict[name] = set_id
  elseif S <: NodeSet
    exo.nset_name_dict[name] = set_id
  elseif S <: SideSet
    exo.sset_name_dict[name] = set_id
  end

  error_code = LibExodus.ex_put_name(
    get_file_id(exo), entity_type(S), set_id, name
  )
  exodus_error_check(exo, error_code, "Exodus.write_set_name -> LibExodus.ex_put_name")
end

"""
$(TYPEDSIGNATURES)
"""
function write_name(exo::ExodusDatabase{M, I, B, F}, set::S, name::String) where {M, I, B, F, S <: AbstractExodusSet}
  if S <: Block
    exo.block_name_dict[name] = set.id
  elseif S <: NodeSet
    exo.nset_name_dict[name] = set.id
  elseif S <: SideSet
    exo.sset_name_dict[name] = set.id
  end

  error_code = LibExodus.ex_put_name(
    get_file_id(exo), entity_type(S), set.id, name
  )
  exodus_error_check(exo, error_code, "Exodus.write_set_name -> LibExodus.ex_put_name")
end

"""
$(TYPEDSIGNATURES)
WARNING: this methods likely does not have good safe guards
"""
function write_names(exo::ExodusDatabase, ::Type{S}, names::Vector{String}) where S <: AbstractExodusSet
  error_code = LibExodus.ex_put_names(
    get_file_id(exo), entity_type(S), names
  )
  exodus_error_check(exo, error_code, "Exodus.write_set_names -> LibExodus.ex_put_names")
end
