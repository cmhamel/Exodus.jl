# TODO check these aren't outdated with older interface also add types to julia call
function ex_get_cmap_params!(exoid::Cint, node_cmap_ids, node_cmap_node_cnts, elem_cmap_ids, elem_cmap_elem_cnts, processor)
  error_code = ccall(
    (:ex_get_cmap_params, libexodus), Cint,
    (Cint, Ptr{void_int}, Ptr{void_int}, Ptr{void_int}, Ptr{void_int}, Cint),
    exoid, node_cmap_ids, node_cmap_node_cnts, elem_cmap_ids, elem_cmap_elem_cnts, processor
  )
  exodus_error_check(error_code, "ex_get_cmap_params!")
end

# TODO add types
"""
  ex_get_init!(exoid::Cint, 
         title::Vector{UInt8},
         num_dim::Ref{Clonglong}, num_nodes::Ref{Clonglong}, num_elem::Ref{Clonglong}, 
         num_elem_blk::Ref{Clonglong}, num_node_sets::Ref{Clonglong}, num_side_sets::Ref{Clonglong})
"""
function ex_get_init!(exoid::Cint, 
            title::Vector{UInt8},
            num_dim::Ref{Clonglong}, num_nodes::Ref{Clonglong}, num_elem::Ref{Clonglong}, 
            num_elem_blk::Ref{Clonglong}, num_node_sets::Ref{Clonglong}, num_side_sets::Ref{Clonglong}) # TODO get the types right
  error_code = ccall(
    (:ex_get_init, libexodus), Cint,
    (
      Cint, Ptr{UInt8},
      Ptr{void_int}, Ptr{void_int}, Ptr{void_int},
      Ptr{void_int}, Ptr{void_int}, Ptr{void_int}
    ),
    exoid, title,
    num_dim, num_nodes, num_elem,
    num_elem_blk, num_node_sets, num_side_sets
  )
  title = unsafe_string(pointer(title))
  exodus_error_check(error_code, "ex_get_init!")
end

function ex_get_init_global!(exoid::Cint, num_nodes_g, num_elems_g, num_elem_blks_g, num_node_sets_g, num_side_sets_g) # TODO get the types right
  error_code = ccall(
    (:ex_get_init_global, libexodus), Cint,
    (Cint, Ptr{void_int}, Ptr{void_int}, Ptr{void_int}, Ptr{void_int}, Ptr{void_int}),
    exoid, num_nodes_g, num_elems_g, num_elem_blks_g, num_node_sets_g, num_side_sets_g
  )
  exodus_error_check(error_code, "ex_get_init_global!")
end

function ex_get_init_info!(exoid::Cint, num_proc, num_proc_in_f, ftype)
  error_code = ccall((:ex_get_init_info, libexodus), Cint,
             (Cint, Ptr{Cint}, Ptr{Cint}, Ptr{UInt8}),
            exoid, num_proc, num_proc_in_f, ftype)
  exodus_error_check(error_code, "ex_get_init_info!")
end

function ex_get_loadbal_param!(exoid::Cint,
                 num_int_nodes, num_bor_nodes, num_ext_nodes,
                 num_int_elems, num_bor_elems,
                 num_node_cmaps, num_elem_cmaps,
                 processor) # TODO get types right and sorted out
  error_code = ccall(
    (:ex_get_loadbal_param, libexodus), Cint,
    (
      Cint, 
      Ptr{void_int}, Ptr{void_int}, Ptr{void_int}, 
      Ptr{void_int}, Ptr{void_int}, 
      Ptr{void_int}, Ptr{void_int}, 
      Cint
    ),
    exoid, 
    num_int_nodes, num_bor_nodes, num_ext_nodes, 
    num_int_elems, num_bor_elems,
    num_node_cmaps, num_elem_cmaps, 
    processor
  )
  exodus_error_check(error_code, "ex_get_loadbal_param!")
end

"""
  Initialization(exo::ExodusDatabase)
"""

function Initialization(exo_id::I) where {I <: Integer}
  num_dim     = Ref{Clonglong}(0)
  num_nodes   = Ref{Clonglong}(0)
  num_elems   = Ref{Clonglong}(0)
  num_elem_blks = Ref{Clonglong}(0)
  num_node_sets = Ref{Clonglong}(0)
  num_side_sets = Ref{Clonglong}(0)
  title = Vector{UInt8}(undef, MAX_LINE_LENGTH)
  ex_get_init!(exo_id, title, # maybe find a way to avoid exo.exo calls
         num_dim, num_nodes, num_elems, 
         num_elem_blks, num_node_sets, num_side_sets)
  title = unsafe_string(pointer(title))
  return Initialization(num_dim[], num_nodes[], num_elems[],
              num_elem_blks[], num_node_sets[], num_side_sets[])
end

function Initialization(exo::E) where {E <: ExodusDatabase}
  num_dim     = Ref{Clonglong}(0)
  num_nodes   = Ref{Clonglong}(0)
  num_elems   = Ref{Clonglong}(0)
  num_elem_blks = Ref{Clonglong}(0)
  num_node_sets = Ref{Clonglong}(0)
  num_side_sets = Ref{Clonglong}(0)
  title = Vector{UInt8}(undef, MAX_LINE_LENGTH)
  ex_get_init!(exo.exo, title, # maybe find a way to avoid exo.exo calls
         num_dim, num_nodes, num_elems, 
         num_elem_blks, num_node_sets, num_side_sets)
  title = unsafe_string(pointer(title))
  return Initialization(num_dim[], num_nodes[], num_elems[],
              num_elem_blks[], num_node_sets[], num_side_sets[])
end

Base.show(io::IO, init::Initialization) =
print(io, "Initialization:\n",
      "\tNumber of dim     = ", init.num_dim, "\n",
      "\tNumber of nodes   = ", init.num_nodes, "\n",
      "\tNumber of elem    = ", init.num_elems, "\n",
      "\tNumber of blocks  = ", init.num_elem_blks, "\n",
      "\tNumber of node sets = ", init.num_node_sets, "\n",
      "\tNumber of side sets = ", init.num_side_sets, "\n")

function ex_put_init!(exoid::Cint, 
                      title,
                      num_dim, num_nodes, num_elem, 
                      num_elem_blk, num_node_sets, num_side_sets) # TODO get the types right
  error_code = ccall(
    (:ex_put_init, libexodus), Cint,
    (
      Cint, Ptr{UInt8},
      Clonglong, Clonglong, Clonglong,
      Clonglong, Clonglong, Clonglong
    ),
    exoid, title,
    num_dim, num_nodes, num_elem,
    num_elem_blk, num_node_sets, num_side_sets
  )
  exodus_error_check(error_code, "ex_put_init!")
end

"""
  write_initialization(exo::ExodusDatabase, init::Initialization)
"""
function write_initialization!(exo::E, init::Initialization) where {E <: ExodusDatabase}

  # to set in the exo object
  ExodusDatabase!(exo, init)
  title = Vector{UInt8}(undef, MAX_LINE_LENGTH)
  ex_put_init!(exo.exo, title,
               init.num_dim, init.num_nodes, init.num_elems,
               init.num_elem_blks, init.num_node_sets, init.num_side_sets)
end

# commenting out parallel stuff for now until I have time to better support and test it
# # note that this needs to be used on mesh.g.xx.xx files not .g.nem files
# struct CommunicationMapInitialization <: FEMContainer
#   node_cmap_ids
#   node_cmap_node_cnts
#   elem_cmap_ids
#   elem_cmap_cnts
#   processor
#   function CommunicationMapInitialization(exo_id::int, processor::Int64)
#     lb_init = LoadBalanceInitialization(exo_id, processor)
#     @show lb_init
#     node_cmap_ids = Vector{IntKind}(undef, lb_init.num_node_cmaps)
#     node_cmap_node_cnts = Vector{IntKind}(undef, lb_init.num_node_cmaps)
#     elem_cmap_ids = Vector{IntKind}(undef, lb_init.num_elem_cmaps)
#     elem_cmap_cnts = Vector{IntKind}(undef, lb_init.num_elem_cmaps)
#     ex_get_cmap_params!(exo_id, node_cmap_ids, node_cmap_node_cnts, elem_cmap_ids, elem_cmap_cnts, processor)
#     return new(node_cmap_ids, node_cmap_node_cnts, elem_cmap_ids, elem_cmap_cnts, processor)
#   end
# end

# # Attempting to access parallel information
# struct GlobalInitialization <: FEMContainer
#   num_nodes::IntKind
#   num_elems::IntKind
#   num_elem_blks::IntKind
#   num_node_sets::IntKind
#   num_side_sets::IntKind
#   function GlobalInitialization(exo_id::int)
#     num_nodes = Ref{IntKind}(0)
#     num_elems = Ref{IntKind}(0)
#     num_elem_blks = Ref{IntKind}(0)
#     num_node_sets = Ref{IntKind}(0)
#     num_side_sets = Ref{IntKind}(0)
#     ex_get_init_global!(exo_id, num_nodes, num_elems, num_elem_blks, num_node_sets, num_side_sets)
#     return new(num_nodes[], num_elems[], num_elem_blks[], num_node_sets[], num_side_sets[])
#   end
# end
# Base.show(io::IO, init::GlobalInitialization) =
# print(io, "GlobalInitialization:\n",
#       "\tNumber of nodes   = ", init.num_nodes, "\n",
#       "\tNumber of elem    = ", init.num_elems, "\n",
#       "\tNumber of blocks  = ", init.num_elem_blks, "\n",
#       "\tNumber of node sets = ", init.num_node_sets, "\n",
#       "\tNumber of side sets = ", init.num_side_sets, "\n")

# struct LoadBalanceInitialization <: FEMContainer
#   num_internal_nodes::IntKind
#   num_border_nodes::IntKind
#   num_external_nodes::IntKind
#   num_internal_elems::IntKind
#   num_border_elems::IntKind
#   num_node_cmaps::IntKind
#   num_elem_cmaps::IntKind
#   processor::IntKind
#   function LoadBalanceInitialization(exo_id::int, processor::IntKind)
#     num_internal_nodes = Ref{IntKind}(0)
#     num_border_nodes = Ref{IntKind}(0)
#     num_external_nodes = Ref{IntKind}(0)
#     num_internal_elems = Ref{IntKind}(0)
#     num_border_elems = Ref{IntKind}(0)
#     num_node_cmaps = Ref{IntKind}(0)
#     num_elem_cmaps = Ref{IntKind}(0)
#     ex_get_loadbal_param!(exo_id,
#                 num_internal_nodes, num_border_nodes, num_external_nodes,
#                 num_internal_elems, num_border_elems,
#                 num_node_cmaps, num_elem_cmaps, 
#                 processor)
#     return new(num_internal_nodes[], num_border_nodes[], num_external_nodes[],
#          num_internal_elems[], num_border_elems[],
#          num_node_cmaps[], num_elem_cmaps[], processor)
#   end
# end
# Base.show(io::IO, init::LoadBalanceInitialization) =
# print(io, "Initialization:\n",
#       "\tNumber of internal nodes       = ", init.num_internal_nodes, "\n",
#       "\tNumber of border nodes         = ", init.num_border_nodes, "\n",
#       "\tNumber of external nodes       = ", init.num_external_nodes, "\n",
#       "\tNumber of internal elements      = ", init.num_internal_elems, "\n",
#       "\tNumber of border elements      = ", init.num_border_elems, "\n",
#       "\tNumber of node communication maps  = ", init.num_node_cmaps, "\n",
#       "\tNumber of element communication maps = ", init.num_elem_cmaps, "\n",
#       "\tProcessor number           = ", init.processor, "\n")
# number_of_total_nodes(init::LoadBalanceInitialization) = init.num_internal_nodes + init.num_border_nodes + init.num_external_nodes
# number_of_total_elements(init::LoadBalanceInitialization) = init.num_internal_elems + init.num_border_elems

# struct ParallelInitialization <: FEMContainer
#   number_of_procesors::IntKind
#   number_of_procesors_in_file::IntKind
#   function ParallelInitialization(exo_id::int)
#     num_procs = Ref{IntKind}(0)
#     num_procs_in_file = Ref{IntKind}(0)
#     info = Vector{UInt8}(undef, MAX_LINE_LENGTH)
#     ex_get_init_info!(exo_id, num_procs, num_procs_in_file, info)
#     info = unsafe_string(pointer(info))
#     # @show info # TODO do something with info in the struct
#     return new(num_procs[], num_procs_in_file[])
#   end
# end
# Base.show(io::IO, init::ParallelInitialization) = 
# print(io, "ParallelInitialization:\n",
#       "\tNumber of processors     = ", init.number_of_procesors, "\n",
#       "\tNumber of processors in file = ", init.number_of_procesors_in_file, "\n")

# local exports
export write_initialization!
