@exodus_ii_error_check function read_ids(exo::ExodusDatabase{M, I, B, F}, ::Type{S}) where {M, I, B, F, S <: AbstractSet}
  if S <: Block
    num_entries = exo.init.num_elem_blks
  elseif S <: NodeSet
    num_entries = exo.init.num_node_sets
  elseif S <: SideSet
    num_entries = exo.init.num_side_sets
  end

  ids = exo.cache_B_1
  resize!(exo.cache_B_1, num_entries)

  if !exo.use_cache_arrays
    ids = copy(ids)
  end

  error_code = @ccall libexodus.ex_get_ids(
    get_file_id(exo)::Cint, entity_type(S)::ex_entity_type, ids::Ptr{B}
  )::Cint
  return ids
end

"""
"""
@exodus_ii_error_check function read_name(exo::ExodusDatabase, ::Type{S}, id::Integer) where S <: AbstractSet
  name = exo.cache_uint8
  resize!(name, MAX_STR_LENGTH)

  error_code = @ccall libexodus.ex_get_name(
    get_file_id(exo)::Cint, entity_type(S)::ex_entity_type, 
    id::ex_entity_id, name::Ptr{UInt8}
  )::Cint

  return unsafe_string(pointer(name))
end

# """
# """
# function read_names(exo::ExodusDatabase, ::Type{S}) where S <: AbstractSet
#   names = [Vector{UInt8}(undef, MAX_STR_LENGTH) for _ in 1:length(read_ids(exo, S))]
#   error_code = @ccall libexodus.ex_get_names(
#     get_file_id(exo)::Cint, entity_type(S)::ex_entity_type, names::Ptr{Ptr{UInt8}}
#   )::Cint
#   exodus_error_check(error_code, "Exodus.read_set_names -> libexodus.ex_get_names")
#  # new_names = map(x -> unsafe_string(pointer(x)), names)
#   new_names = map!(x -> unsafe_string(pointer(x)), exo.cache_strings, names)
#   return new_names
# end

"""
"""
function read_names(exo::ExodusDatabase, ::Type{S}) where S <: AbstractSet
  ids   = read_ids(exo, S)
  names = exo.cache_strings
  resize!(names, length(ids))

  if !exo.use_cache_arrays
    names = copy(names)
  end

  for n in axes(names, 1)
    names[n] = read_name(exo, S, ids[n])
  end
  return names
end

"""
"""
@exodus_ii_error_check function read_set_parameters(exo::ExodusDatabase{M, I, B, F}, set_id::Integer, ::Type{S}) where {M, I, B, F, S <: AbstractSet}
  num_entries = Ref{I}(0)
  num_df = Ref{I}(0)

  error_code = @ccall libexodus.ex_get_set_param(
    get_file_id(exo)::Cint, entity_type(S)::ex_entity_type, set_id::Clonglong, # set_id is really an ex_entity_id but that is weirdly causing a type instability
    num_entries::Ptr{I}, num_df::Ptr{I}
  )::Cint
  return num_entries[], num_df[]
end

"""
"""
@exodus_ii_error_check function read_node_set_nodes(exo::ExodusDatabase{M, I, B, F}, set_id::Integer) where {M, I, B, F}
  num_entries, _ = read_set_parameters(exo, set_id, NodeSet)
  entries = exo.cache_B_1
  resize!(entries, num_entries)

  if !exo.use_cache_arrays
    entries = copy(entries)
  end

  extras = C_NULL

  error_code = @ccall libexodus.ex_get_set(
    get_file_id(exo)::Cint, EX_NODE_SET::ex_entity_type, set_id::Clonglong, # set id is really a ex_entity_id but it's weirldy throwing a type instability
    entries::Ptr{B}, extras::Ptr{Cvoid}
  )::Cint
  return entries
end

"""
"""
@exodus_ii_error_check function read_side_set_elements_and_sides(exo::ExodusDatabase{M, I, B, F}, set_id::Integer) where {M, I, B, F}
  num_entries, _ = read_set_parameters(exo, set_id, SideSet)

  entries = exo.cache_B_1
  extras  = exo.cache_B_2

  resize!(entries, num_entries)
  resize!(extras, num_entries)

  if !exo.use_cache_arrays
    entries = copy(entries)
    extras  = copy(extras)
  end

  error_code = @ccall libexodus.ex_get_set(
    get_file_id(exo)::Cint, EX_SIDE_SET::ex_entity_type, set_id::Clonglong, # set id is really a ex_entity_id but it's weirldy throwing a type instability
    entries::Ptr{B}, extras::Ptr{B}
  )::Cint

  return entries, extras
end

"""
UNTESTED... also edge case for current exodus_ii_error_check method
due to multiple ccalls here
"""
function read_side_set_node_list(exo::ExodusDatabase{M, I, B, F}, side_set_id::Integer) where {M, I, B, F}
  side_set_node_list_len = Ref{Cint}(0)
  error_code = @ccall libexodus.ex_get_side_set_node_list_len(
    get_file_id(exo)::Cint, side_set_id::Clonglong, side_set_node_list_len::Ptr{Cint} # side_set-Id should really be ex_entity_id but it's weirdly causing a type instability
  )::Cint
  exodus_error_check(error_code, "Exodus.read_side_set_node_list -> libexodus.ex_get_side_set_node_list_len")
  
  num_sides, _ = read_set_parameters(exo, side_set_id, SideSet)

  side_set_node_cnt_list = exo.cache_B_1
  side_set_node_list      = exo.cache_B_2

  resize!(side_set_node_cnt_list, num_sides)
  resize!(side_set_node_list, side_set_node_list_len[])

  if !exo.use_cache_arrays
    side_set_node_cnt_list = copy(side_set_node_cnt_list)
    side_set_node_list      = copy(side_set_node_list)
  end

  error_code = @ccall libexodus.ex_get_side_set_node_list(
    get_file_id(exo)::Cint, side_set_id::Clonglong, # should really be ex_entity_id but it's weirdly causing a type instability
    side_set_node_cnt_list::Ptr{B}, side_set_node_list::Ptr{B}
  )::Cint
  exodus_error_check(error_code, "Exodus.read_side_set_node_list -> libexodus.ex_get_side_set_node_list")
  return side_set_node_cnt_list, side_set_node_list
end

"""
"""
function read_set(exo::ExodusDatabase, type::Type{S}, set_id::I) where {S <: AbstractSet, I}
  return type(exo, set_id)
end

"""
"""
function read_sets!(sets::Vector{T}, exo::ExodusDatabase, ids::Vector{I}) where {T <: AbstractSet, I}
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
"""
function read_sets(exo::ExodusDatabase{M, I, B, F}, type::Type{S}) where {M, I, B, F, S <: AbstractSet}
  set_ids = read_ids(exo, type)

  # hack for now so we don't overwrite
  resize!(exo.cache_B_3, length(set_ids))
  exo.cache_B_3 .= set_ids
  set_ids = exo.cache_B_3

  sets = Vector{S{I, B}}(undef, length(set_ids))
  read_sets!(sets, exo, set_ids)
  return sets
end

"""
WARNING:
currently doesn't support distance factors
"""
@exodus_ii_error_check function write_set_parameters(exo::ExodusDatabase{M, I, B, F}, set::T) where {M, I, B, F, T <: AbstractSet}
  num_dist_fact_in_set = 0 # TODO not using distance 
  error_code = @ccall libexodus.ex_put_set_param(
    get_file_id(exo)::Cint, entity_type(T)::ex_entity_type, set.id::Clonglong, # should be ex_entity_id
    length(set)::Clonglong, num_dist_fact_in_set::Clonglong
  )::Cint
end

"""
Typing ensures we don't write a set with non-matching types
to the exodus file.
"""
@exodus_ii_error_check function write_set(exo::ExodusDatabase{M, I, B, F}, set::T) where {T <: AbstractSet, M, I, B, F}
  write_set_parameters(exo, set)
  error_code = @ccall libexodus.ex_put_set(
    get_file_id(exo)::Cint, entity_type(T)::ex_entity_type, set.id::Clonglong, # should be ex_entity_id
    entries(set)::Ptr{B}, extras(set)::Ptr{Union{Cvoid, B}}
  )::Cint
end

"""
"""
function write_sets(exo::ExodusDatabase, sets::Vector{T}) where T <: AbstractSet
  for set in sets
    write_set(exo, set)
  end
end

"""
"""
@exodus_ii_error_check function write_name(exo::ExodusDatabase{M, I, B, F}, ::Type{S}, set_id::Integer, name::String) where {M, I, B, F, S <: AbstractSet}
  
  if S <: Block
    exo.block_name_dict[name] = set_id
  elseif S <: NodeSet
    exo.nset_name_dict[name] = set_id
  elseif S <: SideSet
    exo.sset_name[name] = set_id
  end

  error_code = @ccall libexodus.ex_put_name(
    get_file_id(exo)::Cint, entity_type(S)::ex_entity_type, set_id::Clonglong, # should really be ex_entity_id
    name::Ptr{UInt8}
  )::Cint
end

"""
"""
@exodus_ii_error_check function write_name(exo::ExodusDatabase{M, I, B, F}, set::S, name::String) where {M, I, B, F, S <: AbstractSet}
  if S <: Block
    exo.block_name_dict[name] = set.id
  elseif S <: NodeSet
    exo.nset_name_dict[name] = set.id
  elseif S <: SideSet
    exo.sset_name_dict[name] = set.id
  end

  error_code = @ccall libexodus.ex_put_name(
    get_file_id(exo)::Cint, entity_type(S)::ex_entity_type, set.id::Clonglong, # should really be ex_entity_id
    name::Ptr{UInt8}
  )::Cint
end

"""
WARNING: this methods likely does not have good safe guards
"""
@exodus_ii_error_check function write_names(exo::ExodusDatabase, ::Type{S}, names::Vector{String}) where S <: AbstractSet
  error_code = @ccall libexodus.ex_put_names(
    get_file_id(exo)::Cint, entity_type(S)::ex_entity_type, names::Ptr{Ptr{UInt8}}
  )::Cint
end
