struct Mesh <: FEMContainer
    coords::Array{Float64}
    # blocks::Array{Block}
    blocks::Blocks
    node_sets::Array{NodeSet}
    # add side sets and other relevant stuff
    #
end
