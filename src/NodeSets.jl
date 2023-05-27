"""
Init method for a NodeSet with ID node_set_id.
"""
function NodeSet(exo::ExodusDatabase, node_set_id::Integer)
  node_set_id = convert(exo.I, node_set_id)
  node_set_nodes = read_node_set_nodes(exo, node_set_id)
  return NodeSet{exo.I, exo.B}(node_set_id, length(node_set_nodes), node_set_nodes)
end

"""
"""
Base.length(nset::NodeSet) = length(nset.nodes)
"""
"""
Base.show(io::IO, node_set::N) where {N <: NodeSet} =
print(io, "NodeSet:\n",
      "\tNode set ID   = ", node_set.node_set_id, "\n",
      "\tNumber of nodes = ", node_set.num_nodes, "\n")

"""
"""
function read_node_set_ids(exo::ExodusDatabase)
  node_set_ids = Array{exo.I}(undef, exo.init.num_node_sets)
  ex_get_ids!(exo.exo, EX_NODE_SET, node_set_ids)
  return node_set_ids
end

"""
"""
function read_node_set_parameters(exo::ExodusDatabase, node_set_id::Integer)
  node_set_id = convert(exo.I, node_set_id)
  num_nodes = Ref{exo.I}(0)
  num_df = Ref{exo.I}(0)
  ex_get_set_param!(exo.exo, EX_NODE_SET, node_set_id, num_nodes, num_df)
  return num_nodes[], num_df[]
end

"""
"""
function read_node_set_nodes(exo::ExodusDatabase, node_set_id::Integer)
  num_nodes, _ = read_node_set_parameters(exo, node_set_id)
  node_set_nodes = Array{exo.B}(undef, num_nodes)
  # extras = Array{F}(undef, num_df)
  extras = C_NULL # segfaulting without extras, meaning we probably don't have extras
  ex_get_set!(exo.exo, EX_NODE_SET, node_set_id, node_set_nodes, extras)
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
  node_set_ids = convert(Vector{exo.I}, node_set_ids)
  node_sets = Vector{NodeSet}(undef, size(node_set_ids, 1))
  read_node_sets!(node_sets, exo, node_set_ids)
  return node_sets
end

# local exports
export NodeSet
export read_node_sets
export read_node_set_ids
export read_node_set_parameters
