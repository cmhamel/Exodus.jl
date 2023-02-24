"""
    Exodus
"""
module Exodus

export close
export copy
export ExodusDatabase
export Initialization

using Exodus_jll
# using Seacas_jll

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

include("ExodusConstants.jl")
include("ExodusTypes.jl")
include("ExodusMethods.jl")

include("IO.jl")
include("Initialization.jl")

include("Blocks.jl")
include("Coordinates.jl")
include("Maps.jl")
include("NodeSets.jl")
include("NodalVariables.jl")
include("Times.jl")

# include("NodeMaps.jl") # removing parallel support until serial is fully supported

# include("CommunicationMaps.jl") # removing parallel support until serial is fully supported

# TODO eventually make these options initialized through a flag or something
# TODO really you should move this to ExodusDatabase constructor with
# TODO some optional input arguments like int and float mode
ex_opts(EX_VERBOSE | EX_ABORT)

end # module
