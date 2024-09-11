"""
$(TYPEDSIGNATURES)
"""
function read_qa(exo::ExodusDatabase)
  num_qa_rec = @ccall libexodus.ex_inquire_int(
    get_file_id(exo)::Cint, EX_INQ_QA::ex_inquiry
  )::Cint
  qa_record = Matrix{Vector{UInt8}}(undef, num_qa_rec, 4)
  for i in 1:num_qa_rec
    for j in 1:4
      qa_record[i, j] = Vector{UInt8}(undef, MAX_STR_LENGTH)
    end
  end
  error_code = @ccall libexodus.ex_get_qa(
    get_file_id(exo)::Cint, qa_record::Ptr{Ptr{UInt8}}
  )::Cint
  exodus_error_check(exo, error_code, "Exodus.read_qa -> libexodus.ex_get_qa")

  new_qa_record = Matrix{String}(undef, num_qa_rec, 4)
  for i in 1:num_qa_rec
    for j in 1:4
      new_qa_record[i, j] = unsafe_string(pointer(qa_record[i, j]))
    end
  end
  return new_qa_record
end

"""
$(TYPEDSIGNATURES)
"""
function write_qa(exo::ExodusDatabase, qa_record::Matrix{String})
  num_qa_records = size(qa_record, 1)
  error_code = @ccall libexodus.ex_put_qa(
    get_file_id(exo)::Cint, num_qa_records::Cint, qa_record::Ptr{Ptr{UInt8}}
  )::Cint
  exodus_error_check(exo, error_code, "Exodus.write_qa -> libexodus.ex_put_qa")
end
