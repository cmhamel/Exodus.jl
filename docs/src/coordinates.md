# Coordinates

Nodal coordinates are read and written as a `num_dimensions x num_nodes` matrix, with one row per spatial dimension (`x`, `y`, and optionally `z`).

## Reading

```julia
coords = read_coordinates(exo)        # num_dim x num_nodes matrix
names  = Exodus.read_coordinate_names(exo)  # e.g. ["x", "y"]
```

To read only a contiguous range of nodes, or a single coordinate component:

```julia
# nodes [start_node_num, start_node_num + n_nodes - 1]
partial = Exodus.read_partial_coordinates(exo, start_node_num, n_nodes)

# a single component (1 = x, 2 = y, 3 = z) over a node range
x_chunk = Exodus.read_partial_coordinates_component(exo, start_node_num, n_nodes, 1)
y_chunk = Exodus.read_partial_coordinates_component(exo, start_node_num, n_nodes, "y")
```

## Writing

```julia
write_coordinates(exo, coords)                      # coords is num_dim x num_nodes (or a Vector for 1D)
Exodus.write_coordinate_names(exo, ["x", "y"])
```

Partial/component writes mirror the partial reads above:

```julia
Exodus.write_partial_coordinates(exo, start_node_num, coords)
Exodus.write_partial_coordinates_component(exo, start_node_num, 1, x_coords)
Exodus.write_partial_coordinates_component(exo, start_node_num, "x", x_coords)
```

!!! note
    `write_coordinates` validates that the number of nodes in `coords` matches `num_nodes(exo.init)` and throws an `ErrorException` if not.
