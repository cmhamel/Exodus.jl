# Opening files

The simplest way to open an exodusII file is to call the following method
```julia
mode = "r" # can be "r" for read, "rw" for read write
           # or "w" for write modes
exo = ExodusDatabase("/path/to/file/file.e", mode)
```
this howewer introduces a type stability however since the storage types different data types are not known until runtime. 

If ahead of time you know the types your data are stored as (typeically 32 bit integers for ids and 64 bit floats for values) you can call this constructor which is type stable (important if you keep reading)
```julia
mode = "r" # can be "r" for read, "rw" for read write
           # or "w" for write modes
exo = ExodusDatabase{Int32, Int32, Int32, Float64}("/path/to/file/file.e", mode)
```
Either way, these constructors return an ```ExodusDatabase``` container which has a field "exo" that is a file id for this now opened exodusII database in "mode" i.e. read/read-write/write format.

The container also contains additional meta-data for the current names of sets, variables, etc. present in the file to allow for a clean and efficient user facing interface.

Example opening a file in read-only mode
```julia
using Exodus
exo = ExodusDatabase("../test/example_output/output.gold", "r")

# example output

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
  unnamed_block_1               

NodeSet:
  unnamed_nset_1                  unnamed_nset_2                  unnamed_nset_3                  unnamed_nset_4                               

SideSet:
  unnamed_sset_1                  unnamed_sset_2                  unnamed_sset_3                  unnamed_sset_4                               

NodalVariable:
  u                             



```