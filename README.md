[![CI](https://github.com/cmhamel/Exodus.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/cmhamel/Exodus.jl/actions/workflows/ci.yml)
[![codecov.io](http://codecov.io/github/cmhamel/Exodus.jl/coverage.svg?branch=master)](http://codecov.io/github/cmhamel/Exodus.jl?branch=master)

# Exodus.jl
A julia interface for accessing the ExodusII data format for large scale finite element simulations. The C library is directly called through julia ccalls rather than the existing python interface exodus.py for a more native julia environment. 

# Installation
From the package manager simply type
```
add Exodus
```
# Example
To read in an exodusII file (typically has a .e or .exo extension) simply do the following

```julia
using Exodus
exo = ExodusDatabase("../path-to-file/file.e", "r") # read only format
init = Initialization(exo)

# etc...
@show init
close(exo) # cleanup
```

This returns an ExodusDatabase container which has a single field "exo" that is a file id for this now opened exodusII database in "r" i.e. read only format. The purpose of the container is to attached various types for multiple dispatch later on as the exodusII format can switch between data types for various fields such as element connectivity in Int32 or Int64 format or nodal variables in floats or doubles.

The next step is to get the initialization information which will be useful for many other methods later on.

```julia
init = Initialization(exo)
```


