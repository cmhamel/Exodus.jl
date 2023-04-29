function ex_get_block!(exoid::Cint, blk_type::ex_entity_type, blk_id, #::ex_entity_id,
            entity_descrip, 
            num_entries_this_blk, num_nodes_per_entry,
            num_edges_per_entry, num_faces_per_entry,
            num_attr_per_entry) # TODO get the types right
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

function ex_get_conn!(exoid::Cint, blk_type::ex_entity_type, blk_id, #::ex_entity_id, nned to figure this out
            nodeconn, faceconn, edgeconn) # TODO get the types right
  error_code = ccall(
    (:ex_get_conn, libexodus), Cint,
    (Cint, ex_entity_type, ex_entity_id, Ptr{void_int}, Ptr{void_int}, Ptr{void_int}),
    exoid, blk_type, blk_id, nodeconn, faceconn, edgeconn
  )
  exodus_error_check(error_code, "ex_get_conn") 
end

"""
  Block(exo::ExodusDatabase, block_id::I)
Init method for block container.

Wraps `ex_get_block!` and `ex_get_conn!`
"""
function Block(exo::ExodusDatabase{M, I, B, F}, block_id::I) where {M <: Integer, I <: Integer,
                                                                    B <: Integer, F <: Real}
  element_type, num_elem, num_nodes, _, _, _ =
  read_element_block_parameters(exo, block_id)
  conn = read_block_connectivity(exo, block_id)
  return Block{I, B}(block_id, num_elem, num_nodes, element_type, conn)
end
Base.show(io::IO, block::B) where {B <: Block} =
print(io, "Block:\n",
      "\tBlock ID       = ", block.block_id, "\n",
      "\tNum elem       = ", block.num_elem, "\n",
      "\tNum nodes per elem = ", block.num_nodes_per_elem, "\n",
      "\tElem type      = ", block.elem_type, "\n")

"""
  read_block_ids(exo::ExodusDatabase, init::Initialization)
Retrieves numerical block ids.

Wraps ex_get_ids!
"""
function read_block_ids(exo::ExodusDatabase{M, I, B, F}, 
                        init::Initialization) where {M <: Integer, I <: Integer, 
                                                     B <: Integer, F <: Real}
  block_ids = Vector{I}(undef, init.num_elem_blks)
  ex_get_ids!(exo.exo, EX_ELEM_BLOCK, block_ids)
  return block_ids
end

function read_element_block_parameters(exo::ExodusDatabase{M, I, B, F}, 
                                       block_id::I) where {M <: Integer, I <: Integer,
                                                           B <: Integer, F <: Real}
  element_type   = Vector{UInt8}(undef, MAX_STR_LENGTH)
  num_elem     = Ref{I}(0)
  num_nodes    = Ref{I}(0)
  num_edges    = Ref{I}(0)
  num_faces    = Ref{I}(0)
  num_attributes = Ref{I}(0)
  ex_get_block!(exo.exo, EX_ELEM_BLOCK, block_id,
                element_type,
                num_elem, num_nodes,
                num_edges, num_faces,
                num_attributes)
  element_type = unsafe_string(pointer(element_type))
  return element_type, num_elem[], num_nodes[], num_edges[], num_faces[], num_attributes[]
end

function read_block_connectivity(exo::ExodusDatabase{M, I, B, F}, 
                                 block_id::I) where {M <: Integer, I <: Integer,
                                                     B <: Integer, F <: Real}
  element_type, num_elem, num_nodes, num_edges, num_faces, num_attributes =
  read_element_block_parameters(exo, block_id)
  conn = Vector{I}(undef, num_nodes * num_elem)
  conn_face = Vector{I}(undef, num_nodes * num_elem)  # Not using these currently
  conn_edge = Vector{I}(undef, num_nodes * num_elem)  # Not using these currently
  ex_get_conn!(exo.exo, EX_ELEM_BLOCK, block_id, conn, conn_face, conn_edge)
  return conn
end

function read_blocks!(blocks::Vector{B}, 
                      exo::ExodusDatabase, 
                      block_ids::Vector{I}) where {B <: Block, I <: Integer}
  for (n, block_id) in enumerate(block_ids)
    blocks[n] = Block(exo, block_id)
  end
end

"""
  read_blocks(exo::ExodusDatabase, block_ids::Vector{I})
Helper method for initializing blocks.
"""
function read_blocks(exo::ExodusDatabase{M, I, B, F}, 
                     block_ids::Vector{I}) where {M <: Integer, I <: Integer,
                                                  B <: Integer, F <: Real}
  blocks = Vector{Block{I}}(undef, size(block_ids, 1))
  read_blocks!(blocks, exo, block_ids)
  return blocks
end

# local exports
export read_blocks
export read_block_ids
