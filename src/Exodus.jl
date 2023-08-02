"""
$(EXPORTS)
"""
module Exodus

# exported types
export Block
export ExodusDatabase
export Initialization
export NodeSet
export SideSet

# exported io/misc methods
export close
export copy
export exo_int_types
export exo_float_type
export length
export set_exodus_max_name_length
export set_exodus_options

# exported read methods
export collection_element_block_connectivities
export read_coordinates
export read_coordinate_names
export read_element_blocks
export read_element_block_id_map
export read_element_block_ids
export read_element_block_names
export read_element_block_connectivity
export read_element_block_parameters
export read_element_map
export read_element_type
export read_element_variable_name
export read_element_variable_names
export read_element_variable_values
export read_global_variable_name
export read_global_variable_names
export read_global_variable_values

export read_ids

export read_info

export read_names

export read_nodal_variable_name
export read_nodal_variable_names
export read_nodal_variable_values
export read_node_set_variable_name
export read_node_set_variable_names
export read_node_set_variable_values
export read_partial_coordinates
export read_partial_coordinates_component
export read_partial_element_block_connectivity
export read_partial_nodal_variable_values
export read_qa
export read_number_of_element_variables
export read_number_of_global_variables
export read_number_of_nodal_variables
export read_number_of_node_set_variables
export read_number_of_side_set_variables
export read_number_of_time_steps
export read_side_set_elements_and_sides
export read_side_set_node_list
export read_side_set_variable_name
export read_side_set_variable_names
export read_side_set_variable_values
export read_time
export read_times

# exported write methods
export write_coordinates
export write_coordinate_names
export write_element_block
export write_element_block_connectivity
export write_element_block_name
export write_element_block_names
export write_element_blocks
export write_element_variable_name
export write_element_variable_names
export write_element_variable_values
export write_global_variable_name
export write_global_variable_names
export write_global_variable_values
export write_info
export write_initialization!
export write_nodal_variable_name
export write_nodal_variable_names
export write_nodal_variable_values
export write_node_set
export write_node_set_name
export write_node_set_names
export write_node_set_variable_name
export write_node_set_variable_names
export write_node_set_variable_values
export write_node_sets
export write_number_of_element_variables
export write_number_of_global_variables
export write_number_of_nodal_variables
export write_number_of_node_set_variables
export write_number_of_side_set_variables
export write_partial_coordinates
export write_partial_coordinates_component
export write_qa
export write_side_set
export write_side_set_name
export write_side_set_names
export write_side_set_variable_name
export write_side_set_variable_names
export write_side_set_variable_values
export write_side_sets
export write_time

# exported parallel methods - note not all are exported on purpose
# since some are still very much in development
export decomp
export @decomp
export @epu
export @exodiff

# dependencies
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

# record keeping
include("Info.jl")
include("QA.jl")

# the basic stuff
include("Coordinates.jl")
include("Times.jl")

# maps
include("Maps.jl")

# blocks, nodesets, sidesets
include("Blocks.jl")
include("Sets.jl")

# element, global, nodal, nodeset, and sideset variables
include("Variables.jl")

# parallel capabilities without MPI build
include("Decomp.jl")
include("Epu.jl")
include("ExoDiff.jl")
include("ParallelExodus.jl")

# TODO eventually make these options initialized through a flag or something
# TODO really you should move this to ExodusDatabase constructor with
# TODO some optional input arguments like int and float mode
options = EX_VERBOSE | EX_ABORT
set_exodus_options(options)

end # module
