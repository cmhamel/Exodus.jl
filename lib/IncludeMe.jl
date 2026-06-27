include("LibExodus.jl")
# TODO make below constants not hardcoded. Read from LibExodus.
const cpu_word_size  = Int32(sizeof(Float64)) # TODO make parametric so we can have float models
const IO_word_size   = Int32(8)               # This was what we did before
const version_number = LibExodus.EX_API_VERS
import .LibExodus:
    EX_ABORT,
    EX_API_VERS_NODOT,
    EX_BULK_INT64_API,
    EX_CLOBBER,
    EX_ELEM_BLOCK,
    EX_ELEM_MAP,
    EX_GLOBAL,
    EX_IDS_INT64_API,
    EX_INQ_DB_FLOAT_SIZE,
    EX_INQ_INFO,
    EX_INQ_QA,
    EX_INQ_TIME,
    EX_MAPS_INT64_API,
    EX_NODAL,
    EX_NODE_MAP,
    EX_NODE_SET,
    EX_READ,
    EX_SIDE_SET,
    EX_WRITE,
    EX_VERBOSE,
    MAX_LINE_LENGTH,
    MAX_STR_LENGTH
