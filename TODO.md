# TODO items
- Improved IO
    - Need to get the type of int values for all the different ints out there
    - Need to hook old code up to new ExodusDatabase struct which carries the types with it
- Release new version of Exodus_jll version 0.1.1 with updated build for newer version of exodusII using only cmake-exodus... i.e. much lighter weigth build and simpler
- Write methods for blocks
    - Need method for put of connectivity
    - Block names
- Write methods for nodesets
    - Nodeset IDs
    - Nodeset nodes
    - Nodeset names
- Write methods for nodal variables
    - Read/put variables names
    - Read/put number of variables
- Write methods for element variables
- Global variable stuff

After this you can probably release a serial version as Exodus.jl v0.1.6 and possibly announce it

# Big issues to be fixed
- Should a seperate paralell version be released or keep it all in one?
