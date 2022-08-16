struct Block{T <: Integer}
    block_id::T
    num_elem::T
    num_nodes_per_elem::T
    elem_type::String # TODO maybe just make an index
    conn::Array{T}
    function Block(exo_id::Cint, block_id::T) where {T <: Integer}
        element_type, num_elem, num_nodes, _, _, _ =
        read_element_block_parameters(exo_id::Cint, block_id::T)
        conn = read_block_connectivity(exo_id, block_id)
        return new{T}(block_id, num_elem, num_nodes, element_type, conn)
    end
end
Base.show(io::IO, block::Block) =
print(io, "Block:\n",
          "\tBlock ID           = ", block.block_id, "\n",
          "\tNum elem           = ", block.num_elem, "\n",
          "\tNum nodes per elem = ", block.num_nodes_per_elem, "\n",
          "\tElem type          = ", block.elem_type, "\n")

# methods below
#
function read_block_ids(exo_id::Cint, num_elem_blk::T) where {T <: Integer}
    if ex_int64_status(exo_id) > 0
        block_ids = Vector{Clonglong}(undef, num_elem_blk)
        ex_get_ids!(exo_id, EX_ELEM_BLOCK, block_ids)
    else
        block_ids = Vector{Cint}(undef, num_elem_blk)
        ex_get_ids!(exo_id, EX_ELEM_BLOCK, block_ids)
    end
    return block_ids
end

# function read_block_ids(exo_id::Cint, num_elem_blk::Cint)
#     block_ids = Vector{Cint}(undef, num_elem_blk)
#     ex_get_ids!(exo_id, EX_ELEM_BLOCK, block_ids)
#     return block_ids
# end

# function read_block_ids(exo_id::Cint, num_elem_blk::Clonglong)
#     block_ids = Vector{Clonglong}(undef, num_elem_blk)
#     ex_get_ids!(exo_id, EX_ELEM_BLOCK, block_ids)
#     return block_ids
# end

function read_element_block_parameters(exo_id::Cint, block_id::T) where {T <: Integer}
    element_type = Vector{UInt8}(undef, MAX_STR_LENGTH)
    num_elem = Ref{T}(0)
    num_nodes = Ref{T}(0)
    num_edges = Ref{T}(0)
    num_faces = Ref{T}(0)
    num_attributes = Ref{T}(0)
    ex_get_block!(exo_id, EX_ELEM_BLOCK, block_id,
                  element_type,
                  num_elem, num_nodes,
                  num_edges, num_faces,
                  num_attributes)
    element_type = unsafe_string(pointer(element_type))
    return element_type, num_elem[], num_nodes[], num_edges[], num_faces[], num_attributes[]
end

# TODO maybe turn this into a struct or something like that
function read_block_connectivity(exo_id::Cint, block_id::T) where {T <: Integer}
    element_type, num_elem, num_nodes, num_edges, num_faces, num_attributes =
    read_element_block_parameters(exo_id::Cint, block_id::T)
    conn = Vector{T}(undef, num_nodes * num_elem)
    conn_face = Vector{T}(undef, num_nodes * num_elem)  # Not using these currently
    conn_edge = Vector{T}(undef, num_nodes * num_elem)  # Not using these currently
    ex_get_conn!(exo_id, EX_ELEM_BLOCK, block_id, conn, conn_face, conn_edge)
    return conn
end

function read_blocks!(exo_id::Cint, block_ids::Vector{T}, blocks::Vector{Block}) where {T <: Integer}
    for (n, block_id) in enumerate(block_ids)
        blocks[n] = Block(exo_id, block_id)
    end
end

function read_blocks(exo_id::Cint, block_ids::Vector{T}) where {T <: Integer}
    blocks = Vector{Block}(undef, size(block_ids, 1))
    read_blocks!(exo_id, block_ids, blocks)
    return blocks
end
