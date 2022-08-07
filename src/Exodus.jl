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
include("Variables.jl")
include("CommunicationMaps.jl")

ex_opts(EX_VERBOSE | EX_ABORT)

end # module
