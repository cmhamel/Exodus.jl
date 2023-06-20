function ex_get_variable_name!(exoid::Cint, obj_type::ex_entity_type, var_num::Cint, var_name::Vector{UInt8})
  error_code = ccall(
    (:ex_get_variable_name, libexodus), Cint,
    (Cint, ex_entity_type, Cint, Ptr{UInt8}),
    exoid, obj_type, var_num, var_name
  )
  exodus_error_check(error_code, "ex_get_variable_name")
end

function ex_get_var!(
  exoid::Cint, time_step::Cint, var_type::ex_entity_type, var_index::Cint,
  obj_id::ex_entity_id, num_entry_this_obj::Clonglong, 
  var_vals::Vector{<:Real}
)
  error_code = ccall(
    (:ex_get_var, libexodus), Cint,
    (Cint, Cint, ex_entity_type, Cint, ex_entity_id, Clonglong, Ptr{Cvoid}),
    exoid, time_step, var_type, var_index, obj_id, num_entry_this_obj, var_vals
  )
  exodus_error_check(error_code, "ex_get_var!")
end

function ex_get_variable_param!(exoid::Cint, obj_type::ex_entity_type, num_vars::Ref{Cint})
  error_code = ccall(
    (:ex_get_variable_param, libexodus), Cint,
    (Cint, Cint, Ptr{Cint}),
    exoid, obj_type, num_vars
  )
  exodus_error_check(error_code, "ex_get_variable_param")
end

function ex_put_var!(
  exoid::Cint, 
  time_step::Cint, 
  var_type::ex_entity_type, 
  var_index::Cint,
  obj_id::ex_entity_id, 
  num_entries_this_obj::Clonglong, 
  var_vals::Vector{<:Real}
)
  error_code = ccall(
    (:ex_put_var, libexodus), Cint,
    (Cint, Cint, ex_entity_type, Cint, ex_entity_id, Clonglong, Ptr{Cvoid}),
    exoid, time_step, var_type, var_index, obj_id, num_entries_this_obj, var_vals
  )
  exodus_error_check(error_code, "ex_put_var!")
end

function ex_put_variable_name!(exoid::Cint, obj_type::ex_entity_type, var_num::Cint, var_name::Vector{UInt8})
  error_code = ccall(
    (:ex_put_variable_name, libexodus), Cint,
    (Cint, ex_entity_type, Cint, Ptr{UInt8}),
    exoid, obj_type, var_num, var_name
  )
  exodus_error_check(error_code, "ex_put_variable_name!")
end

function ex_put_variable_param!(exoid::Cint, obj_type::ex_entity_type, num_vars::I_1) where I_1 <: Integer
  num_vars = convert(Cint, num_vars)
  error_code = ccall(
    (:ex_put_variable_param, libexodus), Cint,
    (Cint, ex_entity_type, Cint),
    exoid, obj_type, num_vars
  )
  exodus_error_check(error_code, "ex_put_variable_param!")
end

# local exports
export ex_get_variable_name!
export ex_get_var!
export ex_get_variable_param!
export ex_put_variable_name!
export ex_put_variable_param!
