# Reading Data
To read in an exodusII file (typically has a .e or .exo extension) simply do the following

```julia
exo = ExodusDatabase("/path-to-file/file.e", "r")
```


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