struct Block <: FEMContainer
    block_id::BlockID  # TODO: maybe change to BlockID so types are more verbose
    num_elem::Int64
    num_nodes_per_elem::Int64
    elem_type::String
    conn::Array{Int64}
    function Block(exo_id::ExoID, block_id::BlockID)
        element_type, num_elem, num_nodes, _, _, _ =
        read_element_block_parameters(exo_id::ExoID, block_id::BlockID)
        conn = read_block_connectivity(exo_id, block_id)
        # conn = reshape(conn, (num_elem, num_nodes))  # for easier access downstream
        return new(block_id, num_elem, num_nodes, element_type, conn)
    end
end
Base.show(io::IO, block::Block) =
print(io, "Block:\n",
          "\tBlock ID           = ", block.block_id, "\n",
          "\tNum elem           = ", block.num_elem, "\n",
          "\tNum nodes per elem = ", block.num_nodes_per_elem, "\n",
          "\tElem type          = ", block.elem_type, "\n")

# more verbose types
#
# TODO turn this into actual types with constructors to declutter stuff
BlockIDs = Vector{BlockID}
BlockIDsPtr = Ref{BlockID}
Blocks = Vector{Block}

# methods below
#

function read_block_ids(exo_id::ExoID, num_elem_blk::Int64)::BlockIDs
    block_ids = BlockIDs(undef, num_elem_blk)
    error = ccall((:ex_get_ids, libexodus), ExodusError,
                (ExoID, ExodusConstant, BlockIDsPtr),
                exo_id, EX_ELEM_BLOCK, block_ids)
    exodus_error_check(error, "read_block_ids")
    return block_ids
end

function read_element_block_parameters(exo_id::ExoID, block_id::BlockID)
    element_type = Vector{UInt8}(undef, MAX_STR_LENGTH)
    num_elem = Ref{Int64}(0)
    num_nodes = Ref{Int64}(0)
    num_edges = Ref{Int64}(0)
    num_faces = Ref{Int64}(0)
    num_attributes = Ref{Int64}(0)
    error = ccall((:ex_get_block, libexodus), ExodusError,
                  (ExoID, ExodusConstant, BlockID,
                   Ptr{UInt8}, Ref{Int64}, Ref{Int64}, Ref{Int64}, Ref{Int64}, Ref{Int64}),
                  exo_id, EX_ELEM_BLOCK, block_id,
                  element_type, num_elem, num_nodes, num_edges, num_faces, num_attributes)

    exodus_error_check(error, "read_element_blocK_parameters")

    element_type = unsafe_string(pointer(element_type))

    return element_type, num_elem[], num_nodes[], num_edges[], num_faces[], num_attributes[]
end

function read_block_connectivity(exo_id::ExoID, block_id::BlockID)
    element_type, num_elem, num_nodes, num_edges, num_faces, num_attributes =
    read_element_block_parameters(exo_id::ExoID, block_id::BlockID)

    # old 32 bit IDs behavior
    # conn = Vector{Int32}(undef, num_nodes * num_elem)
    # conn_face = Vector{Int32}(undef, num_nodes * num_elem)  # Not using these currently
    # conn_edge = Vector{Int32}(undef, num_nodes * num_elem)  # Not using these currently
    conn = Vector{Int64}(undef, num_nodes * num_elem)
    conn_face = Vector{Int64}(undef, num_nodes * num_elem)  # Not using these currently
    conn_edge = Vector{Int64}(undef, num_nodes * num_elem)  # Not using these currently

    # TODO: look into why the connectivity arrays need to be 32 bit.
    #
    # error = ccall((:ex_get_conn, libexodus), ExodusError,
    #               (ExoID, ExodusConstant, BlockID, Ref{Int32}, Ref{Int32}, Ref{Int32}),
    #               exo_id, EX_ELEM_BLOCK, block_id, conn, conn_face, conn_edge)
    error = ccall((:ex_get_conn, libexodus), ExodusError,
                  (ExoID, ExodusConstant, BlockID, Ref{Int64}, Ref{Int64}, Ref{Int64}),
                  exo_id, EX_ELEM_BLOCK, block_id, conn, conn_face, conn_edge)
    exodus_error_check(error, "read_block_connectivity")
    return conn
end

function read_blocks!(exo_id::ExoID, block_ids::BlockIDs, blocks::Blocks)
    for (n, block_id) in enumerate(block_ids)
        blocks[n] = Block(exo_id, block_id)
    end
end

function read_blocks(exo_id::ExoID, block_ids::BlockIDs)
    blocks = Vector{Block}(undef, size(block_ids, 1))
    read_blocks!(exo_id, block_ids, blocks)
    return blocks
end
