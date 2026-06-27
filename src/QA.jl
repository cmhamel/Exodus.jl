"""
$(TYPEDSIGNATURES)
"""
function read_qa(exo::ExodusDatabase)
  num_qa_rec = LibExodus.ex_inquire_int(get_file_id(exo), EX_INQ_QA)
  qa_record = Vector{NTuple{4, Cstring}}(undef, num_qa_rec)
  for n in eachindex(qa_record)
    qa_record[n] = (
      pointer(Vector{Cchar}(undef, MAX_STR_LENGTH)),
      pointer(Vector{Cchar}(undef, MAX_STR_LENGTH)),
      pointer(Vector{Cchar}(undef, MAX_STR_LENGTH)),
      pointer(Vector{Cchar}(undef, MAX_STR_LENGTH))
    )
  end
  error_code = LibExodus.ex_get_qa(
    get_file_id(exo), qa_record
  )
  exodus_error_check(exo, error_code, "Exodus.read_qa -> LibExodus.ex_get_qa")

  new_qa_record = Matrix{String}(undef, num_qa_rec, 4)
  for i in 1:num_qa_rec
    for j in 1:4
      new_qa_record[i, j] = unsafe_string(qa_record[i][j])
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
