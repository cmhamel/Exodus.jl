[![Build Status](https://github.com/cmhamel/Exodus.jl/workflows/CI/badge.svg)](https://github.com/cmhamel/Exodus.jl/actions?query=workflow%3ACI)
[![PkgEval](https://JuliaCI.github.io/NanosoldierReports/pkgeval_badges/E/Exodus.svg)](https://JuliaCI.github.io/NanosoldierReports/pkgeval_badges/E/Exodus.html)
[![Aqua QA](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)
[![Coverage](https://codecov.io/gh/cmhamel/Exodus.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/cmhamel/Exodus.jl) 

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://cmhamel.github.io/Exodus.jl/stable/) 
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
exo_old = ExodusDatabase("./mesh/square_meshes/mesh_test_0.0078125.g", "r")
copy(exo_old, "./temp_element_variables.e")
close(exo_old)
exo = ExodusDatabase("./temp_element_variables.e", "rw")

write_time(exo, 1, 0.0)
write_number_of_variables(exo, NodalVariable, 2)
write_number_of_variables(exo, ElementVariable, 3)

write_name(exo, NodalVariable, 1, "displ_x")
write_name(exo, NodalVariable, 2, "displ_y")

write_name(exo, ElementVariable, 1, "stress_xx")
write_name(exo, ElementVariable, 2, "stress_yy")
write_name(exo, ElementVariable, 3, "stress_xy")

write_values(exo, NodalVariable, 1, 1, randn(...))
... # and so on.

close(exo)
```


