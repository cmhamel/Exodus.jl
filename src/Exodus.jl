module Exodus

using Exodus_jll

# some simple types up front
ExoInt   = Union{Int32, Int64}
ExoFloat = Union{Float32, Float64}

include("Errors.jl")

include("ExodusConstants.jl")
include("ExodusTypes.jl")
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

# TODO eventually make these options initialized through a flag or something
ex_opts(EX_VERBOSE | EX_ABORT)

end # module
