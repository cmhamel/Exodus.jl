module Exodus

using Base
using Exodus_jll

include("Types.jl")
include("Errors.jl")

include("ExodusConstants.jl")
include("ExodusMethods.jl")


include("IO.jl")
include("Initialization.jl")
include("Coordinates.jl")
include("Times.jl")
include("Blocks.jl")
include("NodeMaps.jl")
include("NodeSets.jl")
include("Meshes.jl") # I don't think this should be provided, TODO remove Meshes
                     # and let users build there own mesh data structure so it's not to hardened
                     # unless we just leave it as an example?
include("Variables.jl")
include("CommunicationMaps.jl")

ex_opts(EX_VERBOSE | EX_ABORT)

end # module
