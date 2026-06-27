# Parallel / Decomposed Databases

When a mesh has been decomposed across multiple processors (e.g. via `decomp`), each processor's piece is written to its own Exodus file (typically named `mesh.g.N.RRRR` where `N` is the number of processors and `RRRR` is the zero-padded rank). `Exodus.jl` provides read access to the parallel-specific metadata stored in these files: load-balance parameters, communication maps, and processor-local node/element maps.

!!! note
    These capabilities work without requiring an MPI-enabled build of `Exodus.jl`/SEACAS — they simply read the parallel metadata that SEACAS decomposition tools embed in each per-rank file. Genuinely parallel (MPI-collective) I/O is not implemented.

## Global initialization info

```julia
num_proc, num_proc_in_file, file_type = read_init_info(exo)

init_global = InitializationGlobal(exo)  # global mesh sizing, mirrors Initialization
```

## Load balance parameters

For a given per-rank file and processor number (1-indexed, matching the rank's position within the file):

```julia
lb = LoadBalanceParameters(exo, processor)

lb.num_int_nodes    # interior nodes owned solely by this processor
lb.num_bor_nodes    # border (shared) nodes
lb.num_ext_nodes    # external (ghost) nodes
lb.num_int_elems
lb.num_bor_elems
lb.num_node_cmaps
lb.num_elem_cmaps
```

## Communication map parameters

```julia
cmap_params = CommunicationMapParameters(exo, lb, processor)

cmap_params.node_cmap_ids
cmap_params.node_cmap_node_cnts
cmap_params.elem_cmap_ids
cmap_params.elem_cmap_elem_cnts
```

## Node and element communication maps

```julia
node_cmap = NodeCommunicationMap(exo, node_map_id, node_cnt, processor)
node_cmap.node_ids
node_cmap.proc_ids

elem_cmap = ElementCommunicationMap(exo, elem_map_id, elem_cnt, processor)
elem_cmap.elem_ids
elem_cmap.side_ids
elem_cmap.proc_ids
```

## Processor-local node/element maps

```julia
node_maps = ProcessorNodeMaps(exo, processor)
node_maps.node_map_internal
node_maps.node_map_border
node_maps.node_map_external

elem_maps = ProcessorElementMaps(exo, processor)
elem_maps.elem_map_internal
elem_maps.elem_map_border
```

## High-level helpers

A handful of convenience functions in [Helper Utilities](@ref) build on these primitives to assemble global numbering information across an entire decomposed mesh, e.g. `Exodus.read_node_cmaps`, `Exodus.read_ghost_nodes_and_procs`, and `Exodus.read_internal_nodes_and_procs`.

## Command-line tool wrappers

`Exodus.jl` also exposes thin wrappers around the SEACAS command-line utilities for mesh decomposition and post-processing:

- `decomp` — partition a mesh into per-processor files
- `epu` — recombine (un-decompose) per-processor results files
- `exodiff` — numerically compare two Exodus databases

These call out to the corresponding SEACAS executables and are intended for scripting parallel pre/post-processing workflows around `Exodus.jl`.
