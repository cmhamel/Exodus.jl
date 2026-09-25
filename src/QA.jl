"""
$(TYPEDSIGNATURES)
"""
function read_qa(exo::ExodusDatabase)
  num_qa_rec = LibExodus.ex_inquire_int(get_file_id(exo), EX_INQ_QA)
  # The buffers are kept in a matrix, so that they stay alive while the
  # library writes into them through the pointers in qa_record.
  buffers = [string_buffer(MAX_STR_LENGTH) for _ in 1:num_qa_rec, _ in 1:4]
  qa_record = Vector{NTuple{4, Cstring}}(undef, num_qa_rec)
  error_code = GC.@preserve buffers begin
    for n in eachindex(qa_record)
      qa_record[n] = (
        pointer(buffers[n, 1]), pointer(buffers[n, 2]), pointer(buffers[n, 3]), pointer(buffers[n, 4])
      )
    end
    LibExodus.ex_get_qa(get_file_id(exo), qa_record)
  end
  exodus_error_check(exo, error_code, "Exodus.read_qa -> LibExodus.ex_get_qa")

  new_qa_record = Matrix{String}(undef, num_qa_rec, 4)
  for i in 1:num_qa_rec
    for j in 1:4
      new_qa_record[i, j] = buffer_string(buffers[i, j])
    end
  end
  return new_qa_record
end

"""
$(TYPEDSIGNATURES)
"""
function write_qa(exo::ExodusDatabase, qa_record::Matrix{String})
  num_qa_records = size(qa_record, 1)
  qa_ptrs = Vector{NTuple{4, Cstring}}(undef, num_qa_records)
  for i in 1:num_qa_records
    qa_ptrs[i] = (
      pointer(qa_record[i,1]),
      pointer(qa_record[i,2]),
      pointer(qa_record[i,3]),
      pointer(qa_record[i,4]),
    )
  end

  error_code = LibExodus.ex_put_qa(
    get_file_id(exo), num_qa_records, qa_ptrs
  )
  exodus_error_check(exo, error_code, "Exodus.write_qa -> LibExodus.ex_put_qa")
end
