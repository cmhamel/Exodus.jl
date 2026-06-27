# Element Blocks

An element [`Block`](@ref) groups together elements that share the same element topology (e.g. all `QUAD4` elements). Each block has an integer ID, an element type string, and a connectivity array mapping local node-per-element indices to global node numbers.

```julia
struct Block{I, A <: AbstractMatrix} <: AbstractExodusSet{I, A}
    id::I
    num_elem::Clonglong
    num_nodes_per_elem::Clonglong
    elem_type::String
    conn::A
end
```

`conn` is a `num_nodes_per_elem x num_elem` matrix; column `e` holds the global node IDs of element `e`.

## Reading blocks

```julia
block = Block(exo, 1)            # construct directly from an ID
block = Block(exo, "block_1")    # construct directly from a name
block = read_block(exo, 1)       # equivalent convenience method
block = read_block(exo, "block_1")

blocks = read_blocks(exo, [1, 2, 3])  # read several blocks at once
blocks = read_blocks(exo, read_ids(exo, Block)) # read every block
```

Lower-level accessors are also available if you need the raw pieces without constructing a full `Block`:

```julia
element_type, num_elem, num_nodes, num_edges, num_faces, num_attributes =
    Exodus.read_block_parameters(exo, block_id)

conn = Exodus.read_block_connectivity(exo, block_id, num_nodes * num_elem)

# read a contiguous chunk of connectivity, e.g. elements 10..109
partial_conn = Exodus.read_partial_block_connectivity(exo, block_id, 10, 100)

elem_type = read_element_type(exo, block_id)

block_id_map = read_block_id_map(exo, block_id)
```

## Writing blocks

```julia
write_block(exo, block)                       # write a Block object
write_blocks(exo, [block1, block2])           # write several Block objects

# or specify connectivity directly without constructing a Block
write_block(exo, block_id, "QUAD4", conn)     # conn is num_nodes_per_elem x num_elem

write_name(exo, Block, block_id, "block_1")
```

!!! warning
    `write_block` currently does not support edges, faces, or attributes.

## Block names and IDs

All set types (`Block`, `NodeSet`, `SideSet`) share a common name/ID interface, documented in [Node Sets & Side Sets](@ref).

```julia
read_ids(exo, Block)
read_names(exo, Block)
read_name(exo, Block, block_id)
```

## Connectivity helpers

`Exodus.jl` provides utilities for assembling block connectivity into convenient forms for downstream finite element codes; see [Helper Utilities](@ref) for `collect_element_connectivities`, `collect_node_to_element_connectivities`, and `collect_element_to_element_connectivities`.
