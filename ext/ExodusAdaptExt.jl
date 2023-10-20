module ExodusAdaptExt

using Adapt
using Exodus

"""
"""
function Adapt.adapt_storage(to, block::B) where B <: Exodus.Block
  Exodus.Block(
    block.id, block.num_elem, block.num_nodes_per_elem, block.elem_type,
    Adapt.adapt_storage(to, block.conn)
  )
end

"""
"""
function Adapt.adapt_storage(to, nset::N) where N <: Exodus.NodeSet
  Exodus.NodeSet(nset.id, Adapt.adapt_storage(to, nset.nodes))
end

"""
"""
function Adapt.adapt_storage(to, sset::S) where S <: Exodus.SideSet
  Exodus.SideSet(
    sset.id, 
    Adapt.adapt_storage(to, sset.elements),
    Adapt.adapt_storage(to, sset.sides)
  )
end

end # module