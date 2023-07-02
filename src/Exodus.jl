"""
$(EXPORTS)
"""
module Exodus

using DocStringExtensions
using Exodus_jll
using Suppressor

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
include("Initializations.jl")
include("QA.jl")

# the basic stuff
include("Coordinates.jl")
include("Times.jl")

# maps
include("CommunicationMaps.jl")
include("NodeMaps.jl")
include("Maps.jl")

# blocks, nodesets, sidesets
include("Blocks.jl")
include("NodeSets.jl")
include("SideSets.jl")

# variables
include("ElementVariables.jl")
include("GlobalVariables.jl")
include("NodalVariables.jl")
include("NodeSetVariables.jl")
include("SideSetVariables.jl")

# # tooling
include("Decomp.jl")
include("Epu.jl")
include("ExoDiff.jl")

# TODO eventually make these options initialized through a flag or something
# TODO really you should move this to ExodusDatabase constructor with
# TODO some optional input arguments like int and float mode
options = EX_VERBOSE | EX_ABORT
set_exodus_options(options)

end # module
