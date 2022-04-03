abstract type Variable <: FEMContainer end

mutable struct NodalVariable <: FEMContainer
    variable_name::String
    variable_values::Array{Float64}
end

function read_variable_names(exo_id::ExoID)

end

function read_nodal_variables(exo_id::ExoID, variable_names::Array{String})

end