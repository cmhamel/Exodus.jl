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
  ex_get_ids!(get_file_id(exo), EX_NODE_SET, node_set_ids)
  return node_set_ids
end

"""
"""
function read_node_set_names(exo::ExodusDatabase)
  var_names = [Vector{UInt8}(undef, MAX_STR_LENGTH) for _ in 1:length(read_node_set_ids(exo))]
  ex_get_names!(get_file_id(exo), EX_NODE_SET, var_names)
  var_names = map(x -> unsafe_string(pointer(x)), var_names)
  return var_names
end

"""
"""
function read_node_set_parameters(exo::ExodusDatabase, node_set_id::Integer)
  node_set_id = convert(get_id_int_type(exo), node_set_id)
  num_nodes = Ref{get_id_int_type(exo)}(0)
  num_df = Ref{get_id_int_type(exo)}(0)
  ex_get_set_param!(get_file_id(exo), EX_NODE_SET, node_set_id, num_nodes, num_df)
  return num_nodes[], num_df[]
end

"""
"""
function read_node_set_nodes(exo::ExodusDatabase, node_set_id::Integer)
  num_nodes, _ = read_node_set_parameters(exo, node_set_id)
  node_set_nodes = Array{get_bulk_int_type(exo)}(undef, num_nodes)
  # extras = Array{F}(undef, num_df)
  extras = C_NULL # segfaulting without extras, meaning we probably don't have extras
  ex_get_set!(get_file_id(exo), EX_NODE_SET, node_set_id, node_set_nodes, extras)
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

# function write_node_set_names(exo::ExodusDatabase, nodeset_names)
#   # nodeset_names = Vector{UInt8}.(nodeset_names)
#   # @show nodeset_names
#   # @show typeof(nodeset_names)
#   ex_put_names!(get_file_id(exo), EX_NODE_SET, nodeset_names)
# end

"""
"""
# function write_node_set_variable_values()

# local exports
export NodeSet
export read_node_sets
export read_node_set_ids
export read_node_set_names
export read_node_set_parameters
# export write_node_set_names
