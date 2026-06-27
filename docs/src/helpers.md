# Helper Utilities

`Exodus.jl` includes a few higher-level helpers for building connectivity graphs out of raw block data — useful for assembling sparsity patterns, mesh coloring, or other finite-element bookkeeping without re-implementing the traversal yourself.

## Element connectivities

Collects the connectivity of every element across every block in the mesh into a flat `Vector{Vector{B}}` (one entry per element, in block order):

```julia
conns = collect_element_connectivities(exo)
```

## Node-to-element connectivity

Inverts element connectivity into, for each node, the list of elements that contain it:

```julia
node_to_elem = collect_node_to_element_connectivities(exo)
```

## Element-to-element connectivity

Builds, for each element, the sorted, de-duplicated list of all elements that share at least one node with it (i.e. its node-adjacency neighborhood):

```julia
elem_to_elem = collect_element_to_element_connectivities(exo)
```

Each of these has an in-place `!` variant (`collect_element_connectivities!`, `collect_node_to_element_connectivities!`, `collect_element_to_element_connectivities!`) for reuse of pre-allocated buffers in performance-sensitive code.

## Parallel numbering helpers

A few additional helpers support stitching together global numbering information from a decomposed mesh (see [Parallel / Decomposed Databases](@ref) for the underlying communication-map types they build on):

```julia
Exodus.collect_global_element_and_node_numberings(file_name, n_procs)
Exodus.read_element_cmaps(rank, exo)
Exodus.read_node_cmaps(rank, exo)
Exodus.read_ghost_nodes_and_procs(rank, exo)
Exodus.read_internal_nodes_and_procs(rank, exo)
```

`collect_global_element_and_node_numberings` assumes `decomp` has already been run, producing per-rank files named `file_name.n_procs.RRRR`. It determines elements' owning processor, and for shared nodes (owned by multiple processors), applies a reduction function (`maximum` by default) to pick a single owning processor per node.
