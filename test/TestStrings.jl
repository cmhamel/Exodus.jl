# The buffers for the strings the library writes must hold everything it
# writes (issue #232). Each check lets the library write into an oversized
# buffer filled with a marker and compares the number of bytes it wrote with
# the size of the buffer Exodus.jl allocates.

bytes_written(buffer) = something(findlast(!=(Cchar(0x7f)), buffer), 0)
marked_buffer() = fill(Cchar(0x7f), 1024)

@exodus_unit_test_set "Test string buffers - names" begin
  for mesh_file in ("./mesh/square_meshes/mesh_test.g", "./mesh/cube_meshes/mesh_test.g")
    exo = ExodusDatabase(mesh_file, "r")
    exoid = Exodus.get_file_id(exo)
    capacity = length(Exodus.name_buffer(exoid))
    for S in (Block, NodeSet, SideSet)
      for id in read_ids(exo, S)
        buffer = marked_buffer()
        GC.@preserve buffer Exodus.LibExodus.ex_get_name(exoid, Exodus.entity_type(S), id, pointer(buffer))
        # The library pads the name to the read name length, whatever its
        # length, so it writes more than the name and its terminator.
        @test bytes_written(buffer) > length(read_name(exo, S, id)) + 1
        @test bytes_written(buffer) <= capacity
      end
    end
    buffer = marked_buffer()
    GC.@preserve buffer Exodus.LibExodus.ex_get_init(
      exoid, pointer(buffer), Ref{Int32}(0), Ref{Int32}(0), Ref{Int32}(0), Ref{Int32}(0), Ref{Int32}(0), Ref{Int32}(0)
    )
    @test bytes_written(buffer) <= Exodus.MAX_LINE_LENGTH + 1
    close(exo)
  end
end

@exodus_unit_test_set "Test string buffers - variable names and title of a written file" begin
  file = "./string_buffers.e"
  rm(file; force=true)
  init = Initialization{Int32}(Int32(2), Int32(4), Int32(1), Int32(1), Int32(0), Int32(0))
  exo = ExodusDatabase{Int32, Int32, Int32, Float64}(file, "w", init)
  write_coordinates(exo, [0.0 1.0 1.0 0.0; 0.0 0.0 1.0 1.0])
  write_block(exo, 1, "QUAD4", reshape(Int32[1, 2, 3, 4], 4, 1))
  write_number_of_variables(exo, NodalVariable, 2)
  write_names(exo, NodalVariable, ["u", "a_name_of_exactly_32_characters_"])
  close(exo)

  exo = ExodusDatabase(file, "r")
  exoid = Exodus.get_file_id(exo)
  capacity = length(Exodus.name_buffer(exoid))
  for index in 1:2
    buffer = marked_buffer()
    GC.@preserve buffer Exodus.LibExodus.ex_get_variable_name(exoid, Exodus.EX_NODAL, index, pointer(buffer))
    @test bytes_written(buffer) <= capacity
  end
  @test read_names(exo, NodalVariable) == ["u", "a_name_of_exactly_32_characters_"]
  # The title of a file written by Exodus.jl is empty, not the contents of
  # uninitialized memory.
  buffer = marked_buffer()
  GC.@preserve buffer Exodus.LibExodus.ex_get_init(
    exoid, pointer(buffer), Ref{Int32}(0), Ref{Int32}(0), Ref{Int32}(0), Ref{Int32}(0), Ref{Int32}(0), Ref{Int32}(0)
  )
  @test buffer[1] == 0
  close(exo)
  rm(file; force=true)
end
