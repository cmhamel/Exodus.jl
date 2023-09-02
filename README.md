[![Build Status](https://github.com/cmhamel/Exodus.jl/workflows/CI/badge.svg)](https://github.com/cmhamel/Exodus.jl/actions?query=workflow%3ACI)
[![PkgEval](https://JuliaCI.github.io/NanosoldierReports/pkgeval_badges/E/Exodus.svg)](https://JuliaCI.github.io/NanosoldierReports/pkgeval_badges/E/Exodus.html)
[![Aqua QA](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)
[![Coverage](https://codecov.io/gh/cmhamel/Exodus.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/cmhamel/Exodus.jl) 
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://cmhamel.github.io/Exodus.jl/dev/) 




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
blocks = read_sets(exo, Block)
```
For boundary conditions one can grab the nodes with the following commands
```julia
nsets = read_sets(exo, NodeSet)
```

Full code example:
```julia
using Exodus
exo = ExodusDatabase("../path-to-file/file.e", "r") # read only format
coords          = read_coordinates(exo) # matrix of n_nodes x n_dim
blocks          = read_sets(exo, Block) # contains connectivity information
nsets           = read_sets(exo, NodeSet) # contains nodes on boundaries
nodal_var_names = read_names(exo, NodalVariable)
elem_var_names  = read_names(exo, ElementVariable)
close(exo) # cleanup
```

# Write Example where the mesh is first copied
```julia
using Exodus
copy_mesh("./mesh.g", "r")
exo = ExodusDatabase("./temp_element_variables.e", "rw")

write_time(exo, 1, 0.0)

write_names(exo, NodalVariable, ["displ_x", "displ_y"])
write_names(exo, ElementVariable, ["stress_xx", "stress_yy", "stress_xy"])

write_values(exo, NodalVariable, 1, 1, randn(...))
... # and so on.

close(exo)
```

# Write example from scratch
```julia
using Exodus

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

# make init
init = Initialization{bulk_int_type}(
  num_dim, num_nodes, num_elems,
  num_elem_blks, num_side_sets, num_node_sets
)

# finally make empty exo database
exo = ExodusDatabase(
  "test_write.e", "w", init,
  maps_int_type, ids_int_type, bulk_int_type, float_type
)

# how to write coordinates
write_coordinates(exo, coords)
# how to write a block
write_block(exo, 1, "QUAD4", conn)
# need at least one timestep to output variables
write_time(exo, 1, 0.0)
# write number of variables and their names
write_names(exo, NodalVariable, ["v_nodal_1", "v_nodal_2"])
write_names(exo, ElementVariable, ["v_elem_1", "v_elem_2"])
# write variable values the 1 is for the time step
write_values(exo, NodalVariable, 1, "v_nodal_1", v_nodal_1)
write_values(exo, NodalVariable, 1, "v_nodal_2", v_nodal_2)
# the first 1 is for the time step 
# and the second 1 is for the block number
write_values(exo, ElementVariable, 1, 1, "v_elem_1", v_elem_1)
write_values(exo, ElementVariable, 1, 1, "v_elem_2", v_elem_2)
# don't forget to close the exodusdatabase, it can get corrupted otherwise if you're writing
close(exo)
```
