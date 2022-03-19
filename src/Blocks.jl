struct Block <: FEMContainer
    block_id::Int64  # TODO: maybe change to BlockID so types are more verbose
    num_elem::Int64
    num_nodes_per_elem::Int64
    elem_type::String
    conn::Array{Int64}
    function Block(exo_id::ExoID, block_id::BlockID)
        element_type, num_elem, num_nodes, _, _, _ =
        read_element_block_parameters(exo_id::ExoID, block_id::BlockID)
        conn = read_block_connectivity(exo_id, block_id)
        return new(block_id, num_elem, num_nodes, element_type, conn)
    end
end
Base.show(io::IO, block::Block) =
print(io, "Block:\n",
          "\tBlock ID           = ", block.block_id, "\n",
          "\tNum elem           = ", block.num_elem, "\n",
          "\tNum nodes per elem = ", block.num_nodes_per_elem, "\n",
          "\tElem type          = ", block.elem_type, "\n")


function read_block_ids(exo_id::ExoID, num_elem_blk::Int64)
    block_ids = Array{Int32}(undef, num_elem_blk)
    error = ccall((:ex_get_ids, exo_lib_path), Int64,
                  (Int64, Int64, Ref{Int32}),
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

    error = ccall((:ex_get_block, exo_lib_path), Int64,
                  (ExoID, BlockType, BlockID,
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

    conn = Array{Int32}(undef, num_nodes * num_elem)
    conn_face = Array{Int32}(undef, num_nodes * num_elem)  # Not using these currently
    conn_edge = Array{Int32}(undef, num_nodes * num_elem)  # Not using these currently

    # TODO: look into why the connectivity arrays need to be 32 bit.
    #
    error = ccall((:ex_get_conn, exo_lib_path), Int64,
                  (ExoID, Int64, BlockID, Ref{Int32}, Ref{Int32}, Ref{Int32}),
                  exo_id, EX_ELEM_BLOCK, block_id, conn, conn_face, conn_edge)

    return conn
end
