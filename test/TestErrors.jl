@exodus_unit_test_set "Test Errors working" begin
  @test_throws ErrorException Exodus.exodus_error_check(-1, "JohnSmithMethod")
end