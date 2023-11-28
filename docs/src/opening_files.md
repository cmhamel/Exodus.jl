# Opening files

Example opening a file in read-only mode
```jldoctest
using Exodus
exo = ExodusDatabase("../test/example_output/output.gold", "r")

# output

ExodusDatabase:
  File name                   = ../test/example_output/output.gold
  Mode                        = r

Initialization:
  Number of dim       = 2
  Number of nodes     = 16641
  Number of elem      = 16384
  Number of blocks    = 1
  Number of node sets = 4
  Number of side sets = 4

Block:
                                

NodeSet:
                                

SideSet:
                                

NodalVariable:
  u                             


```