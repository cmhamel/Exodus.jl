# TODO check these aren't outdated with older interface also add types to julia call
# function ex_get_cmap_params!(exoid::Cint, node_cmap_ids, node_cmap_node_cnts, elem_cmap_ids, elem_cmap_elem_cnts, processor)
#   error_code = ccall(
#     (:ex_get_cmap_params, libexodus), Cint,
#     (Cint, Ptr{void_int}, Ptr{void_int}, Ptr{void_int}, Ptr{void_int}, Cint),
#     exoid, node_cmap_ids, node_cmap_node_cnts, elem_cmap_ids, elem_cmap_elem_cnts, processor
#   )
#   exodus_error_check(error_code, "ex_get_cmap_params!")
# end

# function ex_get_loadbal_param!(exoid::Cint,
#                  num_int_nodes, num_bor_nodes, num_ext_nodes,
#                  num_int_elems, num_bor_elems,
#                  num_node_cmaps, num_elem_cmaps,
#                  processor) # TODO get types right and sorted out
#   error_code = ccall(
#     (:ex_get_loadbal_param, libexodus), Cint,
#     (
#       Cint, 
#       Ptr{void_int}, Ptr{void_int}, Ptr{void_int}, 
#       Ptr{void_int}, Ptr{void_int}, 
#       Ptr{void_int}, Ptr{void_int}, 
#       Cint
#     ),
#     exoid, 
#     num_int_nodes, num_bor_nodes, num_ext_nodes, 
#     num_int_elems, num_bor_elems,
#     num_node_cmaps, num_elem_cmaps, 
#     processor
#   )
#   exodus_error_check(error_code, "ex_get_loadbal_param!")
# end

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

# """
# Used to set up a exodus database in write mode

# The ccall signatures should reall be B (bulk int type of exo) instead of Clonglong
# """
# function write_initialization!(exoid::Cint, init::Initialization{Int32})
#   title = Vector{UInt8}(undef, MAX_LINE_LENGTH)
#   error_code = @ccall libexodus.ex_put_init(
#     exoid::Cint, title::Ptr{UInt8},
#     init.num_dim::Cint, init.num_nodes::Cint, init.num_elems::Cint,
#     init.num_elem_blks::Cint, init.num_node_sets::Cint, init.num_side_sets::Cint
#   )::Cint
#   exodus_error_check(error_code, "Exodus.write_initialization! -> libexodus.ex_put_init")
# end

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
# export ex_get_cmap_params!
# export ex_get_init_global!
# export ex_get_init_info!
# export ex_get_loadbal_param!

export write_initialization!
