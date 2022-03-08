# types
#
ExoFileName = String
ExoID = Int64
BlockID = Int64
BlockType = Int64

abstract type FEMContainer end

struct Block <: FEMContainer
    block_id::Int64  # TODO: maybe change to BlockID so types are more verbose
    num_elem::Int64
    num_nodes_per_elem::Int64
    elem_type::String
    conn::Array{Int32}
end
