using Exodus
using Test

macro exodus_unit_test_set(test_name::String, ex)
  return quote
    local test_set_name = rpad($test_name, 64)
    @testset verbose = true "$test_set_name" begin
      local val = $ex
      val
    end
  end
end

include("TestBlocks.jl")
include("TestCoordinates.jl")
include("TestEpu.jl")
include("TestErrors.jl")
include("TestDecomp.jl")
include("TestExoDiff.jl")
include("TestGlobalVariables.jl")
include("TestInitialization.jl")
include("TestIO.jl")
include("TestMaps.jl")
include("TestNodalVariables.jl")
include("TestNodeSets.jl")
include("TestSideSets.jl")
include("TestTimes.jl")
