# Exodus.jl
A julia interface for accessing the ExodusII data format for large scale finite element simulations. The C library is directly called through julia ccalls rather than the existing python interface exodus.py for a more native julia environment. 

# Version History

## v 0.1.0
Initial release that had only rudimentary IO access for reading nodal coordinates, element connectivity, blocks and node sets.

## v 0.1.1
Second release that added support for IO of nodal variables.

