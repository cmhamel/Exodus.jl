# types
#
int = Int32 # this is what we should move to to match exodus calls
IntKind = Int64 # eventually deprecate this
ArrayOrRefFloat64 = Union{Array{Float64}, Ref{Float64}}

# void_int = Ptr{Cvoid}
void_int = Cvoid
ex_entity_id = Int32 # not sure if this is completely correct

ExoFileName = String

abstract type FEMContainer end
