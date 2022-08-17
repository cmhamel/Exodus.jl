module Exodus

export close
export copy
export ExodusDatabase
export Initialization

using Exodus_jll

# some simple types up front
# we can thus have databases of 4 varieties
# Int32, Float32 - likely most efficient for explicit dynamics
# Int32, Float64
# Int64, Float32
# Int64, Float64
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
# include("NodeMaps.jl") # removing parallel support until serial is fully supported
include("NodeSets.jl")
include("NodalVariables.jl")
# include("CommunicationMaps.jl") # removing parallel support until serial is fully supported

# TODO eventually make these options initialized through a flag or something
# TODO really you should move this to ExodusDatabase constructor with
# TODO some optional input arguments like int and float mode
ex_opts(EX_VERBOSE | EX_ABORT)

end # module
