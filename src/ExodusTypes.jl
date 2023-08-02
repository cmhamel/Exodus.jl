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
abstract type AbstractSet{I, B} end

"""
"""
struct Block{I, B} <: AbstractSet{I, B}
  block_id::I
  num_elem::Clonglong
  num_nodes_per_elem::Clonglong
  elem_type::String # TODO maybe just make an index
  conn::Matrix{B}
end

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
  ids = read_node_set_ids(exo)
  name_index = findall(x -> x == name, read_node_set_names(exo))
  if length(name_index) < 1
    throw(BoundsError(read_node_set_names(exo), name_index))
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
  ids = read_side_set_ids(exo)
  name_index = findall(x -> x == name, read_side_set_names(exo))
  if length(name_index) < 1
    throw(BoundsError(read_side_set_names(exo), name_index))
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
