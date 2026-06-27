# Node Sets & Side Sets

[`NodeSet`](@ref) and [`SideSet`](@ref) are the other two "set" types in Exodus, alongside [`Block`](@ref). All three subtype `AbstractExodusSet` and share a common ID/name interface.

```julia
struct NodeSet{I, A <: AbstractVector} <: AbstractExodusSet{I, A}
    id::I
    nodes::A
end

struct SideSet{I, A <: AbstractVector} <: AbstractExodusSet{I, A}
    id::I
    elements::A
    sides::A
    num_nodes_per_side::A
    side_nodes::A
end
```

## Common interface

These methods work for any `S <: AbstractExodusSet` (i.e. `Block`, `NodeSet`, or `SideSet`):

```julia
read_ids(exo, S)              # Vector of all set IDs of type S
read_names(exo, S)             # Vector of all set names of type S, in ID order
read_name(exo, S, id)          # name of single set
write_name(exo, S, id, name)   # assign/overwrite a name
write_name(exo, set, name)     # equivalently, from a set object
write_names(exo, S, names)     # write a vector of names at once
```

`length(set)` returns the number of entries in a `NodeSet` (its node count) or `SideSet` (its element/side count).

## Reading sets

```julia
nset = NodeSet(exo, 1)
nset = NodeSet(exo, "nset_1")

sset = SideSet(exo, 1)
sset = SideSet(exo, "sset_1")

# generic form, dispatches on the type
set = read_set(exo, NodeSet, 1)

# read every set of a given type
nsets = read_sets(exo, NodeSet)
ssets = read_sets(exo, SideSet)
```

Lower-level accessors:

```julia
num_entries, num_dist_factors = Exodus.read_set_parameters(exo, set_id, NodeSet)

nodes = Exodus.read_node_set_nodes(exo, set_id)

elements, sides = Exodus.read_side_set_elements_and_sides(exo, set_id)

num_nodes_per_side, side_nodes = read_side_set_node_list(exo, side_set_id)
```

## Writing sets

```julia
write_set(exo, nset)              # write a single NodeSet or SideSet
write_sets(exo, [nset1, nset2])   # write several at once
```

`write_set` first writes the set's parameters (`Exodus.write_set_parameters`) and then its entries.

!!! warning
    Writing sets currently does not support distance factors.

## Errors

If an ID or name does not correspond to an existing set, a `SetIDException` or `SetNameException` is thrown, listing the available IDs/names for that set type.
