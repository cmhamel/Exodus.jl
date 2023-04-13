"""
    Exodus
"""
module Exodus

using Exodus_jll

# some simple types up front
# we can thus have databases of 4 varieties
# Int32, Float32 - likely most efficient for explicit dynamics
# Int32, Float64
# Int64, Float32
# Int64, Float64
"""
    ExoInt
Union of different Exodus integer types.
"""
ExoInt   = Union{Int32, Int64}
"""
    ExoFloat
Union of different Exodus float types
"""
ExoFloat = Union{Float32, Float64}

include("Errors.jl")

# exodus constants and type definitions
include("ExodusConstants.jl")
include("ExodusTypes.jl")
include("ExodusMethods.jl")

# setup
include("IO.jl")
include("Initialization.jl")

# the basic stuff
include("Coordinates.jl")
include("Times.jl")

# blocks, nodesets, sidesets
include("SetsCommon.jl")
include("Blocks.jl")
include("NodeSets.jl")

# variables
include("VariablesCommon.jl")
include("GlobalVariables.jl")
include("NodalVariables.jl")

include("Maps.jl")


# include("NodeMaps.jl") # removing parallel support until serial is fully supported

# include("CommunicationMaps.jl") # removing parallel support until serial is fully supported

# TODO eventually make these options initialized through a flag or something
# TODO really you should move this to ExodusDatabase constructor with
# TODO some optional input arguments like int and float mode
ex_opts(EX_VERBOSE | EX_ABORT)

# exports
export close
export copy
export ExodusDatabase
export Initialization

end # module
