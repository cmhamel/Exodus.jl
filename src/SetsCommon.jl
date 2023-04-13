"""
    ex_get_ids!(exoid::Cint, exo_const::ex_entity_type, ids::Vector{T}) where {T <: ExoInt}
"""
function ex_get_ids!(exoid::Cint, exo_const::ex_entity_type, ids::Vector{T}) where {T <: ExoInt}
    error_code = ccall(
        (:ex_get_ids, libexodus), Cint,
        (Cint, ex_entity_type, Ptr{void_int}),
        exoid, exo_const, ids
    )
    exodus_error_check(error_code, "ex_get_ids!")
end

"""
    ex_get_id_map!(exoid::Cint, map_type::ex_entity_type, map::Vector{T}) where {T <: ExoInt}
"""
function ex_get_id_map!(exoid::Cint, map_type::ex_entity_type, map::Vector{T}) where {T <: ExoInt}
    error_code = ccall(
        (:ex_get_id_map, libexodus), Cint,
        (Cint, ex_entity_type, Ptr{void_int}),
        exoid, map_type, map
    )
    exodus_error_check(error_code, "ex_get_id_map!")
end

function ex_get_set_internal!(exoid::Cint, set_type::ex_entity_type, set_id, set_entry_list, set_extra_list)
    error_code = ccall(
        (:ex_get_set, libexodus), Cint,
        (Cint, ex_entity_type, Cint, Ptr{void_int}, Ptr{void_int}),
        exoid, set_type, set_id, set_entry_list, set_extra_list
    )
    exodus_error_check(error_code, "ex_get_set!")
end
ex_get_set!(exoid::Cint, set_type::ex_entity_type, set_id::I, set_entry_list::Vector{B}, set_extra_list::Ptr{Cvoid}) where {I <: ExoInt, B <: ExoInt} =
ex_get_set_internal!(exoid, set_type, set_id, set_entry_list, set_extra_list)


"""
    ex_get_set_param!(exoid::Cint, set_type::ex_entity_type, set_id::Cint, 
                      num_entry_in_set::Ref{T}, num_dist_fact_in_set::Ref{T}) where {T <: ExoInt}
"""
function ex_get_set_param!(exoid::Cint, set_type::ex_entity_type, set_id::Cint, 
                           num_entry_in_set::Ref{T}, num_dist_fact_in_set::Ref{T}) where {T <: ExoInt}
    error_code = ccall(
        (:ex_get_set_param, libexodus), Cint,
        (Cint, ex_entity_type, Cint, Ptr{void_int}, Ptr{void_int}),
        exoid, set_type, set_id, num_entry_in_set, num_dist_fact_in_set
    )
    exodus_error_check(error_code, "ex_get_set_param!")
end
# ex_get_set_param!(exoid::Cint, set_type::ex_entity_type, set_id::S, num_entry_in_set::Ref{T}, num_dist_fact_in_set::Ref{T}) where {S <: ExoInt, T <: ExoInt} = 
# ex_get_set_internal!(exoid, set_type, set_id, num_entry_in_set, num_dist_fact_in_set)

"""
    ex_get_set_param!(exoid::Cint, set_type::ex_entity_type, set_id::Clonglong,
                      num_entry_in_set::Ref{T}, num_dist_fact_in_set::Ref{T}) where {T <: ExoInt}
"""
function ex_get_set_param!(exoid::Cint, set_type::ex_entity_type, set_id::Clonglong, #::ex_entity_id, # figure thsi out
                           num_entry_in_set::Ref{T}, num_dist_fact_in_set::Ref{T}) where {T <: ExoInt}
    error_code = ccall(
        (:ex_get_set_param, libexodus), Cint,
        (Cint, ex_entity_type, Clonglong, Ptr{void_int}, Ptr{void_int}),
        exoid, set_type, set_id, num_entry_in_set, num_dist_fact_in_set
    )
    exodus_error_check(error_code, "ex_get_set_param!")
end
