# types
#
IntKind = Int32
ExoFileName = String
# ExoID = IntKind #Int64
ExoID = Int64
BlockID = IntKind #Int64
BlockType = IntKind #Int64



abstract type FEMContainer end

struct Initialization <: FEMContainer
    num_dim::IntKind
    num_nodes::IntKind
    num_elem::IntKind
    num_elem_blk::IntKind
    num_node_sets::IntKind
    num_side_sets::IntKind
end
Base.show(io::IO, init::Initialization) =
print(io, "Initialization:\n",
          "\tNum dim       = ", init.num_dim, "\n",
          "\tNum nodes     = ", init.num_nodes, "\n",
          "\tNum elem      = ", init.num_elem, "\n",
          "\tNum blocks    = ", init.num_elem_blk, "\n",
          "\tNum node sets = ", init.num_node_sets, "\n",
          "\tNum side sets = ", init.num_side_sets, "\n")

struct Block <: FEMContainer
    block_id::IntKind  # TODO: maybe change to BlockID so types are more verbose
    num_elem::IntKind
    num_nodes_per_elem::IntKind
    elem_type::String
    conn::Array{IntKind}
end
Base.show(io::IO, block::Block) =
print(io, "Block:\n",
          "\tBlock ID           = ", block.block_id, "\n",
          "\tNum elem           = ", block.num_elem, "\n",
          "\tNum nodes per elem = ", block.num_nodes_per_elem, "\n",
          "\tElem type          = ", block.elem_type, "\n")
