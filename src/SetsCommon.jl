
"""
This method is a problem child for node sets for some reason

  and sidesets!
"""
# function ex_get_ids!(exoid::Cint, exo_const::ex_entity_type, ids::Vector{T}) where {T <: Integer}
function ex_get_ids!(exoid::Cint, exo_const, ids::Vector{T}) where {T <: Integer}
  error_code = ccall(
    (:ex_get_ids, libexodus), Cint,
    (Cint, ex_entity_type, Ptr{void_int}),
    exoid, exo_const, ids
  )
  exodus_error_check(error_code, "ex_get_ids!")
end

function ex_get_id_map!(exoid::Cint, map_type::ex_entity_type, map::Vector{T}) where {T <: Integer}
  error_code = ccall(
    (:ex_get_id_map, libexodus), Cint,
    (Cint, ex_entity_type, Ptr{void_int}),
    exoid, map_type, map
  )
  exodus_error_check(error_code, "ex_get_id_map!")
end

function ex_get_names!(exoid::Cint, set_type::ex_entity_type, names)
  # error_code = ccal(
  #   (:ex_get_names, libexodus), Cint,
  #   (Cint, ex_entity_type, Ptr{Ptr{UInt8}}),
  #   exoid, set_type, names 
  # )
  error_code = @ccall libexodus.ex_get_names(exoid::Cint, set_type::ex_entity_type, names::Ptr{Ptr{UInt8}})::Cint
  exodus_error_check(error_code, "ex_get_names!")
  return names
end

# function ex_get_set_internal!(exoid::Cint, set_type::ex_entity_type, set_id, set_entry_list, set_extra_list)
#   error_code = ccall(
#     (:ex_get_set, libexodus), Cint,
#     (Cint, ex_entity_type, Cint, Ptr{void_int}, Ptr{void_int}),
#     exoid, set_type, set_id, set_entry_list, set_extra_list
#   )
#   exodus_error_check(error_code, "ex_get_set!")
# end
# ex_get_set!(exoid::Cint, set_type::ex_entity_type, set_id::I, set_entry_list::Vector{B}, set_extra_list::Ptr{Cvoid}) where {I <: Integer, B <: Integer} =
# ex_get_set_internal!(exoid, set_type, set_id, set_entry_list, set_extra_list)
# ex_get_set!(exoid::Cint, set_type::ex_entity_type, set_id::I, set_entry_list::Vector{B}, set_extra_list::Vector{B}) where {I <: Integer, B <: Integer} = 
# ex_get_set_internal!(exoid, set_type, set_id, set_entry_list, set_extra_list)

function ex_get_set!(
  # exoid::Cint, set_type::ex_entity_type, set_id::ex_entity_id,
  exoid::Cint, set_type::ex_entity_type, set_id, 
  set_entry_list::Union{Vector{<:Integer}, Ptr}, 
  set_extra_list::Union{Vector{<:Integer}, Ptr}
)
  error_code = ccall(
    (:ex_get_set, libexodus), Cint,
    (Cint, ex_entity_type, Cint, Ptr{void_int}, Ptr{void_int}),
    exoid, set_type, set_id, set_entry_list, set_extra_list
  )
  exodus_error_check(error_code, "ex_get_set!")
end

function ex_get_set_param!(
  # exoid::Cint, set_type::ex_entity_type, set_id::ex_entity_id,
  exoid::Cint, set_type::ex_entity_type, set_id,
  num_entry_in_set::Ref{T}, num_dist_fact_in_set::Ref{T}
) where {T <: Integer}
  error_code = ccall(
    (:ex_get_set_param, libexodus), Cint,
    (Cint, ex_entity_type, Clonglong, Ptr{void_int}, Ptr{void_int}),
    exoid, set_type, set_id, num_entry_in_set, num_dist_fact_in_set
  )
  exodus_error_check(error_code, "ex_get_set_param!")
end

# function ex_put_names!(exoid::Cint, set_type::ex_entity_type, names::Vector{Vector{UInt8}})
#   error_code = ccall(
#     (:ex_put_names, libexodus), Cint,
#     (Cint, ex_entity_type, Ptr{Ptr{UInt8}}),
#     exoid, set_type, names
#   )
#   exodus_error_check(error_code, "ex_put_names!")
# end

# function ex_put_names!(exoid::Cint, set_type::ex_entity_type, names)
#   @ccall libexodus.ex_put_names(exoid::Cint, set_type::ex_entity_type, names::Ptr{Ptr{UInt8}})::Cint
#   # return names
# end

# function