struct Block{T}
    block_id::int  # TODO: maybe change to BlockID so types are more verbose
    num_elem::int
    num_nodes_per_elem::int
    elem_type::String # TODO maybe just make an index
    conn::Array{T}
    function Block(exo_id::int, block_id::int)
        element_type, num_elem, num_nodes, _, _, _ =
        read_element_block_parameters(exo_id::int, block_id::int)
        conn = read_block_connectivity(exo_id, block_id)

        # TODO this could possible break
        if ex_int64_status(exo_id) > 0
            return new{Int64}(block_id, num_elem, num_nodes, element_type, conn)
        else
            return new{Int32}(block_id, num_elem, num_nodes, element_type, conn)
        end
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
function read_block_ids(exo_id::int, num_elem_blk::int)#::BlockIDs
    block_ids = Vector{int}(undef, num_elem_blk)
    ex_get_ids!(exo_id, EX_ELEM_BLOCK, block_ids)
    return block_ids
end

function read_element_block_parameters(exo_id::int, block_id::int)
    element_type = Vector{UInt8}(undef, MAX_STR_LENGTH)
    num_elem = Ref{int}(0)
    num_nodes = Ref{int}(0)
    num_edges = Ref{int}(0)
    num_faces = Ref{int}(0)
    num_attributes = Ref{int}(0)
    ex_get_block!(exo_id, EX_ELEM_BLOCK, block_id,
                  element_type,
                  num_elem, num_nodes,
                  num_edges, num_faces,
                  num_attributes)
    element_type = unsafe_string(pointer(element_type))
    return element_type, num_elem[], num_nodes[], num_edges[], num_faces[], num_attributes[]
end

# TODO maybe turn this into a struct or something like that
function read_block_connectivity(exo_id::int, block_id::int)
    element_type, num_elem, num_nodes, num_edges, num_faces, num_attributes =
    read_element_block_parameters(exo_id::int, block_id::int)
    conn = Vector{IntKind}(undef, num_nodes * num_elem)
    conn_face = Vector{IntKind}(undef, num_nodes * num_elem)  # Not using these currently
    conn_edge = Vector{IntKind}(undef, num_nodes * num_elem)  # Not using these currently
    ex_get_conn!(exo_id, EX_ELEM_BLOCK, block_id, conn, conn_face, conn_edge)
    return conn
end

function read_blocks!(exo_id::int, block_ids::Vector{int}, blocks::Vector{Block})
    for (n, block_id) in enumerate(block_ids)
        blocks[n] = Block(exo_id, block_id)
    end
end

function read_blocks(exo_id::int, block_ids::Vector{int})
    blocks = Vector{Block}(undef, size(block_ids, 1))
    read_blocks!(exo_id, block_ids, blocks)
    return blocks
end
