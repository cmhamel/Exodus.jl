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
  end

  if float_size == 4
    F = Cfloat
  elseif float_size == 8
    F = Cdouble
  end

  return M, I, B, F
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
      "  Number of dim       = ", init.num_dim, "\n",
      "  Number of nodes     = ", init.num_nodes, "\n",
      "  Number of elem      = ", init.num_elems, "\n",
      "  Number of blocks    = ", init.num_elem_blks, "\n",
      "  Number of node sets = ", init.num_node_sets, "\n",
      "  Number of side sets = ", init.num_side_sets, "\n"
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


# sets and blocks
abstract type AbstractExodusType end
abstract type AbstractExodusMap <: AbstractExodusType end
abstract type AbstractExodusSet{I, A} <: AbstractExodusType end
abstract type AbstractExodusVariable <: AbstractExodusType end


@with_kw_noshow struct ExodusDatabase{M, I, B, F}
  exo::Cint
  mode::String
  file_name::String
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
end

# Maps
"""
"""
struct NodeMap <: AbstractExodusMap
end

"""
"""
struct ElementMap <: AbstractExodusMap
end

"""
"""
struct FaceMap <: AbstractExodusMap
end

"""
"""
struct EdgeMap <: AbstractExodusMap
end

# TODO add face and edge maps

"""
"""
struct Block{I, A <: AbstractMatrix} <: AbstractExodusSet{I, A}
  id::I
  num_elem::Clonglong
  num_nodes_per_elem::Clonglong
  elem_type::String # TODO maybe just make an index
  conn::A
end

"""
"""
struct NodeSet{I, A <: AbstractVector} <: AbstractExodusSet{I, A}
  id::I
  nodes::A
end

"""
"""
struct SideSet{I, A <: AbstractVector} <: AbstractExodusSet{I, A}
  id::I
  elements::A
  sides::A
end

"""
"""
struct ElementVariable <: AbstractExodusVariable
end

"""
"""
struct GlobalVariable <: AbstractExodusVariable
end

"""
"""
struct NodalVariable <: AbstractExodusVariable
end

"""
"""
struct NodeSetVariable <: AbstractExodusVariable
end

"""
"""
struct SideSetVariable <: AbstractExodusVariable
end

set_name_dict(exo::ExodusDatabase, ::Type{Block})   = exo.block_name_dict
set_name_dict(exo::ExodusDatabase, ::Type{NodeSet}) = exo.nset_name_dict
set_name_dict(exo::ExodusDatabase, ::Type{SideSet}) = exo.sset_name_dict

var_name_dict(exo::ExodusDatabase, ::Type{ElementVariable}) = exo.element_var_name_dict
var_name_dict(exo::ExodusDatabase, ::Type{GlobalVariable})  = exo.global_var_name_dict
var_name_dict(exo::ExodusDatabase, ::Type{NodalVariable})   = exo.nodal_var_name_dict
var_name_dict(exo::ExodusDatabase, ::Type{NodeSetVariable}) = exo.nset_var_name_dict
var_name_dict(exo::ExodusDatabase, ::Type{SideSetVariable}) = exo.sset_var_name_dict

"""
"""
function ExodusDatabase(
  exo::Cint, mode::String, file_name::String,
  ::Type{M}, ::Type{I}, ::Type{B}, ::Type{F}
) where {M, I, B, F}
  
  # get init
  init = Initialization(exo, B)
  return ExodusDatabase{M, I, B, F}(
    exo=exo, mode=mode, file_name=file_name, init=init
  )
end

"""
"""
function ExodusDatabase(file_name::String, mode::String)
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

  M, I, B, F = int_and_float_modes(exo)

  exo_db = ExodusDatabase(exo, mode, file_name, M, I, B, F)

  # set up set dicts
  for type in [Block, NodeSet, SideSet]
    ids   = read_ids(exo_db, type)
    names = read_names(exo_db, type)
    for (n, name) in enumerate(names)
      set_name_dict(exo_db, type)[name] = ids[n]
    end
  end

  for type in [ElementVariable, GlobalVariable, NodalVariable, NodeSetVariable, SideSetVariable]
    ids   = 1:read_number_of_variables(exo_db, type)
    names = read_names(exo_db, type)
    for (n, name) in enumerate(names)
      var_name_dict(exo_db, type)[name] = ids[n]
    end
  end

  return exo_db
end

function ExodusDatabase(
  file_name::String, mode::String, init::Initialization{B},
  ::Type{M}, ::Type{I}, ::Type{B}, ::Type{F}
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

  # finally return the ExodusDatabase
  return ExodusDatabase{M, I, B, F}(
    exo=exo, mode=mode, file_name=file_name, init=init
  )
end

function Base.show(io::IO, exo::ExodusDatabase) 
  print(
    io,
    "ExodusDatabase:\n",
    "  File name                   = $(exo.file_name)\n",
    "  Mode                        = $(exo.mode)\n",
    "\n",
    "$(exo.init)\n"
  )

  perm = 4
  for type in [Block, NodeSet, SideSet]
    if keys(set_name_dict(exo, type)) |> length > 0
      print(io, "$(type):\n")
      for (n, name) in enumerate(keys(set_name_dict(exo, type)) |> collect |> sort)
        print(io, rpad("  $name", MAX_STR_LENGTH))
        if (n % perm == 0) && (n != length(keys(set_name_dict(exo, type))))
          print(io, "\n")
        end
      end
      print(io, "\n\n")
    end
  end

  perm = 4
  for type in [ElementVariable, GlobalVariable, NodalVariable, NodeSetVariable, SideSetVariable]
    if keys(var_name_dict(exo, type)) |> length > 0
      print(io, "$(type):\n")
      for (n, name) in enumerate(keys(var_name_dict(exo, type)) |> collect |> sort)
        print(io, rpad("  $name", MAX_STR_LENGTH))
        if (n % perm == 0) && (n != length(keys(var_name_dict(exo, type))))
          print(io, "\n")
        end
      end
      print(io, "\n\n")
    end
  end
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

"""
Simpler copy method to only copy a mesh for output later on
"""
function copy_mesh(file_name::String, new_file_name::String)
  exo = ExodusDatabase(file_name, "r")
  copy(exo, new_file_name)
  close(exo)
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
print(io, "Bad read/write mode: $(e.mode)", "\nAvailable modes are \"r\", \"rw\", and \"w\"")

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

id_error(exo, ::Type{t}, id) where t <: AbstractExodusSet = throw(SetIDException(exo, t, id))
name_error(exo, ::Type{t}, name) where t <: AbstractExodusSet = throw(SetNameException(exo, t, name))
id_error(exo, ::Type{t}, id) where t <: AbstractExodusVariable = throw(VariableIDException(exo, t, id))
name_error(exo, ::Type{t}, name) where t <: AbstractExodusVariable = throw(VariableNameException(exo, t, name))

"""
Init method for block container.
"""
function Block(exo::ExodusDatabase, block_id::Integer)
  block_id = convert(get_id_int_type(exo), block_id) # for convenience interfacing
  element_type, num_elem, num_nodes, _, _, _ =
  read_block_parameters(exo, block_id)
  conn = read_block_connectivity(exo, block_id, num_nodes * num_elem)

  conn_out = Matrix{get_bulk_int_type(exo)}(undef, num_nodes, num_elem)
  for e in axes(conn_out, 2)
    conn_out[:, e] = @views conn[(e - 1) * num_nodes + 1:e * num_nodes]
  end

  # return Block{get_id_int_type(exo), get_bulk_int_type(exo)}(block_id, num_elem, num_nodes, element_type, conn_out)
  return Block{get_id_int_type(exo), typeof(conn_out)}(block_id, num_elem, num_nodes, element_type, conn_out)
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
      "  Block ID           = ", block.id, "\n",
      "  Num elem           = ", block.num_elem, "\n",
      "  Num nodes per elem = ", block.num_nodes_per_elem, "\n",
      "  Elem type          = ", block.elem_type, "\n")

"""
"""
function NodeSet(exo::ExodusDatabase{M, I, B, F}, id::Integer) where {M, I, B, F}
  if !(id in read_ids(exo, NodeSet))
    id_error(exo, NodeSet, id)
  end
  nodes = read_node_set_nodes(exo, id)

  nodes = copy(nodes) # need to copy here to be safe

  # return NodeSet{I, B}(id, nodes)
  # return NodeSet{I, typeof(nodes)}(id, nodes)
  return NodeSet(id, nodes)
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
  "  Node set ID     = ", node_set.id,      "\n",
  "  Number of nodes = ", length(node_set), "\n"
)

"""
"""
function SideSet(exo::ExodusDatabase{M, I, B, F}, id::Integer) where {M, I, B, F}
  if !(id in read_ids(exo, SideSet))
    id_error(exo, SideSet, id)
  end
  elements, sides = read_side_set_elements_and_sides(exo, id)

  elements = copy(elements)
  sides   = copy(sides)

  # return SideSet{I, B}(id, elements, sides)
  return SideSet{I, typeof(elements)}(id, elements, sides)
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
  "  Side set ID        = ", sset.id,               "\n",
  "  Number of elements = ", length(sset.elements), "\n",
  "  Number of sides    = ", length(sset.sides),    "\n"
)

entity_type(::Type{S}) where S <: NodeMap         = EX_NODE_MAP
entity_type(::Type{S}) where S <: ElementMap      = EX_ELEM_MAP
entity_type(::Type{S}) where S <: FaceMap         = EX_FACE_MAP
entity_type(::Type{S}) where S <: EdgeMap         = EX_EDGE_MAP
entity_type(::Type{S}) where S <: Block           = EX_ELEM_BLOCK
entity_type(::Type{S}) where S <: ElementVariable = EX_ELEM_BLOCK
entity_type(::Type{S}) where S <: GlobalVariable  = EX_GLOBAL
entity_type(::Type{S}) where S <: NodalVariable   = EX_NODAL
entity_type(::Type{S}) where S <: NodeSet         = EX_NODE_SET
entity_type(::Type{S}) where S <: NodeSetVariable = EX_NODE_SET
entity_type(::Type{S}) where S <: SideSet         = EX_SIDE_SET
entity_type(::Type{S}) where S <: SideSetVariable = EX_SIDE_SET

set_equivalent(::Type{S}) where S <: ElementVariable         = Block
set_equivalent(::Type{S}) where S <: NodeSetVariable = NodeSet
set_equivalent(::Type{S}) where S <: SideSetVariable = SideSet

function set_var_name_index(exo::ExodusDatabase, ::Type{ElementVariable}, index::Integer, name::String) 
  exo.element_var_name_dict[name] = index
end

function set_var_name_index(exo::ExodusDatabase, ::Type{GlobalVariable}, index::Integer, name::String) 
  exo.global_var_name_dict[name] = index
end

function set_var_name_index(exo::ExodusDatabase, ::Type{NodalVariable}, index::Integer, name::String) 
  exo.nodal_var_name_dict[name] = index
end

function set_var_name_index(exo::ExodusDatabase, ::Type{NodeSetVariable}, index::Integer, name::String) 
  exo.nset_var_name_dict[name] = index
end

function set_var_name_index(exo::ExodusDatabase, ::Type{SideSetVariable}, index::Integer, name::String) 
  exo.sset_var_name_dict[name] = index
end

function set_name_index(exo::ExodusDatabase, ::Type{V}, set_name::String) where V <: AbstractExodusSet
  if !(set_name in keys(set_name_dict(exo, V)))
    name_error(exo, V, set_name)
  end
  return set_name_dict(exo, V)[set_name]
end

function var_name_index(exo::ExodusDatabase, ::Type{V}, var_name::String) where V <: AbstractExodusVariable
  if !(var_name in keys(var_name_dict(exo, V)))
    name_error(exo, V, var_name)
  end
  return var_name_dict(exo, V)[var_name]
end
