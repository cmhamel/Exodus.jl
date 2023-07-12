"""
Workaround method
"""
function Initialization(::Type{Int32})
  return Initialization{Int32}(Int32(0), Int32(0), Int32(0), Int32(0), Int32(0), Int32(0))
end

"""
Workaround method
"""
function Initialization(::Type{Int64})
  return Initialization{Int64}(0, 0, 0, 0, 0, 0)
end

"""
"""
function Initialization(exo::ExodusDatabase{M, I, B, F}) where {M, I, B, F}
  num_dim       = Ref{B}(0)
  num_nodes     = Ref{B}(0)
  num_elems     = Ref{B}(0)
  num_elem_blks = Ref{B}(0)
  num_node_sets = Ref{B}(0)
  num_side_sets = Ref{B}(0)
  title = Vector{UInt8}(undef, MAX_LINE_LENGTH)
  error_code = @ccall libexodus.ex_get_init(
    get_file_id(exo)::Cint, 
    title::Ptr{UInt8},
    num_dim::Ptr{B}, num_nodes::Ptr{B}, num_elems::Ptr{B},
    num_elem_blks::Ptr{B}, num_node_sets::Ptr{B}, num_side_sets::Ptr{B}
  )::Cint
  exodus_error_check(error_code, "Exodus.Initialization -> libexodus.ex_get_init")
  title = unsafe_string(pointer(title))
  return Initialization{B}(num_dim[], num_nodes[], num_elems[],
                           num_elem_blks[], num_node_sets[], num_side_sets[])
end

# Initialization(exo::ExodusDatabase) = Initialization(get_file_id(exo))

"""
"""
Base.show(io::IO, init::Initialization) =
print(
  io, "Initialization:\n",
      "\tNumber of dim       = ", init.num_dim, "\n",
      "\tNumber of nodes     = ", init.num_nodes, "\n",
      "\tNumber of elem      = ", init.num_elems, "\n",
      "\tNumber of blocks    = ", init.num_elem_blks, "\n",
      "\tNumber of node sets = ", init.num_node_sets, "\n",
      "\tNumber of side sets = ", init.num_side_sets, "\n"
)

"""
Used to set up a exodus database in write mode

The ccall signatures should reall be B (bulk int type of exo) instead of Clonglong
"""
function write_initialization!(exoid::Cint, init::Initialization)
  title = Vector{UInt8}(undef, MAX_LINE_LENGTH)
  error_code = @ccall libexodus.ex_put_init(
    exoid::Cint, title::Ptr{UInt8},
    init.num_dim::Clonglong, init.num_nodes::Clonglong, init.num_elems::Clonglong,
    init.num_elem_blks::Clonglong, init.num_node_sets::Clonglong, init.num_side_sets::Clonglong
  )::Cint
  exodus_error_check(error_code, "Exodus.write_initialization! -> libexodus.ex_put_init")
end

export write_initialization!
