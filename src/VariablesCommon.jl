# """
#   ex_get_variable_name!(exoid::Cint, obj_type::ex_entity_type, var_num, var_name)
# """
function ex_get_variable_name!(exoid::Cint, obj_type::ex_entity_type, var_num, var_name)
  error_code = ccall(
    (:ex_get_variable_name, libexodus), Cint,
    (Cint, ex_entity_type, Cint, Ptr{UInt8}),
    exoid, obj_type, var_num, var_name
  )
  exodus_error_check(error_code, "ex_get_variable_name")
end

# """
#   ex_get_var!(exoid::Cint, time_step, var_type::ex_entity_type, var_index,
#         obj_id::ex_entity_id, num_entry_this_obj, var_vals)
# """
function ex_get_var!(
  exoid::Cint, time_step::I_1, var_type::ex_entity_type, var_index::I_2,
  obj_id::ex_entity_id, num_entry_this_obj::I_3, 
  var_vals
) where {I_1 <: Integer, I_2 <: Integer, I_3 <: Integer}
  time_step = convert(Cint, time_step)
  var_index = convert(Cint, var_index)
  num_entry_this_obj = convert(Clonglong, num_entry_this_obj)
  error_code = ccall(
    (:ex_get_var, libexodus), Cint,
    (Cint, Cint, ex_entity_type, Cint, ex_entity_id, Clonglong, Ptr{Cvoid}),
    exoid, time_step, var_type, var_index, obj_id, num_entry_this_obj, var_vals
  )
  exodus_error_check(error_code, "ex_get_var!")
end

# """
#   ex_get_variable_param!(exoid::Cint, obj_type::ex_entity_type, num_vars)
# """
function ex_get_variable_param!(exoid::Cint, obj_type::ex_entity_type, num_vars)
  error_code = ccall(
    (:ex_get_variable_param, libexodus), Cint,
    (Cint, Cint, Ptr{Cint}),
    exoid, obj_type, num_vars
  )
  exodus_error_check(error_code, "ex_get_variable_param")
end

function ex_put_var!(
  exoid::Cint, 
  time_step::I_1, 
  var_type::ex_entity_type, 
  var_index::I_2,
  obj_id::ex_entity_id, 
  num_entries_this_obj::I_3, 
  var_vals
) where {I_1 <: Integer, I_2 <: Integer, I_3 <: Integer}
  time_step = convert(Cint, time_step)
  var_index = convert(Cint, var_index)
  num_entries_this_obj = convert(Clonglong, num_entries_this_obj)
  error_code = ccall(
    (:ex_put_var, libexodus), Cint,
    (Cint, Cint, ex_entity_type, Clong, ex_entity_id, Cint, Ptr{Cvoid}),
    exoid, time_step, var_type, var_index, obj_id, num_entries_this_obj, var_vals
  )
  exodus_error_check(error_code, "ex_put_var!")
end

function ex_put_variable_name!(exoid::Cint, obj_type::ex_entity_type, var_num::Cint, var_name)
  error_code = ccall(
    (:ex_put_variable_name, libexodus), Cint,
    (Cint, ex_entity_type, Cint, Ptr{UInt8}),
    exoid, obj_type, var_num, var_name
  )
  exodus_error_check(error_code, "ex_put_variable_name!")
end

function ex_put_variable_param!(exoid::Cint, obj_type::ex_entity_type, num_vars)
  error_code = ccall(
    (:ex_put_variable_param, libexodus), Cint,
    (Cint, ex_entity_type, Cint),
    exoid, obj_type, num_vars
  )
  exodus_error_check(error_code, "ex_put_variable_param!")
end