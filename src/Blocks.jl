"""
    Block{I <: ExoInt, B <: ExoInt}
Container for reading in blocks
"""
struct Block{I <: ExoInt, B <: ExoInt} # maybe don't need M?
    block_id::I
    num_elem::Clonglong
    num_nodes_per_elem::Clonglong
    elem_type::String # TODO maybe just make an index
    conn::Array{B} # TODO look into what they mean by "BULK data"
end

"""
    Block(exo::ExodusDatabase{M, I, B, F}, block_id::I) where {M <: ExoInt, I <: ExoInt,
                                                               B <: ExoInt, F <: ExoFloat}
Init method for block container.
"""
function Block(exo::ExodusDatabase{M, I, B, F}, block_id::I) where {M <: ExoInt, I <: ExoInt,
                                                                    B <: ExoInt, F <: ExoFloat}
    element_type, num_elem, num_nodes, _, _, _ =
    read_element_block_parameters(exo, block_id)
    conn = read_block_connectivity(exo, block_id)
    return Block{I, B}(block_id, num_elem, num_nodes, element_type, conn)
end
Base.show(io::IO, block::Block{I, B}) where {I <: ExoInt, B <: ExoInt} =
print(io, "Block:\n",
          "\tBlock ID           = ", block.block_id, "\n",
          "\tNum elem           = ", block.num_elem, "\n",
          "\tNum nodes per elem = ", block.num_nodes_per_elem, "\n",
          "\tElem type          = ", block.elem_type, "\n")

"""
    read_block_ids(exo::ExodusDatabase{M, I, B, F}, 
                   init::Initialization) where {M <: ExoInt, I <: ExoInt, 
                                                B <: ExoInt, F <: ExoFloat}
Retrieves numerical block ids.
"""
function read_block_ids(exo::ExodusDatabase{M, I, B, F}, 
                        init::Initialization) where {M <: ExoInt, I <: ExoInt, 
                                                     B <: ExoInt, F <: ExoFloat}
    block_ids = Vector{I}(undef, init.num_elem_blks)
    ex_get_ids!(exo.exo, EX_ELEM_BLOCK, block_ids)
    return block_ids
end

function read_element_block_parameters(exo::ExodusDatabase{M, I, B, F}, 
                                       block_id::I) where {M <: ExoInt, I <: ExoInt,
                                                           B <: ExoInt, F <: ExoFloat}
    element_type   = Vector{UInt8}(undef, MAX_STR_LENGTH)
    num_elem       = Ref{I}(0)
    num_nodes      = Ref{I}(0)
    num_edges      = Ref{I}(0)
    num_faces      = Ref{I}(0)
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
                                 block_id::I) where {M <: ExoInt, I <: ExoInt,
                                                     B <: ExoInt, F <: ExoFloat}
    element_type, num_elem, num_nodes, num_edges, num_faces, num_attributes =
    read_element_block_parameters(exo, block_id)
    conn = Vector{I}(undef, num_nodes * num_elem)
    conn_face = Vector{I}(undef, num_nodes * num_elem)  # Not using these currently
    conn_edge = Vector{I}(undef, num_nodes * num_elem)  # Not using these currently
    ex_get_conn!(exo.exo, EX_ELEM_BLOCK, block_id, conn, conn_face, conn_edge)
    return conn
end

function read_blocks!(blocks::Vector{Block{I}}, 
                      exo::ExodusDatabase{M, I, B, F}, 
                      block_ids::Vector{I}) where {M <: ExoInt, I <: ExoInt,
                                                   B <: ExoInt, F <: ExoFloat}
    for (n, block_id) in enumerate(block_ids)
        blocks[n] = Block(exo, block_id)
    end
end

"""
    read_blocks(exo::ExodusDatabase{M, I, B, F}, 
                block_ids::Vector{I}) where {M <: ExoInt, I <: ExoInt,
                                             B <: ExoInt, F <: ExoFloat}
Helper method for initializing blocks.
"""
function read_blocks(exo::ExodusDatabase{M, I, B, F}, 
                     block_ids::Vector{I}) where {M <: ExoInt, I <: ExoInt,
                                                  B <: ExoInt, F <: ExoFloat}
    blocks = Vector{Block{I}}(undef, size(block_ids, 1))
    read_blocks!(blocks, exo, block_ids)
    return blocks
end
