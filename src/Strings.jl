# Buffers for the strings the Exodus library writes, and their conversion.
#
# The library writes a title or an information record with up to
# MAX_LINE_LENGTH characters and a QA field or an element type with up to
# MAX_STR_LENGTH characters, each followed by a terminator. It writes an
# entity, variable, or coordinate name padded to the read name length of the
# database (EX_INQ_MAX_READ_NAME_LENGTH: 32 by default, up to 256 after
# ex_set_max_name_length) and a terminator, whatever the length of the name
# itself. A buffer one byte shorter than that lets the library write past it
# into the Julia heap (issue #232).

"""
$(TYPEDSIGNATURES)
A zero-filled buffer for a string of up to `max_length` characters and its
terminator.
"""
string_buffer(max_length::Integer) = zeros(Cchar, max_length + 1)

"""
$(TYPEDSIGNATURES)
A zero-filled buffer for a name read from the database with id `exoid`: the
read name length of the database, at least MAX_STR_LENGTH, and a terminator.
"""
function name_buffer(exoid::Cint)
  read_length = LibExodus.ex_inquire_int(exoid, EX_INQ_MAX_READ_NAME_LENGTH)
  return string_buffer(max(read_length, MAX_STR_LENGTH))
end

"""
$(TYPEDSIGNATURES)
The string in a buffer filled by the library, up to its first terminator.
"""
function buffer_string(buffer::Vector{Cchar})
  GC.@preserve buffer begin
    return unsafe_string(pointer(buffer))
  end
end
