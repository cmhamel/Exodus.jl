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

# local exports
export ExodusDatabase
export Initialization
# export NodeSet
