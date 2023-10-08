"""
"""
function read_init_info(exo::ExodusDatabase)
  num_proc      = Ref{Cint}(0)
  num_proc_in_f = Ref{Cint}(0)
  # ftype         = Vector{UInt8}(undef, MAX_STR_LENGTH)
  ftype         = exo.cache_uint8
  resize!(ftype, MAX_STR_LENGTH)
  error_code = @ccall libexodus.ex_get_init_info(
    get_file_id(exo)::Cint, num_proc::Ptr{Cint}, num_proc_in_f::Ptr{Cint}, ftype::Ptr{UInt8}
  )::Cint
  exodus_error_check(error_code, "Exodus.ParallelExodusDatabase -> libexodus.ex_get_init_info")
  return num_proc[], num_proc_in_f[], unsafe_string(pointer(ftype))
end

"""
"""
function InitializationGlobal(exo::ExodusDatabase{M, I, B, F}) where {M, I, B, F}
  num_nodes     = Ref{B}(0)
  num_elem      = Ref{B}(0)
  num_elem_blk  = Ref{B}(0)
  num_node_sets = Ref{B}(0)
  num_side_sets = Ref{B}(0)
  error_code = @ccall libexodus.ex_get_init_global(
    get_file_id(exo)::Cint, num_nodes::Ptr{Cint}, num_elem::Ptr{Cint},
    num_elem_blk::Ptr{Cint}, num_node_sets::Ptr{Cint}, num_side_sets::Ptr{Cint}
  )::Cint
  exodus_error_check(error_code, "Exodus.read_init_global -> libexodus.ex_get_init_global")
  return Initialization(
    exo.init.num_dim, num_nodes[], num_elem[],
    num_elem_blk[], num_node_sets[], num_side_sets[]
  )
end

"""
"""
struct LoadBalanceParameters{B}
  num_int_nodes::B
  num_bor_nodes::B
  num_ext_nodes::B
  num_int_elems::B
  num_bor_elems::B
  num_node_cmaps::B
  num_elem_cmaps::B
  processor::Cint
end

"""
"""
Base.show(io::IO, init::LoadBalanceParameters) =
print(
  io, "Initialization:\n",
      "\tNumber of interior nodes             = ", init.num_int_nodes, "\n",
      "\tNumber of border nodes               = ", init.num_bor_nodes, "\n",
      "\tNumber of external nodes             = ", init.num_ext_nodes, "\n",
      "\tNumber of interior elements          = ", init.num_int_elems, "\n",
      "\tNumber of border elements            = ", init.num_bor_elems, "\n",
      "\tNumber of node communication maps    = ", init.num_node_cmaps, "\n",
      "\tNumber of element communication maps = ", init.num_elem_cmaps, "\n",
      "\tProcessor                            = ", init.processor, "\n"
)

"""
"""
function LoadBalanceParameters(exo::ExodusDatabase{M, I, B, F}, processor::Itype) where {M, I, B, F, Itype <: Integer}
  num_int_nodes  = Ref{B}(0)
  num_bor_nodes  = Ref{B}(0)
  num_ext_nodes  = Ref{B}(0)
  num_int_elems  = Ref{B}(0)
  num_bor_elems  = Ref{B}(0)
  num_node_cmaps = Ref{B}(0)
  num_elem_cmaps = Ref{B}(0)
  error_code = @ccall libexodus.ex_get_loadbal_param(
    get_file_id(exo)::Cint,
    num_int_nodes::Ptr{B}, num_bor_nodes::Ptr{B}, num_ext_nodes::Ptr{B},
    num_int_elems::Ptr{B}, num_bor_elems::Ptr{B},
    num_node_cmaps::Ptr{B}, num_elem_cmaps::Ptr{B},
    processor::Cint
  )::Cint
  exodus_error_check(error_code, "Exodus.LoadBalanceParameters -> libexodus.ex_get_loadbal_param")
  return LoadBalanceParameters{B}(
    num_int_nodes[], num_bor_nodes[], num_ext_nodes[],
    num_int_elems[], num_bor_elems[],
    num_node_cmaps[], num_elem_cmaps[],
    processor + 1
  )
end

"""
"""
struct CommunicationMapParameters{B}
  node_cmap_ids::Vector{B} # this appears to be 0-based
  node_cmap_node_cnts::Vector{B}
  elem_cmap_ids::Vector{B} # this appears to be 0-based
  elem_cmap_elem_cnts::Vector{B}
end

"""
"""
Base.show(io::IO, cmap_params::CommunicationMapParameters) = 
print(
  io, "CommunicationMapParameters:\n",
      "\tNode communication map ids               = ", cmap_params.node_cmap_ids, "\n",
      "\tNode communication map node counts       = ", cmap_params.node_cmap_node_cnts, "\n",
      "\tElement communication map ids            = ", cmap_params.elem_cmap_ids, "\n",
      "\tElement communication map element counts = ", cmap_params.elem_cmap_elem_cnts, "\n"
)

"""
"""
function CommunicationMapParameters(exo::ExodusDatabase{M, I, B, F}, lb_params::LoadBalanceParameters{B}, processor::Itype) where {M, I, B, F, Itype <: Integer}
  node_cmap_ids       = Vector{B}(undef, lb_params.num_node_cmaps)
  node_cmap_node_cnts = Vector{B}(undef, lb_params.num_node_cmaps)
  elem_cmap_ids       = Vector{B}(undef, lb_params.num_elem_cmaps)
  elem_cmap_elem_cnts = Vector{B}(undef, lb_params.num_elem_cmaps)
  error_code = @ccall libexodus.ex_get_cmap_params(
    get_file_id(exo)::Cint,
    node_cmap_ids::Ptr{B}, node_cmap_node_cnts::Ptr{B},
    elem_cmap_ids::Ptr{B}, elem_cmap_elem_cnts::Ptr{B},
    processor::Cint
  )::Cint
  exodus_error_check(error_code, "Exodus.CommunicationMapParameters -> libexodus.ex_get_cmap_params")
  return CommunicationMapParameters{B}(
    node_cmap_ids .+ 1, node_cmap_node_cnts,
    elem_cmap_ids .+ 1, elem_cmap_elem_cnts
  ) # Note we added 1 to the cmap ids, we'll need to subtract it downstream. 
    # this is so it's in a julia indexing
end

"""
"""
struct ParallelExodusDatabase{M, I, B, F, N}
  base_file_name::String
  exos::Vector{ExodusDatabase{M, I, B, F}}
  nem::ExodusDatabase{M, I, B, Float32} # seems to be the case at least with Float32
  mode::String
  init_global::Initialization{B}
  lb_params::Vector{LoadBalanceParameters{B}}
  cmap_params::Vector{CommunicationMapParameters{B}}
end

"""
"""
function ParallelExodusDatabase(file_name::String, n_procs::Itype; use_cache_arrays::Bool = false) where Itype <: Integer
  
  exo_files = Vector{String}(undef, n_procs)
  # grab the nem file
  if n_procs < 10
    pad_size = 1
  elseif n_procs < 100
    pad_size = 2
  elseif n_procs < 1000
    pad_size = 3
  elseif n_procs < 10000
    pad_size = 4
  else
    throw(ErrorException("Holy crap that's a big mesh. We need to check if we support that!"))
  end

  for n in axes(exo_files, 1)
    exo_files[n] = file_name * ".$(n_procs).$(lpad(n - 1, pad_size, "0"))"
  end

  nem_file = file_name * ".nem"

  # more efficient ways to do below
  # exos        = Vector{ExodusDatabase}(undef, n_procs)
  nem         = ExodusDatabase(nem_file, "r"; use_cache_arrays=use_cache_arrays)
  mode        = "r" # TODO hardcoded for now
  M, I, B, F = int_and_float_modes(get_file_id(nem))
  init_global = InitializationGlobal(nem) # just to make it in this scope
  lb_params   = Vector{LoadBalanceParameters{B}}(undef, n_procs)
  cmap_params = Vector{CommunicationMapParameters{B}}(undef, n_procs)

  # temp
  exo = ExodusDatabase(exo_files[1], "r"; use_cache_arrays=use_cache_arrays)
  M, I, B, F = int_and_float_modes(get_file_id(exo))
  close(exo)

  exos = Vector{ExodusDatabase{M, I, B, F}}(undef, n_procs)

  # TODO could be an error here assuming all are the same
  # maybe do a more rigourous error check later
  for (n, exo_file) in enumerate(exo_files)
    proc_id        = parse(Int64, split(exo_file, ".")[end])
    exo            = ExodusDatabase(exo_file, "r"; use_cache_arrays=use_cache_arrays)
    exos[n]        = exo
    init_global    = InitializationGlobal(exo)
    lb_params[n]   = LoadBalanceParameters(exo, proc_id) 
    cmap_params[n] = CommunicationMapParameters(exo, lb_params[n], proc_id)
  end

  return ParallelExodusDatabase{M, I, B, F, n_procs}(
    file_name, exos, nem, mode, init_global, lb_params, cmap_params
  )
end

"""
"""
function Base.show(io::IO, exo::ParallelExodusDatabase{M, I, B, F, N}) where {M, I, B, F, N}
  print(
    io,
    "ParallelExodusDatabase:\n",
    "  Base file name       = $(exo.base_file_name)\n",
    "  Mode                 = $(exo.mode)\n",
    "  Number of processors = $N\n",
    "\n",
    "$(exo.init_global)\n"
  )
  print(io, "\n")
  # print(
  #   io,
  #   "Nemesis file:\n",
  #   "$(exo.nem)"
  # )
  perm = 3
  for type in [ElementVariable, GlobalVariable, NodalVariable, NodeSetVariable, SideSetVariable]
    print(io, "$(type):\n")
    for (n, name) in enumerate(keys(var_name_dict(exo.exos[1], type)))
      print(io, rpad("  $name", MAX_STR_LENGTH))
      if (n % perm == 0) && (n != length(keys(var_name_dict(exo.exos[1], type))))
        print(io, "\n")
      end
    end
    print(io, "\n\n")
  end
end

"""
"""
function Base.close(p::ParallelExodusDatabase)
  for exo in p.exos
    close(exo)
  end
  close(p.nem)
end

"""
"""
struct NodeCommunicationMap{B}
  node_ids::Vector{B}
  proc_ids::Vector{B}
end

"""
"""
function NodeCommunicationMap(exo::ParallelExodusDatabase{M, I, B, F, N}, node_map_id::Itype, processor::Itype) where {M, I, B, F, N, Itype <: Integer}
  index = findall(x -> x == node_map_id, exo.cmap_params[processor].node_cmap_ids)
  if length(index) == 0
    error(ErrorException("Invalid node map id"))
  end
  index = index[1]

  node_ids = Vector{B}(undef, exo.cmap_params[processor].node_cmap_node_cnts[index])
  proc_ids = Vector{B}(undef, exo.cmap_params[processor].node_cmap_node_cnts[index])

  error_code = @ccall libexodus.ex_get_node_cmap(
    get_file_id(exo.exos[processor])::Cint, (node_map_id - 1)::Clonglong, # really ex_entity_id
    node_ids::Ptr{B}, proc_ids::Ptr{B},
    processor::Cint
  )::Cint
  exodus_error_check(error_code, "Exodus.NodeCommunicationMap -> libexodus.ex_get_node_cmap")
  return NodeCommunicationMap{B}(node_ids, proc_ids .+ 1) # note adding 1 to proc ids to make them julia indexed
end

"""
"""
struct ElementCommunicationMap{B}
  elem_ids::Vector{B}
  side_ids::Vector{B}
  proc_ids::Vector{B}
end

"""
"""
function ElementCommunicationMap(exo::ParallelExodusDatabase{M, I, B, F, N}, elem_map_id::Itype, processor::Itype) where {M, I, B, F, N, Itype <: Integer}
  index = findall(x -> x == elem_map_id, exo.cmap_params[processor].elem_cmap_ids)
  if length(index) == 0
    error(ErrorException("Invalid element map id"))
  end
  index = index[1]

  elem_ids = Vector{B}(undef, exo.cmap_params[processor].elem_cmap_elem_cnts[index])
  side_ids = Vector{B}(undef, exo.cmap_params[processor].elem_cmap_elem_cnts[index])
  proc_ids = Vector{B}(undef, exo.cmap_params[processor].elem_cmap_elem_cnts[index])

  error_code = @ccall libexodus.ex_get_elem_cmap(
    get_file_id(exo.exos[processor])::Cint, (elem_map_id - 1)::Clonglong, # really ex_entity_id
    elem_ids::Ptr{B}, side_ids::Ptr{B}, proc_ids::Ptr{B},
    processor::Cint
  )::Cint
  exodus_error_check(error_code, "Exodus.ElementCommunicationMap -> libexodus.ex_get_elem_cmap")
  return ElementCommunicationMap{B}(elem_ids, side_ids, proc_ids .+ 1) # note adding 1 to proc ids to make them julia indexed
end

"""
"""
struct ProcessorNodeMaps{B}
  node_map_internal::Vector{B}
  node_map_border::Vector{B}
  node_map_external::Vector{B}
end

"""
"""
function ProcessorNodeMaps(exo::ParallelExodusDatabase{M, I, B, F, N}, processor::Itype) where {M, I, B, F, N, Itype}
  node_map_internal = Vector{B}(undef, exo.lb_params[processor].num_int_nodes)
  node_map_border   = Vector{B}(undef, exo.lb_params[processor].num_bor_nodes)
  node_map_external = Vector{B}(undef, exo.lb_params[processor].num_ext_nodes)
  
  error_code = @ccall libexodus.ex_get_processor_node_maps(
    get_file_id(exo.exos[processor])::Cint, 
    node_map_internal::Ptr{B}, node_map_border::Ptr{B}, node_map_external::Ptr{B},
    processor::Cint
  )::Cint
  exodus_error_check(error_code, "Exodus.ProcessorNodeMap -> libexodus.ex_get_processor_node_maps")
  return ProcessorNodeMaps{B}(node_map_internal, node_map_border, node_map_external)
end

"""
"""
struct ProcessorElementMaps{B}
  elem_map_internal::Vector{B}
  elem_map_border::Vector{B}
end

"""
"""
function ProcessorElementMaps(exo::ParallelExodusDatabase{M, I, B, F, N}, processor::Itype) where {M, I, B, F, N, Itype}
  elem_map_internal = Vector{B}(undef, exo.lb_params[processor].num_int_elems)
  elem_map_border   = Vector{B}(undef, exo.lb_params[processor].num_bor_elems)

  error_code = @ccall libexodus.ex_get_processor_elem_maps(
    get_file_id(exo.exos[processor])::Cint,
    elem_map_internal::Ptr{B}, elem_map_border::Ptr{B},
    processor::Cint
  )::Cint
  exodus_error_check(error_code, "Exodus.ProcessorElementMaps -> libexodus.ex_get_processor_elem_maps")
  return ProcessorElementMaps{B}(elem_map_internal, elem_map_border)
end


# WARNING: these commands are meant for threaded julia
# as a way to do pre-processing on a presonal machine.
# These are not meant for large number of procs or distributed.

"""
"""
# function read_coordinates(exo::ParallelExodusDatabase{M, I, B, F, N}) where {M, I, B, F, N}
#   return read_coordinates.(exo.exos)
# end

"""
"""
read_coordinates(exo::ParallelExodusDatabase) = 
read_coordinates.(exo.exos)

"""
"""
read_ids(exo::ParallelExodusDatabase, type::Type{T}) where T <: AbstractExodusSet = 
read_ids.(exo.exos, (type,))

"""
"""
read_names(exo::ParallelExodusDatabase, type::Type{T}) where T <: Union{AbstractExodusSet, AbstractExodusVariable} = 
read_names.(exo.exos, (type,))

"""
"""
read_set(exo::ParallelExodusDatabase, type::Type{T}, id::I) where {T, I} = 
read_set.(exo.exos, (type,), (id,))

"""
"""
read_sets(exo::ParallelExodusDatabase, type::Type{T}) where T <: AbstractExodusSet = 
read_sets.(exo.exos, (type,))

"""
"""
read_number_of_variables(exo::ParallelExodusDatabase, type::Type{T}) where T <: AbstractExodusVariable = 
read_number_of_variables.(exo.exos, (type,))

"""
"""
read_values(exo::ParallelExodusDatabase, type::Type{T}, time_step::Int, id::Int, var_index::Int) where T <: AbstractExodusSet = 
read_values.(exo.exos, (type,), (time_step,), (id,), (var_index,))


"""
Wrapper method for global variables around the main read_values method
read_values(exo::ParallelExodusDatabase, t::Type{GlobalVariable}, timestep::Integer) = read_values(exo, (t,), (timestep,), (1,), (1,))

Example:
read_values(exo, GlobalVariable, 1)
"""
read_values(exo::ParallelExodusDatabase, t::Type{GlobalVariable}, timestep::Integer) = 
read_values.(exo.exos, (t,), (timestep,), (1,), (1,))

"""
Wrapper method for nodal variables
"""
read_values(exo::ParallelExodusDatabase, t::Type{NodalVariable}, timestep::Integer, index::Integer) = 
read_values.(exo.exos, (t,), (timestep,), (1,), (index,))

"""
"""
read_values(exo::ParallelExodusDatabase, type::Type{V}, time_step::Integer, id::Integer, var_name::String) where V <: AbstractExodusVariable = 
read_values.(exo.exos, (type,), (time_step,), (id,), (var_name,))

"""
Wrapper method for nodal variables
"""
read_values(exo::ParallelExodusDatabase, t::Type{NodalVariable}, timestep::Integer, name::String) = 
read_values.(exo.exos, (t,), (timestep,), (1,), (name,))

"""
"""
read_values(
  exo::ParallelExodusDatabase, type::Type{V}, 
  time_step::Integer, set_name::String, var_name::String
) where V <: AbstractExodusVariable = 
read_values.(exo.exo, (type,), (time_step,), (set_name,), (var_name,))
