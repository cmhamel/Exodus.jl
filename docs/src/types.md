# Core Types

This page describes the type hierarchy used throughout `Exodus.jl`. Most read/write functions dispatch on these types rather than taking string/symbol flags, so understanding the hierarchy is the key to understanding the API.

## Type hierarchy overview

```
AbstractExodusType
├── AbstractExodusMap
│   ├── NodeMap
│   ├── ElementMap
│   ├── FaceMap
│   └── EdgeMap
├── AbstractExodusSet{I, A}
│   ├── Block{I, A}
│   ├── NodeSet{I, A}
│   └── SideSet{I, A}
└── AbstractExodusVariable
    ├── ElementVariable
    ├── GlobalVariable
    ├── NodalVariable        (alias: NodalScalarVariable)
    ├── NodalVectorVariable
    ├── NodeSetVariable
    └── SideSetVariable
```

`AbstractExodusType` is the root abstract type for everything below; `AbstractExodusMap`, `AbstractExodusSet`, and `AbstractExodusVariable` exist purely to let generic functions dispatch on "any map type", "any set type", or "any variable type" respectively.

---

## `ExodusDatabase`

The central handle representing an open Exodus file.

```julia
struct ExodusDatabase{M, I, B, F}
    exo::Cint
    mode::String
    file_name::String
    init::Initialization{B}
    block_name_dict::Dict{String, I}
    nset_name_dict::Dict{String, I}
    sset_name_dict::Dict{String, I}
    element_var_name_dict::Dict{String, I}
    global_var_name_dict::Dict{String, I}
    nodal_var_name_dict::Dict{String, I}
    nset_var_name_dict::Dict{String, I}
    sset_var_name_dict::Dict{String, I}
end
```

The four type parameters mirror the integer/float storage modes Exodus negotiates for a given file:

| Parameter | Meaning |
|:---------:|:--------|
| `M` | Integer type for **maps** (node/element/face/edge maps) — `Cint` or `Clonglong` |
| `I` | Integer type for **IDs** (block, set, and variable IDs) — `Cint` or `Clonglong` |
| `B` | Integer type for **bulk data** (connectivity, counts) — `Cint` or `Clonglong` |
| `F` | Floating point type for **field data** — `Cfloat` or `Cdouble` |

Besides the file handle itself, an `ExodusDatabase` caches the mesh's `Initialization` header and maintains name → ID lookup `Dict`s for every set and variable type, so that repeated by-name access (`Block(exo, "block_1")`, `read_values(exo, NodalVariable, 1, "displ_x")`, etc.) avoids round-tripping to the C library. See [The `ExodusDatabase`](@ref) for full usage details.

---

## `Initialization`

Holds the basic mesh sizing information read from (or to be written to) the Exodus header.

```julia
struct Initialization{B}
    num_dimensions::B
    num_nodes::B
    num_elements::B
    num_element_blocks::B
    num_node_sets::B
    num_side_sets::B
end
```

Accessor functions: `num_dimensions`, `num_nodes`, `num_elements`, `num_element_blocks`, `num_node_sets`, `num_side_sets`.

---

## `AbstractExodusMap` types

Marker types used purely for dispatch when reading/writing the various Exodus numbering maps. They carry no data of their own — the map values themselves are plain `Vector{M}`s.

```julia
abstract type AbstractExodusMap <: AbstractExodusType end

struct NodeMap    <: AbstractExodusMap end
struct ElementMap <: AbstractExodusMap end
struct FaceMap    <: AbstractExodusMap end
struct EdgeMap    <: AbstractExodusMap end
```

See [Maps](@ref) for usage (`FaceMap`/`EdgeMap` are exported for forward compatibility but not yet fully implemented).

---

## `AbstractExodusSet` types

The three "set" types — `Block`, `NodeSet`, `SideSet` — all subtype `AbstractExodusSet{I, A}`, parameterized by an ID type `I` and the array type `A` used to store their bulk entries. They share a common name/ID lookup interface (`read_ids`, `read_names`, `write_name`, etc.) implemented generically over `AbstractExodusSet`.

```julia
abstract type AbstractExodusSet{I, A} <: AbstractExodusType end
```

### `Block`

Groups elements that share the same element topology (e.g. all `QUAD4`s).

```julia
struct Block{I, A <: AbstractMatrix} <: AbstractExodusSet{I, A}
    id::I
    num_elem::Clonglong
    num_nodes_per_elem::Clonglong
    elem_type::String
    conn::A
end
```

`conn` is a `num_nodes_per_elem x num_elem` connectivity matrix; column `e` holds the global node IDs of element `e`. See [Element Blocks](@ref).

### `NodeSet`

A named collection of node IDs.

```julia
struct NodeSet{I, A <: AbstractVector} <: AbstractExodusSet{I, A}
    id::I
    nodes::A
end
```

### `SideSet`

A named collection of element sides (faces/edges), along with the node lists that make up each side.

```julia
struct SideSet{I, A <: AbstractVector} <: AbstractExodusSet{I, A}
    id::I
    elements::A
    sides::A
    num_nodes_per_side::A
    side_nodes::A
end
```

`length(nset)` / `length(sset)` give the number of nodes / number of element-side pairs, respectively. See [Node Sets & Side Sets](@ref).

---

## `AbstractExodusVariable` types

Marker types identifying the five kinds of time-dependent field variables Exodus supports. Like the map types, they carry no data — `read_values`/`write_values` use them purely for dispatch.

```julia
abstract type AbstractExodusVariable <: AbstractExodusType end

struct ElementVariable      <: AbstractExodusVariable end
struct GlobalVariable       <: AbstractExodusVariable end
struct NodalVariable        <: AbstractExodusVariable end
const  NodalScalarVariable  = NodalVariable
struct NodalVectorVariable  <: AbstractExodusVariable end
struct NodeSetVariable      <: AbstractExodusVariable end
struct SideSetVariable      <: AbstractExodusVariable end
```

| Type | Lives on | "Set equivalent" |
|:------|:----------|:------------------|
| `GlobalVariable` | the whole mesh (one scalar per step) | — |
| `NodalVariable` (`NodalScalarVariable`) | every node | — |
| `NodalVectorVariable` | every node, assembled from per-component scalars (`_x`, `_y`, `_z`) | — |
| `ElementVariable` | elements within a block | `Block` |
| `NodeSetVariable` | nodes within a node set | `NodeSet` |
| `SideSetVariable` | sides within a side set | `SideSet` |

`set_equivalent(::Type{V})` maps an `ElementVariable`/`NodeSetVariable`/`SideSetVariable` to its corresponding set type (`Block`/`NodeSet`/`SideSet`), which is how `read_values`/`write_values` validate that an `id` argument refers to an existing set. See [Variables](@ref).

---

## Parallel/decomposed-mesh types

These types hold metadata specific to per-processor pieces of a decomposed mesh (see [Parallel / Decomposed Databases](@ref)). They are plain data containers (not part of the `AbstractExodusType` hierarchy).

```julia
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

struct CommunicationMapParameters{B}
    node_cmap_ids::Vector{B}
    node_cmap_node_cnts::Vector{B}
    elem_cmap_ids::Vector{B}
    elem_cmap_elem_cnts::Vector{B}
end

struct NodeCommunicationMap{B}
    node_ids::Vector{B}
    proc_ids::Vector{B}
end

struct ElementCommunicationMap{B}
    elem_ids::Vector{B}
    side_ids::Vector{B}
    proc_ids::Vector{B}
end

struct ProcessorNodeMaps{B}
    node_map_internal::Vector{B}
    node_map_border::Vector{B}
    node_map_external::Vector{B}
end

struct ProcessorElementMaps{B}
    elem_map_internal::Vector{B}
    elem_map_border::Vector{B}
end
```

---

## Exceptions

`Exodus.jl` defines descriptive exception types instead of relying on raw Exodus error codes for common usage mistakes. Each one's `Base.show` method prints the list of valid alternatives.

```julia
struct ModeException <: Exception
    mode::String
end

struct SetIDException{M, I, B, F, V, I1 <: Integer} <: Exception
    exo::ExodusDatabase{M, I, B, F}
    type::Type{V}
    id::I1
end

struct SetNameException{M, I, B, F, V} <: Exception
    exo::ExodusDatabase{M, I, B, F}
    type::Type{V}
    name::String
end

struct VariableIDException{M, I, B, F, V} <: Exception
    exo::ExodusDatabase{M, I, B, F}
    type::Type{V}
    id::Int
end

struct VariableNameException{M, I, B, F, V} <: Exception
    exo::ExodusDatabase{M, I, B, F}
    type::Type{V}
    name::String
end
```

- `ModeException` — thrown when an invalid `mode` string (anything other than `"r"`, `"rw"`, `"w"`) is passed to `ExodusDatabase`.
- `SetIDException` / `SetNameException` — thrown when a requested `Block`/`NodeSet`/`SideSet` ID or name does not exist.
- `VariableIDException` / `VariableNameException` — thrown when a requested variable index or name does not exist for a given variable type.
