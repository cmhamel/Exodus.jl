# types for convenience
#
"""
  void_int = Cvoid
"""
const void_int = Cvoid
"""
"""
const ex_entity_id = Clonglong

# derived types
"""
"""
# struct Initialization
#   """
#   Dimension of exodus database
#   """
#   num_dim::Clonglong
#   """
#   Number of nodes in exodus database
#   """
#   num_nodes::Clonglong
#   """
#   Number of elements in exodus database
#   """
#   num_elems::Clonglong
#   """
#   Number of element blocks in exodus database
#   """
#   num_elem_blks::Clonglong
#   """
#   Number of node sets in exodus database
#   """
#   num_node_sets::Clonglong
#   """
#   Number of side sets in exodus database
#   """
#   num_side_sets::Clonglong
# end

struct Initialization{B}
  num_dim::B
  num_nodes::B
  num_elems::B
  num_elem_blks::B
  num_node_sets::B
  num_side_sets::B
end

# """
# """
# mutable struct ExodusDatabase{M <: Integer, I <: Integer, B <: Integer, F <: AbstractFloat}
#   """
#   ID of exodus file
#   """
#   exo::Cint
#   """
#   Initiailization object
#   """
#   init::Initialization
# end

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
