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

struct ExodusDatabase{M, I, B, F}
  exo::Cint
  mode::String
  init::Initialization
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

# struct ex_set
mutable struct ex_set
  id::Clonglong
  type::ex_entity_type
  num_entry::Clonglong
  num_distribution_factor::Clonglong
  entry_list::Ptr{void_int}
  extra_list::Ptr{void_int}
  distribution_factor_list::Ptr{Cvoid}
  # entry_list::Vector{Int32}
  # extra_list::Vector{Int32}
  # distribution_factor_list::Vector{Cvoid}
end

function ex_set(id::I, type::ex_entity_type) where I <: Integer
  # num_entry, num_distribution_factor = 129, 129
  # return ex_set(
  #   id, type, num_entry, 0, 
  #   # Ref{void_int}(0), Ref{void_int}(0), Ref{Cvoid}(0)
  #   # Ptr{void_int}(), Ptr{void_int}(), Ptr{Cvoid}()
  #   # Vector{Int32}(undef, num_entry)[], Vector{Int32}(undef, num_entry)[], 
  #   zeros(Int32, num_entry) |> pointer, zeros(Int32, num_entry) |> pointer,
  #   zeros(Int32, num_distribution_factor) |> pointer
  #   # Vector{Cvoid}(undef, num_distribution_factor) |> pointer
  # )
  return ex_set(
    id, type, 129, 0,
    Vector{Int32}(undef, 129) |> pointer, C_NULL, C_NULL
  )
end

# local exports
export Block
export ExodusDatabase
export Initialization
export NodeSet
export SideSet
export ex_set
