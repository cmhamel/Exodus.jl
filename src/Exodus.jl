module Exodus

using Base
using Suppressor
using Exodus_jll

include("Constants.jl")
include("Types.jl")
include("Errors.jl")
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

end # module
