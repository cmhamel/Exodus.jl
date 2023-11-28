"""
# TODO do this one later... it depends on a few things
"""
function read_block_id_map(exo::ExodusDatabase, block_id::I) where I <: Integer
  # block = Block(exo, block_id)
  # block_id_map = Vector{get_map_int_type(exo)}(undef, block.num_elem)
  _, num_elem, _, _, _, _ = read_block_parameters(exo, block_id)
  block_id_map = exo.cache_M
  # resize!(block_id_map, exo.init.num_elem_blks)
  resize!(block_id_map, num_elem)

  if !exo.use_cache_arrays
    block_id_map = copy(block_id_map)
  end

  error_code = @ccall libexodus.ex_get_block_id_map(
    get_file_id(exo)::Cint, EX_ELEM_BLOCK::ex_entity_type, block_id::ex_entity_id, block_id_map::Ptr{void_int}
  )::Cint
  exodus_error_check(error_code, "Exodus.read_element_block_id_map -> libexodus.ex_get_block_id_map")
  return block_id_map
end

"""
"""
function read_block_parameters(exo::ExodusDatabase{M, I, B, F}, block_id::Integer) where {M, I, B, F}
  num_elem       = Ref{B}(0)
  num_nodes      = Ref{B}(0)
  num_edges      = Ref{B}(0)
  num_faces      = Ref{B}(0)
  num_attributes = Ref{B}(0)

  element_type = Vector{UInt8}(undef, MAX_STR_LENGTH)

  error_code = @ccall libexodus.ex_get_block(
    get_file_id(exo)::Cint, EX_ELEM_BLOCK::ex_entity_type, block_id::ex_entity_id,
    element_type::Ptr{UInt8}, 
    num_elem::Ptr{B}, num_nodes::Ptr{B}, num_edges::Ptr{B},
    num_faces::Ptr{B}, num_attributes::Ptr{B}
  )::Cint
  exodus_error_check(error_code, "Exodus.read_element_block_parameters -> libexodus.ex_get_block")
  element_type_out = unsafe_string(pointer(element_type))
  return element_type_out, num_elem[], num_nodes[], num_edges[], num_faces[], num_attributes[]
end

"""
"""
function read_block_connectivity(exo::ExodusDatabase{M, I, B, F}, block_id::Integer, conn_length::Integer) where {M, I, B, F}
  conn = exo.cache_B_1
  resize!(conn, conn_length)

  error_code = @ccall libexodus.ex_get_conn(
    get_file_id(exo)::Cint, EX_ELEM_BLOCK::ex_entity_type, block_id::ex_entity_id,
    conn::Ptr{B}, C_NULL::Ptr{Cvoid}, C_NULL::Ptr{Cvoid}
  )::Cint
  exodus_error_check(error_code, "Exodus.read_element_block_connectivity -> libexodus.ex_get_conn")
  return conn
end

"""
"""
function write_block_connectivity(exo::ExodusDatabase, block_id::Integer, conn::Matrix{I}) where I <: Integer
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
function read_partial_block_connectivity(exo::ExodusDatabase, block_id::I, start_num::I, num_ent::I) where I <: Integer
  _, _, num_nodes, _, _, _ =
  read_block_parameters(exo, block_id)
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
"""
read_block(exo::ExodusDatabase, block_id::Integer) = Block(exo, block_id)

"""
"""
read_block(exo::ExodusDatabase, block_name::String) = Block(exo, block_name)

"""
TODO: change name to read_element_blocks!
"""
function read_blocks!(blocks::Vector{B}, 
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
function read_blocks(exo::ExodusDatabase, block_ids::U) where U <: Union{<:Integer, Vector{<:Integer}}
  if typeof(block_ids) <: Integer
    block_ids = convert(get_id_int_type(exo), block_ids)
    block = Block(exo, block_ids)
    return block
  else
    block_ids = map(x -> convert(get_id_int_type(exo), x), block_ids)
    blocks = Vector{Block{get_id_int_type(exo)}}(undef, size(block_ids, 1))
    read_blocks!(blocks, exo, block_ids)
    return blocks
  end
end

"""
WARNING:
currently does not support edges, faces and attributes
"""
function write_block(exo::ExodusDatabase, block::Block)
  error_code = @ccall libexodus.ex_put_block(
    get_file_id(exo)::Cint, EX_ELEM_BLOCK::ex_entity_type, block.id::ex_entity_id,
    block.elem_type::Ptr{UInt8},
    block.num_elem::Clonglong, block.num_nodes_per_elem::Clonglong,
    0::Clonglong, 0::Clonglong, 0::Clonglong
  )::Cint
  exodus_error_check(error_code, "Exodus.write_element_block -> libexodus.ex_put_block")
  write_block_connectivity(exo, block.id, block.conn)
end

function write_block(exo::ExodusDatabase, block_id::Integer, elem_type::String, conn::Matrix{I}) where I <: Integer
  num_nodes_per_elem, num_elem = size(conn)
  elem_type = uppercase(elem_type)
  error_code = @ccall libexodus.ex_put_block(
    get_file_id(exo)::Cint, EX_ELEM_BLOCK::ex_entity_type, block_id::ex_entity_id,
    elem_type::Ptr{UInt8},
    num_elem::Clonglong, num_nodes_per_elem::Clonglong,
    0::Clonglong, 0::Clonglong, 0::Clonglong
  )::Cint
  exodus_error_check(error_code, "Exodus.write_element_block -> libexodus.ex_put_block")
  write_block_connectivity(exo, block_id, conn)
end

"""
"""
function write_blocks(exo::ExodusDatabase, blocks::Vector{<:Block})
  for block in blocks
    write_block(exo, block)
  end
end

# # some tools below
# """
# TODO reduce allocations and check for type instabilities
# """
# function collect_block_connectivities(exo::ExodusDatabase, block_ids::Vector{<:Integer})
#   blocks = Block.((exo,), block_ids)
#   conns = [block.conn for block in blocks]
#   return mapreduce(permutedims, vcat, conns)' |> collect
# end

# """
# """
# collect_block_connectivities(exo::ExodusDatabase) = 
# collect_block_connectivities(exo, read_ids(exo, Block))
