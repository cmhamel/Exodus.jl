[![CI](https://github.com/cmhamel/Exodus.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/cmhamel/Exodus.jl/actions/workflows/ci.yml)

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

## v 0.1.5
Sixth release that moved to a model that has all ccalls for all the ex_get/ex_put methods in ExodusMethods.jl. Also some parallel support was added for reading in communication and node maps for internal/border nodes from a decomp exodus mesh/nemesis file.
07/04/2022

