module Exodus

using Base

include("Constants.jl")
include("Types.jl")
include("Blocks.jl")

function exodus_error_check(error::Int64, method_name::String)
    if error < 0
        error("Error from exodus library call in method $method_name")
    end
end

function create_exodus_database(file_name::ExoFileName)
    """
    For some reason #define statements are not picked up by ccall
    """
    exo_id = ccall((:ex_create_int, exo_lib_path), Int64,
                   (Base.Cstring, Int64, Ref{Int64}, Ref{Int64}, Int64),
                   file_name, EX_CLOBBER, cpu_word_size, IO_word_size,
                   version_number_2)
    exodus_error_check(exo_id, "create_exodus_database")
    return exo_id
end

function close_exodus_database(exo_id::ExoID)
    error = ccall((:ex_close, exo_lib_path), Int64, (Int64,), exo_id)
    exodus_error_check(error, "close_exodus_database")
end

function open_exodus_database(file_name::ExoFileName)
    # TODO: maybe add multiple methods for different EX_* options
    exo_id = ccall((:ex_open_int, exo_lib_path), Int64,
                   (Base.Cstring, Int64, Ref{Int64},
                    Ref{Int64}, Ref{Float64}, Int),
                   file_name, EX_CLOBBER, cpu_word_size, IO_word_size,
                   version_number, version_number_2)
    exodus_error_check(exo_id, "open_exodus_database")
    return exo_id
end

function get_initialization(exo_id::ExoID)
    num_dim, num_nodes, num_elem,
    num_elem_blk, num_node_sets, num_side_sets, title =
    read_initialization_parameters(exo_id)
    return Initialization(num_dim, num_nodes, num_elem,
                          num_elem_blk, num_node_sets, num_side_sets)
end

function read_initialization_parameters(exo_id::ExoID)
    num_dim = Ref{Int64}(0)
    num_nodes = Ref{Int64}(0)
    num_elem = Ref{Int64}(0)
    num_elem_blk = Ref{Int64}(0)
    num_node_sets = Ref{Int64}(0)
    num_side_sets = Ref{Int64}(0)
    error = Ref{Int64}(0)

    # title = "" # TODO: fix this to behave like Vector{UInt8}(undef, MAX_STR_LENGTH)
    title = Vector{UInt8}(undef, MAX_LINE_LENGTH)
    error = ccall((:ex_get_init, exo_lib_path), Int64,
                  (ExoID, Ptr{UInt8},
                   Ref{Int64}, Ref{Int64}, Ref{Int64},
                   Ref{Int64}, Ref{Int64}, Ref{Int64}),
                  exo_id, title,
                  num_dim, num_nodes, num_elem,
                  num_elem_blk, num_node_sets, num_side_sets)

    title = unsafe_string(pointer(title))
    exodus_error_check(error, "read_initialization_parameterss")

    return num_dim[], num_nodes[], num_elem[],
           num_elem_blk[], num_node_sets[], num_side_sets[], title
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
    error = ccall((:ex_get_coord, exo_lib_path), Int64,
                  (ExoID, Ref{Float64}, Ref{Float64}, Ref{Float64}),
                  exo_id, x_coords, y_coords, z_coords)
    exodus_error_check(error, "read_coordinates")
    return x_coords, y_coords, z_coords
end

end # module
