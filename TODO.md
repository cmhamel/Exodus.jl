# TODO items
- Release new version of Exodus_jll version 0.1.1 with updated build for newer version of exodusII using only cmake-exodus... i.e. much lighter weigth build and simpler
    - This has been achieved but further OS support is in the works    - This is seperate from Yggdrasil currently until an upstream version of seacas can be patched with the cmake removal for FindNetCDF.cmake
    - Windows is working but macOS is now the issue
- Write methods for blocks
    - Need methods for put of connectivity
    - Block initialization
    - Block IDs
    - Block names
    - Element type, etc.
- Write methods for nodesets
    - Nodeset IDs
    - Nodeset nodes
    - Nodeset names
- Write methods for nodal variables
    - put variables names
    - put number of variables
- Read/Write methods for element variables
- Global variable stuff

After this you can probably release a serial version as Exodus.jl v0.1.6 and possibly announce it

# Big issues to be fixed
- Should a seperate paralell version be released or keep it all in one?

# Documentation!
- Need to start documentation and examples so people can actually use this!
