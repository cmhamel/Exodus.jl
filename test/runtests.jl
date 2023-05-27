using Exodus
using Test
using TestSetExtensions

macro exodus_unit_test_set(test_name::String, ex)
  return quote
    local test_set_name = rpad($test_name, 64)
    @testset verbose = true "$test_set_name" begin
      local val = $ex
      val
    end
  end
end

@includetests ARGS
