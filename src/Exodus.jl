"""
$(EXPORTS)
"""
module Exodus

using DocStringExtensions
using Exodus_jll

# for docs
@template (FUNCTIONS, METHODS, MACROS) = 
"""
$(TYPEDSIGNATURES)
$(DOCSTRING)
$(METHODLIST)
"""

@template (TYPES) = 
"""
$(TYPEDFIELDS)
$(DOCSTRING)
"""

include("Errors.jl")

# exodus constants and type definitions
include("ExodusConstants.jl")
include("ExodusTypes.jl")

# setup
include("IO.jl")
include("Initialization.jl")

# # the basic stuff
include("Coordinates.jl")
include("Times.jl")

# # maps
include("CommunicationMaps.jl")
include("NodeMaps.jl")
include("Maps.jl")

# # blocks, nodesets, sidesets
include("SetsCommon.jl")
include("Blocks.jl")
include("NodeSets.jl")

# # variables
include("VariablesCommon.jl")
include("ElementVariables.jl")
include("GlobalVariables.jl")
include("NodalVariables.jl")

# tooling
include("ExoDiff.jl")

# TODO eventually make these options initialized through a flag or something
# TODO really you should move this to ExodusDatabase constructor with
# TODO some optional input arguments like int and float mode
ex_opts(EX_VERBOSE | EX_ABORT)

end # module
