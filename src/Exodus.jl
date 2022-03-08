module Exodus

using Base

include("Constants.jl")
include("Types.jl")

function create_exodus_database(file_name::ExoFileName)
    """
    For some reason #define statements are not picked up by ccall
    """
    exo_id = ccall((:ex_create_int, exo_lib_path), Int,
                   (Base.Cstring, Int64, Ref{Int64}, Ref{Int64}, Int64),
                   file_name, EX_CLOBBER, cpu_word_size, IO_word_size,
                   version_number_2)
    return exo_id
end

function close_exodus_database(exo_id::ExoID)
    ccall((:ex_close, exo_lib_path), Int, (Int,), exo_id)
end

function open_exodus_database(file_name::ExoFileName)
    # TODO: maybe add multiple methods for different EX_* options
    exo_id = ccall((:ex_open_int, exo_lib_path), Int64,
                   (Base.Cstring, Int64, Ref{Int64},
                    Ref{Int64}, Ref{Float64}, Int),
                   file_name, EX_CLOBBER, cpu_word_size, IO_word_size,
                   version_number, version_number_2)
    return exo_id
end

function read_initialization_parameters(exo_id::ExoID)
    num_dim = Ref{Int64}(0)
    num_nodes = Ref{Int64}(0)
    num_elem = Ref{Int64}(0)
    num_elem_blk = Ref{Int64}(0)
    num_node_sets = Ref{Int64}(0)
    num_side_sets = Ref{Int64}(0)
    error = Ref{Int64}(0)

    title = ""
    error = ccall((:ex_get_init, exo_lib_path), Int64,
                  (ExoID, Base.Cstring,
                   Ref{Int64}, Ref{Int64}, Ref{Int64},
                   Ref{Int64}, Ref{Int64}, Ref{Int64}),
                  exo_id, title,
                  num_dim, num_nodes, num_elem,
                  num_elem_blk, num_node_sets, num_side_sets)

    # title = strip(title, '\0') # TODO: do something with this
    if error < 0
        error("Error in read_initialization_parameters\nError = $error")
    end

    return num_dim[], num_nodes[], num_elem[],
           num_elem_blk[], num_node_sets[], num_side_sets[]
end

function read_coordinates(exo_id::ExoID, num_dim::Int64, num_nodes::Int64)
    if num_dim == 1
        x_coords = Array{Float64}(undef, num_nodes)
        y_coords = Ref{Float64}(0.0)
        z_coords = Ref{Float64}(0.0)
    elseif num_dim == 2
        x_coords = Array{Float64}(undef, num_nodes)
        y_coords = Array{Float64}(undef, num_nodes)
        z_coords = Ref{Float64}(0.0)
    elseif num_dim == 3
        x_coords = Array{Float64}(undef, num_nodes)
        y_coords = Array{Float64}(undef, num_nodes)
        z_coords = Array{Float64}(undef, num_nodes)
    end

    ccall((:ex_get_coord, exo_lib_path), Int64,
          (ExoID, Ref{Float64}, Ref{Float64}, Ref{Float64}),
          exo_id, x_coords, y_coords, z_coords)
    return x_coords, y_coords, z_coords
end

function read_element_block_parameters(exo_id::ExoID, block_id::BlockID)
    # element_type = "      "
    element_type = Vector{UInt8}(undef, MAX_STR_LENGTH)
    num_elem = Ref{Int64}(0)
    num_nodes = Ref{Int64}(0)
    num_edges = Ref{Int64}(0)
    num_faces = Ref{Int64}(0)
    num_attributes = Ref{Int64}(0)
    ccall((:ex_get_block, exo_lib_path), Int64,
          (ExoID, BlockType, BlockID,
           Ptr{UInt8}, Ref{Int64}, Ref{Int64}, Ref{Int64}, Ref{Int64}, Ref{Int64}),
          exo_id, EX_ELEM_BLOCK, block_id,
          element_type, num_elem, num_nodes, num_edges, num_faces, num_attributes)

    element_type = unsafe_string(pointer(element_type))

    return element_type, num_elem[], num_nodes[], num_edges[], num_faces[], num_attributes[]
end

function read_block_connectivity(exo_id::ExoID, block_id::BlockID)
    element_type, num_elem, num_nodes, num_edges, num_faces, num_attributes =
    read_element_block_parameters(exo_id::ExoID, block_id::BlockID)

    conn = Array{Int32}(undef, num_nodes * num_elem)
    conn_face = Array{Int32}(undef, num_nodes * num_elem)
    conn_edge = Array{Int32}(undef, num_nodes * num_elem)

    # TODO: look into why the connectivity arrays need to be 32 bit.
    #
    error = ccall((:ex_get_conn, exo_lib_path), Int64,
                  (ExoID, Int64, BlockID, Ref{Int32}, Ref{Int32}, Ref{Int32}),
                  exo_id, EX_ELEM_BLOCK, block_id, conn, conn_face, conn_edge)

    return conn
end

function initialize_block(exo_id::ExoID, block_id::BlockID)
    element_type, num_elem, num_nodes, _, _, _ =
    read_element_block_parameters(exo_id::ExoID, block_id::BlockID)

    conn = read_block_connectivity(exo_id, block_id)

    return Block(block_id, num_elem, num_nodes, element_type, conn)
end

end # module
