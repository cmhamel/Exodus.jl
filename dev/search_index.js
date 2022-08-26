var documenterSearchIndex = {"docs":
[{"location":"#Exodus.jl","page":"Exodus.jl","title":"Exodus.jl","text":"","category":"section"},{"location":"","page":"Exodus.jl","title":"Exodus.jl","text":"Documentation for Exodus.jl","category":"page"},{"location":"#Documentation","page":"Exodus.jl","title":"Documentation","text":"","category":"section"},{"location":"","page":"Exodus.jl","title":"Exodus.jl","text":"Modules = [Exodus]","category":"page"},{"location":"#Exodus.Exodus","page":"Exodus.jl","title":"Exodus.Exodus","text":"Exodus\n\n\n\n\n\n","category":"module"},{"location":"#Exodus.ExoFloat","page":"Exodus.jl","title":"Exodus.ExoFloat","text":"ExoFloat\n\nUnion of different Exodus float types\n\n\n\n\n\n","category":"type"},{"location":"#Exodus.ExoInt","page":"Exodus.jl","title":"Exodus.ExoInt","text":"ExoInt\n\nUnion of different Exodus integer types.\n\n\n\n\n\n","category":"type"},{"location":"#Exodus.Block","page":"Exodus.jl","title":"Exodus.Block","text":"Block{I <: ExoInt, B <: ExoInt}\n\nContainer for reading in blocks\n\n\n\n\n\n","category":"type"},{"location":"#Exodus.Block-Union{Tuple{F}, Tuple{B}, Tuple{I}, Tuple{M}, Tuple{ExodusDatabase{M, I, B, F}, I}} where {M<:Union{Int32, Int64}, I<:Union{Int32, Int64}, B<:Union{Int32, Int64}, F<:Union{Float32, Float64}}","page":"Exodus.jl","title":"Exodus.Block","text":"Block(exo::ExodusDatabase{M, I, B, F}, block_id::I) where {M <: ExoInt, I <: ExoInt,\n                                                           B <: ExoInt, F <: ExoFloat}\n\nInit method for block container.\n\n\n\n\n\n","category":"method"},{"location":"#Exodus.ExodusDatabase","page":"Exodus.jl","title":"Exodus.ExodusDatabase","text":"ExodusDatabase{M <: ExoInt, I <: ExoInt, B <: ExoInt, F <: ExoFloat}\n\nMain entry point for the package whether it's in read or write mode. \n\n\n\n\n\n","category":"type"},{"location":"#Exodus.ExodusDatabase-Tuple{String, String}","page":"Exodus.jl","title":"Exodus.ExodusDatabase","text":"ExodusDatabase(file_name::String, mode::String; int_mode=\"32-bit\", float_mode=\"64-bit\")\n\nInit method.\n\nArguments\n\nfile_name::String: absolute path to exodus file\nmode::String: mode to read \nint_mode: either 32-bit or 64-bit\nfloat_mode: either 32-bit or 64-bit\n\n\n\n\n\n","category":"method"},{"location":"#Exodus.Initialization","page":"Exodus.jl","title":"Exodus.Initialization","text":"Initialization\n\nContainer that should be setup first thing after getting an exo ID\n\n\n\n\n\n","category":"type"},{"location":"#Exodus.Initialization-Union{Tuple{ExodusDatabase{M, I, B, F}}, Tuple{F}, Tuple{B}, Tuple{I}, Tuple{M}} where {M<:Union{Int32, Int64}, I<:Union{Int32, Int64}, B<:Union{Int32, Int64}, F<:Union{Float32, Float64}}","page":"Exodus.jl","title":"Exodus.Initialization","text":"Initialization(exo::ExodusDatabase{M, I, B, F}) where {M <: ExoInt, I <: ExoInt, B <: ExoInt, F <: ExoFloat}\n\n\n\n\n\n","category":"method"},{"location":"#Exodus.NodeSet","page":"Exodus.jl","title":"Exodus.NodeSet","text":"NodeSet{I <: ExoInt, B <: ExoInt}\n\nContainer for node sets.\n\n\n\n\n\n","category":"type"},{"location":"#Exodus.NodeSet-Union{Tuple{F}, Tuple{B}, Tuple{I}, Tuple{M}, Tuple{ExodusDatabase{M, I, B, F}, I}} where {M<:Union{Int32, Int64}, I<:Union{Int32, Int64}, B<:Union{Int32, Int64}, F<:Union{Float32, Float64}}","page":"Exodus.jl","title":"Exodus.NodeSet","text":"NodeSet(exo::ExodusDatabase{M, I, B, F}, node_set_id::I) where {M <: ExoInt, I <: ExoInt,\n                                                                B <: ExoInt, F <: ExoFloat}\n\nInit method for a NodeSet with ID nodesetid.\n\n\n\n\n\n","category":"method"},{"location":"#Exodus.ex_entity_id","page":"Exodus.jl","title":"Exodus.ex_entity_id","text":"ex_entity_id = Clonglong\n\n\n\n\n\n","category":"type"},{"location":"#Exodus.ex_entity_type","page":"Exodus.jl","title":"Exodus.ex_entity_type","text":"ex_entity_type\n\nEntity type enums (exentitytype in exodusII.h)\n\n\n\n\n\n","category":"type"},{"location":"#Exodus.ex_inquiry","page":"Exodus.jl","title":"Exodus.ex_inquiry","text":"ex_inquiry\n\nInquiry enums (ex_inquiry in exodusII.h).\n\n\n\n\n\n","category":"type"},{"location":"#Exodus.void_int","page":"Exodus.jl","title":"Exodus.void_int","text":"void_int = Cvoid\n\n\n\n\n\n","category":"type"},{"location":"#Base.close-Union{Tuple{ExodusDatabase{M, I, B, F}}, Tuple{F}, Tuple{B}, Tuple{I}, Tuple{M}} where {M<:Union{Int32, Int64}, I<:Union{Int32, Int64}, B<:Union{Int32, Int64}, F<:Union{Float32, Float64}}","page":"Exodus.jl","title":"Base.close","text":"Base.close(exo::ExodusDatabase{M, I, B, F}) where {M <: ExoInt, I <: ExoInt, B <: ExoInt, F <: ExoFloat}\n\nUsed to close and ExodusDatabase.\n\n\n\n\n\n","category":"method"},{"location":"#Base.copy-Union{Tuple{F}, Tuple{B}, Tuple{I}, Tuple{M}, Tuple{ExodusDatabase{M, I, B, F}, String}} where {M<:Union{Int32, Int64}, I<:Union{Int32, Int64}, B<:Union{Int32, Int64}, F<:Union{Float32, Float64}}","page":"Exodus.jl","title":"Base.copy","text":"Base.copy(exo::ExodusDatabase{M, I, B, F},\n          new_file_name::String) where {M <: ExoInt, I <: ExoInt, B <: ExoInt, F <: ExoFloat}\n\nUsed to copy an ExodusDatabase. As of right now this is the best way to create a new ExodusDatabase for output. Not all of the put methods have been wrapped and properly tested. This one has though.\n\n\n\n\n\n","category":"method"},{"location":"#Base.length-Tuple{Exodus.NodeSet}","page":"Exodus.jl","title":"Base.length","text":"Base.length(nset::NodeSet)\n\n\n\n\n\n","category":"method"},{"location":"#Exodus.ex_close!-Tuple{Int32}","page":"Exodus.jl","title":"Exodus.ex_close!","text":"ex_close!(exoid::Cint)\n\n\n\n\n\n","category":"method"},{"location":"#Exodus.ex_copy!-Tuple{Int32, Int32}","page":"Exodus.jl","title":"Exodus.ex_copy!","text":"ex_copy!(in_exoid::Cint, out_exoid::Cint)\n\n\n\n\n\n","category":"method"},{"location":"#Exodus.ex_get_coord!-Union{Tuple{T}, Tuple{Int32, Vector{T}, Ptr{Nothing}, Ptr{Nothing}}} where T<:Union{Float32, Float64}","page":"Exodus.jl","title":"Exodus.ex_get_coord!","text":"ex_get_coord!(exoid::Cint, x_coords::Vector{T}, y_coords::Ptr{Cvoid}, z_coords::Ptr{Cvoid}) where {T <: ExoFloat}\n\n\n\n\n\n","category":"method"},{"location":"#Exodus.ex_get_coord!-Union{Tuple{T}, Tuple{Int32, Vector{T}, Vector{T}, Ptr{Nothing}}} where T<:Union{Float32, Float64}","page":"Exodus.jl","title":"Exodus.ex_get_coord!","text":"ex_get_coord!(exoid::Cint, x_coords::Vector{T}, y_coords::Vector{T}, z_coords::Ptr{Cvoid}) where {T <: ExoFloat}\n\n\n\n\n\n","category":"method"},{"location":"#Exodus.ex_get_coord!-Union{Tuple{T}, Tuple{Int32, Vector{T}, Vector{T}, Vector{T}}} where T<:Union{Float32, Float64}","page":"Exodus.jl","title":"Exodus.ex_get_coord!","text":"ex_get_coord!(exoid::Cint, x_coords::Vector{T}, y_coords::Vector{T}, z_coords::Vector{T}) where {T <: ExoFloat}\n\n\n\n\n\n","category":"method"},{"location":"#Exodus.ex_get_coord_names!-Tuple{Int32, Vector{Vector{UInt8}}}","page":"Exodus.jl","title":"Exodus.ex_get_coord_names!","text":"ex_get_coord_names!(exo_id::Cint, coord_names::Vector{Vector{UInt8}})\n\n\n\n\n\n","category":"method"},{"location":"#Exodus.ex_get_id_map!-Union{Tuple{T}, Tuple{Int32, Exodus.ex_entity_type, Vector{T}}} where T<:Union{Int32, Int64}","page":"Exodus.jl","title":"Exodus.ex_get_id_map!","text":"ex_get_id_map!(exoid::Cint, map_type::ex_entity_type, map::Vector{T}) where {T <: ExoInt}\n\n\n\n\n\n","category":"method"},{"location":"#Exodus.ex_get_ids!-Union{Tuple{T}, Tuple{Int32, Exodus.ex_entity_type, Vector{T}}} where T<:Union{Int32, Int64}","page":"Exodus.jl","title":"Exodus.ex_get_ids!","text":"ex_get_ids!(exoid::Cint, exo_const::ex_entity_type, ids::Vector{T}) where {T <: ExoInt}\n\n\n\n\n\n","category":"method"},{"location":"#Exodus.ex_get_init!-Tuple{Int32, Vector{UInt8}, Ref{Int64}, Ref{Int64}, Ref{Int64}, Ref{Int64}, Ref{Int64}, Ref{Int64}}","page":"Exodus.jl","title":"Exodus.ex_get_init!","text":"ex_get_init!(exoid::Cint, \n             title::Vector{UInt8},\n             num_dim::Ref{Clonglong}, num_nodes::Ref{Clonglong}, num_elem::Ref{Clonglong}, \n             num_elem_blk::Ref{Clonglong}, num_node_sets::Ref{Clonglong}, num_side_sets::Ref{Clonglong})\n\n\n\n\n\n","category":"method"},{"location":"#Exodus.ex_get_map!-Union{Tuple{T}, Tuple{Int32, Vector{T}}} where T<:Union{Int32, Int64}","page":"Exodus.jl","title":"Exodus.ex_get_map!","text":"ex_get_map!(exoid::Cint, elem_map::Vector{T}) where {T <: ExoInt}\n\n\n\n\n\n","category":"method"},{"location":"#Exodus.ex_get_set_param!-Union{Tuple{T}, Tuple{Int32, Exodus.ex_entity_type, Int32, Ref{T}, Ref{T}}} where T<:Union{Int32, Int64}","page":"Exodus.jl","title":"Exodus.ex_get_set_param!","text":"ex_get_set_param!(exoid::Cint, set_type::ex_entity_type, set_id::Cint, \n                  num_entry_in_set::Ref{T}, num_dist_fact_in_set::Ref{T}) where {T <: ExoInt}\n\n\n\n\n\n","category":"method"},{"location":"#Exodus.ex_get_set_param!-Union{Tuple{T}, Tuple{Int32, Exodus.ex_entity_type, Int64, Ref{T}, Ref{T}}} where T<:Union{Int32, Int64}","page":"Exodus.jl","title":"Exodus.ex_get_set_param!","text":"ex_get_set_param!(exoid::Cint, set_type::ex_entity_type, set_id::Clonglong,\n                  num_entry_in_set::Ref{T}, num_dist_fact_in_set::Ref{T}) where {T <: ExoInt}\n\n\n\n\n\n","category":"method"},{"location":"#Exodus.ex_get_var!-Tuple{Int32, Any, Exodus.ex_entity_type, Any, Int64, Any, Any}","page":"Exodus.jl","title":"Exodus.ex_get_var!","text":"ex_get_var!(exoid::Cint, time_step, var_type::ex_entity_type, var_index,\n            obj_id::ex_entity_id, num_entry_this_obj, var_vals)\n\n\n\n\n\n","category":"method"},{"location":"#Exodus.ex_get_variable_name!-Tuple{Int32, Exodus.ex_entity_type, Any, Any}","page":"Exodus.jl","title":"Exodus.ex_get_variable_name!","text":"ex_get_variable_name!(exoid::Cint, obj_type::ex_entity_type, var_num, var_name)\n\n\n\n\n\n","category":"method"},{"location":"#Exodus.ex_get_variable_param!-Tuple{Int32, Exodus.ex_entity_type, Any}","page":"Exodus.jl","title":"Exodus.ex_get_variable_param!","text":"ex_get_variable_param!(exoid::Cint, obj_type::ex_entity_type, num_vars)\n\n\n\n\n\n","category":"method"},{"location":"#Exodus.ex_inquire_int-Tuple{Int32, Exodus.ex_inquiry}","page":"Exodus.jl","title":"Exodus.ex_inquire_int","text":"ex_inquire_int(exoid::Cint, req_info::ex_inquiry)\n\n\n\n\n\n","category":"method"},{"location":"#Exodus.ex_int64_status-Tuple{Int32}","page":"Exodus.jl","title":"Exodus.ex_int64_status","text":"ex_int64_status(exoid::Cint)\n\n\n\n\n\n","category":"method"},{"location":"#Exodus.ex_open-NTuple{4, Any}","page":"Exodus.jl","title":"Exodus.ex_open","text":"ex_open(path, mode, comp_ws, io_ws)::Cint\n\nNOT USED\n\n\n\n\n\n","category":"method"},{"location":"#Exodus.ex_open_int-NTuple{6, Any}","page":"Exodus.jl","title":"Exodus.ex_open_int","text":"ex_open_int(path, mode, comp_ws, io_ws, version, run_version)::Cint\n\nFIX TYPES\n\n\n\n\n\n","category":"method"},{"location":"#Exodus.ex_opts-Tuple{Any}","page":"Exodus.jl","title":"Exodus.ex_opts","text":"ex_opts(options)\n\n\n\n\n\n","category":"method"},{"location":"#Exodus.ex_put_coord!-Tuple{Int32, Any, Any, Any}","page":"Exodus.jl","title":"Exodus.ex_put_coord!","text":"ex_put_coord!(exoid::Cint, x_coords, y_coords, z_coords)\n\nNOT THAT WELL TESTED\n\n\n\n\n\n","category":"method"},{"location":"#Exodus.ex_put_coord_names!-Tuple{Int32, Vector{Vector{UInt8}}}","page":"Exodus.jl","title":"Exodus.ex_put_coord_names!","text":"ex_put_coord_names!(exoid::Cint, coord_names::Vector{Vector{UInt8}})\n\n\n\n\n\n","category":"method"},{"location":"#Exodus.exodus_error_check-Union{Tuple{T}, Tuple{T, String}} where T<:Union{Int32, Int64}","page":"Exodus.jl","title":"Exodus.exodus_error_check","text":"exodus_error_check(error_code::T)\n\nGeneric error handling method.\n\nArguments\n\nerror_code::T: error code, usually negative means something went bad\nmethod_name::String: method name that called this\n\n\n\n\n\n","category":"method"},{"location":"#Exodus.put_coordinate_names-Union{Tuple{F}, Tuple{B}, Tuple{I}, Tuple{M}, Tuple{ExodusDatabase{M, I, B, F}, Vector{String}}} where {M<:Union{Int32, Int64}, I<:Union{Int32, Int64}, B<:Union{Int32, Int64}, F<:Union{Float32, Float64}}","page":"Exodus.jl","title":"Exodus.put_coordinate_names","text":"put_coordinate_names(exo::ExodusDatabase{M, I, B, F}, \n                     coord_names::Vector{String}) where {M <: ExoInt, I <: ExoInt,\n                                                         B <: ExoInt, F <: ExoFloat}\n\nWork in progress...\n\n\n\n\n\n","category":"method"},{"location":"#Exodus.put_coordinates-Union{Tuple{F}, Tuple{B}, Tuple{I}, Tuple{M}, Tuple{ExodusDatabase{M, I, B, F}, Matrix{F}}} where {M<:Union{Int32, Int64}, I<:Union{Int32, Int64}, B<:Union{Int32, Int64}, F<:Union{Float32, Float64}}","page":"Exodus.jl","title":"Exodus.put_coordinates","text":"put_coordinates(exo::ExodusDatabase{M, I, B, F}, \n                     coords::Matrix{F}) where {M <: ExoInt, I <: ExoInt,\n                                               B <: ExoInt, F <: ExoFloat}\n\nWork in progress... not that well tested\n\n\n\n\n\n","category":"method"},{"location":"#Exodus.put_initialization-Union{Tuple{F}, Tuple{B}, Tuple{I}, Tuple{M}, Tuple{ExodusDatabase{M, I, B, F}, Initialization}} where {M<:Union{Int32, Int64}, I<:Union{Int32, Int64}, B<:Union{Int32, Int64}, F<:Union{Float32, Float64}}","page":"Exodus.jl","title":"Exodus.put_initialization","text":"put_initialization(exo::ExodusDatabase{M, I, B, F}, \n                   init::Initialization) where {M <: ExoInt, I <: ExoInt,\n                                                B <: ExoInt, F <: ExoFloat}\n\n\n\n\n\n","category":"method"},{"location":"#Exodus.read_block_ids-Union{Tuple{F}, Tuple{B}, Tuple{I}, Tuple{M}, Tuple{ExodusDatabase{M, I, B, F}, Initialization}} where {M<:Union{Int32, Int64}, I<:Union{Int32, Int64}, B<:Union{Int32, Int64}, F<:Union{Float32, Float64}}","page":"Exodus.jl","title":"Exodus.read_block_ids","text":"read_block_ids(exo::ExodusDatabase{M, I, B, F}, \n               init::Initialization) where {M <: ExoInt, I <: ExoInt, \n                                            B <: ExoInt, F <: ExoFloat}\n\nRetrieves numerical block ids.\n\n\n\n\n\n","category":"method"},{"location":"#Exodus.read_blocks-Union{Tuple{F}, Tuple{B}, Tuple{I}, Tuple{M}, Tuple{ExodusDatabase{M, I, B, F}, Vector{I}}} where {M<:Union{Int32, Int64}, I<:Union{Int32, Int64}, B<:Union{Int32, Int64}, F<:Union{Float32, Float64}}","page":"Exodus.jl","title":"Exodus.read_blocks","text":"read_blocks(exo::ExodusDatabase{M, I, B, F}, \n            block_ids::Vector{I}) where {M <: ExoInt, I <: ExoInt,\n                                         B <: ExoInt, F <: ExoFloat}\n\nHelper method for initializing blocks.\n\n\n\n\n\n","category":"method"},{"location":"#Exodus.read_coordinate_names-Union{Tuple{F}, Tuple{B}, Tuple{I}, Tuple{M}, Tuple{ExodusDatabase{M, I, B, F}, Initialization}} where {M<:Union{Int32, Int64}, I<:Union{Int32, Int64}, B<:Union{Int32, Int64}, F<:Union{Float32, Float64}}","page":"Exodus.jl","title":"Exodus.read_coordinate_names","text":"read_coordinate_names(exo::ExodusDatabase{M, I, B, F}, \n                      init::Initialization) where {M <: ExoInt, I <: ExoInt,\n                                                   B <: ExoInt, F <: ExoFloat}\n\n\n\n\n\n","category":"method"},{"location":"#Exodus.read_coordinates-Union{Tuple{F}, Tuple{B}, Tuple{I}, Tuple{M}, Tuple{ExodusDatabase{M, I, B, F}, Initialization}} where {M<:Union{Int32, Int64}, I<:Union{Int32, Int64}, B<:Union{Int32, Int64}, F<:Union{Float32, Float64}}","page":"Exodus.jl","title":"Exodus.read_coordinates","text":"read_coordinates(exo::ExodusDatabase{M, I, B, F}, \n                 init::Initialization) where {M <: ExoInt, I <: ExoInt,\n                                              B <: ExoInt, F <: ExoFloat}\n\nMethod to read coordinates. Returns a matrix that is nnodes x ndim.\n\nTODO... This method should really return ndim x nnodes but there's TODO... issues encountered downstream with some views found in Tardigrade\n\n\n\n\n\n","category":"method"},{"location":"#Exodus.read_element_map-Union{Tuple{F}, Tuple{B}, Tuple{I}, Tuple{M}, Tuple{ExodusDatabase{M, I, B, F}, Initialization}} where {M<:Union{Int32, Int64}, I<:Union{Int32, Int64}, B<:Union{Int32, Int64}, F<:Union{Float32, Float64}}","page":"Exodus.jl","title":"Exodus.read_element_map","text":"read_element_map(exo::ExodusDatabase{M, I, B, F}, init::Initialization) where {M <: ExoInt, I <: ExoInt,\n                                                                               B <: ExoInt, F <: ExoFloat}\n\n\n\n\n\n","category":"method"},{"location":"#Exodus.read_node_set_ids-Union{Tuple{F}, Tuple{B}, Tuple{I}, Tuple{M}, Tuple{ExodusDatabase{M, I, B, F}, Initialization}} where {M<:Union{Int32, Int64}, I<:Union{Int32, Int64}, B<:Union{Int32, Int64}, F<:Union{Float32, Float64}}","page":"Exodus.jl","title":"Exodus.read_node_set_ids","text":"read_node_set_ids(exo::ExodusDatabase{M, I, B, F},\n                  init::Initialization) where {M <: ExoInt, I <: ExoInt,\n                                               B <: ExoInt, F <: ExoFloat}\n\n\n\n\n\n","category":"method"},{"location":"#Exodus.read_node_sets-Union{Tuple{F}, Tuple{B}, Tuple{I}, Tuple{M}, Tuple{ExodusDatabase{M, I, B, F}, Array{I}}} where {M<:Union{Int32, Int64}, I<:Union{Int32, Int64}, B<:Union{Int32, Int64}, F<:Union{Float32, Float64}}","page":"Exodus.jl","title":"Exodus.read_node_sets","text":"read_node_sets(exo::ExodusDatabase{M, I, B, F}, \n               node_set_ids::Array{I}) where {M <: ExoInt, I <: ExoInt,\n                                              B <: ExoInt, F <: ExoFloat}\n\n\n\n\n\n","category":"method"},{"location":"#Exodus.read_number_of_nodal_variables-Union{Tuple{ExodusDatabase{M, I, B, F}}, Tuple{F}, Tuple{B}, Tuple{I}, Tuple{M}} where {M<:Union{Int32, Int64}, I<:Union{Int32, Int64}, B<:Union{Int32, Int64}, F<:Union{Float32, Float64}}","page":"Exodus.jl","title":"Exodus.read_number_of_nodal_variables","text":"read_number_of_nodal_variables(exo::ExodusDatabase{M, I, B, F}) where {M <: ExoInt, I <: ExoInt,\n                                                                       B <: ExoInt, F <: ExoFloat}\n\n\n\n\n\n","category":"method"},{"location":"#Exodus.read_number_of_time_steps-Union{Tuple{ExodusDatabase{M, I, B, F}}, Tuple{F}, Tuple{B}, Tuple{I}, Tuple{M}} where {M<:Union{Int32, Int64}, I<:Union{Int32, Int64}, B<:Union{Int32, Int64}, F<:Union{Float32, Float64}}","page":"Exodus.jl","title":"Exodus.read_number_of_time_steps","text":"read_number_of_time_steps(exo::ExodusDatabase{M, I, B, F}) where {M <: ExoInt, I <: ExoInt,\n                                                                  B <: ExoInt, F <: ExoFloat}\n\n\n\n\n\n","category":"method"},{"location":"#Exodus.read_times-Union{Tuple{ExodusDatabase{M, I, B, F}}, Tuple{F}, Tuple{B}, Tuple{I}, Tuple{M}} where {M<:Union{Int32, Int64}, I<:Union{Int32, Int64}, B<:Union{Int32, Int64}, F<:Union{Float32, Float64}}","page":"Exodus.jl","title":"Exodus.read_times","text":"read_times(exo::ExodusDatabase{M, I, B, F}) where {M <: ExoInt, I <: ExoInt,\n                                                   B <: ExoInt, F <: ExoFloat}\n\n\n\n\n\n","category":"method"},{"location":"#Exodus.write_time-Union{Tuple{F}, Tuple{B}, Tuple{I}, Tuple{M}, Tuple{ExodusDatabase{M, I, B, F}, Any, F}} where {M<:Union{Int32, Int64}, I<:Union{Int32, Int64}, B<:Union{Int32, Int64}, F<:Union{Float32, Float64}}","page":"Exodus.jl","title":"Exodus.write_time","text":"write_time(exo::ExodusDatabase{M, I, B, F}, \n           time_step, time_value::F) where {M <: ExoInt, I <: ExoInt,\n                                            B <: ExoInt, F <: ExoFloat}\n\n\n\n\n\n","category":"method"}]
}
