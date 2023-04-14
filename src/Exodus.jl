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

# setup
include("IO.jl")
include("Initialization.jl")

# the basic stuff
include("Coordinates.jl")
include("Times.jl")

# maps
include("CommunicationMaps.jl")
include("NodeMaps.jl")
include("Maps.jl")

# blocks, nodesets, sidesets
include("SetsCommon.jl")
include("Blocks.jl")
include("NodeSets.jl")

# variables
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
export exodiff

# export types
export ExodusDatabase
export Initialization
export NodeSet

# export methods
export close
export copy

export put_coordinates
export put_coordinate_names

export read_blocks
export read_block_ids

export read_coordinates
export read_coordinate_names

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

export put_initialization

export read_number_of_time_steps
export read_times
export write_time

end # module
