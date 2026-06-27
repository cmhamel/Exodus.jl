# Variables

Exodus supports five kinds of time-dependent field variables, each represented in `Exodus.jl` by a marker type subtyping `AbstractExodusVariable`:

| Type                  | Lives on                          | "Set equivalent"  |
|:-----------------------|:-----------------------------------|:------------------|
| `GlobalVariable`        | the whole mesh (scalars per step) | — |
| `NodalVariable`         | every node                        | — |
| `ElementVariable`       | elements within a [`Block`](@ref) | `Block` |
| `NodeSetVariable`       | nodes within a [`NodeSet`](@ref)  | `NodeSet` |
| `SideSetVariable`       | sides within a [`SideSet`](@ref)  | `SideSet` |

`NodalScalarVariable` is an alias for `NodalVariable`. `NodalVectorVariable` is a convenience marker type for reading/writing multi-component nodal fields stored as separate scalar variables (e.g. `displ_x`, `displ_y`, `displ_z`).

## Variable counts and names

These work uniformly for every variable type `V`:

```julia
read_number_of_variables(exo, ElementVariable)   # e.g. 6
read_number_of_variables(exo, GlobalVariable)    # e.g. 5
read_number_of_variables(exo, NodalVariable)     # e.g. 3
read_number_of_variables(exo, NodeSetVariable)
read_number_of_variables(exo, SideSetVariable)

read_name(exo, ElementVariable, 1)    # "stress_xx"
read_names(exo, ElementVariable)      # ["stress_xx", "stress_yy", ...]
```

To write the number of variables and their names:

```julia
write_number_of_variables(exo, ElementVariable, 6)
write_name(exo, ElementVariable, 1, "stress_xx")

# or write all the names at once (also sets the variable count if not already set)
write_names(exo, ElementVariable, ["stress_xx", "stress_yy", "stress_zz"])
```

## Reading values

The core method signature is:

```julia
read_values(exo, VariableType, timestep, id, var_index_or_name)
```

where `id` means different things depending on `VariableType`:

- `ElementVariable` — the block ID that owns the variable
- `NodeSetVariable` — the node set ID
- `SideSetVariable` — the side set ID
- `GlobalVariable` / `NodalVariable` — `id` is omitted (fixed at `1`); convenience wrappers are provided

```julia
# element variable on block 1, "stress_xx" at time step 1
stress_xx = read_values(exo, ElementVariable, 1, 1, "stress_xx")
stress_xx = read_values(exo, ElementVariable, 1, 1, 1)        # by index instead of name

# global variables at time step 1 (returns the full vector of global variables)
g = read_values(exo, GlobalVariable, 1)

# nodal variable, by index or by name
u = read_values(exo, NodalVariable, 1, 1)
u = read_values(exo, NodalVariable, 1, "displ_x")

# node set / side set variables, by ID+index, or by name+name
v = read_values(exo, NodeSetVariable, 1, nset_id, "nset_displ_x")
v = read_values(exo, NodeSetVariable, 1, "nset_1", "nset_displ_x")
```

### Vector nodal fields

`NodalVectorVariable` assembles per-component nodal scalar variables (named `base_name * "_x"`, `"_y"`, and optionally `"_z"`) into a single `num_dim x num_nodes` matrix:

```julia
displ = read_values(exo, NodalVectorVariable, 1, "displ")  # uses displ_x, displ_y, (displ_z)
```

This only supports 2D and 3D meshes.

### Reading into a pre-allocated buffer

```julia
values = Vector{Float64}(undef, n)
read_values!(values, exo, ElementVariable, timestep, block_id, var_index)
```

## Writing values

```julia
write_values(exo, ElementVariable, timestep, block_id, var_index, var_values)
write_values(exo, ElementVariable, timestep, block_id, "stress_xx", var_values)
write_values(exo, NodeSetVariable, timestep, set_name, var_name, var_values)

# global variables (write_number_of_variables must be called first)
write_number_of_variables(exo, GlobalVariable, 5)
write_values(exo, GlobalVariable, 1, [10.0, 20.0, 30.0, 40.0, 50.0])

# nodal variables, by index or by name
write_values(exo, NodalVariable, 1, 1, u)
write_values(exo, NodalVariable, 1, "displ_x", u)
```

## Errors

If `id` does not correspond to an existing block/node set/side set, or `var_index`/`var_name` is invalid, a `VariableIDException` or `VariableNameException` is thrown describing the valid choices.
