# types for convenience
#
"""
  void_int = Cvoid
"""
void_int = Cvoid
"""
  ex_entity_id = Clonglong
"""
ex_entity_id = Clonglong

# derived types
"""
"""
struct Initialization
  """
  Dimension of exodus database
  """
  num_dim::Clonglong
  """
  Number of nodes in exodus database
  """
  num_nodes::Clonglong
  """
  Number of elements in exodus database
  """
  num_elems::Clonglong
  """
  Number of element blocks in exodus database
  """
  num_elem_blks::Clonglong
  """
  Number of node sets in exodus database
  """
  num_node_sets::Clonglong
  """
  Number of side sets in exodus database
  """
  num_side_sets::Clonglong
end

# """
# """
# mutable struct ExodusDatabase{M <: Integer, I <: Integer, B <: Integer, F <: Real}
#   """
#   ID of exodus file
#   """
#   exo::Cint
#   """
#   Initiailization object
#   """
#   init::Initialization
# end
struct ExodusDatabase
  """
  ID of exodus file
  """
  exo::Cint
  """
  Mode
  """
  mode::String
  """
  Type of integer stuff # make this a better comment 
  """
  M::Type
  """
  Integer type of IDs
  """
  I::Type
  """
  Integer type of set IDs
  """
  B::Type
  """
  Floating type
  """
  F::Type
  """
  Initialization type
  """
  init::Initialization
end

"""
"""
struct Block{I <: Integer, B <: Integer}
  """
  ID of block
  """
  block_id::I
  """
  Number of elements in block
  """
  num_elem::Clonglong
  """
  Number of nodes per element in block
  """
  num_nodes_per_elem::Clonglong
  """
  Type of finite element, e.g. QUAD4
  """
  elem_type::String # TODO maybe just make an index
  """
  Connectivty of integer type consistent with exodus database
  """
  conn::Matrix{B}
end

# """
# New attempt at block to match ex_block in exodusII.h
# """
# mutable struct ExodusBlock
#   id::Int64
#   type::ex_entity_type
#   topology::Vector{UInt8}
#   num_entry::Int64
#   num_nodes_per_entry::Int64
#   num_edges_per_entry::Int64
#   num_faces_per_entry::Int64
#   num_attributes::Int64
# end

"""
"""
struct NodeSet{I <: Integer, B <: Integer}
  """
  ID of node set
  """
  node_set_id::I
  """
  Number of nodes in the node set
  """
  num_nodes::Clonglong
  """
  Node IDs for each node in the node set
  """
  nodes::Vector{B}
end

"""
"""
struct SideSet{I <: Integer, B <: Integer}
  """
  ID of side set
  """
  side_set_id::I
  """
  Number of elements in the side set
  """
  num_elements::Clonglong
  """
  Element IDs
  """
  elements::Vector{B}
  """
  Sides
  """
  sides::Vector{B}
end

# local exports
export Block
export ExodusDatabase
export Initialization
export NodeSet
export SideSet
