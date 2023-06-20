function ex_get_block!(
  exoid::Cint, blk_type::ex_entity_type, blk_id, #::ex_entity_id,
  entity_descrip, 
  num_entries_this_blk, num_nodes_per_entry,
  num_edges_per_entry, num_faces_per_entry,
  num_attr_per_entry
) # TODO get the types right
  error_code = ccall(
    (:ex_get_block, libexodus), Cint,
    (
      Cint, ex_entity_type, ex_entity_id,
      Ptr{UInt8}, 
      Ptr{void_int}, Ptr{void_int}, 
      Ptr{void_int}, Ptr{void_int}, 
      Ptr{void_int}
    ),
    exoid, blk_type, blk_id,
    entity_descrip, 
    num_entries_this_blk, num_nodes_per_entry, 
    num_edges_per_entry, num_faces_per_entry, 
    num_attr_per_entry
  )
  exodus_error_check(error_code, "ex_get_block!")
end

function ex_get_block_id_map!(
  exoid::Cint, obj_type::ex_entity_type, blk_id,
  blk_map
)
  error_code = ccall(
    (:ex_get_block_id_map, libexodus), Cint,
    (Cint, ex_entity_type, ex_entity_id, Ptr{void_int}),
    exoid, obj_type, blk_id, blk_map
  )
  exodus_error_check(error_code, "ex_get_block_id_map!")
end

function ex_get_conn!(
  exoid::Cint, blk_type::ex_entity_type, blk_id, #::ex_entity_id, nned to figure this out
  nodeconn, faceconn, edgeconn
) # TODO get the types right
  error_code = ccall(
    (:ex_get_conn, libexodus), Cint,
    (Cint, ex_entity_type, ex_entity_id, Ptr{void_int}, Ptr{void_int}, Ptr{void_int}),
    exoid, blk_type, blk_id, nodeconn, faceconn, edgeconn
  )
  exodus_error_check(error_code, "ex_get_conn") 
end

"""
Init method for block container.

Wraps `ex_get_block!` and `ex_get_conn!`
"""
function Block(exo::ExodusDatabase, block_id::Integer)
  block_id = convert(exo.I, block_id) # for convenience interfacing
  element_type, num_elem, num_nodes, _, _, _ =
  read_element_block_parameters(exo, block_id)
  conn = read_block_connectivity(exo, block_id)
  conn = reshape(conn, (num_nodes, num_elem))#'
  return Block{exo.I, exo.B}(block_id, num_elem, num_nodes, element_type, conn)
end
Base.show(io::IO, block::B) where {B <: Block} =
print(io, "Block:\n",
      "\tBlock ID       = ", block.block_id, "\n",
      "\tNum elem       = ", block.num_elem, "\n",
      "\tNum nodes per elem = ", block.num_nodes_per_elem, "\n",
      "\tElem type      = ", block.elem_type, "\n")

"""
"""
function Block(exo::ExodusDatabase, block_name::String)
  block_ids = read_block_ids(exo)
  name_index = findall(x -> x == block_name, read_block_names(exo))
  if length(name_index) > 1
    throw(ErrorException("This shoudl never happen"))
  end
  name_index = name_index[1]
  return Block(exo, block_ids[name_index])
end

"""
Retrieves numerical block ids.

Wraps ex_get_ids!
"""
function read_block_ids(exo::ExodusDatabase)
  block_ids = Vector{exo.I}(undef, exo.init.num_elem_blks)
  ex_get_ids!(exo.exo, EX_ELEM_BLOCK, block_ids)
  return block_ids
end

"""
"""
function read_block_id_map(exo::ExodusDatabase, block_id::I) where I <: Integer
  block = Block(exo, block_id)
  block_id_map = Vector{exo.M}(undef, block.num_elem)
  ex_get_block_id_map!(exo.exo, EX_ELEM_BLOCK, convert(exo.I, block_id), block_id_map)
  return block_id_map
end

"""
"""
function read_block_names(exo::ExodusDatabase)
  var_names = [Vector{UInt8}(undef, MAX_STR_LENGTH) for _ in 1:length(read_block_ids(exo))]
  ex_get_names!(exo.exo, EX_ELEM_BLOCK, var_names)
  var_names = map(x -> unsafe_string(pointer(x)), var_names)
  return var_names
end

"""
"""
function read_element_block_parameters(exo::ExodusDatabase, block_id::Integer)
  block_id = convert(exo.I, block_id)
  element_type   = Vector{UInt8}(undef, MAX_STR_LENGTH)
  num_elem       = Ref{exo.I}(0)
  num_nodes      = Ref{exo.I}(0)
  num_edges      = Ref{exo.I}(0)
  num_faces      = Ref{exo.I}(0)
  num_attributes = Ref{exo.I}(0)
  ex_get_block!(exo.exo, EX_ELEM_BLOCK, block_id,
                element_type,
                num_elem, num_nodes,
                num_edges, num_faces,
                num_attributes)
  element_type = unsafe_string(pointer(element_type))
  return element_type, num_elem[], num_nodes[], num_edges[], num_faces[], num_attributes[]
end

"""
"""
function read_block_connectivity(exo::ExodusDatabase, block_id::Integer)
  block_id = convert(exo.I, block_id)
  element_type, num_elem, num_nodes, num_edges, num_faces, num_attributes =
  read_element_block_parameters(exo, block_id)
  conn = Vector{exo.B}(undef, num_nodes * num_elem)
  conn_face = Vector{exo.B}(undef, num_nodes * num_elem)  # Not using these currently
  conn_edge = Vector{exo.B}(undef, num_nodes * num_elem)  # Not using these currently
  ex_get_conn!(exo.exo, EX_ELEM_BLOCK, block_id, conn, conn_face, conn_edge)
  return conn
end

"""
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
"""
function read_blocks(exo::ExodusDatabase, block_ids::U) where U <: Union{<:Integer, Vector{<:Integer}}
  if typeof(block_ids) <: Integer
    block_id = convert(exo.I, block_id)
    block = Block(exo, block_id)
    return block
  else
    block_ids = map(x -> convert(exo.I, x), block_ids)
    blocks = Vector{Block{exo.I}}(undef, size(block_ids, 1))
    read_blocks!(blocks, exo, block_ids)
    return blocks
  end
end

# local exports
export ex_get_block!
export ex_get_block_id_map!
export ex_get_conn!

export Block

export read_blocks
export read_block_id_map
export read_block_ids
export read_block_names
export read_block_connectivity
export read_element_block_parameters

