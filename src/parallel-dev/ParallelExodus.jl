function read_init_info(exo::ExodusDatabase)
  num_proc      = Ref{Cint}(0)
  num_proc_in_f = Ref{Cint}(0)
  ftype         = Vector{UInt8}(undef, MAX_STR_LENGTH)
  error_code = @ccall libexodus.ex_get_init_info(
    get_file_id(exo)::Cint, num_proc::Ptr{Cint}, num_proc_in_f::Ptr{Cint}, ftype::Ptr{UInt8}
  )::Cint
  exodus_error_check(error_code, "Exodus.ParallelExodusDatabase -> libexodus.ex_get_init_info")
  return num_proc[], num_proc_in_f[], unsafe_string(pointer(ftype))
end

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

struct ParallelExodusDatabase{M, I, B, F, N}
  exos::Vector{ExodusDatabase{M, I, B, F}}
  nem::ExodusDatabase{M, I, B, Float32} # seems to be the case at least with Float32
  mode::String
  init_global::Initialization{B}
  lb_params::Vector{LoadBalanceParameters{B}}
end


function ParallelExodusDatabase(file_name::String, n_procs::Itype) where Itype <: Integer
  # first decomp, this will be the lazy constructor
  decomp(file_name, n_procs)
  # grab .g, .e, .exo, etc. files, but not the initial one
  exo_files = Vector{String}(undef, n_procs)
  ext = splitext(file_name)[2]
  exo_files = filter(x -> occursin("$ext.", x) && occursin(".$n_procs.", x), readdir(dirname(file_name)))
  sort!(exo_files)
  exo_files = map(x -> joinpath(dirname(file_name), x), exo_files)
  # grab the nem file
  nem_file = file_name * ".nem"

  # more efficient ways to do below
  exos        = Vector{ExodusDatabase}(undef, n_procs)
  nem         = ExodusDatabase(nem_file, "r")
  mode        = "r" # TODO hardcoded for now
  M, I, B     = exo_int_types(get_file_id(nem))
  F           = exo_float_type(get_file_id(nem))
  init_global = InitializationGlobal(nem) # just to make it in this scope
  lb_params   = Vector{LoadBalanceParameters{B}}(undef, n_procs)
  # TODO could be an error here assuming all are the same
  # maybe do a more rigourous error check later
  for (n, exo_file) in enumerate(exo_files)
    proc_id      = parse(Int64, split(exo_file, ".")[end])
    exo          = ExodusDatabase(exo_file, "r")
    exos[n]      = exo
    init_global  = InitializationGlobal(exo)
    lb_params[n] = LoadBalanceParameters(exo, proc_id) 
    F            = exo_float_type(get_file_id(exo))
  end
  return ParallelExodusDatabase{M, I, B, F, n_procs}(
    exos, nem, mode, init_global, lb_params
  )
end

function Base.close(p::ParallelExodusDatabase)
  for exo in p.exos
    close(exo)
  end
  close(p.nem)
end

struct CommunicationMapParameters{B}
  node_cmap_ids::Vector{B}
  node_cmap_node_cnts::Vector{B}
  elem_cmap_ids::Vector{B}
  elem_cmap_elem_cnts::Vector{B}
end

function CommunicationMapParameters(exo::ParallelExodusDatabase{M, I, B, F, N}, processor::Itype) where {M, I, B, F, N, Itype}
  node_cmap_ids       = Vector{B}(undef, exo.lb_params[processor].num_node_cmaps)
  node_cmap_node_cnts = Vector{B}(undef, exo.lb_params[processor].num_node_cmaps)
  elem_cmap_ids       = Vector{B}(undef, exo.lb_params[processor].num_elem_cmaps)
  elem_cmap_elem_cnts = Vector{B}(undef, exo.lb_params[processor].num_elem_cmaps)
  error_code = @ccall libexodus.ex_get_cmap_params(
    get_file_id(exo.exos[processor])::Cint,
    node_cmap_ids::Ptr{B}, node_cmap_node_cnts::Ptr{B},
    elem_cmap_ids::Ptr{B}, elem_cmap_elem_cnts::Ptr{B},
    processor::Cint
  )::Cint
  exodus_error_check(error_code, "Exodus.CommunicationMapParameters -> libexodus.ex_get_cmap_params")
  return CommunicationMapParameters{B}(
    node_cmap_ids, node_cmap_node_cnts,
    elem_cmap_ids, elem_cmap_elem_cnts
  )
end

function CommunicationMapParameters(exo::ParallelExodusDatabase{M, I, B, F, N}) where {M, I, B, F, N}
  cmap_params = Vector{CommunicationMapParameters{B}}(undef, length(exo.exos))
  for n in 1:length(exo.exos)
    cmap_params[n] = CommunicationMapParameters(exo, n)
  end
  return cmap_params
end

# function NodecommunicationMap(exo::ExodusDatabase{M, I, B, F}, node_map_id::Itype, processor::Itype) where {M, I, B, F, Itype <: Integer}
#   ids::Vector{B}(undef)

# end

export LoadBalanceParameters
export ParallelExodusDatabase
