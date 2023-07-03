# @show "disabling exodiff tests for now"
@exodus_unit_test_set "exodiff" begin
  if Sys.iswindows()
    @show "skipping exodiff tests for windows"
  else
    @exodiff "./example_output/output.gold" "./example_output/output.gold"
    rm("./exodiff.log", force=true)
  end
  # @test begin
  #   @exodiff "./example_output/output.gold" "./example_output/output.gold"
  # end skip=Sys.iswindows() 
end