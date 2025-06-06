"""
$(EXPORTS)
"""
module Exodus

# exported types
export Block
export EdgeMap
# export ElementCommunicationMap
export ElementMap
export ElementVariable
export ExodusDatabase
export FaceMap
export GlobalVariable
export Initialization
export NodalVariable
export NodalVectorVariable
# export NodeCommunicationMap
export NodeMap
export NodeSet
export NodeSetVariable
# export ParallelExodusDatabase
export SideSet
export SideSetVariable

# exported io/misc methods
export close
export copy
export copy_mesh
export length

# exported read methods
export collect_element_connectivities
export collect_element_to_element_connectivities
export collect_node_to_element_connectivities
export read_block
export read_blocks
export read_block_id_map
export read_coordinates
export read_element_type
export read_id_map
export read_ids
export read_info
export read_map
export read_name
export read_names
# export read_num_map # not working as expected
export read_qa
export read_number_of_variables
export read_number_of_time_steps
export read_set
export read_sets
export read_side_set_node_list
export read_time
export read_times
export read_values

# exported write methods
export write_block
export write_blocks
export write_coordinates
export write_id_map
export write_info
export write_name
export write_names
export write_number_of_variables
export write_qa
export write_set
export write_sets
export write_time
export write_values

# exported parallel methods - note not all are exported on purpose
# since some are still very much in development
export decomp
export epu
export exodiff

# dependencies
using DocStringExtensions
using Exodus_jll

include("Errors.jl")

# exodus constants and type definitions
include("ExodusConstants.jl")
include("ExodusTypes.jl")

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

include("Helpers.jl")

function vizmesh end
function vizmesh! end

# TODO eventually make these options initialized through a flag or something
# TODO really you should move this to ExodusDatabase constructor with
# TODO some optional input arguments like int and float mode
options = EX_VERBOSE | EX_ABORT
set_exodus_options(options)

end # module
