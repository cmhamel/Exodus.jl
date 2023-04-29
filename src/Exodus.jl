"""
  Exodus
"""
module Exodus

using Exodus_jll

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
include("GlobalVariables.jl")
include("NodalVariables.jl")

# tooling
include("ExoDiff.jl")

# TODO eventually make these options initialized through a flag or something
# TODO really you should move this to ExodusDatabase constructor with
# TODO some optional input arguments like int and float mode
ex_opts(EX_VERBOSE | EX_ABORT)

# export macros
export @exodiff

# export types
export ExodusDatabase
export Initialization
export NodeSet

# export methods

export read_blocks
export read_block_ids

export read_element_map

export read_node_sets
export read_node_set_ids

export read_number_of_global_variables
export read_global_variables
export write_number_of_global_variables
export write_global_variable_values

export read_number_of_nodal_variables
export read_nodal_variable_names
export read_nodal_variable_values

export put_initialization!

export read_number_of_time_steps
export read_times
export write_time

end # module
