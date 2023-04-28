@exodus_unit_test_set "exodiff" begin
  if Sys.iswindows()
    @show "skipping exodiff tests for windows"
  else
    @exodiff "./example_output/output.gold" "./example_output/output.gold"
  end
end