# Exodus.jl
A julia interface for accessing the ExodusII data format for large scale finite element simulations. The C library is directly called through julia ccalls rather than the existing python interface exodus.py for a more native julia environment. 

# Version History

## v 0.1.0
Initial release that had only rudimentary IO access for reading nodal coordinates, element connectivity, blocks and node sets.
03/23/2022

## v 0.1.1
Second release that added support for IO of nodal variables. 
04/03/2022

## v 0.1.2
Third release that fixed a small convenience issue in block connectivity.
04/03/2022

## v 0.1.3
Fourth release that added suppressor macros for some exodus warnings.
04/03/2022

## v 0.1.4
Fifth release that is a patch for some inconsistenices in block connectivity ordering"
04/08/2022



