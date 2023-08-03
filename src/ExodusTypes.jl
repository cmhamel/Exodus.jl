# types for convenience
#
"""
  void_int = Cvoid
"""
const void_int = Cvoid
"""
"""
const ex_entity_id = Clonglong


struct Initialization{B}
  num_dim::B
  num_nodes::B
  num_elems::B
  num_elem_blks::B
  num_node_sets::B
  num_side_sets::B
end

struct ExodusDatabase{M, I, B, F}
  exo::Cint
  mode::String
  init::Initialization{B}
end

get_map_int_type(::ExodusDatabase{M, I, B, F}) where {M, I, B, F} = M
get_id_int_type(::ExodusDatabase{M, I, B, F}) where {M, I, B, F} = I
get_bulk_int_type(::ExodusDatabase{M, I, B, F}) where {M, I, B, F} = B
get_float_type(::ExodusDatabase{M, I, B, F}) where {M, I, B, F} = F
get_init(exo::ExodusDatabase)      = getfield(exo, :init)
get_mode(exo::ExodusDatabase)      = getfield(exo, :mode)
get_file_id(exo::ExodusDatabase)   = getfield(exo, :exo)
get_num_dim(exo::ExodusDatabase)   = getfield(getfield(exo, :init), :num_dim)
get_num_nodes(exo::ExodusDatabase) = getfield(getfield(exo, :init), :num_nodes)

# sets and blocks
abstract type AbstractExodusType end
abstract type AbstractSet{I, B} <: AbstractExodusType end
abstract type AbstractVariable <: AbstractExodusType end


"""
"""
struct Block{I, B} <: AbstractSet{I, B}
  id::I
  num_elem::Clonglong
  num_nodes_per_elem::Clonglong
  elem_type::String # TODO maybe just make an index
  conn::Matrix{B}
end

"""
Init method for block container.
"""
function Block(exo::ExodusDatabase, block_id::Integer)
  block_id = convert(get_id_int_type(exo), block_id) # for convenience interfacing
  element_type, num_elem, num_nodes, _, _, _ =
  read_block_parameters(exo, block_id)
  conn = read_block_connectivity(exo, block_id)
  conn = reshape(conn, (num_nodes, num_elem))#'
  return Block{get_id_int_type(exo), get_bulk_int_type(exo)}(block_id, num_elem, num_nodes, element_type, conn)
end

"""
"""
function Block(exo::ExodusDatabase, block_name::String)
  block_ids = read_ids(exo, Block)
  name_index = findall(x -> x == block_name, read_names(exo, Block))
  if length(name_index) < 1
    throw(BoundsError(read_names(exo, Block), name_index))
  end
  name_index = name_index[1]
  return Block(exo, block_ids[name_index])
end

"""
"""
Base.show(io::IO, block::B) where {B <: Block} =
print(io, "Block:\n",
      "\tBlock ID           = ", block.id, "\n",
      "\tNum elem           = ", block.num_elem, "\n",
      "\tNum nodes per elem = ", block.num_nodes_per_elem, "\n",
      "\tElem type          = ", block.elem_type, "\n")


"""
"""
struct NodeSet{I, B} <: AbstractSet{I, B}
  id::I
  nodes::Vector{B}
end

"""
"""
function NodeSet(exo::ExodusDatabase{M, I, B, F}, id::Integer) where {M, I, B, F}
  nodes = read_node_set_nodes(exo, id)
  return NodeSet{I, B}(id, nodes)
end

"""
"""
function NodeSet(exo::ExodusDatabase, name::String)
  ids = read_ids(exo, NodeSet)
  name_index = findall(x -> x == name, read_names(exo, NodeSet))
  if length(name_index) < 1
    throw(BoundsError(read_names(exo, NodeSet), name_index))
  end
  name_index = name_index[1]
  return NodeSet(exo, ids[name_index])
end

entries(n::NodeSet)     = n.nodes
extras(::NodeSet)       = C_NULL
Base.length(n::NodeSet) = length(n.nodes)
Base.show(io::IO, node_set::NodeSet) =
print(
  io, "NodeSet:\n",
  "\tNode set ID     = ", node_set.id,      "\n",
  "\tNumber of nodes = ", length(node_set), "\n"
)

"""
"""
struct SideSet{I, B} <: AbstractSet{I, B}
  id::I
  elements::Vector{B}
  sides::Vector{B}
end

"""
"""
function SideSet(exo::ExodusDatabase{M, I, B, F}, id::Integer) where {M, I, B, F}
  elements, sides = read_side_set_elements_and_sides(exo, id)
  return SideSet{I, B}(id, elements, sides)
end

"""
"""
function SideSet(exo::ExodusDatabase, name::String)
  # ids = read_side_set_ids(exo)
  ids = read_ids(exo, SideSet)
  # name_index = findall(x -> x == name, read_side_set_names(exo))
  name_index = findall(x -> x == name, read_names(exo, SideSet))
  if length(name_index) < 1
    # throw(BoundsError(read_side_set_names(exo), name_index))
    throw(BoundsError(read_names(exo, SideSet), name_index))
  end
  name_index = name_index[1]
  return SideSet(exo, ids[name_index])
end

entries(s::SideSet)     = s.elements
extras(s::SideSet)      = s.sides
Base.length(s::SideSet) = length(s.elements)
Base.show(io::IO, sset::SideSet) = 
print(
  io, "SideSet:\n",
  "\tSide set ID        = ", sset.id,               "\n",
  "\tNumber of elements = ", length(sset.elements), "\n",
  "\tNumber of sides    = ", length(sset.sides),    "\n"
)

struct Element <: AbstractVariable
end

struct Global <: AbstractVariable
end

struct Nodal <: AbstractVariable
end

struct NodeSetVariable <: AbstractVariable
end

struct SideSetVariable <: AbstractVariable
end

entity_type(::Type{S}) where S <: Block           = EX_ELEM_BLOCK
entity_type(::Type{S}) where S <: Element         = EX_ELEM_BLOCK
entity_type(::Type{S}) where S <: Global          = EX_GLOBAL
entity_type(::Type{S}) where S <: Nodal           = EX_NODAL
entity_type(::Type{S}) where S <: NodeSet         = EX_NODE_SET
entity_type(::Type{S}) where S <: NodeSetVariable = EX_NODE_SET
entity_type(::Type{S}) where S <: SideSet         = EX_SIDE_SET
entity_type(::Type{S}) where S <: SideSetVariable = EX_SIDE_SET

set_equivalent(::Type{S}) where S <: NodeSetVariable = NodeSet
set_equivalent(::Type{S}) where S <: SideSetVariable = SideSet
