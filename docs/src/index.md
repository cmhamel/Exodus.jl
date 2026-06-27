# Exodus.jl

`Exodus.jl` is a Julia wrapper around the [SEACAS ExodusII](https://github.com/sandialabs/seacas) C library (`libexodus`, provided via `Exodus_jll`). It exposes a thin, type-stable interface for reading and writing finite-element mesh databases in the Exodus/Genesis (`.e`/`.g`) format: coordinates, element blocks, node sets, side sets, maps, QA/info records, time steps, and field variables (global, nodal, element, node set, and side set variables).

## Features

- Read and write Exodus mesh databases (`ExodusDatabase`)
- Access blocks, node sets, and side sets by ID or by name
- Read/write nodal coordinates and coordinate names
- Read/write maps (node, element, face, edge) and ID maps
- Read/write global, nodal, element, node set, and side set variables
- Read/write time steps
- Read/write QA and info records
- Helper utilities for building connectivity graphs (element-to-element, node-to-element)
- Basic support for parallel/decomposed Exodus databases (load-balance and communication-map parameters)
- Thin wrappers around the `decomp`, `epu`, and `exodiff` SEACAS command line tools

## Installation

```julia
] add Exodus
```

`Exodus.jl` depends on `Exodus_jll`, which ships a prebuilt `libexodus`, so no separate installation of the SEACAS/ExodusII library is required.

## Quick start

```julia
using Exodus

# open an existing mesh in read mode
exo = ExodusDatabase("mesh.g", "r")

init = Exodus.initialization(exo)       # mesh sizing info
coords = read_coordinates(exo)          # num_dim x num_nodes matrix
block = read_block(exo, 1)              # element Block by ID
nsets = read_sets(exo, NodeSet)         # all NodeSets

close(exo)
```

Or, using the do-block form which closes the file automatically:

```julia
ExodusDatabase("mesh.g", "r") do exo
    coords = read_coordinates(exo)
    block_ids = read_ids(exo, Block)
end
```

## Manual Outline

```@contents
Pages = [
    "database.md",
    "blocks.md",
    "sets.md",
    "coordinates.md",
    "maps.md",
    "variables.md",
    "times.md",
    "info_qa.md",
    "parallel.md",
    "helpers.md",
]
Depth = 2
```

## Reference

```@contents
Pages = ["api.md"]
Depth = 2
```
