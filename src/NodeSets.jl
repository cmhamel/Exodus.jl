"""
Init method for a NodeSet with ID node_set_id.
"""
function NodeSet(exo::ExodusDatabase, node_set_id::Integer)
  node_set_id = convert(get_id_int_type(exo), node_set_id)
  node_set_nodes = read_node_set_nodes(exo, node_set_id)
  return NodeSet{get_id_int_type(exo), get_bulk_int_type(exo)}(node_set_id, length(node_set_nodes), node_set_nodes)
end

"""
"""
function NodeSet(exo::ExodusDatabase, nset_name::String)
  nset_ids = read_node_set_ids(exo)
  name_index = findall(x -> x == nset_name, read_node_set_names(exo))
  if length(name_index) > 1
    throw(ErrorException("This shoudl never happen"))
  end
  name_index = name_index[1]
  return NodeSet(exo, nset_ids[name_index])
end

"""
"""
Base.length(nset::NodeSet) = length(nset.nodes)
"""
"""
Base.show(io::IO, node_set::N) where {N <: NodeSet} =
print(io, "NodeSet:\n",
      "\tNode set ID   = ", node_set.node_set_id, "\n",
      "\tNumber of nodes = ", node_set.num_nodes, "\n"
)

"""
"""
function read_node_set_ids(exo::ExodusDatabase)
  node_set_ids = Array{get_id_int_type(exo)}(undef, exo.init.num_node_sets)
  error_code = @ccall libexodus.ex_get_ids(
    get_file_id(exo)::Cint, EX_NODE_SET::ex_entity_type, node_set_ids::Ptr{void_int}
  )::Cint
  exodus_error_check(error_code, "Exodus.read_node_set_ids -> libexodus.ex_get_ids")
  return node_set_ids
end

"""
"""
function read_node_set_names(exo::ExodusDatabase)
  var_names = [Vector{UInt8}(undef, MAX_STR_LENGTH) for _ in 1:length(read_node_set_ids(exo))]
  error_code = @ccall libexodus.ex_get_names(
    get_file_id(exo)::Cint, EX_NODE_SET::ex_entity_type, var_names::Ptr{Ptr{UInt8}}
  )::Cint
  exodus_error_check(error_code, "Exodus.read_node_set_names -> libexodus.ex_get_names")
  var_names = map(x -> unsafe_string(pointer(x)), var_names)
  return var_names
end

"""
"""
function read_node_set_parameters(exo::ExodusDatabase, node_set_id::Integer)
  node_set_id = convert(get_id_int_type(exo), node_set_id)
  num_nodes = Ref{get_id_int_type(exo)}(0)
  num_df = Ref{get_id_int_type(exo)}(0)
  error_code = @ccall libexodus.ex_get_set_param(
    get_file_id(exo)::Cint, EX_NODE_SET::ex_entity_type, node_set_id::ex_entity_id,
    num_nodes::Ptr{void_int}, num_df::Ptr{void_int}
  )::Cint
  exodus_error_check(error_code, "Exodus.read_node_set_parameters -> libexodus.ex_get_set_param")
  return num_nodes[], num_df[]
end

"""
"""
function read_node_set_nodes(exo::ExodusDatabase, node_set_id::Integer)
  num_nodes, _ = read_node_set_parameters(exo, node_set_id)
  node_set_nodes = Array{get_bulk_int_type(exo)}(undef, num_nodes)
  # extras = Array{F}(undef, num_df)
  extras = C_NULL # segfaulting without extras, meaning we probably don't have extras
  error_code = @ccall libexodus.ex_get_set(
    get_file_id(exo)::Cint, EX_NODE_SET::ex_entity_type, node_set_id::ex_entity_id,
    node_set_nodes::Ptr{void_int}, extras::Ptr{void_int}
  )::Cint
  exodus_error_check(error_code, "Exodus.read_node_set_nodes -> libexodus.ex_get_set")
  return node_set_nodes
end

"""
"""
function read_node_sets!(
  node_sets::Vector{NodeSet}, 
  exo::ExodusDatabase, node_set_ids::Vector{<:Integer}
)
  for (n, node_set_id) in enumerate(node_set_ids)
    node_sets[n] = NodeSet(exo, node_set_id)
  end
end

"""
"""
function read_node_sets(exo::ExodusDatabase, node_set_ids::Array{<:Integer})
  node_set_ids = convert(Vector{get_id_int_type(exo)}, node_set_ids)
  node_sets = Vector{NodeSet}(undef, size(node_set_ids, 1))
  read_node_sets!(node_sets, exo, node_set_ids)
  return node_sets
end

"""
"""
function read_node_sets_new(exo::ExodusDatabase)
  node_set_ids = read_node_set_ids(exo)
  nsets = Vector{ex_set}(undef, length(node_set_ids))
  for n in 1:length(node_set_ids)
    # num_nodes, num_df = read_node_set_parameters(exo, node_set_ids[n])
    # num_nodes, num_df = Int32(0), Int32(0)
    nsets[n] = ex_set(node_set_ids[n], EX_NODE_SET)
  end
  error_code = @ccall libexodus.ex_get_sets(
    get_file_id(exo)::Cint, length(node_set_ids)::Csize_t, nsets::Ref{ex_set}
  )::Cint
  exodus_error_check(error_code, "Exodus.read_node_sets -> ex_get_sets")
  @show nsets
  # @show nsets[1].entry_list |> unsafe_pointer_to_objref
  @show nsets[1].entry_list |> pointer_from_objref
end
"""
WARNING:
currently doesn't support distance factors
"""
function write_node_set_parameters(exo::ExodusDatabase, nset::NodeSet)
  num_dist_fact_in_set = 0 # TODO not using distance 
  error_code = @ccall libexodus.ex_put_set_param(
    get_file_id(exo)::Cint, EX_NODE_SET::ex_entity_type, nset.node_set_id::ex_entity_id,
    nset.num_nodes::Clonglong, num_dist_fact_in_set::Clonglong
  )::Cint
  exodus_error_check(error_code, "Exodus.write_node_set_parameters -> libexodus.ex_put_set_param")
end

"""
WARNING:
currently doesn't support distance factors
"""
function write_node_set(exo::ExodusDatabase, nset::NodeSet)
  nodes = convert(Vector{get_bulk_int_type(exo)}, nset.nodes)
  write_node_set_parameters(exo, nset)
  error_code = @ccall libexodus.ex_put_set(
    get_file_id(exo)::Cint, EX_NODE_SET::ex_entity_type, nset.node_set_id::ex_entity_id,
    nodes::Ptr{void_int}, C_NULL::Ptr{void_int}
  )::Cint
  exodus_error_check(error_code, "Exodus.write_node_set -> libexodus.ex_put_set")
end

"""
WARNING:
currently doesn't support distance factors
"""
function write_node_sets(exo::ExodusDatabase, nsets::Vector{NodeSet})
  for nset in nsets
    write_node_set(exo, nset)
  end
end

"""
"""
function write_node_set_name(exo::ExodusDatabase, nset::NodeSet, name::String)
  error_code = @ccall libexodus.ex_put_name(
    get_file_id(exo)::Cint, EX_NODE_SET::ex_entity_type, nset.node_set_id::ex_entity_id,
    name::Ptr{UInt8}
  )::Cint
  exodus_error_check(error_code, "Exodus.write_node_set_name -> libexodus.ex_put_name")
end

"""
"""
function write_node_set_names(exo::ExodusDatabase, names::Vector{String})
  error_code = @ccall libexodus.ex_put_names(
    get_file_id(exo)::Cint, EX_NODE_SET::ex_entity_type, names::Ptr{Ptr{UInt8}}
  )::Cint
  exodus_error_check(error_code, "Exodus.write_node_set_names -> libexodus.ex_put_names")
end

# local exports
export NodeSet
export read_node_sets
export read_node_set_ids
export read_node_set_names
export read_node_set_parameters

export write_node_set
export write_node_set_name
export write_node_set_names
export write_node_sets
