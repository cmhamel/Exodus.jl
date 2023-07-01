"""
Init method for block container.
"""
function Block(exo::ExodusDatabase, block_id::Integer)
  block_id = convert(get_id_int_type(exo), block_id) # for convenience interfacing
  element_type, num_elem, num_nodes, _, _, _ =
  read_element_block_parameters(exo, block_id)
  conn = read_element_block_connectivity(exo, block_id)
  conn = reshape(conn, (num_nodes, num_elem))#'
  return Block{get_id_int_type(exo), get_bulk_int_type(exo)}(block_id, num_elem, num_nodes, element_type, conn)
end
"""
"""
Base.show(io::IO, block::B) where {B <: Block} =
print(io, "Block:\n",
      "\tBlock ID       = ", block.block_id, "\n",
      "\tNum elem       = ", block.num_elem, "\n",
      "\tNum nodes per elem = ", block.num_nodes_per_elem, "\n",
      "\tElem type      = ", block.elem_type, "\n")

"""
"""
function Block(exo::ExodusDatabase, block_name::String)
  block_ids = read_element_block_ids(exo)
  name_index = findall(x -> x == block_name, read_element_block_names(exo))
  if length(name_index) > 1
    throw(ErrorException("This shoudl never happen"))
  end
  name_index = name_index[1]
  return Block(exo, block_ids[name_index])
end

# """
# default dummy constructor
# """
# function ExodusBlock()
#   return ExodusBlock(0, EX_ELEM_BLOCK, Vector{UInt8}(undef, MAX_STR_LENGTH), 0, 0, 0, 0, 0)
# end

# """
# """
# function ExodusBlock(exo::ExodusDatabase, block_id::I) where I <: Integer
#   block_id = convert(get_id_int_type(exo), block_id)
#   block = ExodusBlock()
#   ex_get_block_param!(get_file_id(exo), block)
#   return block
# end

"""
Retrieves numerical block ids.
"""
function read_element_block_ids(exo::ExodusDatabase)
  block_ids = Vector{get_id_int_type(exo)}(undef, exo.init.num_elem_blks)
  # ex_get_ids!(get_file_id(exo), EX_ELEM_BLOCK, block_ids)
  error_code = @ccall libexodus.ex_get_ids(get_file_id(exo)::Cint, EX_ELEM_BLOCK::ex_entity_type, block_ids::Ptr{void_int})::Cint
  exodus_error_check(error_code, "Exodus.read_element_block_ids -> libexodus.ex_get_ids")
  return block_ids
end

"""
"""
function read_element_block_id_map(exo::ExodusDatabase, block_id::I) where I <: Integer
  block = Block(exo, block_id)
  block_id_map = Vector{get_map_int_type(exo)}(undef, block.num_elem)
  error_code = @ccall libexodus.ex_get_block_id_map(
    get_file_id(exo)::Cint, EX_ELEM_BLOCK::ex_entity_type, block_id::ex_entity_id, block_id_map::Ptr{void_int}
  )::Cint
  exodus_error_check(error_code, "Exodus.read_element_block_id_map -> libexodus.ex_get_block_id_map")
  return block_id_map
end

"""
"""
function read_element_block_names(exo::ExodusDatabase)
  var_names = [Vector{UInt8}(undef, MAX_STR_LENGTH) for _ in 1:length(read_element_block_ids(exo))]
  # ex_get_names!(get_file_id(exo), EX_ELEM_BLOCK, var_names)
  error_code = @ccall libexodus.ex_get_names(
    get_file_id(exo)::Cint, EX_ELEM_BLOCK::ex_entity_type, var_names::Ptr{Ptr{UInt8}}
  )::Cint
  exodus_error_check(error_code, "Exodus.read_element_block_names -> libexodus.ex_get_names")
  var_names = map(x -> unsafe_string(pointer(x)), var_names)
  return var_names
end

"""
"""
function read_element_block_parameters(exo::ExodusDatabase, block_id::Integer)
  int_type       = get_id_int_type(exo)
  element_type   = Vector{UInt8}(undef, MAX_STR_LENGTH)
  num_elem       = Ref{int_type}(0)
  num_nodes      = Ref{int_type}(0)
  num_edges      = Ref{int_type}(0)
  num_faces      = Ref{int_type}(0)
  num_attributes = Ref{int_type}(0)
  error_code = @ccall libexodus.ex_get_block(
    get_file_id(exo)::Cint, EX_ELEM_BLOCK::ex_entity_type, block_id::ex_entity_id,
    element_type::Ptr{UInt8}, 
    num_elem::Ptr{void_int}, num_nodes::Ptr{void_int}, num_edges::Ptr{void_int},
    num_faces::Ptr{void_int}, num_attributes::Ptr{void_int}
  )::Cint
  exodus_error_check(error_code, "Exodus.read_element_block_parameters -> libexodus.ex_get_block")
  element_type = unsafe_string(pointer(element_type))
  return element_type, num_elem[], num_nodes[], num_edges[], num_faces[], num_attributes[]
end

"""
"""
function read_element_block_connectivity(exo::ExodusDatabase, block_id::Integer)
  _, num_elem, num_nodes, _, _, _ =
  read_element_block_parameters(exo, block_id)
  conn = Vector{get_bulk_int_type(exo)}(undef, num_nodes * num_elem)
  conn_face = Vector{get_bulk_int_type(exo)}(undef, num_nodes * num_elem)  # Not using these currently
  conn_edge = Vector{get_bulk_int_type(exo)}(undef, num_nodes * num_elem)  # Not using these currently
  error_code = @ccall libexodus.ex_get_conn(
    get_file_id(exo)::Cint, EX_ELEM_BLOCK::ex_entity_type, block_id::ex_entity_id,
    conn::Ptr{void_int}, conn_face::Ptr{void_int}, conn_edge::Ptr{void_int}
  )::Cint
  exodus_error_check(error_code, "Exodus.read_element_block_connectivity -> libexodus.ex_get_conn")
  return conn
end

"""
"""
function write_element_block_connectivity(exo::ExodusDatabase, block_id::Integer, conn::Matrix{I}) where I <: Integer
  if I != get_bulk_int_type(exo)
    conn = convert(Matrix{get_bulk_int_type(exo)}, conn)
  end
  conn = conn[:]
  # TODO currently not using face or edges, should probably be there own methods maybe?
  conn_face = C_NULL  # Not using these currently
  conn_edge = C_NULL  # Not using these currently
  error_code = @ccall libexodus.ex_put_conn(
    get_file_id(exo)::Cint, EX_ELEM_BLOCK::ex_entity_type, block_id::ex_entity_id,
    conn::Ptr{void_int}, conn_face::Ptr{void_int}, conn_edge::Ptr{void_int} 
  )::Cint
  exodus_error_check(error_code, "Exodus_write_block_connectivity -> libexodus.ex_put_conn")
end

"""
"""
function read_partial_element_block_connectivity(exo::ExodusDatabase, block_id::I, start_num::I, num_ent::I) where I <: Integer
  _, _, num_nodes, _, _, _ =
  read_element_block_parameters(exo, block_id)
  conn = Vector{get_bulk_int_type(exo)}(undef, num_nodes * num_ent)
  conn_face = Vector{get_bulk_int_type(exo)}(undef, num_nodes * num_ent)  # Not using these currently
  conn_edge = Vector{get_bulk_int_type(exo)}(undef, num_nodes * num_ent)  # Not using these currently
  error_code = @ccall libexodus.ex_get_partial_conn(
    get_file_id(exo)::Cint, EX_ELEM_BLOCK::ex_entity_type, block_id::ex_entity_id,
    start_num::Clonglong, num_ent::Clonglong,
    conn::Ptr{void_int}, conn_face::Ptr{void_int}, conn_edge::Ptr{void_int}
  )::Cint
  exodus_error_check(error_code, "Exodus.read_partial_element_block_connectivity -> libexodus.ex_get_partial_conn")
  return conn
end

"""
"""
function read_element_type(exo::ExodusDatabase, block_id::I) where I <: Integer
  element_type = Vector{UInt8}(undef, MAX_STR_LENGTH)
  error_code = @ccall libexodus.ex_get_elem_type(
    get_file_id(exo)::Cint, block_id::ex_entity_id, element_type::Ptr{UInt8}
  )::Cint
  exodus_error_check(error_code, "Exodus.read_element_type -> libexodus.ex_get_elem_type")
  return unsafe_string(pointer(element_type))
end

"""
TODO: change name to read_element_blocks!
"""
function read_element_blocks!(blocks::Vector{B}, 
                              exo::ExodusDatabase, 
                              block_ids::Vector{I}) where {B <: Block, I <: Integer}
  for (n, block_id) in enumerate(block_ids)
    blocks[n] = Block(exo, block_id)
  end
end

"""
Helper method for initializing blocks.

TODO: change name to read_element_blocks
"""
function read_element_blocks(exo::ExodusDatabase, block_ids::U) where U <: Union{<:Integer, Vector{<:Integer}}
  if typeof(block_ids) <: Integer
    block_id = convert(get_id_int_type(exo), block_id)
    block = Block(exo, block_id)
    return block
  else
    block_ids = map(x -> convert(get_id_int_type(exo), x), block_ids)
    blocks = Vector{Block{get_id_int_type(exo)}}(undef, size(block_ids, 1))
    read_element_blocks!(blocks, exo, block_ids)
    return blocks
  end
end

"""
WARNING:
currently does not support edges, faces and attributes
"""
function write_element_block(exo::ExodusDatabase, block::Block)
  error_code = @ccall libexodus.ex_put_block(
    get_file_id(exo)::Cint, EX_ELEM_BLOCK::ex_entity_type, block.block_id::ex_entity_id,
    block.elem_type::Ptr{UInt8},
    block.num_elem::Clonglong, block.num_nodes_per_elem::Clonglong,
    0::Clonglong, 0::Clonglong, 0::Clonglong
  )::Cint
  exodus_error_check(error_code, "Exodus.write_element_block -> libexodus.ex_put_block")
  write_element_block_connectivity(exo, block.block_id, block.conn)
end

"""
"""
function write_element_blocks(exo::ExodusDatabase, blocks::Vector{<:Block})
  for block in blocks
    write_element_block(exo, block)
  end
end

"""
"""
function write_element_block_name(exo::ExodusDatabase, block::Block, name::String)
  error_code = @ccall libexodus.ex_put_name(
    get_file_id(exo)::Cint, EX_ELEM_BLOCK::ex_entity_type, block.block_id::ex_entity_id,
    name::Ptr{UInt8}
  )::Cint
  exodus_error_check(error_code, "Exodus.write_element_block_name -> libexodus.ex_put_name")
end

"""
"""
function write_element_block_names(exo::ExodusDatabase, blocks::Vector{<:Block}, names::Vector{String})
  if length(blocks) != length(names)
    throw(ErrorException("unequal length vectors"))
  end
  for n in eachindex(blocks)
    write_element_block_name(exo, blocks[n], names[n])
  end
end


# local exports
export Block
# export ExodusBlock

export read_element_blocks
export read_element_block_id_map
export read_element_block_ids
export read_element_block_names
export read_element_block_connectivity
export read_element_block_parameters
export read_element_type
export read_partial_element_block_connectivity

export write_element_block
export write_element_block_connectivity
export write_element_block_name
export write_element_block_names
export write_element_blocks
