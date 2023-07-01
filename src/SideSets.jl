"""
"""
function SideSet(exo::ExodusDatabase, side_set_id)
  side_set_elems, side_set_sides = read_side_set_elements_and_sides(exo, side_set_id)
  return SideSet{get_id_int_type(exo), get_bulk_int_type(exo)}(side_set_id, length(side_set_elems), side_set_elems, side_set_sides)
end

"""
"""
function SideSet(exo::ExodusDatabase, sset_name::String)
  sset_ids = read_side_set_ids(exo)
  name_index = findall(x -> x == sset_name, read_side_set_names(exo))
  if length(name_index) > 1
    throw(ErrorException("This shoudl never happen"))
  end
  name_index = name_index[1]
  return SideSet(exo, sset_ids[name_index])
end

"""
"""
Base.length(sset::SideSet) = length(sset.num_elements)

"""
"""
Base.show(io::IO, sset::SideSet) = 
print(io, "SideSet:\n",
      "\tSide set ID        = ", sset.num_elements, "\n",
      "\tNumber of elements = ", sset.num_elements, "\n"
)

"""
"""
function read_side_set_ids(exo::ExodusDatabase)
  side_set_ids = Array{get_id_int_type(exo)}(undef, exo.init.num_side_sets)
  error_code = @ccall libexodus.ex_get_ids(
    get_file_id(exo)::Cint, EX_SIDE_SET::ex_entity_type, side_set_ids::Ptr{void_int}
  )::Cint
  exodus_error_check(error_code, "Exodus.read_side_set_ids -> libexodus.ex_get_ids")
  side_set_ids = convert(Vector{get_id_int_type(exo)}, side_set_ids) # hack for now
  return side_set_ids
end

"""
"""
function read_side_set_names(exo::ExodusDatabase)
  var_names = [Vector{UInt8}(undef, MAX_STR_LENGTH) for _ in 1:length(read_side_set_ids(exo))]
  error_code = @ccall libexodus.ex_get_names(
    get_file_id(exo)::Cint, EX_SIDE_SET::ex_entity_type, var_names::Ptr{Ptr{UInt8}}
  )::Cint
  exodus_error_check(error_code, "Exodus.read_side_set_names -> libexodus.ex_get_names")
  var_names = map(x -> unsafe_string(pointer(x)), var_names)
  return var_names
end

"""
"""
function read_side_set_parameters(exo::ExodusDatabase, side_set_id::Integer)
  side_set_id = convert(get_id_int_type(exo), side_set_id)
  num_sides = Ref{get_id_int_type(exo)}(0)
  num_df = Ref{get_id_int_type(exo)}(0)
  error_code = @ccall libexodus.ex_get_set_param(
    get_file_id(exo)::Cint, EX_SIDE_SET::ex_entity_type, side_set_id::ex_entity_id,
    num_sides::Ptr{void_int}, num_df::Ptr{void_int}
  )::Cint
  exodus_error_check(error_code, "Exodus.read_side_set_parameters -> libexodus.ex_get_set_param")
  return num_sides[], num_df[]
end

"""
"""
function read_side_set_elements_and_sides(exo::ExodusDatabase, side_set_id::Integer)
  side_set_id = convert(get_id_int_type(exo), side_set_id)
  num_sides, _ = read_side_set_parameters(exo, side_set_id)
  side_set_elems = Array{get_bulk_int_type(exo)}(undef, num_sides)
  side_set_sides = Array{get_bulk_int_type(exo)}(undef, num_sides)
  error_code = @ccall libexodus.ex_get_set(
    get_file_id(exo)::Cint, EX_SIDE_SET::ex_entity_type, side_set_id::ex_entity_id,
    side_set_elems::Ptr{void_int}, side_set_sides::Ptr{void_int}
  )::Cint
  exodus_error_check(error_code, "Exodus.read_side_set_elements_and_sides -> libexodus.ex_get_set")
  return side_set_elems, side_set_sides
end

"""
"""
function read_side_set_node_list(exo::ExodusDatabase, side_set_id::Integer)
  side_set_node_list_len = Ref{Cint}(0)
  error_code = @ccall libexodus.ex_get_side_set_node_list_len(
    get_file_id(exo)::Cint, side_set_id::ex_entity_id, side_set_node_list_len::Ptr{Cint}
  )::Cint
  exodus_error_check(error_code, "Exodus.read_side_set_node_list -> libexodus.ex_get_side_set_node_list_len")
  side_set_id = convert(get_id_int_type(exo), side_set_id)
  num_sides, _ = read_side_set_parameters(exo, side_set_id)
  side_set_node_cnt_list = Vector{get_bulk_int_type(exo)}(undef, num_sides)
  # side_set_node_list = Vector{get_bulk_int_type(exo)}(undef, num_sides * 21) # the 21 here assumes no distribution factors are stored. This is probably not general enough
  side_set_node_list = Vector{get_bulk_int_type(exo)}(undef, side_set_node_list_len[])
  error_code = @ccall libexodus.ex_get_side_set_node_list(
    get_file_id(exo)::Cint, side_set_id::ex_entity_id,
    side_set_node_cnt_list::Ptr{void_int}, side_set_node_list::Ptr{void_int}
  )::Cint
  exodus_error_check(error_code, "Exodus.read_side_set_node_list -> libexodus.ex_get_side_set_node_list")
  return side_set_node_cnt_list, side_set_node_list
end

"""
"""
function read_side_sets!(
  side_sets::Vector{SideSet}, 
  exo::ExodusDatabase, side_set_ids::Vector{<:Integer}
)
  for (n, side_set_id) in enumerate(side_set_ids)
    side_sets[n] = SideSet(exo, side_set_id)
  end
end

"""
"""
function read_side_sets(exo::ExodusDatabase, side_set_ids::Array{<:Integer})
  side_set_ids = convert(Vector{get_id_int_type(exo)}, side_set_ids)
  side_sets = Vector{SideSet}(undef, size(side_set_ids, 1))
  read_side_sets!(side_sets, exo, side_set_ids)
  return side_sets
end

"""
WARNING:
currently doesn't support distance factors
"""
function write_side_set_parameters(exo::ExodusDatabase, sset::SideSet)
  num_dist_fact_in_set = 0 # TODO not using distance 
  error_code = @ccall libexodus.ex_put_set_param(
    get_file_id(exo)::Cint, EX_SIDE_SET::ex_entity_type, sset.side_set_id::ex_entity_id,
    sset.num_elements::Clonglong, num_dist_fact_in_set::Clonglong
  )::Cint
  exodus_error_check(error_code, "Exodus.write_side_set_parameters -> libexodus.ex_put_set_param")
end

"""
WARNING:
currently doesn't support distance factors
"""
function write_side_set(exo::ExodusDatabase, sset::SideSet)
  elements = convert(Vector{get_bulk_int_type(exo)}, sset.elements)
  sides    = convert(Vector{get_bulk_int_type(exo)}, sset.sides)
  write_side_set_parameters(exo, sset)
  error_code = @ccall libexodus.ex_put_set(
    get_file_id(exo)::Cint, EX_SIDE_SET::ex_entity_type, sset.side_set_id::ex_entity_id,
    elements::Ptr{void_int}, sides::Ptr{void_int}
  )::Cint
  exodus_error_check(error_code, "Exodus.write_side_set -> libexodus.ex_put_set")
end

"""
WARNING:
currently doesn't support distance factors
"""
function write_side_sets(exo::ExodusDatabase, ssets::Vector{SideSet})
  for sset in ssets
    write_side_set(exo, sset)
  end
end

# local exports
export read_side_set_ids
export read_side_set_names
export read_side_set_parameters
export read_side_set_elements_and_sides
export read_side_set_node_list
export read_side_sets

export write_side_set
export write_side_sets
