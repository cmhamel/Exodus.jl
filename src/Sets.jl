"""
"""
abstract type AbstractSet{I, B} end

"""
"""
struct NodeSet{I, B} <: AbstractSet{I, B}
  id::I
  nodes::Vector{B}
end
"""
"""
entries(n::NodeSet) = n.nodes
"""
"""
extras(n::NodeSet) = C_NULL
"""
"""
Base.length(n::NodeSet) = length(n.nodes)
"""
"""
Base.show(io::IO, node_set::NodeSet) =
print(
  io, "NodeSet:\n",
  "\tNode set ID     = ", node_set.id,      "\n",
  "\tNumber of nodes = ", node_set.nodes, "\n"
)

"""
"""
function NodeSet(exo::ExodusDatabase{M, I, B, F}, id::Integer) where {M, I, B, F}
  nodes = read_node_set_nodes(exo, id)
  return NodeSet{I, B}(id, nodes)
end

"""
"""
function NodeSet(exo::ExodusDatabase, name::String)
  ids = read_node_set_ids(exo)
  name_index = findall(x -> x == name, read_node_set_names(exo))
  if length(name_index) > 1
    throw(BoundsError(read_node_set_names(exo), name_index))
  end
  name_index = name_index[1]
  return NodeSet(exo, ids[name_index])
end

"""
"""
struct SideSet{I, B} <: AbstractSet{I, B}
  id::I
  elements::Vector{B}
  sides::Vector{B}
end
"""
"""
entries(s::SideSet) = s.elements
"""
"""
extras(s::SideSet) = s.sides
"""
"""
Base.length(s::SideSet) = length(s.elements)
"""
"""
Base.show(io::IO, sset::SideSet) = 
print(
  io, "SideSet:\n",
  "\tSide set ID        = ", sset.id,               "\n",
  "\tNumber of elements = ", length(sset.elements), "\n",
  "\tNumber of sides    = ", length(sset.sides),    "\n"
)

"""
"""
function SideSet(exo::ExodusDatabase{M, I, B, F}, id::Integer) where {M, I, B, F}
  elements, sides = read_side_set_elements_and_sides(exo, id)
  return SideSet{I, B}(id, elements, sides)
end

"""
"""
function SideSet(exo::ExodusDatabase, name::String)
  ids = read_side_set_ids(exo)
  name_index = findall(x -> x == name, read_side_set_names(exo))
  if length(name_index) > 1
    throw(BoundsError(read_side_set_names(exo), name_index))
  end
  name_index = name_index[1]
  return SideSet(exo, ids[name_index])
end

"""
"""
function read_set_ids(exo::ExodusDatabase{M, I, B, F}, type::ex_entity_type) where {M, I, B, F}
  if type == EX_NODE_SET
    num_entries = exo.init.num_node_sets
  elseif type == EX_SIDE_SET
    num_entries = exo.init.num_side_sets
  end
  ids = Vector{B}(undef, num_entries)
  error_code = @ccall libexodus.ex_get_ids(
    get_file_id(exo)::Cint, type::ex_entity_type, ids::Ptr{B}
  )::Cint
  exodus_error_check(error_code, "Exodus.read_set_ids -> libexodus.ex_get_ids")
  return ids
end

"""
"""
read_node_set_ids(exo::ExodusDatabase) = read_set_ids(exo, EX_NODE_SET)
"""
"""
read_side_set_ids(exo::ExodusDatabase) = read_set_ids(exo, EX_SIDE_SET)


"""
"""
function read_set_names(exo::ExodusDatabase, type::ex_entity_type)
  names = [Vector{UInt8}(undef, MAX_STR_LENGTH) for _ in 1:length(read_set_ids(exo, type))]
  error_code = @ccall libexodus.ex_get_names(
    get_file_id(exo)::Cint, type::ex_entity_type, names::Ptr{Ptr{UInt8}}
  )::Cint
  exodus_error_check(error_code, "Exodus.read_set_names -> libexodus.ex_get_names")
  new_names = map(x -> unsafe_string(pointer(x)), names)
  return new_names
end

"""
"""
read_node_set_names(exo::ExodusDatabase) = read_set_names(exo, EX_NODE_SET)

"""
"""
read_side_set_names(exo::ExodusDatabase) = read_set_names(exo, EX_SIDE_SET)

"""
"""
function read_set_parameters(exo::ExodusDatabase{M, I, B, F}, set_id::Integer, type::ex_entity_type) where {M, I, B, F}
  num_entries = Ref{I}(0)
  num_df = Ref{I}(0)
  error_code = @ccall libexodus.ex_get_set_param(
    get_file_id(exo)::Cint, type::ex_entity_type, set_id::Clonglong, # set_id is really an ex_entity_id but that is weirdly causing a type instability
    num_entries::Ptr{I}, num_df::Ptr{I}
  )::Cint
  exodus_error_check(error_code, "Exodus.read_set_parameters -> libexodus.ex_get_set_param")
  return num_entries[], num_df[]
end

"""
"""
read_node_set_parameters(exo::ExodusDatabase, set_id::Integer) = read_set_parameters(exo, set_id, EX_NODE_SET)

"""
"""
read_side_set_parameters(exo::ExodusDatabase, set_id::Integer) = read_set_parameters(exo, set_id, EX_SIDE_SET)

# """
# """
# function read_set(exo::ExodusDatabase{M, I, B, F}, set_id::Integer, type::Val{EX_NODE_SET}) where {M, I, B, F}
#   num_entries, _ = read_set_parameters(exo, set_id, type)
#   entries = Vector{B}(undef, num_entries)
#   extras = C_NULL
#     error_code = @ccall libexodus.ex_get_set(
#     get_file_id(exo)::Cint, type::ex_entity_type, set_id::Clonglong, # set id is really a ex_entity_id but it's weirldy throwing a type instability
#     entries::Ptr{B}, extras::Ptr{Cvoid}
#   )::Cint
#   exodus_error_check(error_code, "Exodus.read_node_set_nodes -> libexodus.ex_get_set")
#   return entries
# end

"""
"""
function read_node_set_nodes(exo::ExodusDatabase{M, I, B, F}, set_id::Integer) where {M, I, B, F}
  num_entries, _ = read_set_parameters(exo, set_id, EX_NODE_SET)
  entries = Vector{B}(undef, num_entries)
  extras = C_NULL
    error_code = @ccall libexodus.ex_get_set(
    get_file_id(exo)::Cint, EX_NODE_SET::ex_entity_type, set_id::Clonglong, # set id is really a ex_entity_id but it's weirldy throwing a type instability
    entries::Ptr{B}, extras::Ptr{Cvoid}
  )::Cint
  exodus_error_check(error_code, "Exodus.read_node_set_nodes -> libexodus.ex_get_set")
  return entries
end

"""
"""
function read_side_set_elements_and_sides(exo::ExodusDatabase{M, I, B, F}, set_id::Integer) where {M, I, B, F}
  num_entries, _ = read_set_parameters(exo, set_id, EX_SIDE_SET)
  entries = Vector{B}(undef, num_entries)
  extras = Vector{B}(undef, num_entries)
    error_code = @ccall libexodus.ex_get_set(
    get_file_id(exo)::Cint, EX_SIDE_SET::ex_entity_type, set_id::Clonglong, # set id is really a ex_entity_id but it's weirldy throwing a type instability
    entries::Ptr{B}, extras::Ptr{B}
  )::Cint
  exodus_error_check(error_code, "Exodus.read_side_set_elements_and_sides -> libexodus.ex_get_set")
  return entries, extras
end

"""
"""
function read_side_set_node_list(exo::ExodusDatabase{M, I, B, F}, side_set_id::Integer) where {M, I, B, F}
  side_set_node_list_len = Ref{Cint}(0)
  error_code = @ccall libexodus.ex_get_side_set_node_list_len(
    get_file_id(exo)::Cint, side_set_id::Clonglong, side_set_node_list_len::Ptr{Cint} # side_set-Id should really be ex_entity_id but it's weirdly causing a type instability
  )::Cint
  exodus_error_check(error_code, "Exodus.read_side_set_node_list -> libexodus.ex_get_side_set_node_list_len")
  num_sides, _ = read_side_set_parameters(exo, side_set_id)
  side_set_node_cnt_list = Vector{B}(undef, num_sides)
  side_set_node_list = Vector{B}(undef, side_set_node_list_len[])
  error_code = @ccall libexodus.ex_get_side_set_node_list(
    get_file_id(exo)::Cint, side_set_id::Clonglong, # should really be ex_entity_id but it's weirdly causing a type instability
    side_set_node_cnt_list::Ptr{B}, side_set_node_list::Ptr{B}
  )::Cint
  exodus_error_check(error_code, "Exodus.read_side_set_node_list -> libexodus.ex_get_side_set_node_list")
  return side_set_node_cnt_list, side_set_node_list
end

"""
"""
function read_sets!(sets::Vector{T}, exo::ExodusDatabase, set_ids::Vector{I}) where {I <: Integer, T <: AbstractSet}
  for n in eachindex(sets)
    sets[n] = T(exo, set_ids[n])
  end
end

"""
"""
function read_sets(exo::ExodusDatabase, set_ids::Vector{I}, type::Type{T}) where {I <: Integer, T <: AbstractSet}
  sets = Vector{type}(undef, length(set_ids))
  read_sets!(sets, exo, set_ids)
  return sets
end

"""
"""
read_node_sets(exo::ExodusDatabase, set_ids::Vector{<:Integer}) = read_sets(exo, set_ids, NodeSet)
"""
"""
read_side_sets(exo::ExodusDatabase, set_ids::Vector{<:Integer}) = read_sets(exo, set_ids, SideSet)

"""
WARNING:
currently doesn't support distance factors
"""
function write_set_parameters(exo::ExodusDatabase{M, I, B, F}, set::T) where {M, I, B, F, T <: AbstractSet}
  num_dist_fact_in_set = 0 # TODO not using distance 
  if T == NodeSet{I, B}
    type = EX_NODE_SET
  elseif T == SideSet{I, B}
    type = EX_SIDE_SET
  else
    throw(ErrorException("Incompatable ExodusDatabase and AbstractSet types"))
  end
  error_code = @ccall libexodus.ex_put_set_param(
    get_file_id(exo)::Cint, type::ex_entity_type, set.id::Clonglong, # should be ex_entity_id
    length(set)::Clonglong, num_dist_fact_in_set::Clonglong
  )::Cint
  exodus_error_check(error_code, "Exodus.write_node_set_parameters -> libexodus.ex_put_set_param")
end

"""
Typing ensures we don't write a set with non-matching types
to the exodus file.
"""
function write_set(exo::ExodusDatabase{M, I, B, F}, set::T) where {T <: AbstractSet, M, I, B, F}
  if T == NodeSet{I, B}
    type = EX_NODE_SET
  elseif T == SideSet{I, B}
    type = EX_SIDE_SET
  else
    throw(ErrorException("Incompatable ExodusDatabase and AbstractSet types"))
  end
  write_set_parameters(exo, set)
  error_code = @ccall libexodus.ex_put_set(
    get_file_id(exo)::Cint, type::ex_entity_type, set.id::Clonglong, # should be ex_entity_id
    entries(set)::Ptr{B}, extras(set)::Ptr{Union{Cvoid, B}}
  )::Cint
  exodus_error_check(error_code, "Exodus.write_set -> libexodus.ex_put_set")
end

"""
"""
write_node_set(exo::ExodusDatabase, set::NodeSet) = write_set(exo, set)

"""
"""
write_side_set(exo::ExodusDatabase, set::SideSet) = write_set(exo, set)

"""
"""
function write_sets(exo::ExodusDatabase, sets::Vector{T}) where T <: AbstractSet
  for set in sets
    write_set(exo, set)
  end
end

"""
"""
write_node_sets(exo::ExodusDatabase, sets::Vector{NodeSet}) = write_sets(exo, sets)

"""
"""
write_side_sets(exo::ExodusDatabase, sets::Vector{SideSet}) = write_sets(exo, sets)

"""
"""
function write_set_name(exo::ExodusDatabase{M, I, B, F}, set::T, name::String) where {M, I, B, F, T <: AbstractSet}
  if T == NodeSet{I, B}
    type = EX_NODE_SET
  elseif T == SideSet{I, B}
    type = EX_SIDE_SET
  end
  error_code = @ccall libexodus.ex_put_name(
    get_file_id(exo)::Cint, type::ex_entity_type, set.id::Clonglong, # should really be ex_entity_id
    name::Ptr{UInt8}
  )::Cint
  exodus_error_check(error_code, "Exodus.write_set_name -> libexodus.ex_put_name")
end

"""
"""
write_node_set_name(exo::ExodusDatabase, set::NodeSet, name::String) = write_set_name(exo, set, name)

"""
"""
write_side_set_name(exo::ExodusDatabase, set::SideSet, name::String) = write_set_name(exo, set, name)

"""
"""
function write_set_names(exo::ExodusDatabase, names::Vector{String}, type::ex_entity_type)
  error_code = @ccall libexodus.ex_put_names(
    get_file_id(exo)::Cint, type::ex_entity_type, names::Ptr{Ptr{UInt8}}
  )::Cint
  exodus_error_check(error_code, "Exodus.write_set_names -> libexodus.ex_put_names")
end

"""
"""
write_node_set_names(exo::ExodusDatabase, names::Vector{String}) = write_set_names(exo, names, EX_NODE_SET)

"""
"""
write_side_set_names(exo::ExodusDatabase, names::Vector{String}) = write_set_names(exo, names, EX_SIDE_SET)
