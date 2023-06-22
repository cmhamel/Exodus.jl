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
  # side_set_ids = Array{Int32}(undef, exo.init.num_side_sets)
  ex_get_ids!(get_file_id(exo), EX_SIDE_SET, side_set_ids)
  side_set_ids = convert(Vector{get_id_int_type(exo)}, side_set_ids) # hack for now
  return side_set_ids
end

"""
"""
function read_side_set_names(exo::ExodusDatabase)
  var_names = [Vector{UInt8}(undef, MAX_STR_LENGTH) for _ in 1:length(read_side_set_ids(exo))]
  ex_get_names!(get_file_id(exo), EX_SIDE_SET, var_names)
  var_names = map(x -> unsafe_string(pointer(x)), var_names)
  return var_names
end

"""
"""
function read_side_set_parameters(exo::ExodusDatabase, side_set_id::Integer)
  side_set_id = convert(get_id_int_type(exo), side_set_id)
  num_sides = Ref{get_id_int_type(exo)}(0)
  num_df = Ref{get_id_int_type(exo)}(0)
  ex_get_set_param!(get_file_id(exo), EX_SIDE_SET, side_set_id, num_sides, num_df)
  return num_sides[], num_df[]
end

"""
"""
function read_side_set_elements_and_sides(exo::ExodusDatabase, side_set_id::Integer)
  side_set_id = convert(get_id_int_type(exo), side_set_id)
  num_sides, df = read_side_set_parameters(exo, side_set_id)
  side_set_elems = Array{get_bulk_int_type(exo)}(undef, num_sides)
  side_set_sides = Array{get_bulk_int_type(exo)}(undef, num_sides)
  ex_get_set!(get_file_id(exo), EX_SIDE_SET, side_set_id, side_set_elems, side_set_sides)
  return side_set_elems, side_set_sides
end

function ex_get_side_set_node_list_len!(
  exoid::Cint, side_set_id::ex_entity_id,
  side_set_node_list_len # TODO add type
)
  error_code = ccall(
    (:ex_get_side_set_node_list_len, libexodus), Cint,
    (Cint, ex_entity_id, Ptr{Cint}),
    exoid, side_set_id, side_set_node_list_len
  )
  exodus_error_check(error_code, "ex_get_side_set_node_list_len!")
end

function ex_get_side_set_node_list!(
  exoid::Cint, side_set_id::ex_entity_id,
  side_set_node_cnt_list::Vector{B}, side_set_node_list::Vector{B}
) where {B <: Integer}
  error_code = ccall(
    (:ex_get_side_set_node_list, libexodus), Cint,
    (Cint, ex_entity_id, Ptr{void_int}, Ptr{void_int}),
    exoid, side_set_id, side_set_node_cnt_list, side_set_node_list
  )
  exodus_error_check(error_code, "ex_get_side_set_node_list!")
end

"""
"""
function read_side_set_node_list(exo::ExodusDatabase, side_set_id::Integer)
  side_set_node_list_len = Ref{Cint}(0)
  ex_get_side_set_node_list_len!(get_file_id(exo), side_set_id, side_set_node_list_len)
  side_set_id = convert(get_id_int_type(exo), side_set_id)
  num_sides, _ = read_side_set_parameters(exo, side_set_id)
  side_set_node_cnt_list = Vector{get_bulk_int_type(exo)}(undef, num_sides)
  # side_set_node_list = Vector{get_bulk_int_type(exo)}(undef, num_sides * 21) # the 21 here assumes no distribution factors are stored. This is probably not general enough
  side_set_node_list = Vector{get_bulk_int_type(exo)}(undef, side_set_node_list_len[]) # the 21 here assumes no distribution factors are stored. This is probably not general enough
  ex_get_side_set_node_list!(
    get_file_id(exo), convert(Int64, side_set_id), 
    side_set_node_cnt_list, side_set_node_list
  )
  return side_set_node_cnt_list, side_set_node_list
end

# local exports
export ex_get_side_set_node_list!
export ex_get_side_set_node_list_len!

export read_side_set_ids
export read_side_set_names
export read_side_set_parameters
export read_side_set_elements_and_sides
export read_side_set_node_list
