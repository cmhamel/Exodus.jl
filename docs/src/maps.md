# Maps

Exodus distinguishes between several kinds of integer "maps" used to track the correspondence between local and global numbering. `Exodus.jl` represents these with lightweight marker types:

```julia
abstract type AbstractExodusMap <: AbstractExodusType end

struct NodeMap    <: AbstractExodusMap end
struct ElementMap <: AbstractExodusMap end
struct FaceMap    <: AbstractExodusMap end
struct EdgeMap    <: AbstractExodusMap end
```

These types are used purely for dispatch — they carry no data themselves; the actual map values are plain `Vector`s of the database's map integer type `M`.

## The element map

```julia
elem_map = read_map(exo)   # Vector{M} of length num_elements(exo.init)
```

## ID maps

ID maps relate local node/element numbers to "global" application IDs and are commonly used in parallel/decomposed meshes.

```julia
node_id_map = read_id_map(exo, NodeMap)
elem_id_map = read_id_map(exo, ElementMap)

write_id_map(exo, NodeMap, node_id_map)
write_id_map(exo, ElementMap, elem_id_map)
```

`write_id_map` asserts that the length of `map` matches the expected number of nodes or elements for the chosen map type.

!!! note "Face and edge maps"
    `FaceMap` and `EdgeMap` exist as marker types (and are exported) for forward compatibility, but full read/write support for them is not yet implemented.
