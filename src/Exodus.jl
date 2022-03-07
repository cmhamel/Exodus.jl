module Exodus

using Base

const exo_lib_path = ENV["EXODUS_LIB_PATH"]

const EX_WRITE = 0x0001
const EX_READ = 0x0002
const EX_NOCLOBBER = 0x0004
const EX_CLOBBER = 0x0008

const EX_ELEM_BLOCK = 1

const MAX_LINE_LENGTH = 80

const cpu_word_size = Ref{Int64}(sizeof(Float64))
const IO_word_size = Ref{Int64}(8)

# TODO: make this be read in from the OS or something like that
#
const version_number_1 = 8
const version_number_2 = 12
const version_number = 8.12

# types
#
ExoFileName = String
ExoID = Int64
BlockID = Int64
BlockType = Int64


struct ElementBlock

end

struct Nodeset

end

struct Sideset

end

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

    return num_dim[], num_nodes[], num_elem[],
           num_elem_blk[], num_node_sets[], num_side_sets[]
end

function read_coordinates(exo_id::ExoID, num_dim::Int64, num_nodes::Int64)
    # TODO: figure out the best way to pass this stuff to exodus
    # TODO: for 2D this requires allocating memory for z even though it's
    # TODO: not there
    x_coords = Array{Float64}(undef, num_nodes)
    y_coords = Array{Float64}(undef, num_nodes)
    z_coords = Array{Float64}(undef, num_nodes)
    ccall((:ex_get_coord, exo_lib_path), Int64,
          (ExoID, Ref{Float64}, Ref{Float64}, Ref{Float64}),
          exo_id, x_coords, y_coords, z_coords)
    return x_coords, y_coords, z_coords
end

function read_element_block_parameters(exo_id::ExoID, block_id::BlockID)
    element_type = "aaaaa"  # TODO: This needs to be addressed
    num_elem = Ref{Int64}(0)
    num_nodes = Ref{Int64}(0)
    num_edges = Ref{Int64}(0)
    num_faces = Ref{Int64}(0)
    num_attributes = Ref{Int64}(0)
    ccall((:ex_get_block, exo_lib_path), Int64,
          (ExoID, BlockType, BlockID,
           Base.Cstring, Ref{Int64}, Ref{Int64}, Ref{Int64}, Ref{Int64}, Ref{Int64}),
          exo_id, EX_ELEM_BLOCK, block_id,
          element_type, num_elem, num_nodes, num_edges, num_faces, num_attributes)
    return element_type, num_elem[], num_nodes[], num_edges[], num_faces[], num_attributes[]
end

function read_connectivity(exo_id::ExoID)

end

end # module
