module Exodus

export close
export copy
export ExodusDatabase
export Initialization


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
# include("NodeMaps.jl") # removing parallel support until serial is fully supported
include("NodeSets.jl")
include("NodalVariables.jl")
# include("CommunicationMaps.jl") # removing parallel support until serial is fully supported

# TODO eventually make these options initialized through a flag or something
ex_opts(EX_VERBOSE | EX_ABORT)

end # module
