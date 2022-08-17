[![CI](https://github.com/cmhamel/Exodus.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/cmhamel/Exodus.jl/actions/workflows/ci.yml)
[![codecov.io](http://codecov.io/github/cmhamel/Exodus.jl/coverage.svg?branch=master)](http://codecov.io/github/cmhamel/Exodus.jl?branch=master)

# Exodus.jl
A julia interface for accessing the ExodusII data format for large scale finite element simulations. The C library is directly called through julia ccalls rather than the existing python interface exodus.py for a more native julia environment. 

# Installation
From the package manager simply type
```
add Exodus
```
# Read Example
To read in an exodusII file (typically has a .e or .exo extension) simply do the following

```julia
exo = ExodusDatabase("/path-to-file/file.e", "r")
```
This returns an ExodusDatabase container which has a single field "exo" that is a file id for this now opened exodusII database in "r" i.e. read only format. The purpose of the container is to attached various types for multiple dispatch later on as the exodusII format can switch between data types for various fields such as element connectivity in Int32 or Int64 format or nodal variables in floats or doubles.

The next step is to get the initialization information which will be useful for many other methods later on.
```julia
init = Initialization(exo)
```
This is a container which contains the dimensionality, the number of nodes, the number of elements and all other low level global information. 

For more useful methods, one can fetch the blocks of elements as follows which contains connectivity information for different blocks of elements useful for grouping materials
```julia
block_ids = Exodus.read_block_ids(exo, init)
blocks = Exodus.read_blocks(exo, block_ids)
```
For boundary conditions one can grab the nodes with the following commands
```julia
nset_ids = Exodus.read_node_set_ids(exo, init)
nsets = Exodus.read_node_sets(exo, nset_ids)
```

Full code example:
```julia
using Exodus
exo = ExodusDatabase("../path-to-file/file.e", "r") # read only format
init = Initialization(exo)
coords = Exodus.read_coordinates(exo, init) # matrix of n_nodes x n_dim
block_ids = Exodus.read_block_ids(exo, init)
blocks = Exodus.read_blocks(exo, block_ids) # contains connectivity information
nset_ids = Exodus.read_node_set_ids(exo, init)
nsets = Exodus.read_node_sets(exo, nset_ids) # contains nodes on boundaries

# etc...
@show init
close(exo) # cleanup
```

# Write Example
Coming soon...
