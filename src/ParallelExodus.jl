"""
$(TYPEDSIGNATURES)
"""
function read_init_info(exo::ExodusDatabase)
  num_proc      = Base.RefValue{Cint}(0)
  num_proc_in_f = Base.RefValue{Cint}(0)
  ftype = Vector{Cchar}(undef, MAX_STR_LENGTH)
  error_code = LibExodus.ex_get_init_info(
    get_file_id(exo), num_proc, num_proc_in_f, pointer(ftype)
  )
  exodus_error_check(exo, error_code, "Exodus.ParallelExodusDatabase -> LibExodus.ex_get_init_info")
  return num_proc[], num_proc_in_f[], unsafe_string(pointer(ftype))
end

"""
$(TYPEDSIGNATURES)
"""
function InitializationGlobal(exo::ExodusDatabase{M, I, B, F}) where {M, I, B, F}
  num_nodes     = Base.RefValue{B}(0)
  num_elem      = Base.RefValue{B}(0)
  num_elem_blk  = Base.RefValue{B}(0)
  num_node_sets = Base.RefValue{B}(0)
  num_side_sets = Base.RefValue{B}(0)
  error_code = LibExodus.ex_get_init_global(
    get_file_id(exo), num_nodes, num_elem,
    num_elem_blk, num_node_sets, num_side_sets
  )
  exodus_error_check(exo, error_code, "Exodus.read_init_global -> LibExodus.ex_get_init_global")
  return Initialization{B}(
    num_dimensions(exo.init), num_nodes[], num_elem[],
    num_elem_blk[], num_node_sets[], num_side_sets[]
  )
end

"""
$(TYPEDEF)
$(TYPEDFIELDS)
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
$(TYPEDSIGNATURES)
"""
function LoadBalanceParameters(exo::ExodusDatabase{M, I, B, F}, processor::Itype) where {M, I, B, F, Itype <: Integer}
  num_int_nodes  = Base.RefValue{B}(0)
  num_bor_nodes  = Base.RefValue{B}(0)
  num_ext_nodes  = Base.RefValue{B}(0)
  num_int_elems  = Base.RefValue{B}(0)
  num_bor_elems  = Base.RefValue{B}(0)
  num_node_cmaps = Base.RefValue{B}(0)
  num_elem_cmaps = Base.RefValue{B}(0)
  error_code = LibExodus.ex_get_loadbal_param(
    get_file_id(exo),
    num_int_nodes, num_bor_nodes, num_ext_nodes,
    num_int_elems, num_bor_elems,
    num_node_cmaps, num_elem_cmaps,
    processor
  )
  exodus_error_check(exo, error_code, "Exodus.LoadBalanceParameters -> LibExodus.ex_get_loadbal_param")
  return LoadBalanceParameters{B}(
    num_int_nodes[], num_bor_nodes[], num_ext_nodes[],
    num_int_elems[], num_bor_elems[],
    num_node_cmaps[], num_elem_cmaps[],
    processor + 1
  )
end

"""
$(TYPEDEF)
$(TYPEDFIELDS)
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
$(TYPEDSIGNATURES)
"""
function CommunicationMapParameters(exo::ExodusDatabase{M, I, B, F}, lb_params::LoadBalanceParameters{B}, processor::Itype) where {M, I, B, F, Itype <: Integer}
  node_cmap_ids       = Vector{B}(undef, lb_params.num_node_cmaps)
  node_cmap_node_cnts = Vector{B}(undef, lb_params.num_node_cmaps)
  elem_cmap_ids       = Vector{B}(undef, lb_params.num_elem_cmaps)
  elem_cmap_elem_cnts = Vector{B}(undef, lb_params.num_elem_cmaps)
  error_code = LibExodus.ex_get_cmap_params(
    get_file_id(exo),
    node_cmap_ids, node_cmap_node_cnts,
    elem_cmap_ids, elem_cmap_elem_cnts,
    processor
  )
  exodus_error_check(exo, error_code, "Exodus.CommunicationMapParameters -> LibExodus.ex_get_cmap_params")
  return CommunicationMapParameters{B}(
    node_cmap_ids .+ 1, node_cmap_node_cnts,
    elem_cmap_ids .+ 1, elem_cmap_elem_cnts
  ) # Note we added 1 to the cmap ids, we'll need to subtract it downstream. 
    # this is so it's in a julia indexing
end

"""
$(TYPEDEF)
$(TYPEDFIELDS)
"""
struct NodeCommunicationMap{B}
  node_ids::Vector{B}
  proc_ids::Vector{B}
end

"""
$(TYPEDSIGNATURES)
"""
function NodeCommunicationMap(exo::ExodusDatabase{M, I, B, F}, node_map_id, node_cnt, processor) where {M, I, B, F}

  node_ids = Vector{B}(undef, node_cnt)
  proc_ids = Vector{B}(undef, node_cnt)

  error_code = LibExodus.ex_get_node_cmap(
    get_file_id(exo), (node_map_id - 1),
    node_ids, proc_ids, processor
  )
  exodus_error_check(exo, error_code, "Exodus.NodeCommunicationMap -> LibExodus.ex_get_node_cmap")

  return NodeCommunicationMap{B}(node_ids, proc_ids .+ 1) # note adding 1 to proc ids to make them julia indexed
end

"""
$(TYPEDEF)
$(TYPEDFIELDS)
"""
struct ElementCommunicationMap{B}
  elem_ids::Vector{B}
  side_ids::Vector{B}
  proc_ids::Vector{B}
end

"""
$(TYPEDSIGNATURES)
"""
function ElementCommunicationMap(exo::ExodusDatabase{M, I, B, F}, elem_map_id::Itype, elem_cnt, processor::Itype) where {M, I, B, F, Itype <: Integer}

  elem_ids = Vector{B}(undef, elem_cnt)
  side_ids = Vector{B}(undef, elem_cnt)
  proc_ids = Vector{B}(undef, elem_cnt)

  error_code = LibExodus.ex_get_elem_cmap(
    get_file_id(exo), (elem_map_id - 1),
    elem_ids, side_ids, proc_ids,
    processor
  )
  exodus_error_check(exo, error_code, "Exodus.ElementCommunicationMap -> LibExodus.ex_get_elem_cmap")
  return ElementCommunicationMap{B}(elem_ids, side_ids, proc_ids .+ 1) # note adding 1 to proc ids to make them julia indexed
end

"""
$(TYPEDEF)
$(TYPEDFIELDS)
"""
struct ProcessorNodeMaps{B}
  node_map_internal::Vector{B}
  node_map_border::Vector{B}
  node_map_external::Vector{B}
end

"""
$(TYPEDSIGNATURES)
"""
function ProcessorNodeMaps(exo::ExodusDatabase{M, I, B, F}, processor::Itype) where {M, I, B, F, Itype}
  lb_params = LoadBalanceParameters(exo, processor - 1)

  node_map_internal = Vector{B}(undef, lb_params.num_int_nodes)
  node_map_border   = Vector{B}(undef, lb_params.num_bor_nodes)
  node_map_external = Vector{B}(undef, lb_params.num_ext_nodes)

  error_code = LibExodus.ex_get_processor_node_maps(
    get_file_id(exo),
    node_map_internal, node_map_border, node_map_external,
    processor
  )
  exodus_error_check(exo, error_code, "Exodus.ProcessorNodeMap -> LibExodus.ex_get_processor_node_maps")
  return ProcessorNodeMaps{B}(node_map_internal, node_map_border, node_map_external)
end

"""
$(TYPEDEF)
$(TYPEDFIELDS)
"""
struct ProcessorElementMaps{B}
  elem_map_internal::Vector{B}
  elem_map_border::Vector{B}
end

"""
$(TYPEDSIGNATURES)
"""
function ProcessorElementMaps(exo::ExodusDatabase{M, I, B, F}, processor::Itype) where {M, I, B, F, Itype}
  lb_params = LoadBalanceParameters(exo, processor - 1)
  
  elem_map_internal = Vector{B}(undef, lb_params.num_int_elems)
  elem_map_border   = Vector{B}(undef, lb_params.num_bor_elems)

  error_code = LibExodus.ex_get_processor_elem_maps(
    get_file_id(exo),
    elem_map_internal, elem_map_border, processor
  )
  exodus_error_check(exo, error_code, "Exodus.ProcessorElementMaps -> LibExodus.ex_get_processor_elem_maps")
  return ProcessorElementMaps{B}(elem_map_internal, elem_map_border)
end
