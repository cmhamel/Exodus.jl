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
  Initialization
Container that should be setup first thing after getting an exo ID
"""
struct Initialization
  num_dim::Clonglong
  num_nodes::Clonglong
  num_elems::Clonglong
  num_elem_blks::Clonglong
  num_node_sets::Clonglong
  num_side_sets::Clonglong
end

"""
  ExodusDatabase{M <: ExoInt, I <: ExoInt, B <: ExoInt, F <: ExoFloat}
Main entry point for the package whether it's in read or write mode. 
"""
mutable struct ExodusDatabase{M <: Integer, I <: Integer, B <: Integer, F <: Real}
  exo::Cint
  init::Initialization
end

"""
  Block{I <: ExoInt, B <: ExoInt}
Container for reading in blocks
"""
struct Block{I <: Integer, B <: Integer}
  block_id::I
  num_elem::Clonglong
  num_nodes_per_elem::Clonglong
  elem_type::String # TODO maybe just make an index
  conn::Array{B} # TODO look into what they mean by "BULK data"
end

"""
  NodeSet
Container for node sets.
"""
struct NodeSet{I <: Integer, B <: Integer}
  node_set_id::I
  num_nodes::Clonglong
  nodes::Vector{B}
end

# local exports
export Block
export ExodusDatabase
export Initialization
export NodeSet
