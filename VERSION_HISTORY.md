# Version History

## v0.1.0
Initial release that had only rudimentary IO access for reading nodal coordinates, element connectivity, blocks and node sets.
03/23/2022

## v0.1.1
Second release that added support for IO of nodal variables. 
04/03/2022

## v0.1.2
Third release that fixed a small convenience issue in block connectivity.
04/03/2022

## v0.1.3
Fourth release that added suppressor macros for some exodus warnings.
04/03/2022

## v0.1.4
Fifth release that is a patch for some inconsistenices in block connectivity ordering"
04/08/2022

## v0.1.5
Sixth release that moved to a model that has all ccalls for all the ex_get/ex_put methods in ExodusMethods.jl. Also some parallel support was added for reading in communication and node maps for internal/border nodes from a decomp exodus mesh/nemesis file.
07/04/2022

## v0.1.6
Seventh release which majorly refactored the code to handle the many different possible ways to utilize exodus i.e. 32 vs. 64 bit types for different fields. More tests added and focus was put on hardening the serial IO while temporarily deprecating parallel capabilities. Testing pipelines were adding. Also Exodus_jll was upgraded to v0.1.1 which deprecated MacOs temporarily to simplify the build process. Test coverage is now being tracked as well.
08/23/2022

## v0.1.7
Coming soon...