# types for convenience
#
"""
  void_int = Cvoid
"""
const void_int = Cvoid

"""
"""
const ex_entity_id = Clonglong

"""
"""
function set_exodus_options(options::T) where T
  error_code = @ccall libexodus.ex_opts(options::Cint)::Cint
  exodus_error_check(error_code, "Exodus.set_exodus_options -> libexodus.ex_opts")
end

"""
"""
function set_exodus_max_name_length(exoid::Cint, len::Cint)
  error_code = @ccall libexodus.ex_set_max_name_length(
    exoid::Cint, len::Cint
  )::Cint
  exodus_error_check(error_code, "ex_set_max_name_length")
end

"""
"""
function int_and_float_modes(exo::Cint)::Tuple{Type, Type, Type, Type}
  int64_status = @ccall libexodus.ex_int64_status(exo::Cint)::UInt32
  float_size   = @ccall libexodus.ex_inquire_int(exo::Cint, EX_INQ_DB_FLOAT_SIZE::ex_inquiry)::Cint

  # should be 8 options or 2^3
  if int64_status == 0x00000000
    M, I, B = Cint, Cint, Cint
  elseif int64_status == EX_MAPS_INT64_API
    M, I, B = Clonglong, Cint, Cint
  elseif int64_status == EX_MAPS_INT64_API | EX_IDS_INT64_API
    M, I, B = Clonglong, Clonglong, Cint
  elseif int64_status == EX_MAPS_INT64_API | EX_BULK_INT64_API
    M, I, B = Clonglong, Cint, Clonglong
  elseif int64_status == EX_IDS_INT64_API
    M, I, B = Cint, Clonglong, Cint
  elseif int64_status == EX_IDS_INT64_API | EX_BULK_INT64_API
    M, I, B = Cint, Clonglong, Clonglong
  elseif int64_status == EX_BULK_INT64_API
    M, I, B = Cint, Cint, Clonglong
  elseif int64_status == EX_MAPS_INT64_API | EX_IDS_INT64_API | EX_BULK_INT64_API
    M, I, B = Clonglong, Clonglong, Clonglong
  else
    mode_error("Bad int64_status, probably 64 int bit mesh, not supported right now $int64_status")
  end

  if float_size == 4
    F = Cfloat
  elseif float_size == 8
    F = Cdouble
  else
    mode_error("Bad float mode: float_size == $(float_size)")
  end

  return M, I, B, F
end

function map_int_type(int_status::UInt32)
  if int_status == 0x00000000
    return Cint
  elseif int_status == EX_MAPS_INT64_API
    return Clonglong
  elseif int_status == EX_ALL_INT64_API
    return Clonglong
  else
    return Cint# hack for now
  end
end

function id_int_type(int_status::UInt32)
  if int_status == 0x00000000
    return Cint
  elseif int_status == EX_IDS_INT64_API
    return Clonglong
  elseif int_status == EX_ALL_INT64_API
    return Clonglong
  else
    return Cint# hack for now
  end
end

function bulk_int_type(int_status::UInt32)
  if int_status == 0x00000000
    return Cint
  elseif int_status == EX_BULK_INT64_API
    return Clonglong
  elseif int_status == EX_ALL_INT64_API
    return Clonglong
  else
    return Cint# hack for now
  end
end

function float_type(float_size::Int32)
  if float_size == 4
    return Cfloat
  elseif float_size == 8
    return Cdouble
  end
end


struct Initialization{B}
  num_dim::B
  num_nodes::B
  num_elems::B
  num_elem_blks::B
  num_node_sets::B
  num_side_sets::B
end

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
# function Initialization(exo::ExodusDatabase{M, I, B, F}) where {M, I, B, F}
function Initialization(exo::Cint, ::Type{B}) where B
  num_dim       = Ref{B}(0)
  num_nodes     = Ref{B}(0)
  num_elems     = Ref{B}(0)
  num_elem_blks = Ref{B}(0)
  num_node_sets = Ref{B}(0)
  num_side_sets = Ref{B}(0)
  title = Vector{UInt8}(undef, MAX_LINE_LENGTH)

  error_code = @ccall libexodus.ex_get_init(
    exo::Cint,
    title::Ptr{UInt8},
    num_dim::Ptr{B}, num_nodes::Ptr{B}, num_elems::Ptr{B},
    num_elem_blks::Ptr{B}, num_node_sets::Ptr{B}, num_side_sets::Ptr{B}
  )::Cint
  exodus_error_check(error_code, "Exodus.Initialization -> libexodus.ex_get_init")

  title = unsafe_string(pointer(title))

  return Initialization{B}(num_dim[], num_nodes[], num_elems[],
                           num_elem_blks[], num_node_sets[], num_side_sets[])
end

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


@with_kw struct ExodusDatabase{M, I, B, F}
  exo::Cint
  mode::String
  init::Initialization{B}
  # name to id dict for reducing allocations from access by name
  block_name_dict::Dict{String, I} = Dict{String, I}()
  nset_name_dict::Dict{String, I} = Dict{String, I}()
  sset_name_dict::Dict{String, I} = Dict{String, I}()
  # variables names
  element_var_name_dict::Dict{String, I} = Dict{String, I}()
  global_var_name_dict::Dict{String, I} = Dict{String, I}()
  nodal_var_name_dict::Dict{String, I} = Dict{String, I}()
  nset_var_name_dict::Dict{String, I} = Dict{String, I}()
  sset_var_name_dict::Dict{String, I} = Dict{String, I}()
  # cache arrays and variables
  use_cache_arrays::Bool
  cache_M::Vector{M} = M[]
  cache_I::Vector{I} = I[]
  cache_B_1::Vector{B} = B[]
  cache_B_2::Vector{B} = B[]
  cache_B_3::Vector{B} = B[]
  cache_F_1::Vector{F} = F[]
  cache_F_2::Vector{F} = F[]
  cache_F_3::Vector{F} = F[]
  cache_uint8::Vector{UInt8} = UInt8[]
  cache_strings::Vector{String} = String[]
end

"""
"""
function ExodusDatabase(
  exo::Cint, mode::String,
  ::Type{M}, ::Type{I}, ::Type{B}, ::Type{F};
  use_cache_arrays::Bool = false
) where {M, I, B, F}
  
  # get init
  init = Initialization(exo, B)
  return ExodusDatabase{M, I, B, F}(
    exo=exo, mode=mode, init=init, 
    use_cache_arrays=use_cache_arrays
  )
end

"""
"""
function ExodusDatabase(file_name::String, mode::String; use_cache_arrays::Bool = false)
  if mode == "r"
    ex_mode = EX_READ
  elseif mode == "rw" || (mode == "w" && !isfile(file_name))
    ex_mode = EX_WRITE
  elseif mode == "w" && isfile(file_name)
    ex_mode = EX_CLOBBER
  else
    mode_error(mode)
  end

  # get exodus
  if mode == "w" && !isfile(file_name)
    exo = @ccall libexodus.ex_create_int(
      file_name::Cstring, EX_WRITE::Cint, 
      cpu_word_size::Ref{Cint}, IO_word_size::Ref{Cint}, 
      EX_API_VERS_NODOT::Cint
    )::Cint
    exodus_error_check(exo, "Exodus.ExodusDatabase -> libexodus.ex_create_int")
  else
    exo = @ccall libexodus.ex_open_int(
      file_name::Cstring, ex_mode::Cint, 
      cpu_word_size::Ref{Cint}, IO_word_size::Ref{Cint}, 
      version_number::Ref{Cfloat}, EX_API_VERS_NODOT::Cint
    )::Cint
    exodus_error_check(exo, "Exodus.ExodusDatabase -> libexodus.ex_open_int")
  end

  int64_status = @ccall libexodus.ex_int64_status(exo::Cint)::UInt32
  float_size   = @ccall libexodus.ex_inquire_int(exo::Cint, EX_INQ_DB_FLOAT_SIZE::ex_inquiry)::Cint

  M = map_int_type(int64_status)
  I = id_int_type(int64_status)
  B = bulk_int_type(int64_status)
  F = float_type(float_size)

  if use_cache_arrays
    println("WARNING: Arrays returned from methods in this mode will change")
    println("WARNING: with subsequent method calls so use wisely!!!")
  end

  exo_db = ExodusDatabase(exo, mode, M, I, B, F; use_cache_arrays=use_cache_arrays)

  # set up set dicts
  block_ids   = read_ids(exo_db, Block)
  block_names = read_names(exo_db, Block)

  @assert length(block_ids) == length(block_names)

  for (n, name) in enumerate(block_names)
    exo_db.block_name_dict[name] = block_ids[n]
  end

  nset_ids   = read_ids(exo_db, NodeSet)
  nset_names = read_names(exo_db, NodeSet)

  @assert length(nset_ids) == length(nset_names)

  for (n, name) in enumerate(nset_names)
    exo_db.nset_name_dict[name] = nset_ids[n]
  end

  sset_ids   = read_ids(exo_db, SideSet)
  sset_names = read_names(exo_db, SideSet)

  for (n, name) in enumerate(sset_names)
    exo_db.sset_name_dict[name] = sset_ids[n]
  end

  # setup variable name dicts
  element_var_names = read_names(exo_db, Element)
  for (n, name) in enumerate(element_var_names)
    exo_db.element_var_name_dict[name] = n
  end

  global_var_names = read_names(exo_db, Global)
  for (n, name) in enumerate(global_var_names)
    exo_db.global_var_name_dict[name] = n
  end

  nodal_var_names = read_names(exo_db, Nodal)
  for (n, name) in enumerate(nodal_var_names)
    exo_db.nodal_var_name_dict[name] = n
  end

  nset_var_names = read_names(exo_db, NodeSetVariable)
  for (n, name) in enumerate(nset_var_names)
    exo_db.nset_var_name_dict[name] = n
  end

  sset_var_names = read_names(exo_db, SideSetVariable)
  for (n, name) in enumerate(sset_var_names)
    exo_db.sset_var_name_dict[name] = n
  end

  return exo_db
end

function ExodusDatabase(
  file_name::String, mode::String, init::Initialization{B},
  ::Type{M}, ::Type{I}, ::Type{B}, ::Type{F};
  use_cache_arrays = false
) where {M, I, B, F}
  
  if mode != "w"
    mode_error("You can only use write mode with this method!")
  end

  # trying out different float sizes
  exo = @ccall libexodus.ex_create_int(
    file_name::Cstring, EX_WRITE::Cint, 
    # sizeof(F)::Ref{Cint}, sizeof(F)::Ref{Cint}, 
    cpu_word_size::Ref{Cint}, sizeof(F)::Ref{Cint},
    EX_API_VERS_NODOT::Cint
  )::Cint
  exodus_error_check(exo, "Exodus.ExodusDatabase -> libexodus.ex_create_int")

  int_modes = 0x00000000
  if M == Int64
    int_modes = int_modes | EX_MAPS_INT64_API
  end

  if I == Int64
    int_modes = int_modes | EX_IDS_INT64_API
  end

  if B == Int64
    int_modes = int_modes | EX_BULK_INT64_API
  end

  if int_modes != 0x00000000
    error = @ccall libexodus.ex_set_int64_status(exo::Cint, int_modes::Cint)::Cint
    exodus_error_check(error, "Exodus.ExodusDatabase -> libexodus.ex_set_int64_status")
  end

  write_initialization!(exo, init)

  if use_cache_arrays
    println("WARNING: Arrays returned from methods in this mode will change")
    println("WARNING: with subsequent method calls so use wisely!!!")
  end

  # finally return the ExodusDatabase
  return ExodusDatabase{M, I, B, F}(
    exo=exo, mode=mode, init=init, use_cache_arrays=use_cache_arrays
  )
end

"""
Used to close and ExodusDatabase.
"""
function Base.close(exo::ExodusDatabase)
  error_code = @ccall libexodus.ex_close(get_file_id(exo)::Cint)::Cint
  exodus_error_check(error_code, "Exodus.close -> libexodus.ex_close")
end

"""
Used to copy an ExodusDatabase. As of right now this is the best way to create a new ExodusDatabase
for output. Not all of the put methods have been wrapped and properly tested. This one has though.
"""
function Base.copy(exo::E, new_file_name::String) where {E <: ExodusDatabase}
  int64_status = @ccall libexodus.ex_int64_status(get_file_id(exo)::Cint)::UInt32
  # TODO maybe make options an optional argument
  options = EX_CLOBBER | int64_status
  new_exo_id = @ccall libexodus.ex_create_int(
    new_file_name::Cstring, options::Cint, cpu_word_size::Ref{Cint}, IO_word_size::Ref{Cint}, EX_API_VERS_NODOT::Cint
  )::Cint
  exodus_error_check(new_exo_id, "Exodus.copy -> libexodus.ex_create_int")
  # first make a copy
  error_code = @ccall libexodus.ex_copy(get_file_id(exo)::Cint, new_exo_id::Cint)::Cint
  exodus_error_check(error_code, "Exodus.copy -> libexodus.ex_copy")
  # now close the exodus file
  error_code = @ccall libexodus.ex_close(new_exo_id::Cint)::Cint
  exodus_error_check(error_code, "Exodus.close -> libexodus.ex_close")
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

# helper method
Initialization(exo::ExodusDatabase{M, I, B, F}) where {M, I, B, F} = Initialization(exo.exo, B)

"""
"""
struct ModeException <: Exception
  mode::String
end
Base.show(io::IO, e::ModeException) = 
print(io, "Bad read/write mode: $(e.mode)", "\nAvailablae modes are \"r\"")

mode_error(mode::String) = throw(ModeException(mode))


"""
"""
struct SetIDException{M, I, B, F, V, I1 <: Integer} <: Exception 
  exo::ExodusDatabase{M, I, B, F}
  type::Type{V}
  id::I1
end

"""
"""
function Base.show(io::IO, e::SetIDException)
  print(io, "\nSet of type $(e.type) with ID \"$(e.id)\" not found.\n")
  print(io, "Available set IDs for type $(e.type) are:\n")
  for id in read_ids(e.exo, e.type)
    print(io, "  $id\n")
  end
end

"""
"""
struct SetNameException{M, I, B, F, V} <: Exception 
  exo::ExodusDatabase{M, I, B, F}
  type::Type{V}
  name::String
end

"""
"""
function Base.show(io::IO, e::SetNameException)
  print(io, "\nSet of type $(e.type) named \"$(e.name)\" not found.\n")
  print(io, "Available set names for type $(e.type) are:\n")
  for name in read_names(e.exo, e.type)
    print(io, "  $name\n")
  end
end

"""
"""
struct VariableIDException{M, I, B, F, V} <: Exception 
  exo::ExodusDatabase{M, I, B, F}
  type::Type{V}
  id::Int
end

"""
"""
function Base.show(io::IO, e::VariableIDException)
  print(io, "\nVariable of type $(e.type) with ID \"$(e.id)\" not found.\n")
  print(io, "Available variable IDs of type $(e.type) are:\n")
  # TODO TODO TODO might not be best
  for id in 1:read_number_of_variables(e.exo, e.type)
    print(io, "  $id\n")
  end
end

"""
"""
struct VariableNameException{M, I, B, F, V} <: Exception 
  exo::ExodusDatabase{M, I, B, F}
  type::Type{V}
  name::String
end

"""
"""
function Base.show(io::IO, e::VariableNameException)
  print(io, "\nVariable of type $(e.type) named \"$(e.name)\" not found.\n")
  print(io, "Available variable names of type $(e.type) are:\n")
  for name in read_names(e.exo, e.type)
    print(io, "  $name\n")
  end
end

# sets and blocks
abstract type AbstractExodusType end
abstract type AbstractSet{I, B} <: AbstractExodusType end
abstract type AbstractVariable <: AbstractExodusType end

id_error(exo, ::Type{t}, id) where t <: AbstractSet = throw(SetIDException(exo, t, id))
name_error(exo, ::Type{t}, name) where t <: AbstractSet = throw(SetNameException(exo, t, name))
id_error(exo, ::Type{t}, id) where t <: AbstractVariable = throw(VariableIDException(exo, t, id))
name_error(exo, ::Type{t}, name) where t <: AbstractVariable = throw(VariableNameException(exo, t, name))

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
  conn = read_block_connectivity(exo, 1, num_nodes * num_elem)

  conn_out = Matrix{get_bulk_int_type(exo)}(undef, num_nodes, num_elem)
  for e in axes(conn_out, 2)
    conn_out[:, e] = @views conn[(e - 1) * num_nodes + 1:e * num_nodes]
  end

  return Block{get_id_int_type(exo), get_bulk_int_type(exo)}(block_id, num_elem, num_nodes, element_type, conn_out)
end

"""
"""
function Block(exo::ExodusDatabase, name::String)
  if !(name in keys(exo.block_name_dict))
    name_error(exo, Block, name)
  end

  return Block(exo, exo.block_name_dict[name])
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
  if !(id in read_ids(exo, NodeSet))
    id_error(exo, NodeSet, id)
  end
  nodes = read_node_set_nodes(exo, id)

  nodes = copy(nodes) # need to copy here to be safe

  return NodeSet{I, B}(id, nodes)
end

"""
"""
function NodeSet(exo::ExodusDatabase, name::String)
  if !(name in keys(exo.nset_name_dict))
    throw(SetNameException(exo, NodeSet, name))
  end

  return NodeSet(exo, exo.nset_name_dict[name])
end

entries(n::NodeSet)     = n.nodes
extras(::NodeSet)       = C_NULL

"""
"""
Base.length(n::NodeSet) = length(n.nodes)

"""
"""
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
  if !(id in read_ids(exo, SideSet))
    id_error(exo, SideSet, id)
  end
  elements, sides = read_side_set_elements_and_sides(exo, id)

  elements = copy(elements)
  sides   = copy(sides)

  return SideSet{I, B}(id, elements, sides)
end

"""
"""
function SideSet(exo::ExodusDatabase, name::String)
  if !(name in keys(exo.sset_name_dict))
    name_error(exo, SideSet, name)
  end

  return SideSet(exo, exo.sset_name_dict[name])
end

entries(s::SideSet)     = s.elements
extras(s::SideSet)      = s.sides

"""
"""
Base.length(s::SideSet) = length(s.elements)

"""
"""
Base.show(io::IO, sset::SideSet) = 
print(
  io, "SideSet:\n",
  "\tSide set ID        = ", sset.id,               "\n",
  "\tNumber of elements = ", length(sset.elements), "\n",
  "\tNumber of sides    = ", length(sset.sides),    "\n"
)

"""
"""
struct Element <: AbstractVariable
end

"""
"""
struct Global <: AbstractVariable
end

"""
"""
struct Nodal <: AbstractVariable
end

"""
"""
struct NodeSetVariable <: AbstractVariable
end

"""
"""
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

set_equivalent(::Type{S}) where S <: Element         = Block
set_equivalent(::Type{S}) where S <: NodeSetVariable = NodeSet
set_equivalent(::Type{S}) where S <: SideSetVariable = SideSet

set_name_dict(exo::ExodusDatabase, ::Type{Block})   = exo.block_name_dict
set_name_dict(exo::ExodusDatabase, ::Type{NodeSet}) = exo.nset_name_dict
set_name_dict(exo::ExodusDatabase, ::Type{SideSet}) = exo.sset_name_dict

var_name_dict(exo::ExodusDatabase, ::Type{Element})         = exo.element_var_name_dict
var_name_dict(exo::ExodusDatabase, ::Type{Global})          = exo.global_var_name_dict
var_name_dict(exo::ExodusDatabase, ::Type{Nodal})           = exo.nodal_var_name_dict
var_name_dict(exo::ExodusDatabase, ::Type{NodeSetVariable}) = exo.nset_var_name_dict
var_name_dict(exo::ExodusDatabase, ::Type{SideSetVariable}) = exo.sset_var_name_dict

function set_var_name_index(exo::ExodusDatabase, ::Type{Element}, index::Integer, name::String) 
  exo.element_var_name_dict[name] = index
end

function set_var_name_index(exo::ExodusDatabase, ::Type{Global}, index::Integer, name::String) 
  exo.global_var_name_dict[name] = index
end

function set_var_name_index(exo::ExodusDatabase, ::Type{Nodal}, index::Integer, name::String) 
  exo.nodal_var_name_dict[name] = index
end

function set_var_name_index(exo::ExodusDatabase, ::Type{NodeSetVariable}, index::Integer, name::String) 
  exo.nset_var_name_dict[name] = index
end

function set_var_name_index(exo::ExodusDatabase, ::Type{SideSetVariable}, index::Integer, name::String) 
  exo.sset_var_name_dict[name] = index
end

function set_name_index(exo::ExodusDatabase, ::Type{V}, set_name::String) where V <: AbstractSet
  if !(set_name in keys(set_name_dict(exo, V)))
    name_error(exo, V, set_name)
  end
  return set_name_dict(exo, V)[set_name]
end

function var_name_index(exo::ExodusDatabase, ::Type{V}, var_name::String) where V <: AbstractVariable
  if !(var_name in keys(var_name_dict(exo, V)))
    name_error(exo, V, var_name)
  end
  return var_name_dict(exo, V)[var_name]
end
