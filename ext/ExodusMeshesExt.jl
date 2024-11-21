module ExodusMeshesExt

using DocStringExtensions
using Exodus
using Meshes

elem_type_to_polytope = Dict{String, Any}(
  "HEX8"  => Hexahedron,
  "QUAD4" => Quadrangle,
  "TRI"   => Triangle,
  "TRI3"  => Triangle
)

"""
$(TYPEDSIGNATURES)
"""
function Meshes.SimpleMesh(exo::ExodusDatabase)
  coords = read_coordinates(exo)
  coords = map(x -> tuple(x...), eachcol(coords))
  blocks = read_sets(exo, Block)
  new_blocks = map(
    block -> connect.(
      map(x -> tuple(x...), eachcol(block.conn)), 
      elem_type_to_polytope[block.elem_type]
    ),
    blocks
  )
  new_blocks = vcat(new_blocks...)
  return SimpleMesh(coords, new_blocks)
end

function Meshes.SimpleMesh(exo::ExodusDatabase, time_step::Int; disp_var::String="displ")
  coords = read_coordinates(exo)
  U = read_values(exo, NodalVectorVariable, time_step, disp_var)

  coords = coords .+ U
  coords = map(x -> tuple(x...), eachcol(coords))

  blocks = read_sets(exo, Block)
  new_blocks = map(
    block -> connect.(
      map(x -> tuple(x...), eachcol(block.conn)), 
      elem_type_to_polytope[block.elem_type]
    ),
    blocks
  )
  new_blocks = vcat(new_blocks...)
  return SimpleMesh(coords, new_blocks)
end

end # module