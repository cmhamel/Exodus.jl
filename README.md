<!-- [![CI](https://github.com/cmhamel/Exodus.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/cmhamel/Exodus.jl/actions/workflows/ci.yml)
[![codecov.io](http://codecov.io/github/cmhamel/Exodus.jl/coverage.svg?branch=master)](http://codecov.io/github/cmhamel/Exodus.jl?branch=master)
[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://cmhamel.github.io/Exodus.jl)
[![Aqua QA](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl) -->

[![Build Status](https://github.com/cmhamel/Exodus.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/cmhamel/Exodus.jl/actions/workflows/CI.yml?query=branch%3Amain) 
[![PkgEval](https://JuliaCI.github.io/NanosoldierReports/pkgeval_badges/E/Exodus.svg)](https://JuliaCI.github.io/NanosoldierReports/pkgeval_badges/E/Exodus.html)
[![Aqua QA](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://cmhamel.github.io/Exodus.jl/stable/) 
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://cmhamel.github.io/Exodus.jl/dev/) 
[![Coverage](https://codecov.io/gh/cmhamel/Exodus.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/cmhamel/Exodus.jl) 


# Exodus.jl
A julia interface for accessing the ExodusII data format for large scale finite element simulations. The C library is directly called through julia ccalls. 

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

For more useful methods, one can fetch the blocks of elements as follows which contains connectivity information for different blocks of elements useful for grouping materials
```julia
block_ids = read_element_block_ids(exo)
blocks = read_element_blocks(exo, block_ids)
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
block_ids       = read_element_block_ids(exo)
blocks          = read_element_blocks(exo, block_ids) # contains connectivity information
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

# Writing an exodus file from scratch example - 4 element mesh of Quad4 elements

```julia
# data to write
coords = [
  1.0 0.5 0.5 1.0 0.0 0.0 0.5 1.0 0.0
  1.0 1.0 0.5 0.5 1.0 0.5 0.0 0.0 0.0
]

conn = [
  1 2 4 3
  2 5 3 6
  3 6 7 9
  4 3 8 7
]

# make some hack variables to write
v_nodal_1 = rand(9)
v_nodal_2 = rand(9)

v_elem_1 = rand(4)
v_elem_2 = rand(4)

# set the types
maps_int_type = Int32
ids_int_type  = Int32
bulk_int_type = Int32
float_type    = Float64

# initialization parameters
num_dim, num_nodes = size(coords)
num_elems          = size(conn, 2)
num_elem_blks      = 1
num_side_sets      = 0
num_node_sets      = 0

# create exodus database
exo = ExodusDatabase(
  "test_write.e";
  maps_int_type, ids_int_type, bulk_int_type, float_type,
  num_dim, num_nodes, num_elems,
  num_elem_blks, num_node_sets, num_side_sets
)

@show exo

# how to write coordinates
write_coordinates(exo, coords)
# how to write a block
write_element_block(exo, 1, "QUAD4", conn)
# need at least one timestep to output variables
write_time(exo, 1, 0.0)
# write number of variables and their names
write_number_of_nodal_variables(exo, 2)
write_nodal_variable_names(exo, ["v_nodal_1", "v_nodal_2"])
write_number_of_element_variables(exo, 2)
write_element_variable_names(exo, ["v_elem_1", "v_elem_2"])
# write variable values the 1 is for the time step
write_nodal_variable_values(exo, 1, "v_nodal_1", v_nodal_1)
write_nodal_variable_values(exo, 1, "v_nodal_2", v_nodal_2)
# the first 1 is for the time step 
# and the second 1 is for the block number
write_element_variable_values(exo, 1, 1, "v_elem_1", v_elem_1)
write_element_variable_values(exo, 1, 1, "v_elem_2", v_elem_2)

# don't forget to close the exodusdatabase, it can get corrupted otherwise if you're writing
close(exo)

```