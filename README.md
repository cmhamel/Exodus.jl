[![CI](https://github.com/cmhamel/Exodus.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/cmhamel/Exodus.jl/actions/workflows/ci.yml)
[![codecov.io](http://codecov.io/github/cmhamel/Exodus.jl/coverage.svg?branch=master)](http://codecov.io/github/cmhamel/Exodus.jl?branch=master)
[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://cmhamel.github.io/Exodus.jl)
[![Aqua QA](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

# Exodus.jl
A julia interface for accessing the ExodusII data format for large scale finite element simulations. The C library is directly called through julia ccalls. 

# Installation
From the package manager simply type
```
add Exodus
```

# Installation bug on mac due to hash mismatch
To overcome a hash mistmatch error do the following while we work this out
```
ENV["JULIA_PKG_IGNORE_HASHES"] = 1
using Pkg
Pkg.add("Exodus")
```

# Dependencies
The main dependency is Exodus_jll which has a build process that is still being worked out due to evolving changes in NetCDF_jll, HDF5_jll, and LibCURL_jll.

# Read Example
To read in an exodusII file (typically has a .e or .exo extension) simply do the following

```julia
exo = ExodusDatabase("/path-to-file/file.e", "r")
```
This returns an ExodusDatabase container which has a single field "exo" that is a file id for this now opened exodusII database in "r" i.e. read only format. The purpose of the container is to attached various types for multiple dispatch later on as the exodusII format can switch between data types for various fields such as element connectivity in Int32 or Int64 format or nodal variables in floats or doubles.

For more useful methods, one can fetch the blocks of elements as follows which contains connectivity information for different blocks of elements useful for grouping materials
```julia
block_ids = read_block_ids(exo)
blocks = read_blocks(exo, block_ids)
```
For boundary conditions one can grab the nodes with the following commands
```julia
nset_ids = read_node_set_ids(exo)
nsets = read_node_sets(exo, nset_ids)
```

Full code example:
```julia
using Exodus
exo = ExodusDatabase("../path-to-file/file.e", "r") # read only format
coords          = read_coordinates(exo) # matrix of n_nodes x n_dim
block_ids       = read_block_ids(exo)
blocks          = read_blocks(exo, block_ids) # contains connectivity information
nset_ids        = read_node_set_ids(exo)
nsets           = read_node_sets(exo, nset_ids) # contains nodes on boundaries
nodal_var_names = read_nodal_variable_names(exo)
elem_var_names  = read_element_variable_names(exo)
close(exo) # cleanup
```

# Write Example where the mesh is first copied
```julia
using Exodus
exo_old = ExodusDatabase("./mesh/square_meshes/mesh_test_0.0078125.g", "r")
copy(exo_old, "./temp_element_variables.e")
close(exo_old)
exo = ExodusDatabase("./temp_element_variables.e", "rw")

write_time(exo, 1, 0.0)
write_number_of_nodal_variables(exo, 2)
write_number_of_element_variables(exo, 3)

write_nodal_variable_name(exo, 1, "displ_x")
write_nodal_variable_name(exo, 2, "displ_y")

write_element_variable_name(exo, 1, "stress_xx")
write_element_variable_name(exo, 2, "stress_yy")
write_element_variable_name(exo, 3, "stress_xy")

write_nodal_variable_value(exo, 1, 1, randn(...))
... # and so on.

close(exo)
```