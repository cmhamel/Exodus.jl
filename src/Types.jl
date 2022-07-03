# types
#
IntKind = Int64
ArrayOrRefFloat64 = Union{Array{Float64}, Ref{Float64}}

ExoFileName = String
ExoID = IntKind #Int64
BlockID = IntKind #Int64
NodeSetID = IntKind
BlockType = IntKind #Int64

abstract type FEMContainer end
