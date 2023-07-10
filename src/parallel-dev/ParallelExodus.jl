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
  exos::Vector{Cint}
  nem::Cint
  mode::String
  init_global::Initialization{B}
  inits::Vector{Initialization{B}}
  lb_params::Vector{LoadBalanceParameters{B}}
end

function ParallelExodusDatabase(file_name::String, n_procs::Itype) where Itype <: Integer
  # first decomp, this will be the lazy constructor
  decomp(file_name, n_procs)
  # grab .g, .e, .exo, etc. files, but not the initial one
  exo_files = Vector{String}(undef, n_procs)
  for n in 0:n_procs - 1
    exo_files[n + 1] = file_name * ".$n_procs.$n"
  end
  # grab the nem file
  nem_file = file_name * ".nem"

  exos = Vector{Cint}(undef, n_procs)
  nem = ExodusDatabase(nem_file, "r")
  mode = "r" # TODO hardcoded for now
  M, I, B = exo_int_types(get_file_id(nem))
  F       = exo_float_type(get_file_id(nem))
  init_global = InitializationGlobal(nem)
  inits = Vector{Initialization{B}}(undef, n_procs)
  lb_params = Vector{LoadBalanceParameters{B}}(undef, n_procs)
  # TODO could be an error here assuming all are the same
  # maybe do a more rigourous error check later
  for (n, exo_file) in enumerate(exo_files)
    proc_id = parse(Int64, split(exo_file, ".")[end])
    exo = ExodusDatabase(exo_file, "r")
    exos[n] = get_file_id(exo)
    init_global = InitializationGlobal(exo)
    inits[n] = get_init(exo)
    lb_params[n] = LoadBalanceParameters(exo, proc_id) 
    F = exo_float_type(get_file_id(exo))
  end
  return ParallelExodusDatabase{M, I, B, F, n_procs}(
    exos, get_file_id(nem), mode, init_global, inits, lb_params
  )
end

function Base.close(p::ParallelExodusDatabase)
  for exo in p.exos
    error_code = @ccall libexodus.ex_close(exo::Cint)::Cint
    exodus_error_check(error_code, "Exodus.close -> libexodus.ex_close")
  end
  error_code = @ccall libexodus.ex_close(p.nem::Cint)::Cint
  exodus_error_check(error_code, "Exodus.close -> libexodus.ex_close")
end

export LoadBalanceParameters
export ParallelExodusDatabase
