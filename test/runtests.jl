using Exodus
using Test
using Profile
using Suppressor

macro exodus_unit_test_set(test_name::String, ex)
    return quote
        local test_set_name = rpad($test_name, 64)
        @testset "$test_set_name" begin
            local val = $ex
            val
        end
    end
end

include("TestCoordinates.jl")
include("TestInitialization.jl")
include("TestIO.jl")
include("TestTimes.jl")
