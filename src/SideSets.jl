"""
"""
function SideSet(exo::ExodusDatabase{M, I, B, F},
                 side_set_id::I) where {M, I, B, F}
  side_set_elems, side_set_sides = read_side_set_elements_and_sides(exo, side_set_id)
  return SideSet{I, B}(side_set_id, length(side_set_elems), side_set_elems, side_set_sides)
end


"""
"""
function read_side_set_ids(exo::ExodusDatabase{M, I, B, F}) where {M <: Integer, I <: Integer,
                                               B <: Integer, F <: Real}
  side_set_ids = Array{I}(undef, exo.init.num_side_sets)
  ex_get_ids!(exo.exo, EX_SIDE_SET, side_set_ids)
  return side_set_ids
end

"""
"""
function read_side_set_parameters(exo::ExodusDatabase{M, I, B, F}, 
                                  side_set_id::I) where {M <: Integer, I <: Integer,
                                                         B <: Integer, F <: Real}
  num_sides = Ref{I}(0)
  num_df = Ref{I}(0)
  ex_get_set_param!(exo.exo, EX_SIDE_SET, side_set_id, num_sides, num_df)
  return num_sides[], num_df[]
end

"""
"""
function read_side_set_elements_and_sides(exo::ExodusDatabase{M, I, B, F}, 
                                          side_set_id) where {M <: Integer, I <: Integer,
                                                              B <: Integer, F <: Real}

  num_sides, df = read_side_set_parameters(exo, side_set_id)
  side_set_elems = Array{B}(undef, num_sides)
  side_set_sides = Array{B}(undef, num_sides)
  ex_get_set!(exo.exo, EX_SIDE_SET, side_set_id, side_set_elems, side_set_sides)
  return side_set_elems, side_set_sides
end

function ex_get_side_set_node_list!(
  exoid::Cint, side_set_id::ex_entity_id,
  side_set_node_cnt_list::Vector{B}, side_set_node_list::Vector{B}
) where {B <: Integer}
  error_code = ccall(
    (:ex_get_side_set_node_list, libexodus), Cint,
    (Cint, ex_entity_id, Ptr{void_int}, Ptr{void_int}),
    exoid, side_set_id, side_set_node_cnt_list, side_set_node_list
  )
  exodus_error_check(error_code, "ex_get_side_set_node_list!")
end

function read_side_set_node_list(exo::ExodusDatabase{M, I, B, F},
                                 side_set_id) where {M <: Integer, I <: Integer,
                                                     B <: Integer, F <: Real}
  num_sides, _ = read_side_set_parameters(exo, side_set_id)
  side_set_node_cnt_list = Vector{B}(undef, num_sides)
  side_set_node_list = Vector{B}(undef, num_sides * 21)
  ex_get_side_set_node_list!(
    exo.exo, convert(Int64, side_set_id), 
    side_set_node_cnt_list, side_set_node_list
  )
  return side_set_node_cnt_list, side_set_node_list
end

export read_side_set_ids
export read_side_set_parameters
export read_side_set_elements_and_sides
export read_side_set_node_list
