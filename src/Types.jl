# types
#
int = Int64 # this is what we should move to to match exodus calls
IntKind = Int64 # eventually deprecate this
ArrayOrRefFloat64 = Union{Array{Float64}, Ref{Float64}}

# void_int = Ptr{Cvoid}
void_int = Cvoid
ex_entity_id = Int64 # not sure if this is completely correct

ExoFileName = String
ExoID = IntKind #Int64
BlockID = IntKind #Int64
NodeSetID = IntKind
BlockType = IntKind #Int64

abstract type FEMContainer end
