import Base.Filesystem: copy
using Aqua
using Exodus
using Test
using TestSetExtensions

macro exodus_unit_test_set(test_name::String, ex)
  return quote
    local test_set_name = rpad($test_name, 64)
    @testset ExtendedTestSet "$test_set_name" begin
      local val = $ex
      val
    end
  end
end

# @includetests ARGS
include("TestDecomp.jl")
# include("TestEpu.jl")
include("TestErrors.jl")
include("TestExoDiff.jl")
include("TestRead.jl")
include("TestReadWrite.jl")
include("TestWrite.jl")

Aqua.test_all(Exodus)
