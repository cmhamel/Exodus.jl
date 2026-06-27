module LibExodus

using Exodus_jll
export Exodus_jll

using CEnum: CEnum, @cenum

to_c_type(t::Type) = t
to_c_type_pairs(va_list) = map(enumerate(to_c_type.(va_list))) do (ind, type)
    :(va_list[$ind]::$type)
end

function interface(nvtxs, start, adjacency, vwgts, ewgts, x, y, z, outassignname, outfilename, assignment, architecture, ndims_tot, mesh_dims, goal, global_method, local_method, rqi_flag, vmax, ndims, eigtol, seed)
    @ccall libexodus.interface(nvtxs::Cint, start::Ptr{Cint}, adjacency::Ptr{Cint}, vwgts::Ptr{Cint}, ewgts::Ptr{Cfloat}, x::Ptr{Cfloat}, y::Ptr{Cfloat}, z::Ptr{Cfloat}, outassignname::Cstring, outfilename::Cstring, assignment::Ptr{Cint}, architecture::Cint, ndims_tot::Cint, mesh_dims::Ptr{Cint}, goal::Ptr{Cdouble}, global_method::Cint, local_method::Cint, rqi_flag::Cint, vmax::Cint, ndims::Cint, eigtol::Cdouble, seed::Clong)::Cint
end

function input_assign(arg1, arg2, arg3, arg4)
    @ccall libexodus.input_assign(arg1::Ptr{Libc.FILE}, arg2::Cstring, arg3::Cint, arg4::Ptr{Cint})::Cint
end

function ex_create_int(rel_path, cmode, comp_ws, io_ws, run_version)
    @ccall libexodus.ex_create_int(rel_path::Cstring, cmode::Cint, comp_ws::Ptr{Cint}, io_ws::Ptr{Cint}, run_version::Cint)::Cint
end

function ex_open_int(rel_path, mode, comp_ws, io_ws, version, run_version)
    @ccall libexodus.ex_open_int(rel_path::Cstring, mode::Cint, comp_ws::Ptr{Cint}, io_ws::Ptr{Cint}, version::Ptr{Cfloat}, run_version::Cint)::Cint
end

"""
    ex_inquiry

| Enumerator                                    | Note                                                          |
| :-------------------------------------------- | :------------------------------------------------------------ |
| EX\\_INQ\\_FILE\\_TYPE                        | EXODUS file type (deprecated)                                 |
| EX\\_INQ\\_API\\_VERS                         | API version number (float)                                    |
| EX\\_INQ\\_DB\\_VERS                          | database version number (float)                               |
| EX\\_INQ\\_TITLE                              | database title. [`MAX_LINE_LENGTH`](@ref)+1 char* size        |
| EX\\_INQ\\_DIM                                | number of dimensions                                          |
| EX\\_INQ\\_NODES                              | number of nodes                                               |
| EX\\_INQ\\_ELEM                               | number of elements                                            |
| EX\\_INQ\\_ELEM\\_BLK                         | number of element blocks                                      |
| EX\\_INQ\\_NODE\\_SETS                        | number of node sets                                           |
| EX\\_INQ\\_NS\\_NODE\\_LEN                    | length of node set node list                                  |
| EX\\_INQ\\_SIDE\\_SETS                        | number of side sets                                           |
| EX\\_INQ\\_SS\\_NODE\\_LEN                    | length of side set node list                                  |
| EX\\_INQ\\_SS\\_ELEM\\_LEN                    | length of side set element list                               |
| EX\\_INQ\\_QA                                 | number of QA records                                          |
| EX\\_INQ\\_INFO                               | number of info records                                        |
| EX\\_INQ\\_TIME                               | number of time steps in the database                          |
| EX\\_INQ\\_EB\\_PROP                          | number of element block properties                            |
| EX\\_INQ\\_NS\\_PROP                          | number of node set properties                                 |
| EX\\_INQ\\_SS\\_PROP                          | number of side set properties                                 |
| EX\\_INQ\\_NS\\_DF\\_LEN                      | length of node set distribution factor list                   |
| EX\\_INQ\\_SS\\_DF\\_LEN                      | length of side set distribution factor list                   |
| EX\\_INQ\\_LIB\\_VERS                         | API Lib vers number (float)                                   |
| EX\\_INQ\\_EM\\_PROP                          | number of element map properties                              |
| EX\\_INQ\\_NM\\_PROP                          | number of node map properties                                 |
| EX\\_INQ\\_ELEM\\_MAP                         | number of element maps                                        |
| EX\\_INQ\\_NODE\\_MAP                         | number of node maps                                           |
| EX\\_INQ\\_EDGE                               | number of edges                                               |
| EX\\_INQ\\_EDGE\\_BLK                         | number of edge blocks                                         |
| EX\\_INQ\\_EDGE\\_SETS                        | number of edge sets                                           |
| EX\\_INQ\\_ES\\_LEN                           | length of concat edge set edge list                           |
| EX\\_INQ\\_ES\\_DF\\_LEN                      | length of concat edge set dist factor list                    |
| EX\\_INQ\\_EDGE\\_PROP                        | number of properties stored per edge block                    |
| EX\\_INQ\\_ES\\_PROP                          | number of properties stored per edge set                      |
| EX\\_INQ\\_FACE                               | number of faces                                               |
| EX\\_INQ\\_FACE\\_BLK                         | number of face blocks                                         |
| EX\\_INQ\\_FACE\\_SETS                        | number of face sets                                           |
| EX\\_INQ\\_FS\\_LEN                           | length of concat face set face list                           |
| EX\\_INQ\\_FS\\_DF\\_LEN                      | length of concat face set dist factor list                    |
| EX\\_INQ\\_FACE\\_PROP                        | number of properties stored per face block                    |
| EX\\_INQ\\_FS\\_PROP                          | number of properties stored per face set                      |
| EX\\_INQ\\_ELEM\\_SETS                        | number of element sets                                        |
| EX\\_INQ\\_ELS\\_LEN                          | length of concat element set element list                     |
| EX\\_INQ\\_ELS\\_DF\\_LEN                     | length of concat element set dist factor list                 |
| EX\\_INQ\\_ELS\\_PROP                         | number of properties stored per elem set                      |
| EX\\_INQ\\_EDGE\\_MAP                         | number of edge maps                                           |
| EX\\_INQ\\_FACE\\_MAP                         | number of face maps                                           |
| EX\\_INQ\\_COORD\\_FRAMES                     | number of coordinate frames                                   |
| EX\\_INQ\\_DB\\_MAX\\_ALLOWED\\_NAME\\_LENGTH | size of [`MAX_NAME_LENGTH`](@ref) dimension on database       |
| EX\\_INQ\\_DB\\_MAX\\_USED\\_NAME\\_LENGTH    |                                                               |
| EX\\_INQ\\_MAX\\_READ\\_NAME\\_LENGTH         | client-specified max size of returned names                   |
| EX\\_INQ\\_DB\\_FLOAT\\_SIZE                  | size of floating-point values stored on database              |
| EX\\_INQ\\_NUM\\_CHILD\\_GROUPS               | number of groups contained in this (exoid) group              |
| EX\\_INQ\\_GROUP\\_PARENT                     | id of parent of this (exoid) group; returns exoid if at root  |
| EX\\_INQ\\_GROUP\\_NAME\\_LEN                 | length of name of group exoid                                 |
| EX\\_INQ\\_FULL\\_GROUP\\_NAME\\_LEN          | length of full path name of this (exoid) group                |
| EX\\_INQ\\_FULL\\_GROUP\\_NAME                | full "/"-separated path name of this (exoid) group            |
| EX\\_INQ\\_THREADSAFE                         | Returns 1 if library is thread-safe; 0 otherwise              |
| EX\\_INQ\\_ASSEMBLY                           | number of assemblies                                          |
| EX\\_INQ\\_BLOB                               | number of blobs                                               |
| EX\\_INQ\\_NUM\\_NODE\\_VAR                   | number of nodal variables                                     |
| EX\\_INQ\\_NUM\\_EDGE\\_BLOCK\\_VAR           | number of edge block variables                                |
| EX\\_INQ\\_NUM\\_FACE\\_BLOCK\\_VAR           | number of face block variables                                |
| EX\\_INQ\\_NUM\\_ELEM\\_BLOCK\\_VAR           | number of element block variables                             |
| EX\\_INQ\\_NUM\\_NODE\\_SET\\_VAR             | number of node set variables                                  |
| EX\\_INQ\\_NUM\\_EDGE\\_SET\\_VAR             | number of edge set variables                                  |
| EX\\_INQ\\_NUM\\_FACE\\_SET\\_VAR             | number of face set variables                                  |
| EX\\_INQ\\_NUM\\_ELEM\\_SET\\_VAR             | number of element set variables                               |
| EX\\_INQ\\_NUM\\_SIDE\\_SET\\_VAR             | number of sideset variables                                   |
| EX\\_INQ\\_NUM\\_GLOBAL\\_VAR                 | number of global variables                                    |
| EX\\_INQ\\_FILE\\_FORMAT                      | netCDF file format                                            |
# See also
[`ex_inquire`](@ref)() All inquiries return an integer of the current database integer size unless otherwise noted.
"""
@cenum ex_inquiry::Int32 begin
    EX_INQ_FILE_TYPE = 1
    EX_INQ_API_VERS = 2
    EX_INQ_DB_VERS = 3
    EX_INQ_TITLE = 4
    EX_INQ_DIM = 5
    EX_INQ_NODES = 6
    EX_INQ_ELEM = 7
    EX_INQ_ELEM_BLK = 8
    EX_INQ_NODE_SETS = 9
    EX_INQ_NS_NODE_LEN = 10
    EX_INQ_SIDE_SETS = 11
    EX_INQ_SS_NODE_LEN = 12
    EX_INQ_SS_ELEM_LEN = 13
    EX_INQ_QA = 14
    EX_INQ_INFO = 15
    EX_INQ_TIME = 16
    EX_INQ_EB_PROP = 17
    EX_INQ_NS_PROP = 18
    EX_INQ_SS_PROP = 19
    EX_INQ_NS_DF_LEN = 20
    EX_INQ_SS_DF_LEN = 21
    EX_INQ_LIB_VERS = 22
    EX_INQ_EM_PROP = 23
    EX_INQ_NM_PROP = 24
    EX_INQ_ELEM_MAP = 25
    EX_INQ_NODE_MAP = 26
    EX_INQ_EDGE = 27
    EX_INQ_EDGE_BLK = 28
    EX_INQ_EDGE_SETS = 29
    EX_INQ_ES_LEN = 30
    EX_INQ_ES_DF_LEN = 31
    EX_INQ_EDGE_PROP = 32
    EX_INQ_ES_PROP = 33
    EX_INQ_FACE = 34
    EX_INQ_FACE_BLK = 35
    EX_INQ_FACE_SETS = 36
    EX_INQ_FS_LEN = 37
    EX_INQ_FS_DF_LEN = 38
    EX_INQ_FACE_PROP = 39
    EX_INQ_FS_PROP = 40
    EX_INQ_ELEM_SETS = 41
    EX_INQ_ELS_LEN = 42
    EX_INQ_ELS_DF_LEN = 43
    EX_INQ_ELS_PROP = 44
    EX_INQ_EDGE_MAP = 45
    EX_INQ_FACE_MAP = 46
    EX_INQ_COORD_FRAMES = 47
    EX_INQ_DB_MAX_ALLOWED_NAME_LENGTH = 48
    EX_INQ_DB_MAX_USED_NAME_LENGTH = 49
    EX_INQ_MAX_READ_NAME_LENGTH = 50
    EX_INQ_DB_FLOAT_SIZE = 51
    EX_INQ_NUM_CHILD_GROUPS = 52
    EX_INQ_GROUP_PARENT = 53
    EX_INQ_GROUP_ROOT = 54
    EX_INQ_GROUP_NAME_LEN = 55
    EX_INQ_GROUP_NAME = 56
    EX_INQ_FULL_GROUP_NAME_LEN = 57
    EX_INQ_FULL_GROUP_NAME = 58
    EX_INQ_THREADSAFE = 59
    EX_INQ_ASSEMBLY = 60
    EX_INQ_BLOB = 61
    EX_INQ_NUM_NODE_VAR = 62
    EX_INQ_NUM_EDGE_BLOCK_VAR = 63
    EX_INQ_NUM_FACE_BLOCK_VAR = 64
    EX_INQ_NUM_ELEM_BLOCK_VAR = 65
    EX_INQ_NUM_NODE_SET_VAR = 66
    EX_INQ_NUM_EDGE_SET_VAR = 67
    EX_INQ_NUM_FACE_SET_VAR = 68
    EX_INQ_NUM_ELEM_SET_VAR = 69
    EX_INQ_NUM_SIDE_SET_VAR = 70
    EX_INQ_NUM_GLOBAL_VAR = 71
    EX_INQ_FILE_FORMAT = 72
    EX_INQ_INVALID = -1
end

"""
    ex_option_type

` FileOptions Variables controlling the compression, name size, and integer size.`

@{

Modes for [`ex_set_option`](@ref)()

The compression-related options are only available on netcdf-4 filessince the underlying hdf5 compression functionality is used for theimplementation. The compression level indicates how much effort shouldbe expended in the compression and the computational expense increaseswith higher levels; in many cases, a compression level of 1 issufficient.

SZIP-based compression is typically faster than ZLIB, but may notbe as widely available as ZLIB. SZIP is also only supported inNetCDF-4.?.? and later

| Enumerator                       | Note                                                                                 |
| :------------------------------- | :----------------------------------------------------------------------------------- |
| EX\\_OPT\\_COMPRESSION\\_TYPE    | Default is gzip                                                                      |
| EX\\_OPT\\_COMPRESSION\\_LEVEL   | Range depends on compression type.                                                   |
| EX\\_OPT\\_COMPRESSION\\_SHUFFLE | 1 if enabled, 0 if disabled                                                          |
| EX\\_OPT\\_QUANTIZE\\_NSD        | if > 0, Number of significant digits to retain in lossy quantize compression         |
| EX\\_OPT\\_INTEGER\\_SIZE\\_API  | 4 or 8 indicating byte size of integers used in api functions.                       |
| EX\\_OPT\\_INTEGER\\_SIZE\\_DB   | Query only, returns 4 or 8 indicating byte size of integers stored on the database.  |
"""
@cenum ex_option_type::UInt32 begin
    EX_OPT_MAX_NAME_LENGTH = 1
    EX_OPT_COMPRESSION_TYPE = 2
    EX_OPT_COMPRESSION_LEVEL = 3
    EX_OPT_COMPRESSION_SHUFFLE = 4
    EX_OPT_QUANTIZE_NSD = 5
    EX_OPT_INTEGER_SIZE_API = 6
    EX_OPT_INTEGER_SIZE_DB = 7
end

"""
    ex_compression_type

| Enumerator           | Note                                        |
| :------------------- | :------------------------------------------ |
| EX\\_COMPRESS\\_ZLIB | Use ZLIB-based compression (if available)   |
| EX\\_COMPRESS\\_GZIP | Same as ZLIB, but typical alias used        |
| EX\\_COMPRESS\\_SZIP | Use SZIP-based compression (if available)   |
| EX\\_COMPRESS\\_ZSTD | Use ZStandard compression (if available)    |
| EX\\_COMPRESS\\_BZ2  | Use BZ2 / Bzip2 compression (if available)  |
"""
@cenum ex_compression_type::UInt32 begin
    EX_COMPRESS_ZLIB = 1
    EX_COMPRESS_GZIP = 1
    EX_COMPRESS_SZIP = 2
    EX_COMPRESS_ZSTD = 3
    EX_COMPRESS_BZ2 = 4
end

"""
    ex_entity_type

@}

| Enumerator        | Note                                           |
| :---------------- | :--------------------------------------------- |
| EX\\_NODAL        | nodal "block" for variables                    |
| EX\\_NODE\\_BLOCK | alias for EX\\_NODAL                           |
| EX\\_NODE\\_SET   | node set property code                         |
| EX\\_EDGE\\_BLOCK | edge block property code                       |
| EX\\_EDGE\\_SET   | edge set property code                         |
| EX\\_FACE\\_BLOCK | face block property code                       |
| EX\\_FACE\\_SET   | face set property code                         |
| EX\\_ELEM\\_BLOCK | element block property code                    |
| EX\\_ELEM\\_SET   | face set property code                         |
| EX\\_SIDE\\_SET   | side set property code                         |
| EX\\_ELEM\\_MAP   | element map property code                      |
| EX\\_NODE\\_MAP   | node map property code                         |
| EX\\_EDGE\\_MAP   | edge map property code                         |
| EX\\_FACE\\_MAP   | face map property code                         |
| EX\\_GLOBAL       | global "block" for variables                   |
| EX\\_COORDINATE   | kluge so some internal wrapper functions work  |
| EX\\_ASSEMBLY     | assembly property code                         |
| EX\\_BLOB         | blob property code                             |
"""
@cenum ex_entity_type::Int32 begin
    EX_NODAL = 14
    EX_NODE_BLOCK = 14
    EX_NODE_SET = 2
    EX_EDGE_BLOCK = 6
    EX_EDGE_SET = 7
    EX_FACE_BLOCK = 8
    EX_FACE_SET = 9
    EX_ELEM_BLOCK = 1
    EX_ELEM_SET = 10
    EX_SIDE_SET = 3
    EX_ELEM_MAP = 4
    EX_NODE_MAP = 5
    EX_EDGE_MAP = 11
    EX_FACE_MAP = 12
    EX_GLOBAL = 13
    EX_COORDINATE = 15
    EX_ASSEMBLY = 16
    EX_BLOB = 17
    EX_INVALID = -1
end

@cenum ex_field_type::UInt32 begin
    EX_FIELD_TYPE_INVALID = 0
    EX_FIELD_TYPE_USER_DEFINED = 1
    EX_FIELD_TYPE_SEQUENCE = 2
    EX_BASIS = 3
    EX_QUADRATURE = 4
    EX_SCALAR = 5
    EX_VECTOR_1D = 6
    EX_VECTOR_2D = 7
    EX_VECTOR_3D = 8
    EX_QUATERNION_2D = 9
    EX_QUATERNION_3D = 10
    EX_FULL_TENSOR_36 = 11
    EX_FULL_TENSOR_32 = 12
    EX_FULL_TENSOR_22 = 13
    EX_FULL_TENSOR_16 = 14
    EX_FULL_TENSOR_12 = 15
    EX_SYM_TENSOR_33 = 16
    EX_SYM_TENSOR_31 = 17
    EX_SYM_TENSOR_21 = 18
    EX_SYM_TENSOR_13 = 19
    EX_SYM_TENSOR_11 = 20
    EX_SYM_TENSOR_10 = 21
    EX_ASYM_TENSOR_03 = 22
    EX_ASYM_TENSOR_02 = 23
    EX_ASYM_TENSOR_01 = 24
    EX_MATRIX_2X2 = 25
    EX_MATRIX_3X3 = 26
end

struct ex_field
    entity_type::ex_entity_type
    entity_id::Int64
    name::Cchar
    nesting::Cint
    type_name::Cchar
    type::NTuple{2, ex_field_type}
    cardinality::NTuple{2, Cint}
    component_separator::NTuple{2, Cchar}
    suffices::Cchar
end

struct ex_basis
    name::Cchar
    cardinality::Cint
    subc_dim::Ptr{Cint}
    subc_ordinal::Ptr{Cint}
    subc_dof_ordinal::Ptr{Cint}
    subc_num_dof::Ptr{Cint}
    xi::Ptr{Cdouble}
    eta::Ptr{Cdouble}
    zeta::Ptr{Cdouble}
end

struct ex_quadrature
    name::Cchar
    cardinality::Cint
    dimension::Cint
    xi::Ptr{Cdouble}
    eta::Ptr{Cdouble}
    zeta::Ptr{Cdouble}
    weight::Ptr{Cdouble}
end

"""
    ex_options

[`ex_opts`](@ref)() function codes - codes are OR'ed into exopts

| Enumerator       | Note                                            |
| :--------------- | :---------------------------------------------- |
| EX\\_VERBOSE     | verbose mode message flag                       |
| EX\\_DEBUG       | debug mode def                                  |
| EX\\_ABORT       | abort mode flag def                             |
| EX\\_NULLVERBOSE | verbose mode for null entity detection warning  |
"""
@cenum ex_options::UInt32 begin
    EX_DEFAULT = 0
    EX_VERBOSE = 1
    EX_DEBUG = 2
    EX_ABORT = 4
    EX_NULLVERBOSE = 8
end

"""
Specifies that this argument is the id of an entity: element block, nodeset, sideset, ...
"""
const ex_entity_id = Int64

"""
The mechanism for passing double/float and int/int64\\_t both use a void*; to avoid some confusion as to whether a function takes an integer or a float/double, the following typedef is used for the integer argument
"""
const void_int = Cvoid

"""
    ex_init_params

` APIStructs Structures used by external API functions.`

[`ex_put_init_ext`](@ref)(), [`ex_get_init_ext`](@ref)(), [`ex_get_block_param`](@ref)(), [`ex_put_block_param`](@ref)(), [`ex_get_block_params`](@ref)(), [`ex_put_block_params`](@ref)(), [`ex_put_concat_all_blocks`](@ref)(), [`ex_put_concat_sets`](@ref)(), [`ex_get_concat_sets`](@ref)(), [`ex_put_sets`](@ref)(), [`ex_get_sets`](@ref)() @{
"""
struct ex_init_params
    title::NTuple{81, Cchar}
    num_dim::Int64
    num_nodes::Int64
    num_edge::Int64
    num_edge_blk::Int64
    num_face::Int64
    num_face_blk::Int64
    num_elem::Int64
    num_elem_blk::Int64
    num_node_sets::Int64
    num_edge_sets::Int64
    num_face_sets::Int64
    num_side_sets::Int64
    num_elem_sets::Int64
    num_node_maps::Int64
    num_edge_maps::Int64
    num_face_maps::Int64
    num_elem_maps::Int64
    num_assembly::Int64
    num_blob::Int64
end

@cenum ex_type::UInt32 begin
    EX_INTEGER = 0
    EX_DOUBLE = 1
    EX_CHAR = 2
end

struct ex_attribute
    entity_type::ex_entity_type
    entity_id::Int64
    name::Cchar
    type::ex_type
    value_count::Cint
    values::Ptr{Cvoid}
end

struct ex_blob
    id::ex_entity_id
    name::Cstring
    num_entry::Int64
end

struct ex_assembly
    id::ex_entity_id
    name::Cstring
    type::ex_entity_type
    entity_count::Cint
    entity_list::Ptr{ex_entity_id}
end

struct ex_block
    id::ex_entity_id
    type::ex_entity_type
    topology::NTuple{33, Cchar}
    num_entry::Int64
    num_nodes_per_entry::Int64
    num_edges_per_entry::Int64
    num_faces_per_entry::Int64
    num_attribute::Int64
end

struct ex_set
    id::ex_entity_id
    type::ex_entity_type
    num_entry::Int64
    num_distribution_factor::Int64
    entry_list::Ptr{void_int}
    extra_list::Ptr{void_int}
    distribution_factor_list::Ptr{Cvoid}
end

struct ex_block_params
    edge_blk_id::Ptr{void_int}
    edge_type::Ptr{Cstring}
    num_edge_this_blk::Ptr{Cint}
    num_nodes_per_edge::Ptr{Cint}
    num_attr_edge::Ptr{Cint}
    face_blk_id::Ptr{void_int}
    face_type::Ptr{Cstring}
    num_face_this_blk::Ptr{Cint}
    num_nodes_per_face::Ptr{Cint}
    num_attr_face::Ptr{Cint}
    elem_blk_id::Ptr{void_int}
    elem_type::Ptr{Cstring}
    num_elem_this_blk::Ptr{Cint}
    num_nodes_per_elem::Ptr{Cint}
    num_edges_per_elem::Ptr{Cint}
    num_faces_per_elem::Ptr{Cint}
    num_attr_elem::Ptr{Cint}
    define_maps::Cint
end

struct ex_set_specs
    sets_ids::Ptr{void_int}
    num_entries_per_set::Ptr{void_int}
    num_dist_per_set::Ptr{void_int}
    sets_entry_index::Ptr{void_int}
    sets_dist_index::Ptr{void_int}
    sets_entry_list::Ptr{void_int}
    sets_extra_list::Ptr{void_int}
    sets_dist_fact::Ptr{Cvoid}
end

struct ex_var_params
    num_glob::Cint
    num_node::Cint
    num_edge::Cint
    num_face::Cint
    num_elem::Cint
    num_nset::Cint
    num_eset::Cint
    num_fset::Cint
    num_sset::Cint
    num_elset::Cint
    edge_var_tab::Ptr{Cint}
    face_var_tab::Ptr{Cint}
    elem_var_tab::Ptr{Cint}
    nset_var_tab::Ptr{Cint}
    eset_var_tab::Ptr{Cint}
    fset_var_tab::Ptr{Cint}
    sset_var_tab::Ptr{Cint}
    elset_var_tab::Ptr{Cint}
end

"""
    ex_close(exoid)

` Utilities`

@{
"""
function ex_close(exoid)
    @ccall libexodus.ex_close(exoid::Cint)::Cint
end

function ex_copy(in_exoid, out_exoid)
    @ccall libexodus.ex_copy(in_exoid::Cint, out_exoid::Cint)::Cint
end

function ex_copy_transient(in_exoid, out_exoid)
    @ccall libexodus.ex_copy_transient(in_exoid::Cint, out_exoid::Cint)::Cint
end

function ex_get_group_id(parent_id, group_name, group_id)
    @ccall libexodus.ex_get_group_id(parent_id::Cint, group_name::Cstring, group_id::Ptr{Cint})::Cint
end

function ex_get_group_ids(parent_id, num_groups, group_ids)
    @ccall libexodus.ex_get_group_ids(parent_id::Cint, num_groups::Ptr{Cint}, group_ids::Ptr{Cint})::Cint
end

function ex_get_info(exoid, info)
    @ccall libexodus.ex_get_info(exoid::Cint, info::Ptr{Cstring})::Cint
end

function ex_get_qa(exoid, qa_record)
    @ccall libexodus.ex_get_qa(exoid::Cint, qa_record::Ptr{NTuple{4, Cstring}})::Cint
end

function ex_put_info(exoid, num_info, info)
    @ccall libexodus.ex_put_info(exoid::Cint, num_info::Cint, info::Ptr{Cstring})::Cint
end

function ex_put_qa(exoid, num_qa_records, qa_record)
    @ccall libexodus.ex_put_qa(exoid::Cint, num_qa_records::Cint, qa_record::Ptr{NTuple{4, Cstring}})::Cint
end

function ex_update(exoid)
    @ccall libexodus.ex_update(exoid::Cint)::Cint
end

function ex_get_num_props(exoid, obj_type)
    @ccall libexodus.ex_get_num_props(exoid::Cint, obj_type::ex_entity_type)::Cint
end

function ex_large_model(exoid)
    @ccall libexodus.ex_large_model(exoid::Cint)::Cint
end

function ex_header_size(exoid)
    @ccall libexodus.ex_header_size(exoid::Cint)::Csize_t
end

function ex_err(module_name, message, err_num)
    @ccall libexodus.ex_err(module_name::Cstring, message::Cstring, err_num::Cint)::Cvoid
end

function ex_err_fn(exoid, module_name, message, err_num)
    @ccall libexodus.ex_err_fn(exoid::Cint, module_name::Cstring, message::Cstring, err_num::Cint)::Cvoid
end

function ex_set_err(module_name, message, err_num)
    @ccall libexodus.ex_set_err(module_name::Cstring, message::Cstring, err_num::Cint)::Cvoid
end

function ex_strerror(err_num)
    @ccall libexodus.ex_strerror(err_num::Cint)::Cstring
end

function ex_get_err(msg, func, err_num)
    @ccall libexodus.ex_get_err(msg::Ptr{Cstring}, func::Ptr{Cstring}, err_num::Ptr{Cint})::Cvoid
end

function ex_opts(options)
    @ccall libexodus.ex_opts(options::Cint)::Cint
end

function ex_inquire(exoid, req_info, ret_int, ret_float, ret_char)
    @ccall libexodus.ex_inquire(exoid::Cint, req_info::ex_inquiry, ret_int::Ptr{void_int}, ret_float::Ptr{Cfloat}, ret_char::Cstring)::Cint
end

function ex_inquire_int(exoid, req_info)
    @ccall libexodus.ex_inquire_int(exoid::Cint, req_info::ex_inquiry)::Int64
end

function ex_int64_status(exoid)
    @ccall libexodus.ex_int64_status(exoid::Cint)::Cuint
end

function ex_set_int64_status(exoid, mode)
    @ccall libexodus.ex_set_int64_status(exoid::Cint, mode::Cint)::Cint
end

function ex_print_config()
    @ccall libexodus.ex_print_config()::Cvoid
end

function ex_config()
    @ccall libexodus.ex_config()::Cstring
end

function ex_set_max_name_length(exoid, length)
    @ccall libexodus.ex_set_max_name_length(exoid::Cint, length::Cint)::Cint
end

function ex_set_option(exoid, option, option_value)
    @ccall libexodus.ex_set_option(exoid::Cint, option::ex_option_type, option_value::Cint)::Cint
end

function ex_cvt_nodes_to_sides(exoid, num_elem_per_set, num_nodes_per_set, side_sets_elem_index, side_sets_node_index, side_sets_elem_list, side_sets_node_list, side_sets_side_list)
    @ccall libexodus.ex_cvt_nodes_to_sides(exoid::Cint, num_elem_per_set::Ptr{void_int}, num_nodes_per_set::Ptr{void_int}, side_sets_elem_index::Ptr{void_int}, side_sets_node_index::Ptr{void_int}, side_sets_elem_list::Ptr{void_int}, side_sets_node_list::Ptr{void_int}, side_sets_side_list::Ptr{void_int})::Cint
end

"""
    ex_get_time(exoid, time_step, time_value)

` ResultsData`

@{
"""
function ex_get_time(exoid, time_step, time_value)
    @ccall libexodus.ex_get_time(exoid::Cint, time_step::Cint, time_value::Ptr{Cvoid})::Cint
end

function ex_get_variable_names(exoid, obj_type, num_vars, var_names)
    @ccall libexodus.ex_get_variable_names(exoid::Cint, obj_type::ex_entity_type, num_vars::Cint, var_names::Ptr{Cstring})::Cint
end

function ex_get_variable_name(exoid, obj_type, var_num, var_name)
    @ccall libexodus.ex_get_variable_name(exoid::Cint, obj_type::ex_entity_type, var_num::Cint, var_name::Cstring)::Cint
end

function ex_get_variable_param(exoid, obj_type, num_vars)
    @ccall libexodus.ex_get_variable_param(exoid::Cint, obj_type::ex_entity_type, num_vars::Ptr{Cint})::Cint
end

function ex_get_reduction_variable_names(exoid, obj_type, num_vars, var_names)
    @ccall libexodus.ex_get_reduction_variable_names(exoid::Cint, obj_type::ex_entity_type, num_vars::Cint, var_names::Ptr{Cstring})::Cint
end

function ex_get_reduction_variable_name(exoid, obj_type, var_num, var_name)
    @ccall libexodus.ex_get_reduction_variable_name(exoid::Cint, obj_type::ex_entity_type, var_num::Cint, var_name::Cstring)::Cint
end

function ex_get_reduction_variable_param(exoid, obj_type, num_vars)
    @ccall libexodus.ex_get_reduction_variable_param(exoid::Cint, obj_type::ex_entity_type, num_vars::Ptr{Cint})::Cint
end

function ex_get_object_truth_vector(exoid, obj_type, entity_id, num_var, var_vec)
    @ccall libexodus.ex_get_object_truth_vector(exoid::Cint, obj_type::ex_entity_type, entity_id::ex_entity_id, num_var::Cint, var_vec::Ptr{Cint})::Cint
end

function ex_get_truth_table(exoid, obj_type, num_blk, num_var, var_tab)
    @ccall libexodus.ex_get_truth_table(exoid::Cint, obj_type::ex_entity_type, num_blk::Cint, num_var::Cint, var_tab::Ptr{Cint})::Cint
end

function ex_put_all_var_param(exoid, num_g, num_n, num_e, elem_var_tab, num_m, nset_var_tab, num_s, sset_var_tab)
    @ccall libexodus.ex_put_all_var_param(exoid::Cint, num_g::Cint, num_n::Cint, num_e::Cint, elem_var_tab::Ptr{Cint}, num_m::Cint, nset_var_tab::Ptr{Cint}, num_s::Cint, sset_var_tab::Ptr{Cint})::Cint
end

function ex_put_time(exoid, time_step, time_value)
    @ccall libexodus.ex_put_time(exoid::Cint, time_step::Cint, time_value::Ptr{Cvoid})::Cint
end

function ex_get_all_times(exoid, time_values)
    @ccall libexodus.ex_get_all_times(exoid::Cint, time_values::Ptr{Cvoid})::Cint
end

function ex_put_variable_name(exoid, obj_type, var_num, var_name)
    @ccall libexodus.ex_put_variable_name(exoid::Cint, obj_type::ex_entity_type, var_num::Cint, var_name::Cstring)::Cint
end

function ex_put_variable_names(exoid, obj_type, num_vars, var_names)
    @ccall libexodus.ex_put_variable_names(exoid::Cint, obj_type::ex_entity_type, num_vars::Cint, var_names::Ptr{Cstring})::Cint
end

function ex_put_variable_param(exoid, obj_type, num_vars)
    @ccall libexodus.ex_put_variable_param(exoid::Cint, obj_type::ex_entity_type, num_vars::Cint)::Cint
end

function ex_put_reduction_variable_name(exoid, obj_type, var_num, var_name)
    @ccall libexodus.ex_put_reduction_variable_name(exoid::Cint, obj_type::ex_entity_type, var_num::Cint, var_name::Cstring)::Cint
end

function ex_put_reduction_variable_names(exoid, obj_type, num_vars, var_names)
    @ccall libexodus.ex_put_reduction_variable_names(exoid::Cint, obj_type::ex_entity_type, num_vars::Cint, var_names::Ptr{Cstring})::Cint
end

function ex_put_reduction_variable_param(exoid, obj_type, num_vars)
    @ccall libexodus.ex_put_reduction_variable_param(exoid::Cint, obj_type::ex_entity_type, num_vars::Cint)::Cint
end

function ex_put_truth_table(exoid, obj_type, num_blk, num_var, var_tab)
    @ccall libexodus.ex_put_truth_table(exoid::Cint, obj_type::ex_entity_type, num_blk::Cint, num_var::Cint, var_tab::Ptr{Cint})::Cint
end

function ex_put_all_var_param_ext(exoid, vp)
    @ccall libexodus.ex_put_all_var_param_ext(exoid::Cint, vp::Ptr{ex_var_params})::Cint
end

function ex_put_var(exoid, time_step, var_type, var_index, obj_id, num_entries_this_obj, var_vals)
    @ccall libexodus.ex_put_var(exoid::Cint, time_step::Cint, var_type::ex_entity_type, var_index::Cint, obj_id::ex_entity_id, num_entries_this_obj::Int64, var_vals::Ptr{Cvoid})::Cint
end

function ex_put_var_multi_time(exoid, var_type, var_index, obj_id, num_entries_this_obj, beg_time_step, end_time_step, var_vals)
    @ccall libexodus.ex_put_var_multi_time(exoid::Cint, var_type::ex_entity_type, var_index::Cint, obj_id::ex_entity_id, num_entries_this_obj::Int64, beg_time_step::Cint, end_time_step::Cint, var_vals::Ptr{Cvoid})::Cint
end

function ex_put_partial_var(exoid, time_step, var_type, var_index, obj_id, start_index, num_entities, var_vals)
    @ccall libexodus.ex_put_partial_var(exoid::Cint, time_step::Cint, var_type::ex_entity_type, var_index::Cint, obj_id::ex_entity_id, start_index::Int64, num_entities::Int64, var_vals::Ptr{Cvoid})::Cint
end

function ex_put_reduction_vars(exoid, time_step, obj_type, obj_id, num_variables, var_vals)
    @ccall libexodus.ex_put_reduction_vars(exoid::Cint, time_step::Cint, obj_type::ex_entity_type, obj_id::ex_entity_id, num_variables::Int64, var_vals::Ptr{Cvoid})::Cint
end

function ex_get_var(exoid, time_step, var_type, var_index, obj_id, num_entry_this_obj, var_vals)
    @ccall libexodus.ex_get_var(exoid::Cint, time_step::Cint, var_type::ex_entity_type, var_index::Cint, obj_id::ex_entity_id, num_entry_this_obj::Int64, var_vals::Ptr{Cvoid})::Cint
end

function ex_get_var_multi_time(exoid, var_type, var_index, obj_id, num_entry_this_obj, beg_time_step, end_time_step, var_vals)
    @ccall libexodus.ex_get_var_multi_time(exoid::Cint, var_type::ex_entity_type, var_index::Cint, obj_id::ex_entity_id, num_entry_this_obj::Int64, beg_time_step::Cint, end_time_step::Cint, var_vals::Ptr{Cvoid})::Cint
end

function ex_get_var_time(exoid, var_type, var_index, id, beg_time_step, end_time_step, var_vals)
    @ccall libexodus.ex_get_var_time(exoid::Cint, var_type::ex_entity_type, var_index::Cint, id::ex_entity_id, beg_time_step::Cint, end_time_step::Cint, var_vals::Ptr{Cvoid})::Cint
end

function ex_get_partial_var(exoid, time_step, var_type, var_index, obj_id, start_index, num_entities, var_vals)
    @ccall libexodus.ex_get_partial_var(exoid::Cint, time_step::Cint, var_type::ex_entity_type, var_index::Cint, obj_id::ex_entity_id, start_index::Int64, num_entities::Int64, var_vals::Ptr{Cvoid})::Cint
end

function ex_get_reduction_vars(exoid, time_step, obj_type, obj_id, num_variables, var_vals)
    @ccall libexodus.ex_get_reduction_vars(exoid::Cint, time_step::Cint, obj_type::ex_entity_type, obj_id::ex_entity_id, num_variables::Int64, var_vals::Ptr{Cvoid})::Cint
end

"""
    ex_get_init_info(exoid, num_proc, num_proc_in_f, ftype)

@}
"""
function ex_get_init_info(exoid, num_proc, num_proc_in_f, ftype)
    @ccall libexodus.ex_get_init_info(exoid::Cint, num_proc::Ptr{Cint}, num_proc_in_f::Ptr{Cint}, ftype::Cstring)::Cint
end

function ex_put_init_info(exoid, num_proc, num_proc_in_f, ftype)
    @ccall libexodus.ex_put_init_info(exoid::Cint, num_proc::Cint, num_proc_in_f::Cint, ftype::Cstring)::Cint
end

function ex_get_init_global(exoid, num_nodes_g, num_elems_g, num_elem_blks_g, num_node_sets_g, num_side_sets_g)
    @ccall libexodus.ex_get_init_global(exoid::Cint, num_nodes_g::Ptr{void_int}, num_elems_g::Ptr{void_int}, num_elem_blks_g::Ptr{void_int}, num_node_sets_g::Ptr{void_int}, num_side_sets_g::Ptr{void_int})::Cint
end

function ex_put_init_global(exoid, num_nodes_g, num_elems_g, num_elem_blks_g, num_node_sets_g, num_side_sets_g)
    @ccall libexodus.ex_put_init_global(exoid::Cint, num_nodes_g::Int64, num_elems_g::Int64, num_elem_blks_g::Int64, num_node_sets_g::Int64, num_side_sets_g::Int64)::Cint
end

function ex_get_loadbal_param(exoid, num_int_nodes, num_bor_nodes, num_ext_nodes, num_int_elems, num_bor_elems, num_node_cmaps, num_elem_cmaps, processor)
    @ccall libexodus.ex_get_loadbal_param(exoid::Cint, num_int_nodes::Ptr{void_int}, num_bor_nodes::Ptr{void_int}, num_ext_nodes::Ptr{void_int}, num_int_elems::Ptr{void_int}, num_bor_elems::Ptr{void_int}, num_node_cmaps::Ptr{void_int}, num_elem_cmaps::Ptr{void_int}, processor::Cint)::Cint
end

function ex_put_loadbal_param(exoid, num_int_nodes, num_bor_nodes, num_ext_nodes, num_int_elems, num_bor_elems, num_node_cmaps, num_elem_cmaps, processor)
    @ccall libexodus.ex_put_loadbal_param(exoid::Cint, num_int_nodes::Int64, num_bor_nodes::Int64, num_ext_nodes::Int64, num_int_elems::Int64, num_bor_elems::Int64, num_node_cmaps::Int64, num_elem_cmaps::Int64, processor::Cint)::Cint
end

function ex_put_loadbal_param_cc(exoid, num_int_nodes, num_bor_nodes, num_ext_nodes, num_int_elems, num_bor_elems, num_node_cmaps, num_elem_cmaps)
    @ccall libexodus.ex_put_loadbal_param_cc(exoid::Cint, num_int_nodes::Ptr{void_int}, num_bor_nodes::Ptr{void_int}, num_ext_nodes::Ptr{void_int}, num_int_elems::Ptr{void_int}, num_bor_elems::Ptr{void_int}, num_node_cmaps::Ptr{void_int}, num_elem_cmaps::Ptr{void_int})::Cint
end

function ex_copy_string(dest, source, elements)
    @ccall libexodus.ex_copy_string(dest::Cstring, source::Cstring, elements::Csize_t)::Cstring
end

"""
    ex_create_group(parent_id, group_name)

` ModelDescription`

@{
"""
function ex_create_group(parent_id, group_name)
    @ccall libexodus.ex_create_group(parent_id::Cint, group_name::Cstring)::Cint
end

function ex_get_coord_names(exoid, coord_names)
    @ccall libexodus.ex_get_coord_names(exoid::Cint, coord_names::Ptr{Cstring})::Cint
end

function ex_get_coord(exoid, x_coor, y_coor, z_coor)
    @ccall libexodus.ex_get_coord(exoid::Cint, x_coor::Ptr{Cvoid}, y_coor::Ptr{Cvoid}, z_coor::Ptr{Cvoid})::Cint
end

function ex_get_partial_coord_component(exoid, start_node_num, num_nodes, component, coor)
    @ccall libexodus.ex_get_partial_coord_component(exoid::Cint, start_node_num::Int64, num_nodes::Int64, component::Cint, coor::Ptr{Cvoid})::Cint
end

function ex_get_partial_coord(exoid, start_node_num, num_nodes, x_coor, y_coor, z_coor)
    @ccall libexodus.ex_get_partial_coord(exoid::Cint, start_node_num::Int64, num_nodes::Int64, x_coor::Ptr{Cvoid}, y_coor::Ptr{Cvoid}, z_coor::Ptr{Cvoid})::Cint
end

function ex_get_ids(exoid, obj_type, ids)
    @ccall libexodus.ex_get_ids(exoid::Cint, obj_type::ex_entity_type, ids::Ptr{void_int})::Cint
end

function ex_get_coordinate_frames(exoid, nframes, cf_ids, pt_coordinates, tags)
    @ccall libexodus.ex_get_coordinate_frames(exoid::Cint, nframes::Ptr{Cint}, cf_ids::Ptr{void_int}, pt_coordinates::Ptr{Cvoid}, tags::Cstring)::Cint
end

function ex_put_init_ext(exoid, model)
    @ccall libexodus.ex_put_init_ext(exoid::Cint, model::Ptr{ex_init_params})::Cint
end

function ex_get_init_ext(exoid, info)
    @ccall libexodus.ex_get_init_ext(exoid::Cint, info::Ptr{ex_init_params})::Cint
end

function ex_get_init(exoid, title, num_dim, num_nodes, num_elem, num_elem_blk, num_node_sets, num_side_sets)
    @ccall libexodus.ex_get_init(exoid::Cint, title::Cstring, num_dim::Ptr{void_int}, num_nodes::Ptr{void_int}, num_elem::Ptr{void_int}, num_elem_blk::Ptr{void_int}, num_node_sets::Ptr{void_int}, num_side_sets::Ptr{void_int})::Cint
end

function ex_put_init(exoid, title, num_dim, num_nodes, num_elem, num_elem_blk, num_node_sets, num_side_sets)
    @ccall libexodus.ex_put_init(exoid::Cint, title::Cstring, num_dim::Int64, num_nodes::Int64, num_elem::Int64, num_elem_blk::Int64, num_node_sets::Int64, num_side_sets::Int64)::Cint
end

function ex_get_map(exoid, elem_map)
    @ccall libexodus.ex_get_map(exoid::Cint, elem_map::Ptr{void_int})::Cint
end

function ex_get_map_param(exoid, num_node_maps, num_elem_maps)
    @ccall libexodus.ex_get_map_param(exoid::Cint, num_node_maps::Ptr{Cint}, num_elem_maps::Ptr{Cint})::Cint
end

function ex_get_name(exoid, obj_type, entity_id, name)
    @ccall libexodus.ex_get_name(exoid::Cint, obj_type::ex_entity_type, entity_id::ex_entity_id, name::Cstring)::Cint
end

function ex_get_names(exoid, obj_type, names)
    @ccall libexodus.ex_get_names(exoid::Cint, obj_type::ex_entity_type, names::Ptr{Cstring})::Cint
end

function ex_get_prop_array(exoid, obj_type, prop_name, values)
    @ccall libexodus.ex_get_prop_array(exoid::Cint, obj_type::ex_entity_type, prop_name::Cstring, values::Ptr{void_int})::Cint
end

function ex_get_prop(exoid, obj_type, obj_id, prop_name, value)
    @ccall libexodus.ex_get_prop(exoid::Cint, obj_type::ex_entity_type, obj_id::ex_entity_id, prop_name::Cstring, value::Ptr{void_int})::Cint
end

function ex_get_partial_num_map(exoid, map_type, map_id, ent_start, ent_count, map)
    @ccall libexodus.ex_get_partial_num_map(exoid::Cint, map_type::ex_entity_type, map_id::ex_entity_id, ent_start::Int64, ent_count::Int64, map::Ptr{void_int})::Cint
end

function ex_get_prop_names(exoid, obj_type, prop_names)
    @ccall libexodus.ex_get_prop_names(exoid::Cint, obj_type::ex_entity_type, prop_names::Ptr{Cstring})::Cint
end

function ex_add_attr(exoid, obj_type, obj_id, num_attr_per_entry)
    @ccall libexodus.ex_add_attr(exoid::Cint, obj_type::ex_entity_type, obj_id::ex_entity_id, num_attr_per_entry::Int64)::Cint
end

function ex_put_attr_param(exoid, obj_type, obj_id, num_attrs)
    @ccall libexodus.ex_put_attr_param(exoid::Cint, obj_type::ex_entity_type, obj_id::ex_entity_id, num_attrs::Cint)::Cint
end

function ex_get_attr_param(exoid, obj_type, obj_id, num_attrs)
    @ccall libexodus.ex_get_attr_param(exoid::Cint, obj_type::ex_entity_type, obj_id::ex_entity_id, num_attrs::Ptr{Cint})::Cint
end

function ex_put_concat_elem_block(exoid, elem_blk_id, elem_type, num_elem_this_blk, num_nodes_per_elem, num_attr_this_blk, define_maps)
    @ccall libexodus.ex_put_concat_elem_block(exoid::Cint, elem_blk_id::Ptr{void_int}, elem_type::Ptr{Cstring}, num_elem_this_blk::Ptr{void_int}, num_nodes_per_elem::Ptr{void_int}, num_attr_this_blk::Ptr{void_int}, define_maps::Cint)::Cint
end

function ex_put_coord_names(exoid, coord_names)
    @ccall libexodus.ex_put_coord_names(exoid::Cint, coord_names::Ptr{Cstring})::Cint
end

function ex_put_coord(exoid, x_coor, y_coor, z_coor)
    @ccall libexodus.ex_put_coord(exoid::Cint, x_coor::Ptr{Cvoid}, y_coor::Ptr{Cvoid}, z_coor::Ptr{Cvoid})::Cint
end

function ex_put_partial_coord_component(exoid, start_node_num, num_nodes, component, coor)
    @ccall libexodus.ex_put_partial_coord_component(exoid::Cint, start_node_num::Int64, num_nodes::Int64, component::Cint, coor::Ptr{Cvoid})::Cint
end

function ex_put_partial_coord(exoid, start_node_num, num_nodes, x_coor, y_coor, z_coor)
    @ccall libexodus.ex_put_partial_coord(exoid::Cint, start_node_num::Int64, num_nodes::Int64, x_coor::Ptr{Cvoid}, y_coor::Ptr{Cvoid}, z_coor::Ptr{Cvoid})::Cint
end

function ex_put_map(exoid, elem_map)
    @ccall libexodus.ex_put_map(exoid::Cint, elem_map::Ptr{void_int})::Cint
end

function ex_put_id_map(exoid, map_type, map)
    @ccall libexodus.ex_put_id_map(exoid::Cint, map_type::ex_entity_type, map::Ptr{void_int})::Cint
end

function ex_put_partial_id_map(exoid, map_type, start_entity_num, num_entities, map)
    @ccall libexodus.ex_put_partial_id_map(exoid::Cint, map_type::ex_entity_type, start_entity_num::Int64, num_entities::Int64, map::Ptr{void_int})::Cint
end

function ex_get_id_map(exoid, map_type, map)
    @ccall libexodus.ex_get_id_map(exoid::Cint, map_type::ex_entity_type, map::Ptr{void_int})::Cint
end

function ex_get_partial_id_map(exoid, map_type, start_entity_num, num_entities, map)
    @ccall libexodus.ex_get_partial_id_map(exoid::Cint, map_type::ex_entity_type, start_entity_num::Int64, num_entities::Int64, map::Ptr{void_int})::Cint
end

function ex_get_block_id_map(exoid, map_type, entity_id, map)
    @ccall libexodus.ex_get_block_id_map(exoid::Cint, map_type::ex_entity_type, entity_id::ex_entity_id, map::Ptr{void_int})::Cint
end

function ex_put_coordinate_frames(exoid, nframes, cf_ids, pt_coordinates, tags)
    @ccall libexodus.ex_put_coordinate_frames(exoid::Cint, nframes::Cint, cf_ids::Ptr{void_int}, pt_coordinates::Ptr{Cvoid}, tags::Cstring)::Cint
end

function ex_put_map_param(exoid, num_node_maps, num_elem_maps)
    @ccall libexodus.ex_put_map_param(exoid::Cint, num_node_maps::Cint, num_elem_maps::Cint)::Cint
end

function ex_put_name(exoid, obj_type, entity_id, name)
    @ccall libexodus.ex_put_name(exoid::Cint, obj_type::ex_entity_type, entity_id::ex_entity_id, name::Cstring)::Cint
end

function ex_put_names(exoid, obj_type, names)
    @ccall libexodus.ex_put_names(exoid::Cint, obj_type::ex_entity_type, names::Ptr{Cstring})::Cint
end

function ex_put_partial_one_attr(exoid, obj_type, obj_id, start_num, num_ent, attrib_index, attrib)
    @ccall libexodus.ex_put_partial_one_attr(exoid::Cint, obj_type::ex_entity_type, obj_id::ex_entity_id, start_num::Int64, num_ent::Int64, attrib_index::Cint, attrib::Ptr{Cvoid})::Cint
end

function ex_put_prop(exoid, obj_type, obj_id, prop_name, value)
    @ccall libexodus.ex_put_prop(exoid::Cint, obj_type::ex_entity_type, obj_id::ex_entity_id, prop_name::Cstring, value::ex_entity_id)::Cint
end

function ex_put_prop_array(exoid, obj_type, prop_name, values)
    @ccall libexodus.ex_put_prop_array(exoid::Cint, obj_type::ex_entity_type, prop_name::Cstring, values::Ptr{void_int})::Cint
end

function ex_put_prop_names(exoid, obj_type, num_props, prop_names)
    @ccall libexodus.ex_put_prop_names(exoid::Cint, obj_type::ex_entity_type, num_props::Cint, prop_names::Ptr{Cstring})::Cint
end

function ex_put_num_map(exoid, map_type, map_id, map)
    @ccall libexodus.ex_put_num_map(exoid::Cint, map_type::ex_entity_type, map_id::ex_entity_id, map::Ptr{void_int})::Cint
end

function ex_get_num_map(exoid, map_type, map_id, map)
    @ccall libexodus.ex_get_num_map(exoid::Cint, map_type::ex_entity_type, map_id::ex_entity_id, map::Ptr{void_int})::Cint
end

function ex_put_block(exoid, blk_type, blk_id, entry_descrip, num_entries_this_blk, num_nodes_per_entry, num_edges_per_entry, num_faces_per_entry, num_attr_per_entry)
    @ccall libexodus.ex_put_block(exoid::Cint, blk_type::ex_entity_type, blk_id::ex_entity_id, entry_descrip::Cstring, num_entries_this_blk::Int64, num_nodes_per_entry::Int64, num_edges_per_entry::Int64, num_faces_per_entry::Int64, num_attr_per_entry::Int64)::Cint
end

function ex_get_block(exoid, blk_type, blk_id, elem_type, num_entries_this_blk, num_nodes_per_entry, num_edges_per_entry, num_faces_per_entry, num_attr_per_entry)
    @ccall libexodus.ex_get_block(exoid::Cint, blk_type::ex_entity_type, blk_id::ex_entity_id, elem_type::Cstring, num_entries_this_blk::Ptr{void_int}, num_nodes_per_entry::Ptr{void_int}, num_edges_per_entry::Ptr{void_int}, num_faces_per_entry::Ptr{void_int}, num_attr_per_entry::Ptr{void_int})::Cint
end

function ex_get_block_param(exoid, block)
    @ccall libexodus.ex_get_block_param(exoid::Cint, block::Ptr{ex_block})::Cint
end

function ex_put_block_param(exoid, block)
    @ccall libexodus.ex_put_block_param(exoid::Cint, block::ex_block)::Cint
end

function ex_get_block_params(exoid, block_count, blocks)
    @ccall libexodus.ex_get_block_params(exoid::Cint, block_count::Csize_t, blocks::Ptr{Ptr{ex_block}})::Cint
end

function ex_put_block_params(exoid, block_count, blocks)
    @ccall libexodus.ex_put_block_params(exoid::Cint, block_count::Csize_t, blocks::Ptr{ex_block})::Cint
end

function ex_put_concat_all_blocks(exoid, param)
    @ccall libexodus.ex_put_concat_all_blocks(exoid::Cint, param::Ptr{ex_block_params})::Cint
end

function ex_put_entity_count_per_polyhedra(exoid, blk_type, blk_id, entity_counts)
    @ccall libexodus.ex_put_entity_count_per_polyhedra(exoid::Cint, blk_type::ex_entity_type, blk_id::ex_entity_id, entity_counts::Ptr{Cint})::Cint
end

function ex_get_entity_count_per_polyhedra(exoid, blk_type, blk_id, entity_counts)
    @ccall libexodus.ex_get_entity_count_per_polyhedra(exoid::Cint, blk_type::ex_entity_type, blk_id::ex_entity_id, entity_counts::Ptr{Cint})::Cint
end

function ex_put_conn(exoid, blk_type, blk_id, node_conn, elem_edge_conn, elem_face_conn)
    @ccall libexodus.ex_put_conn(exoid::Cint, blk_type::ex_entity_type, blk_id::ex_entity_id, node_conn::Ptr{void_int}, elem_edge_conn::Ptr{void_int}, elem_face_conn::Ptr{void_int})::Cint
end

function ex_get_conn(exoid, blk_type, blk_id, nodeconn, edgeconn, faceconn)
    @ccall libexodus.ex_get_conn(exoid::Cint, blk_type::ex_entity_type, blk_id::ex_entity_id, nodeconn::Ptr{void_int}, edgeconn::Ptr{void_int}, faceconn::Ptr{void_int})::Cint
end

function ex_get_partial_conn(exoid, blk_type, blk_id, start_num, num_ent, nodeconn, edgeconn, faceconn)
    @ccall libexodus.ex_get_partial_conn(exoid::Cint, blk_type::ex_entity_type, blk_id::ex_entity_id, start_num::Int64, num_ent::Int64, nodeconn::Ptr{void_int}, edgeconn::Ptr{void_int}, faceconn::Ptr{void_int})::Cint
end

function ex_put_partial_conn(exoid, blk_type, blk_id, start_num, num_ent, nodeconn, edgeconn, faceconn)
    @ccall libexodus.ex_put_partial_conn(exoid::Cint, blk_type::ex_entity_type, blk_id::ex_entity_id, start_num::Int64, num_ent::Int64, nodeconn::Ptr{void_int}, edgeconn::Ptr{void_int}, faceconn::Ptr{void_int})::Cint
end

function ex_put_attr(exoid, blk_type, blk_id, attrib)
    @ccall libexodus.ex_put_attr(exoid::Cint, blk_type::ex_entity_type, blk_id::ex_entity_id, attrib::Ptr{Cvoid})::Cint
end

function ex_put_partial_attr(exoid, blk_type, blk_id, start_entity, num_entity, attrib)
    @ccall libexodus.ex_put_partial_attr(exoid::Cint, blk_type::ex_entity_type, blk_id::ex_entity_id, start_entity::Int64, num_entity::Int64, attrib::Ptr{Cvoid})::Cint
end

function ex_get_attr(exoid, obj_type, obj_id, attrib)
    @ccall libexodus.ex_get_attr(exoid::Cint, obj_type::ex_entity_type, obj_id::ex_entity_id, attrib::Ptr{Cvoid})::Cint
end

function ex_get_partial_attr(exoid, obj_type, obj_id, start_num, num_ent, attrib)
    @ccall libexodus.ex_get_partial_attr(exoid::Cint, obj_type::ex_entity_type, obj_id::ex_entity_id, start_num::Int64, num_ent::Int64, attrib::Ptr{Cvoid})::Cint
end

function ex_put_one_attr(exoid, obj_type, obj_id, attrib_index, attrib)
    @ccall libexodus.ex_put_one_attr(exoid::Cint, obj_type::ex_entity_type, obj_id::ex_entity_id, attrib_index::Cint, attrib::Ptr{Cvoid})::Cint
end

function ex_get_one_attr(exoid, obj_type, obj_id, attrib_index, attrib)
    @ccall libexodus.ex_get_one_attr(exoid::Cint, obj_type::ex_entity_type, obj_id::ex_entity_id, attrib_index::Cint, attrib::Ptr{Cvoid})::Cint
end

function ex_get_partial_one_attr(exoid, obj_type, obj_id, start_num, num_ent, attrib_index, attrib)
    @ccall libexodus.ex_get_partial_one_attr(exoid::Cint, obj_type::ex_entity_type, obj_id::ex_entity_id, start_num::Int64, num_ent::Int64, attrib_index::Cint, attrib::Ptr{Cvoid})::Cint
end

function ex_put_attr_names(exoid, blk_type, blk_id, names)
    @ccall libexodus.ex_put_attr_names(exoid::Cint, blk_type::ex_entity_type, blk_id::ex_entity_id, names::Ptr{Cstring})::Cint
end

function ex_get_attr_names(exoid, obj_type, obj_id, names)
    @ccall libexodus.ex_get_attr_names(exoid::Cint, obj_type::ex_entity_type, obj_id::ex_entity_id, names::Ptr{Cstring})::Cint
end

function ex_put_assembly(exoid, assembly)
    @ccall libexodus.ex_put_assembly(exoid::Cint, assembly::ex_assembly)::Cint
end

function ex_get_assembly(exoid, assembly)
    @ccall libexodus.ex_get_assembly(exoid::Cint, assembly::Ptr{ex_assembly})::Cint
end

function ex_put_assemblies(exoid, count, assemblies)
    @ccall libexodus.ex_put_assemblies(exoid::Cint, count::Csize_t, assemblies::Ptr{ex_assembly})::Cint
end

function ex_get_assemblies(exoid, assemblies)
    @ccall libexodus.ex_get_assemblies(exoid::Cint, assemblies::Ptr{ex_assembly})::Cint
end

function ex_put_blob(exoid, blob)
    @ccall libexodus.ex_put_blob(exoid::Cint, blob::ex_blob)::Cint
end

function ex_get_blob(exoid, blob)
    @ccall libexodus.ex_get_blob(exoid::Cint, blob::Ptr{ex_blob})::Cint
end

function ex_put_blobs(exoid, count, blobs)
    @ccall libexodus.ex_put_blobs(exoid::Cint, count::Csize_t, blobs::Ptr{ex_blob})::Cint
end

function ex_get_blobs(exoid, blobs)
    @ccall libexodus.ex_get_blobs(exoid::Cint, blobs::Ptr{ex_blob})::Cint
end

function ex_put_multi_field_metadata(exoid, field, field_count)
    @ccall libexodus.ex_put_multi_field_metadata(exoid::Cint, field::Ptr{ex_field}, field_count::Cint)::Cint
end

function ex_put_field_metadata(exoid, field)
    @ccall libexodus.ex_put_field_metadata(exoid::Cint, field::ex_field)::Cint
end

function ex_put_field_suffices(exoid, field, suffices)
    @ccall libexodus.ex_put_field_suffices(exoid::Cint, field::ex_field, suffices::Cstring)::Cint
end

function ex_get_field_metadata(exoid, field)
    @ccall libexodus.ex_get_field_metadata(exoid::Cint, field::Ptr{ex_field})::Cint
end

function ex_get_field_metadata_count(exoid, obj_type, id)
    @ccall libexodus.ex_get_field_metadata_count(exoid::Cint, obj_type::ex_entity_type, id::ex_entity_id)::Cint
end

function ex_get_field_suffices(exoid, field, suffices)
    @ccall libexodus.ex_get_field_suffices(exoid::Cint, field::ex_field, suffices::Cstring)::Cint
end

function ex_get_basis_count(exoid)
    @ccall libexodus.ex_get_basis_count(exoid::Cint)::Cint
end

function ex_get_basis(exoid, pbasis, num_basis)
    @ccall libexodus.ex_get_basis(exoid::Cint, pbasis::Ptr{Ptr{ex_basis}}, num_basis::Ptr{Cint})::Cint
end

function ex_put_basis(exoid, basis)
    @ccall libexodus.ex_put_basis(exoid::Cint, basis::ex_basis)::Cint
end

function ex_get_quadrature_count(exoid)
    @ccall libexodus.ex_get_quadrature_count(exoid::Cint)::Cint
end

function ex_get_quadrature(exoid, pquad, num_quad)
    @ccall libexodus.ex_get_quadrature(exoid::Cint, pquad::Ptr{Ptr{ex_quadrature}}, num_quad::Ptr{Cint})::Cint
end

function ex_put_quadrature(exoid, quad)
    @ccall libexodus.ex_put_quadrature(exoid::Cint, quad::ex_quadrature)::Cint
end

function ex_put_attribute(exoid, attributes)
    @ccall libexodus.ex_put_attribute(exoid::Cint, attributes::ex_attribute)::Cint
end

function ex_put_attributes(exoid, attr_count, attributes)
    @ccall libexodus.ex_put_attributes(exoid::Cint, attr_count::Csize_t, attributes::Ptr{ex_attribute})::Cint
end

function ex_put_double_attribute(exoid, obj_type, id, atr_name, num_values, values)
    @ccall libexodus.ex_put_double_attribute(exoid::Cint, obj_type::ex_entity_type, id::ex_entity_id, atr_name::Cstring, num_values::Cint, values::Ptr{Cdouble})::Cint
end

function ex_put_integer_attribute(exoid, obj_type, id, atr_name, num_values, values)
    @ccall libexodus.ex_put_integer_attribute(exoid::Cint, obj_type::ex_entity_type, id::ex_entity_id, atr_name::Cstring, num_values::Cint, values::Ptr{void_int})::Cint
end

function ex_put_text_attribute(exoid, obj_type, id, atr_name, value)
    @ccall libexodus.ex_put_text_attribute(exoid::Cint, obj_type::ex_entity_type, id::ex_entity_id, atr_name::Cstring, value::Cstring)::Cint
end

function ex_get_attribute(exoid, attributes)
    @ccall libexodus.ex_get_attribute(exoid::Cint, attributes::Ptr{ex_attribute})::Cint
end

function ex_get_attributes(exoid, count, attributes)
    @ccall libexodus.ex_get_attributes(exoid::Cint, count::Csize_t, attributes::Ptr{ex_attribute})::Cint
end

function ex_get_attribute_count(exoid, obj_type, id)
    @ccall libexodus.ex_get_attribute_count(exoid::Cint, obj_type::ex_entity_type, id::ex_entity_id)::Cint
end

function ex_get_attribute_param(exoid, obj_type, id, attributes)
    @ccall libexodus.ex_get_attribute_param(exoid::Cint, obj_type::ex_entity_type, id::ex_entity_id, attributes::Ptr{ex_attribute})::Cint
end

function ex_put_set_param(exoid, set_type, set_id, num_entries_in_set, num_dist_fact_in_set)
    @ccall libexodus.ex_put_set_param(exoid::Cint, set_type::ex_entity_type, set_id::ex_entity_id, num_entries_in_set::Int64, num_dist_fact_in_set::Int64)::Cint
end

function ex_get_set_param(exoid, set_type, set_id, num_entry_in_set, num_dist_fact_in_set)
    @ccall libexodus.ex_get_set_param(exoid::Cint, set_type::ex_entity_type, set_id::ex_entity_id, num_entry_in_set::Ptr{void_int}, num_dist_fact_in_set::Ptr{void_int})::Cint
end

function ex_put_set(exoid, set_type, set_id, set_entry_list, set_extra_list)
    @ccall libexodus.ex_put_set(exoid::Cint, set_type::ex_entity_type, set_id::ex_entity_id, set_entry_list::Ptr{void_int}, set_extra_list::Ptr{void_int})::Cint
end

function ex_get_partial_set(exoid, set_type, set_id, offset, num_to_get, set_entry_list, set_extra_list)
    @ccall libexodus.ex_get_partial_set(exoid::Cint, set_type::ex_entity_type, set_id::ex_entity_id, offset::Int64, num_to_get::Int64, set_entry_list::Ptr{void_int}, set_extra_list::Ptr{void_int})::Cint
end

function ex_put_partial_set(exoid, set_type, set_id, offset, num_to_put, set_entry_list, set_extra_list)
    @ccall libexodus.ex_put_partial_set(exoid::Cint, set_type::ex_entity_type, set_id::ex_entity_id, offset::Int64, num_to_put::Int64, set_entry_list::Ptr{void_int}, set_extra_list::Ptr{void_int})::Cint
end

function ex_get_set(exoid, set_type, set_id, set_entry_list, set_extra_list)
    @ccall libexodus.ex_get_set(exoid::Cint, set_type::ex_entity_type, set_id::ex_entity_id, set_entry_list::Ptr{void_int}, set_extra_list::Ptr{void_int})::Cint
end

function ex_put_set_dist_fact(exoid, set_type, set_id, set_dist_fact)
    @ccall libexodus.ex_put_set_dist_fact(exoid::Cint, set_type::ex_entity_type, set_id::ex_entity_id, set_dist_fact::Ptr{Cvoid})::Cint
end

function ex_get_set_dist_fact(exoid, set_type, set_id, set_dist_fact)
    @ccall libexodus.ex_get_set_dist_fact(exoid::Cint, set_type::ex_entity_type, set_id::ex_entity_id, set_dist_fact::Ptr{Cvoid})::Cint
end

function ex_get_partial_set_dist_fact(exoid, set_type, set_id, offset, num_to_put, set_dist_fact)
    @ccall libexodus.ex_get_partial_set_dist_fact(exoid::Cint, set_type::ex_entity_type, set_id::ex_entity_id, offset::Int64, num_to_put::Int64, set_dist_fact::Ptr{Cvoid})::Cint
end

function ex_put_concat_sets(exoid, set_type, set_specs)
    @ccall libexodus.ex_put_concat_sets(exoid::Cint, set_type::ex_entity_type, set_specs::Ptr{ex_set_specs})::Cint
end

function ex_get_concat_sets(exoid, set_type, set_specs)
    @ccall libexodus.ex_get_concat_sets(exoid::Cint, set_type::ex_entity_type, set_specs::Ptr{ex_set_specs})::Cint
end

function ex_put_sets(exoid, set_count, sets)
    @ccall libexodus.ex_put_sets(exoid::Cint, set_count::Csize_t, sets::Ptr{ex_set})::Cint
end

function ex_get_sets(exoid, set_count, sets)
    @ccall libexodus.ex_get_sets(exoid::Cint, set_count::Csize_t, sets::Ptr{ex_set})::Cint
end

function ex_put_partial_num_map(exoid, map_type, map_id, ent_start, ent_count, map)
    @ccall libexodus.ex_put_partial_num_map(exoid::Cint, map_type::ex_entity_type, map_id::ex_entity_id, ent_start::Int64, ent_count::Int64, map::Ptr{void_int})::Cint
end

function ex_put_partial_set_dist_fact(exoid, set_type, set_id, offset, num_to_put, set_dist_fact)
    @ccall libexodus.ex_put_partial_set_dist_fact(exoid::Cint, set_type::ex_entity_type, set_id::ex_entity_id, offset::Int64, num_to_put::Int64, set_dist_fact::Ptr{Cvoid})::Cint
end

function ex_get_concat_side_set_node_count(exoid, side_set_node_cnt_list)
    @ccall libexodus.ex_get_concat_side_set_node_count(exoid::Cint, side_set_node_cnt_list::Ptr{Cint})::Cint
end

function ex_get_side_set_node_list_len(exoid, side_set_id, side_set_node_list_len)
    @ccall libexodus.ex_get_side_set_node_list_len(exoid::Cint, side_set_id::ex_entity_id, side_set_node_list_len::Ptr{void_int})::Cint
end

function ex_get_side_set_node_count(exoid, side_set_id, side_set_node_cnt_list)
    @ccall libexodus.ex_get_side_set_node_count(exoid::Cint, side_set_id::ex_entity_id, side_set_node_cnt_list::Ptr{Cint})::Cint
end

function ex_get_side_set_node_list(exoid, side_set_id, side_set_node_cnt_list, side_set_node_list)
    @ccall libexodus.ex_get_side_set_node_list(exoid::Cint, side_set_id::ex_entity_id, side_set_node_cnt_list::Ptr{void_int}, side_set_node_list::Ptr{void_int})::Cint
end

function ex_get_ns_param_global(exoid, global_ids, node_cnts, df_cnts)
    @ccall libexodus.ex_get_ns_param_global(exoid::Cint, global_ids::Ptr{void_int}, node_cnts::Ptr{void_int}, df_cnts::Ptr{void_int})::Cint
end

function ex_put_ns_param_global(exoid, global_ids, node_cnts, df_cnts)
    @ccall libexodus.ex_put_ns_param_global(exoid::Cint, global_ids::Ptr{void_int}, node_cnts::Ptr{void_int}, df_cnts::Ptr{void_int})::Cint
end

function ex_get_ss_param_global(exoid, global_ids, side_cnts, df_cnts)
    @ccall libexodus.ex_get_ss_param_global(exoid::Cint, global_ids::Ptr{void_int}, side_cnts::Ptr{void_int}, df_cnts::Ptr{void_int})::Cint
end

function ex_put_ss_param_global(exoid, global_ids, side_cnts, df_cnts)
    @ccall libexodus.ex_put_ss_param_global(exoid::Cint, global_ids::Ptr{void_int}, side_cnts::Ptr{void_int}, df_cnts::Ptr{void_int})::Cint
end

function ex_get_eb_info_global(exoid, el_blk_ids, el_blk_cnts)
    @ccall libexodus.ex_get_eb_info_global(exoid::Cint, el_blk_ids::Ptr{void_int}, el_blk_cnts::Ptr{void_int})::Cint
end

function ex_put_eb_info_global(exoid, el_blk_ids, el_blk_cnts)
    @ccall libexodus.ex_put_eb_info_global(exoid::Cint, el_blk_ids::Ptr{void_int}, el_blk_cnts::Ptr{void_int})::Cint
end

function ex_get_elem_type(exoid, elem_blk_id, elem_type)
    @ccall libexodus.ex_get_elem_type(exoid::Cint, elem_blk_id::ex_entity_id, elem_type::Cstring)::Cint
end

function ex_get_processor_node_maps(exoid, node_mapi, node_mapb, node_mape, processor)
    @ccall libexodus.ex_get_processor_node_maps(exoid::Cint, node_mapi::Ptr{void_int}, node_mapb::Ptr{void_int}, node_mape::Ptr{void_int}, processor::Cint)::Cint
end

function ex_put_processor_node_maps(exoid, node_mapi, node_mapb, node_mape, proc_id)
    @ccall libexodus.ex_put_processor_node_maps(exoid::Cint, node_mapi::Ptr{void_int}, node_mapb::Ptr{void_int}, node_mape::Ptr{void_int}, proc_id::Cint)::Cint
end

function ex_get_processor_elem_maps(exoid, elem_mapi, elem_mapb, processor)
    @ccall libexodus.ex_get_processor_elem_maps(exoid::Cint, elem_mapi::Ptr{void_int}, elem_mapb::Ptr{void_int}, processor::Cint)::Cint
end

function ex_put_processor_elem_maps(exoid, elem_mapi, elem_mapb, processor)
    @ccall libexodus.ex_put_processor_elem_maps(exoid::Cint, elem_mapi::Ptr{void_int}, elem_mapb::Ptr{void_int}, processor::Cint)::Cint
end

function ex_get_cmap_params(exoid, node_cmap_ids, node_cmap_node_cnts, elem_cmap_ids, elem_cmap_elem_cnts, processor)
    @ccall libexodus.ex_get_cmap_params(exoid::Cint, node_cmap_ids::Ptr{void_int}, node_cmap_node_cnts::Ptr{void_int}, elem_cmap_ids::Ptr{void_int}, elem_cmap_elem_cnts::Ptr{void_int}, processor::Cint)::Cint
end

function ex_put_cmap_params(exoid, node_cmap_ids, node_cmap_node_cnts, elem_cmap_ids, elem_cmap_elem_cnts, processor)
    @ccall libexodus.ex_put_cmap_params(exoid::Cint, node_cmap_ids::Ptr{void_int}, node_cmap_node_cnts::Ptr{void_int}, elem_cmap_ids::Ptr{void_int}, elem_cmap_elem_cnts::Ptr{void_int}, processor::Int64)::Cint
end

function ex_put_cmap_params_cc(exoid, node_cmap_ids, node_cmap_node_cnts, node_proc_ptrs, elem_cmap_ids, elem_cmap_elem_cnts, elem_proc_ptrs)
    @ccall libexodus.ex_put_cmap_params_cc(exoid::Cint, node_cmap_ids::Ptr{void_int}, node_cmap_node_cnts::Ptr{void_int}, node_proc_ptrs::Ptr{void_int}, elem_cmap_ids::Ptr{void_int}, elem_cmap_elem_cnts::Ptr{void_int}, elem_proc_ptrs::Ptr{void_int})::Cint
end

function ex_get_node_cmap(exoid, map_id, node_ids, proc_ids, processor)
    @ccall libexodus.ex_get_node_cmap(exoid::Cint, map_id::ex_entity_id, node_ids::Ptr{void_int}, proc_ids::Ptr{void_int}, processor::Cint)::Cint
end

function ex_put_node_cmap(exoid, map_id, node_ids, proc_ids, processor)
    @ccall libexodus.ex_put_node_cmap(exoid::Cint, map_id::ex_entity_id, node_ids::Ptr{void_int}, proc_ids::Ptr{void_int}, processor::Cint)::Cint
end

function ex_put_partial_node_cmap(exoid, map_id, start_entity_num, num_entities, node_ids, proc_ids, processor)
    @ccall libexodus.ex_put_partial_node_cmap(exoid::Cint, map_id::ex_entity_id, start_entity_num::Int64, num_entities::Int64, node_ids::Ptr{void_int}, proc_ids::Ptr{void_int}, processor::Cint)::Cint
end

function ex_get_elem_cmap(exoid, map_id, elem_ids, side_ids, proc_ids, processor)
    @ccall libexodus.ex_get_elem_cmap(exoid::Cint, map_id::ex_entity_id, elem_ids::Ptr{void_int}, side_ids::Ptr{void_int}, proc_ids::Ptr{void_int}, processor::Cint)::Cint
end

function ex_put_elem_cmap(exoid, map_id, elem_ids, side_ids, proc_ids, processor)
    @ccall libexodus.ex_put_elem_cmap(exoid::Cint, map_id::ex_entity_id, elem_ids::Ptr{void_int}, side_ids::Ptr{void_int}, proc_ids::Ptr{void_int}, processor::Cint)::Cint
end

function ex_initialize_basis_struct(basis, num_basis, mode)
    @ccall libexodus.ex_initialize_basis_struct(basis::Ptr{ex_basis}, num_basis::Csize_t, mode::Cint)::Cint
end

function ex_initialize_quadrature_struct(quad, num_quad, mode)
    @ccall libexodus.ex_initialize_quadrature_struct(quad::Ptr{ex_quadrature}, num_quad::Csize_t, mode::Cint)::Cint
end

function ex_component_field_name(field, component)
    @ccall libexodus.ex_component_field_name(field::Ptr{ex_field}, component::Ptr{Cint})::Cstring
end

function ex_field_component_suffix(field, nest_level, component)
    @ccall libexodus.ex_field_component_suffix(field::Ptr{ex_field}, nest_level::Cint, component::Cint)::Cstring
end

function ex_field_cardinality(field_type)
    @ccall libexodus.ex_field_cardinality(field_type::ex_field_type)::Cint
end

function ex_field_type_name(field_type)
    @ccall libexodus.ex_field_type_name(field_type::ex_field_type)::Cstring
end

function ex_string_to_field_type_enum(field_name)
    @ccall libexodus.ex_string_to_field_type_enum(field_name::Cstring)::ex_field_type
end

function ex_field_type_enum_to_string(field_type)
    @ccall libexodus.ex_field_type_enum_to_string(field_type::ex_field_type)::Cstring
end

function ex_get_glob_vars(exoid, time_step, num_glob_vars, glob_var_vals)
    @ccall libexodus.ex_get_glob_vars(exoid::Cint, time_step::Cint, num_glob_vars::Cint, glob_var_vals::Ptr{Cvoid})::Cint
end

function ex_get_glob_var_time(exoid, glob_var_index, beg_time_step, end_time_step, glob_var_vals)
    @ccall libexodus.ex_get_glob_var_time(exoid::Cint, glob_var_index::Cint, beg_time_step::Cint, end_time_step::Cint, glob_var_vals::Ptr{Cvoid})::Cint
end

function ex_get_concat_node_sets(exoid, node_set_ids, num_nodes_per_set, num_df_per_set, node_sets_node_index, node_sets_df_index, node_sets_node_list, node_sets_dist_fact)
    @ccall libexodus.ex_get_concat_node_sets(exoid::Cint, node_set_ids::Ptr{void_int}, num_nodes_per_set::Ptr{void_int}, num_df_per_set::Ptr{void_int}, node_sets_node_index::Ptr{void_int}, node_sets_df_index::Ptr{void_int}, node_sets_node_list::Ptr{void_int}, node_sets_dist_fact::Ptr{Cvoid})::Cint
end

function ex_get_concat_side_sets(exoid, side_set_ids, num_elem_per_set, num_dist_per_set, side_sets_elem_index, side_sets_dist_index, side_sets_elem_list, side_sets_side_list, side_sets_dist_fact)
    @ccall libexodus.ex_get_concat_side_sets(exoid::Cint, side_set_ids::Ptr{void_int}, num_elem_per_set::Ptr{void_int}, num_dist_per_set::Ptr{void_int}, side_sets_elem_index::Ptr{void_int}, side_sets_dist_index::Ptr{void_int}, side_sets_elem_list::Ptr{void_int}, side_sets_side_list::Ptr{void_int}, side_sets_dist_fact::Ptr{Cvoid})::Cint
end

function ex_get_elem_attr(exoid, elem_blk_id, attrib)
    @ccall libexodus.ex_get_elem_attr(exoid::Cint, elem_blk_id::ex_entity_id, attrib::Ptr{Cvoid})::Cint
end

function ex_get_elem_attr_names(exoid, elem_blk_id, names)
    @ccall libexodus.ex_get_elem_attr_names(exoid::Cint, elem_blk_id::ex_entity_id, names::Ptr{Cstring})::Cint
end

function ex_get_elem_blk_ids(exoid, ids)
    @ccall libexodus.ex_get_elem_blk_ids(exoid::Cint, ids::Ptr{void_int})::Cint
end

function ex_get_elem_block(exoid, elem_blk_id, elem_type, num_elem_this_blk, num_nodes_per_elem, num_attr)
    @ccall libexodus.ex_get_elem_block(exoid::Cint, elem_blk_id::ex_entity_id, elem_type::Cstring, num_elem_this_blk::Ptr{void_int}, num_nodes_per_elem::Ptr{void_int}, num_attr::Ptr{void_int})::Cint
end

function ex_get_elem_conn(exoid, elem_blk_id, connect)
    @ccall libexodus.ex_get_elem_conn(exoid::Cint, elem_blk_id::ex_entity_id, connect::Ptr{void_int})::Cint
end

function ex_get_elem_map(exoid, map_id, elem_map)
    @ccall libexodus.ex_get_elem_map(exoid::Cint, map_id::ex_entity_id, elem_map::Ptr{void_int})::Cint
end

function ex_get_elem_num_map(exoid, elem_map)
    @ccall libexodus.ex_get_elem_num_map(exoid::Cint, elem_map::Ptr{void_int})::Cint
end

function ex_get_nodal_var(exoid, time_step, nodal_var_index, num_nodes, nodal_var_vals)
    @ccall libexodus.ex_get_nodal_var(exoid::Cint, time_step::Cint, nodal_var_index::Cint, num_nodes::Int64, nodal_var_vals::Ptr{Cvoid})::Cint
end

function ex_put_nodal_var(exoid, time_step, nodal_var_index, num_nodes, nodal_var_vals)
    @ccall libexodus.ex_put_nodal_var(exoid::Cint, time_step::Cint, nodal_var_index::Cint, num_nodes::Int64, nodal_var_vals::Ptr{Cvoid})::Cint
end

function ex_get_nodal_var_time(exoid, nodal_var_index, node_number, beg_time_step, end_time_step, nodal_var_vals)
    @ccall libexodus.ex_get_nodal_var_time(exoid::Cint, nodal_var_index::Cint, node_number::Int64, beg_time_step::Cint, end_time_step::Cint, nodal_var_vals::Ptr{Cvoid})::Cint
end

function ex_put_partial_nodal_var(exoid, time_step, nodal_var_index, start_node, num_nodes, nodal_var_vals)
    @ccall libexodus.ex_put_partial_nodal_var(exoid::Cint, time_step::Cint, nodal_var_index::Cint, start_node::Int64, num_nodes::Int64, nodal_var_vals::Ptr{Cvoid})::Cint
end

function ex_get_partial_nodal_var(exoid, time_step, nodal_var_index, start_node, num_nodes, var_vals)
    @ccall libexodus.ex_get_partial_nodal_var(exoid::Cint, time_step::Cint, nodal_var_index::Cint, start_node::Int64, num_nodes::Int64, var_vals::Ptr{Cvoid})::Cint
end

function ex_get_elem_var(exoid, time_step, elem_var_index, elem_blk_id, num_elem_this_blk, elem_var_vals)
    @ccall libexodus.ex_get_elem_var(exoid::Cint, time_step::Cint, elem_var_index::Cint, elem_blk_id::ex_entity_id, num_elem_this_blk::Int64, elem_var_vals::Ptr{Cvoid})::Cint
end

function ex_get_elem_var_tab(exoid, num_elem_blk, num_elem_var, elem_var_tab)
    @ccall libexodus.ex_get_elem_var_tab(exoid::Cint, num_elem_blk::Cint, num_elem_var::Cint, elem_var_tab::Ptr{Cint})::Cint
end

function ex_get_elem_var_time(exoid, elem_var_index, elem_number, beg_time_step, end_time_step, elem_var_vals)
    @ccall libexodus.ex_get_elem_var_time(exoid::Cint, elem_var_index::Cint, elem_number::Int64, beg_time_step::Cint, end_time_step::Cint, elem_var_vals::Ptr{Cvoid})::Cint
end

function ex_get_node_map(exoid, map_id, node_map)
    @ccall libexodus.ex_get_node_map(exoid::Cint, map_id::ex_entity_id, node_map::Ptr{void_int})::Cint
end

function ex_get_node_num_map(exoid, node_map)
    @ccall libexodus.ex_get_node_num_map(exoid::Cint, node_map::Ptr{void_int})::Cint
end

function ex_get_node_set_param(exoid, node_set_id, num_nodes_in_set, num_df_in_set)
    @ccall libexodus.ex_get_node_set_param(exoid::Cint, node_set_id::ex_entity_id, num_nodes_in_set::Ptr{void_int}, num_df_in_set::Ptr{void_int})::Cint
end

function ex_get_node_set(exoid, node_set_id, node_set_node_list)
    @ccall libexodus.ex_get_node_set(exoid::Cint, node_set_id::ex_entity_id, node_set_node_list::Ptr{void_int})::Cint
end

function ex_get_node_set_dist_fact(exoid, node_set_id, node_set_dist_fact)
    @ccall libexodus.ex_get_node_set_dist_fact(exoid::Cint, node_set_id::ex_entity_id, node_set_dist_fact::Ptr{Cvoid})::Cint
end

function ex_get_node_set_ids(exoid, ids)
    @ccall libexodus.ex_get_node_set_ids(exoid::Cint, ids::Ptr{void_int})::Cint
end

function ex_get_nset_var_tab(exoid, num_nodesets, num_nset_var, nset_var_tab)
    @ccall libexodus.ex_get_nset_var_tab(exoid::Cint, num_nodesets::Cint, num_nset_var::Cint, nset_var_tab::Ptr{Cint})::Cint
end

function ex_get_nset_var(exoid, time_step, nset_var_index, nset_id, num_node_this_nset, nset_var_vals)
    @ccall libexodus.ex_get_nset_var(exoid::Cint, time_step::Cint, nset_var_index::Cint, nset_id::ex_entity_id, num_node_this_nset::Int64, nset_var_vals::Ptr{Cvoid})::Cint
end

function ex_get_one_elem_attr(exoid, elem_blk_id, attrib_index, attrib)
    @ccall libexodus.ex_get_one_elem_attr(exoid::Cint, elem_blk_id::ex_entity_id, attrib_index::Cint, attrib::Ptr{Cvoid})::Cint
end

function ex_get_side_set(exoid, side_set_id, side_set_elem_list, side_set_side_list)
    @ccall libexodus.ex_get_side_set(exoid::Cint, side_set_id::ex_entity_id, side_set_elem_list::Ptr{void_int}, side_set_side_list::Ptr{void_int})::Cint
end

function ex_get_side_set_dist_fact(exoid, side_set_id, side_set_dist_fact)
    @ccall libexodus.ex_get_side_set_dist_fact(exoid::Cint, side_set_id::ex_entity_id, side_set_dist_fact::Ptr{Cvoid})::Cint
end

function ex_get_side_set_ids(exoid, ids)
    @ccall libexodus.ex_get_side_set_ids(exoid::Cint, ids::Ptr{void_int})::Cint
end

function ex_get_side_set_param(exoid, side_set_id, num_side_in_set, num_dist_fact_in_set)
    @ccall libexodus.ex_get_side_set_param(exoid::Cint, side_set_id::ex_entity_id, num_side_in_set::Ptr{void_int}, num_dist_fact_in_set::Ptr{void_int})::Cint
end

function ex_get_sset_var(exoid, time_step, sset_var_index, sset_id, num_side_this_sset, sset_var_vals)
    @ccall libexodus.ex_get_sset_var(exoid::Cint, time_step::Cint, sset_var_index::Cint, sset_id::ex_entity_id, num_side_this_sset::Int64, sset_var_vals::Ptr{Cvoid})::Cint
end

function ex_get_sset_var_tab(exoid, num_sidesets, num_sset_var, sset_var_tab)
    @ccall libexodus.ex_get_sset_var_tab(exoid::Cint, num_sidesets::Cint, num_sset_var::Cint, sset_var_tab::Ptr{Cint})::Cint
end

function ex_get_var_names(exoid, var_type, num_vars, var_names)
    @ccall libexodus.ex_get_var_names(exoid::Cint, var_type::Cstring, num_vars::Cint, var_names::Ptr{Cstring})::Cint
end

function ex_get_var_name(exoid, var_type, var_num, var_name)
    @ccall libexodus.ex_get_var_name(exoid::Cint, var_type::Cstring, var_num::Cint, var_name::Cstring)::Cint
end

function ex_get_var_param(exoid, var_type, num_vars)
    @ccall libexodus.ex_get_var_param(exoid::Cint, var_type::Cstring, num_vars::Ptr{Cint})::Cint
end

function ex_get_var_tab(exoid, var_type, num_blk, num_var, var_tab)
    @ccall libexodus.ex_get_var_tab(exoid::Cint, var_type::Cstring, num_blk::Cint, num_var::Cint, var_tab::Ptr{Cint})::Cint
end

function ex_put_concat_node_sets(exoid, node_set_ids, num_nodes_per_set, num_dist_per_set, node_sets_node_index, node_sets_df_index, node_sets_node_list, node_sets_dist_fact)
    @ccall libexodus.ex_put_concat_node_sets(exoid::Cint, node_set_ids::Ptr{void_int}, num_nodes_per_set::Ptr{void_int}, num_dist_per_set::Ptr{void_int}, node_sets_node_index::Ptr{void_int}, node_sets_df_index::Ptr{void_int}, node_sets_node_list::Ptr{void_int}, node_sets_dist_fact::Ptr{Cvoid})::Cint
end

function ex_put_concat_side_sets(exoid, side_set_ids, num_elem_per_set, num_dist_per_set, side_sets_elem_index, side_sets_dist_index, side_sets_elem_list, side_sets_side_list, side_sets_dist_fact)
    @ccall libexodus.ex_put_concat_side_sets(exoid::Cint, side_set_ids::Ptr{void_int}, num_elem_per_set::Ptr{void_int}, num_dist_per_set::Ptr{void_int}, side_sets_elem_index::Ptr{void_int}, side_sets_dist_index::Ptr{void_int}, side_sets_elem_list::Ptr{void_int}, side_sets_side_list::Ptr{void_int}, side_sets_dist_fact::Ptr{Cvoid})::Cint
end

function ex_put_concat_var_param(exoid, num_g, num_n, num_e, num_elem_blk, elem_var_tab)
    @ccall libexodus.ex_put_concat_var_param(exoid::Cint, num_g::Cint, num_n::Cint, num_e::Cint, num_elem_blk::Cint, elem_var_tab::Ptr{Cint})::Cint
end

function ex_put_elem_attr_names(exoid, elem_blk_id, names)
    @ccall libexodus.ex_put_elem_attr_names(exoid::Cint, elem_blk_id::ex_entity_id, names::Ptr{Cstring})::Cint
end

function ex_put_elem_attr(exoid, elem_blk_id, attrib)
    @ccall libexodus.ex_put_elem_attr(exoid::Cint, elem_blk_id::ex_entity_id, attrib::Ptr{Cvoid})::Cint
end

function ex_put_elem_block(exoid, elem_blk_id, elem_type, num_elem_this_blk, num_nodes_per_elem, num_attr_per_elem)
    @ccall libexodus.ex_put_elem_block(exoid::Cint, elem_blk_id::ex_entity_id, elem_type::Cstring, num_elem_this_blk::Int64, num_nodes_per_elem::Int64, num_attr_per_elem::Int64)::Cint
end

function ex_put_elem_conn(exoid, elem_blk_id, connect)
    @ccall libexodus.ex_put_elem_conn(exoid::Cint, elem_blk_id::ex_entity_id, connect::Ptr{void_int})::Cint
end

function ex_put_elem_map(exoid, map_id, elem_map)
    @ccall libexodus.ex_put_elem_map(exoid::Cint, map_id::ex_entity_id, elem_map::Ptr{void_int})::Cint
end

function ex_put_elem_num_map(exoid, elem_map)
    @ccall libexodus.ex_put_elem_num_map(exoid::Cint, elem_map::Ptr{void_int})::Cint
end

function ex_put_elem_var(exoid, time_step, elem_var_index, elem_blk_id, num_elem_this_blk, elem_var_vals)
    @ccall libexodus.ex_put_elem_var(exoid::Cint, time_step::Cint, elem_var_index::Cint, elem_blk_id::ex_entity_id, num_elem_this_blk::Int64, elem_var_vals::Ptr{Cvoid})::Cint
end

function ex_put_elem_var_tab(exoid, num_elem_blk, num_elem_var, elem_var_tab)
    @ccall libexodus.ex_put_elem_var_tab(exoid::Cint, num_elem_blk::Cint, num_elem_var::Cint, elem_var_tab::Ptr{Cint})::Cint
end

function ex_put_glob_vars(exoid, time_step, num_glob_vars, glob_var_vals)
    @ccall libexodus.ex_put_glob_vars(exoid::Cint, time_step::Cint, num_glob_vars::Cint, glob_var_vals::Ptr{Cvoid})::Cint
end

function ex_put_node_map(exoid, map_id, node_map)
    @ccall libexodus.ex_put_node_map(exoid::Cint, map_id::ex_entity_id, node_map::Ptr{void_int})::Cint
end

function ex_put_node_num_map(exoid, node_map)
    @ccall libexodus.ex_put_node_num_map(exoid::Cint, node_map::Ptr{void_int})::Cint
end

function ex_put_node_set(exoid, node_set_id, node_set_node_list)
    @ccall libexodus.ex_put_node_set(exoid::Cint, node_set_id::ex_entity_id, node_set_node_list::Ptr{void_int})::Cint
end

function ex_put_node_set_dist_fact(exoid, node_set_id, node_set_dist_fact)
    @ccall libexodus.ex_put_node_set_dist_fact(exoid::Cint, node_set_id::ex_entity_id, node_set_dist_fact::Ptr{Cvoid})::Cint
end

function ex_put_node_set_param(exoid, node_set_id, num_nodes_in_set, num_dist_in_set)
    @ccall libexodus.ex_put_node_set_param(exoid::Cint, node_set_id::ex_entity_id, num_nodes_in_set::Int64, num_dist_in_set::Int64)::Cint
end

function ex_put_nset_var(exoid, time_step, nset_var_index, nset_id, num_nodes_this_nset, nset_var_vals)
    @ccall libexodus.ex_put_nset_var(exoid::Cint, time_step::Cint, nset_var_index::Cint, nset_id::ex_entity_id, num_nodes_this_nset::Int64, nset_var_vals::Ptr{Cvoid})::Cint
end

function ex_put_nset_var_tab(exoid, num_nset, num_nset_var, nset_var_tab)
    @ccall libexodus.ex_put_nset_var_tab(exoid::Cint, num_nset::Cint, num_nset_var::Cint, nset_var_tab::Ptr{Cint})::Cint
end

function ex_put_one_elem_attr(exoid, elem_blk_id, attrib_index, attrib)
    @ccall libexodus.ex_put_one_elem_attr(exoid::Cint, elem_blk_id::ex_entity_id, attrib_index::Cint, attrib::Ptr{Cvoid})::Cint
end

function ex_put_side_set(exoid, side_set_id, side_set_elem_list, side_set_side_list)
    @ccall libexodus.ex_put_side_set(exoid::Cint, side_set_id::ex_entity_id, side_set_elem_list::Ptr{void_int}, side_set_side_list::Ptr{void_int})::Cint
end

function ex_put_side_set_dist_fact(exoid, side_set_id, side_set_dist_fact)
    @ccall libexodus.ex_put_side_set_dist_fact(exoid::Cint, side_set_id::ex_entity_id, side_set_dist_fact::Ptr{Cvoid})::Cint
end

function ex_put_side_set_param(exoid, side_set_id, num_side_in_set, num_dist_fact_in_set)
    @ccall libexodus.ex_put_side_set_param(exoid::Cint, side_set_id::ex_entity_id, num_side_in_set::Int64, num_dist_fact_in_set::Int64)::Cint
end

function ex_put_sset_var(exoid, time_step, sset_var_index, sset_id, num_faces_this_sset, sset_var_vals)
    @ccall libexodus.ex_put_sset_var(exoid::Cint, time_step::Cint, sset_var_index::Cint, sset_id::ex_entity_id, num_faces_this_sset::Int64, sset_var_vals::Ptr{Cvoid})::Cint
end

function ex_put_sset_var_tab(exoid, num_sset, num_sset_var, sset_var_tab)
    @ccall libexodus.ex_put_sset_var_tab(exoid::Cint, num_sset::Cint, num_sset_var::Cint, sset_var_tab::Ptr{Cint})::Cint
end

function ex_put_var_name(exoid, var_type, var_num, var_name)
    @ccall libexodus.ex_put_var_name(exoid::Cint, var_type::Cstring, var_num::Cint, var_name::Cstring)::Cint
end

function ex_put_var_names(exoid, var_type, num_vars, var_names)
    @ccall libexodus.ex_put_var_names(exoid::Cint, var_type::Cstring, num_vars::Cint, var_names::Ptr{Cstring})::Cint
end

function ex_put_var_param(exoid, var_type, num_vars)
    @ccall libexodus.ex_put_var_param(exoid::Cint, var_type::Cstring, num_vars::Cint)::Cint
end

function ex_put_var_tab(exoid, var_type, num_blk, num_var, var_tab)
    @ccall libexodus.ex_put_var_tab(exoid::Cint, var_type::Cstring, num_blk::Cint, num_var::Cint, var_tab::Ptr{Cint})::Cint
end

function ex_get_n_coord(exoid, start_node_num, num_nodes, x_coor, y_coor, z_coor)
    @ccall libexodus.ex_get_n_coord(exoid::Cint, start_node_num::Int64, num_nodes::Int64, x_coor::Ptr{Cvoid}, y_coor::Ptr{Cvoid}, z_coor::Ptr{Cvoid})::Cint
end

function ex_get_n_nodal_var(exoid, time_step, nodal_var_index, start_node, num_nodes, var_vals)
    @ccall libexodus.ex_get_n_nodal_var(exoid::Cint, time_step::Cint, nodal_var_index::Cint, start_node::Int64, num_nodes::Int64, var_vals::Ptr{Cvoid})::Cint
end

function ex_get_n_conn(exoid, blk_type, blk_id, start_num, num_ent, nodeconn, edgeconn, faceconn)
    @ccall libexodus.ex_get_n_conn(exoid::Cint, blk_type::ex_entity_type, blk_id::ex_entity_id, start_num::Int64, num_ent::Int64, nodeconn::Ptr{void_int}, edgeconn::Ptr{void_int}, faceconn::Ptr{void_int})::Cint
end

function ex_get_n_attr(exoid, obj_type, obj_id, start_num, num_ent, attrib)
    @ccall libexodus.ex_get_n_attr(exoid::Cint, obj_type::ex_entity_type, obj_id::ex_entity_id, start_num::Int64, num_ent::Int64, attrib::Ptr{Cvoid})::Cint
end

function ex_get_n_one_attr(exoid, obj_type, obj_id, start_num, num_ent, attrib_index, attrib)
    @ccall libexodus.ex_get_n_one_attr(exoid::Cint, obj_type::ex_entity_type, obj_id::ex_entity_id, start_num::Int64, num_ent::Int64, attrib_index::Cint, attrib::Ptr{Cvoid})::Cint
end

function ex_get_n_var(exoid, time_step, var_type, var_index, obj_id, start_index, num_entities, var_vals)
    @ccall libexodus.ex_get_n_var(exoid::Cint, time_step::Cint, var_type::ex_entity_type, var_index::Cint, obj_id::ex_entity_id, start_index::Int64, num_entities::Int64, var_vals::Ptr{Cvoid})::Cint
end

function ex_get_n_elem_var(exoid, time_step, elem_var_index, elem_blk_id, num_elem_this_blk, start_elem_num, num_elem, elem_var_vals)
    @ccall libexodus.ex_get_n_elem_var(exoid::Cint, time_step::Cint, elem_var_index::Cint, elem_blk_id::ex_entity_id, num_elem_this_blk::Int64, start_elem_num::Int64, num_elem::Int64, elem_var_vals::Ptr{Cvoid})::Cint
end

function ex_get_n_side_set(exoid, side_set_id, start_side_num, num_sides, side_set_elem_list, side_set_side_list)
    @ccall libexodus.ex_get_n_side_set(exoid::Cint, side_set_id::ex_entity_id, start_side_num::Int64, num_sides::Int64, side_set_elem_list::Ptr{void_int}, side_set_side_list::Ptr{void_int})::Cint
end

function ex_put_n_side_set(exoid, side_set_id, start_side_num, num_sides, side_set_elem_list, side_set_side_list)
    @ccall libexodus.ex_put_n_side_set(exoid::Cint, side_set_id::ex_entity_id, start_side_num::Int64, num_sides::Int64, side_set_elem_list::Ptr{void_int}, side_set_side_list::Ptr{void_int})::Cint
end

function ex_get_n_side_set_df(exoid, side_set_id, start_num, num_df_to_get, side_set_dist_fact)
    @ccall libexodus.ex_get_n_side_set_df(exoid::Cint, side_set_id::ex_entity_id, start_num::Int64, num_df_to_get::Int64, side_set_dist_fact::Ptr{Cvoid})::Cint
end

function ex_put_n_side_set_df(exoid, side_set_id, start_num, num_df_to_get, side_set_dist_fact)
    @ccall libexodus.ex_put_n_side_set_df(exoid::Cint, side_set_id::ex_entity_id, start_num::Int64, num_df_to_get::Int64, side_set_dist_fact::Ptr{Cvoid})::Cint
end

function ex_get_n_node_set(exoid, node_set_id, start_node_num, num_nodes, node_set_node_list)
    @ccall libexodus.ex_get_n_node_set(exoid::Cint, node_set_id::ex_entity_id, start_node_num::Int64, num_nodes::Int64, node_set_node_list::Ptr{void_int})::Cint
end

function ex_put_n_node_set(exoid, node_set_id, start_node_num, num_nodes, node_set_node_list)
    @ccall libexodus.ex_put_n_node_set(exoid::Cint, node_set_id::ex_entity_id, start_node_num::Int64, num_nodes::Int64, node_set_node_list::Ptr{void_int})::Cint
end

function ex_get_n_node_set_df(exoid, node_set_id, start_num, num_df_to_get, node_set_dist_fact)
    @ccall libexodus.ex_get_n_node_set_df(exoid::Cint, node_set_id::ex_entity_id, start_num::Int64, num_df_to_get::Int64, node_set_dist_fact::Ptr{Cvoid})::Cint
end

function ex_put_n_node_set_df(exoid, node_set_id, start_num, num_df_to_get, node_set_dist_fact)
    @ccall libexodus.ex_put_n_node_set_df(exoid::Cint, node_set_id::ex_entity_id, start_num::Int64, num_df_to_get::Int64, node_set_dist_fact::Ptr{Cvoid})::Cint
end

function ex_get_n_elem_conn(exoid, elem_blk_id, start_elem_num, num_elems, connect)
    @ccall libexodus.ex_get_n_elem_conn(exoid::Cint, elem_blk_id::ex_entity_id, start_elem_num::Int64, num_elems::Int64, connect::Ptr{void_int})::Cint
end

function ex_put_n_elem_conn(exoid, elem_blk_id, start_elem_num, num_elems, connect)
    @ccall libexodus.ex_put_n_elem_conn(exoid::Cint, elem_blk_id::ex_entity_id, start_elem_num::Int64, num_elems::Int64, connect::Ptr{void_int})::Cint
end

function ex_get_n_elem_attr(exoid, elem_blk_id, start_elem_num, num_elems, attrib)
    @ccall libexodus.ex_get_n_elem_attr(exoid::Cint, elem_blk_id::ex_entity_id, start_elem_num::Int64, num_elems::Int64, attrib::Ptr{Cvoid})::Cint
end

function ex_put_n_elem_attr(exoid, elem_blk_id, start_elem_num, num_elems, attrib)
    @ccall libexodus.ex_put_n_elem_attr(exoid::Cint, elem_blk_id::ex_entity_id, start_elem_num::Int64, num_elems::Int64, attrib::Ptr{Cvoid})::Cint
end

function ex_get_n_elem_num_map(exoid, start_ent, num_ents, elem_map)
    @ccall libexodus.ex_get_n_elem_num_map(exoid::Cint, start_ent::Int64, num_ents::Int64, elem_map::Ptr{void_int})::Cint
end

function ex_get_n_node_num_map(exoid, start_ent, num_ents, node_map)
    @ccall libexodus.ex_get_n_node_num_map(exoid::Cint, start_ent::Int64, num_ents::Int64, node_map::Ptr{void_int})::Cint
end

function ex_put_n_coord(exoid, start_node_num, num_nodes, x_coor, y_coor, z_coor)
    @ccall libexodus.ex_put_n_coord(exoid::Cint, start_node_num::Int64, num_nodes::Int64, x_coor::Ptr{Cvoid}, y_coor::Ptr{Cvoid}, z_coor::Ptr{Cvoid})::Cint
end

function ex_put_n_elem_num_map(exoid, start_ent, num_ents, elem_map)
    @ccall libexodus.ex_put_n_elem_num_map(exoid::Cint, start_ent::Int64, num_ents::Int64, elem_map::Ptr{void_int})::Cint
end

function ex_put_n_node_num_map(exoid, start_ent, num_ents, node_map)
    @ccall libexodus.ex_put_n_node_num_map(exoid::Cint, start_ent::Int64, num_ents::Int64, node_map::Ptr{void_int})::Cint
end

function ex_put_n_one_attr(exoid, obj_type, obj_id, start_num, num_ent, attrib_index, attrib)
    @ccall libexodus.ex_put_n_one_attr(exoid::Cint, obj_type::ex_entity_type, obj_id::ex_entity_id, start_num::Int64, num_ent::Int64, attrib_index::Cint, attrib::Ptr{Cvoid})::Cint
end

function ex_put_n_var(exoid, time_step, var_type, var_index, obj_id, start_index, num_entities, var_vals)
    @ccall libexodus.ex_put_n_var(exoid::Cint, time_step::Cint, var_type::ex_entity_type, var_index::Cint, obj_id::ex_entity_id, start_index::Int64, num_entities::Int64, var_vals::Ptr{Cvoid})::Cint
end

function ex_put_n_nodal_var(exoid, time_step, nodal_var_index, start_node, num_nodes, nodal_var_vals)
    @ccall libexodus.ex_put_n_nodal_var(exoid::Cint, time_step::Cint, nodal_var_index::Cint, start_node::Int64, num_nodes::Int64, nodal_var_vals::Ptr{Cvoid})::Cint
end

function ex_get_partial_elem_var(exoid, time_step, elem_var_index, elem_blk_id, num_elem_this_blk, start_elem_num, num_elem, elem_var_vals)
    @ccall libexodus.ex_get_partial_elem_var(exoid::Cint, time_step::Cint, elem_var_index::Cint, elem_blk_id::ex_entity_id, num_elem_this_blk::Int64, start_elem_num::Int64, num_elem::Int64, elem_var_vals::Ptr{Cvoid})::Cint
end

function ex_get_partial_elem_map(exoid, map_id, ent_start, ent_count, elem_map)
    @ccall libexodus.ex_get_partial_elem_map(exoid::Cint, map_id::ex_entity_id, ent_start::Int64, ent_count::Int64, elem_map::Ptr{void_int})::Cint
end

function ex_get_partial_elem_conn(exoid, elem_blk_id, start_elem_num, num_elems, connect)
    @ccall libexodus.ex_get_partial_elem_conn(exoid::Cint, elem_blk_id::ex_entity_id, start_elem_num::Int64, num_elems::Int64, connect::Ptr{void_int})::Cint
end

function ex_get_partial_elem_attr(exoid, elem_blk_id, start_elem_num, num_elems, attrib)
    @ccall libexodus.ex_get_partial_elem_attr(exoid::Cint, elem_blk_id::ex_entity_id, start_elem_num::Int64, num_elems::Int64, attrib::Ptr{Cvoid})::Cint
end

function ex_get_partial_elem_num_map(exoid, start_ent, num_ents, elem_map)
    @ccall libexodus.ex_get_partial_elem_num_map(exoid::Cint, start_ent::Int64, num_ents::Int64, elem_map::Ptr{void_int})::Cint
end

function ex_get_partial_node_num_map(exoid, start_ent, num_ents, node_map)
    @ccall libexodus.ex_get_partial_node_num_map(exoid::Cint, start_ent::Int64, num_ents::Int64, node_map::Ptr{void_int})::Cint
end

function ex_get_partial_node_set(exoid, node_set_id, start_node_num, num_nodes, node_set_node_list)
    @ccall libexodus.ex_get_partial_node_set(exoid::Cint, node_set_id::ex_entity_id, start_node_num::Int64, num_nodes::Int64, node_set_node_list::Ptr{void_int})::Cint
end

function ex_get_partial_node_set_df(exoid, node_set_id, start_num, num_df_to_get, node_set_dist_fact)
    @ccall libexodus.ex_get_partial_node_set_df(exoid::Cint, node_set_id::ex_entity_id, start_num::Int64, num_df_to_get::Int64, node_set_dist_fact::Ptr{Cvoid})::Cint
end

function ex_get_partial_side_set(exoid, side_set_id, start_side_num, num_sides, side_set_elem_list, side_set_side_list)
    @ccall libexodus.ex_get_partial_side_set(exoid::Cint, side_set_id::ex_entity_id, start_side_num::Int64, num_sides::Int64, side_set_elem_list::Ptr{void_int}, side_set_side_list::Ptr{void_int})::Cint
end

function ex_get_partial_side_set_df(exoid, side_set_id, start_num, num_df_to_get, side_set_dist_fact)
    @ccall libexodus.ex_get_partial_side_set_df(exoid::Cint, side_set_id::ex_entity_id, start_num::Int64, num_df_to_get::Int64, side_set_dist_fact::Ptr{Cvoid})::Cint
end

function ex_put_partial_node_num_map(exoid, start_ent, num_ents, node_map)
    @ccall libexodus.ex_put_partial_node_num_map(exoid::Cint, start_ent::Int64, num_ents::Int64, node_map::Ptr{void_int})::Cint
end

function ex_put_partial_elem_num_map(exoid, start_ent, num_ents, elem_map)
    @ccall libexodus.ex_put_partial_elem_num_map(exoid::Cint, start_ent::Int64, num_ents::Int64, elem_map::Ptr{void_int})::Cint
end

function ex_put_partial_elem_map(exoid, map_id, ent_start, ent_count, elem_map)
    @ccall libexodus.ex_put_partial_elem_map(exoid::Cint, map_id::ex_entity_id, ent_start::Int64, ent_count::Int64, elem_map::Ptr{void_int})::Cint
end

function ex_put_partial_side_set(exoid, side_set_id, start_side_num, num_sides, side_set_elem_list, side_set_side_list)
    @ccall libexodus.ex_put_partial_side_set(exoid::Cint, side_set_id::ex_entity_id, start_side_num::Int64, num_sides::Int64, side_set_elem_list::Ptr{void_int}, side_set_side_list::Ptr{void_int})::Cint
end

function ex_put_partial_side_set_df(exoid, side_set_id, start_num, num_df_to_get, side_set_dist_fact)
    @ccall libexodus.ex_put_partial_side_set_df(exoid::Cint, side_set_id::ex_entity_id, start_num::Int64, num_df_to_get::Int64, side_set_dist_fact::Ptr{Cvoid})::Cint
end

function ex_put_partial_node_set(exoid, node_set_id, start_node_num, num_nodes, node_set_node_list)
    @ccall libexodus.ex_put_partial_node_set(exoid::Cint, node_set_id::ex_entity_id, start_node_num::Int64, num_nodes::Int64, node_set_node_list::Ptr{void_int})::Cint
end

function ex_put_partial_node_set_df(exoid, node_set_id, start_num, num_df_to_get, node_set_dist_fact)
    @ccall libexodus.ex_put_partial_node_set_df(exoid::Cint, node_set_id::ex_entity_id, start_num::Int64, num_df_to_get::Int64, node_set_dist_fact::Ptr{Cvoid})::Cint
end

function ex_put_partial_elem_conn(exoid, elem_blk_id, start_elem_num, num_elems, connect)
    @ccall libexodus.ex_put_partial_elem_conn(exoid::Cint, elem_blk_id::ex_entity_id, start_elem_num::Int64, num_elems::Int64, connect::Ptr{void_int})::Cint
end

function ex_put_partial_elem_attr(exoid, elem_blk_id, start_elem_num, num_elems, attrib)
    @ccall libexodus.ex_put_partial_elem_attr(exoid::Cint, elem_blk_id::ex_entity_id, start_elem_num::Int64, num_elems::Int64, attrib::Ptr{Cvoid})::Cint
end

function ex_put_elem_var_slab(exoid, time_step, elem_var_index, elem_blk_id, start_pos, num_vals, elem_var_vals)
    @ccall libexodus.ex_put_elem_var_slab(exoid::Cint, time_step::Cint, elem_var_index::Cint, elem_blk_id::ex_entity_id, start_pos::Int64, num_vals::Int64, elem_var_vals::Ptr{Cvoid})::Cint
end

function ex_put_nodal_var_slab(exoid, time_step, nodal_var_index, start_pos, num_vals, nodal_var_vals)
    @ccall libexodus.ex_put_nodal_var_slab(exoid::Cint, time_step::Cint, nodal_var_index::Cint, start_pos::Int64, num_vals::Int64, nodal_var_vals::Ptr{Cvoid})::Cint
end

function ex_name_of_object(obj_type)
    @ccall libexodus.ex_name_of_object(obj_type::ex_entity_type)::Cstring
end

function ex_var_type_to_ex_entity_type(var_type)
    @ccall libexodus.ex_var_type_to_ex_entity_type(var_type::Cchar)::ex_entity_type
end

function ex_set_parallel(exoid, is_parallel)
    @ccall libexodus.ex_set_parallel(exoid::Cint, is_parallel::Cint)::Cint
end

function ex_get_idx(exoid, ne_var_name, my_index, pos)
    @ccall libexodus.ex_get_idx(exoid::Cint, ne_var_name::Cstring, my_index::Ptr{Int64}, pos::Cint)::Cint
end

"""
    ex_error_return_code

` ErrorReturnCodes Error return codes - #exerrval return values`

@{

| Enumerator         | Note                                               |
| :----------------- | :------------------------------------------------- |
| EX\\_MEMFAIL       | memory allocation failure flag def                 |
| EX\\_BADFILEMODE   | bad file mode def                                  |
| EX\\_BADFILEID     | bad file id def                                    |
| EX\\_WRONGFILETYPE | wrong file type for function                       |
| EX\\_LOOKUPFAIL    | id table lookup failed                             |
| EX\\_BADPARAM      | bad parameter passed                               |
| EX\\_INTERNAL      | internal logic error                               |
| EX\\_DUPLICATEID   | duplicate id found                                 |
| EX\\_DUPLICATEOPEN | duplicate open                                     |
| EX\\_BADFILENAME   | empty or null filename specified                   |
| EX\\_MSG           | message print code - no error implied              |
| EX\\_PRTLASTMSG    | print last error message msg code                  |
| EX\\_NOTROOTID     | file id is not the root id; it is a subgroup id    |
| EX\\_LASTERR       | in [`ex_err`](@ref), use existing err\\_num value  |
| EX\\_NULLENTITY    | null entity found                                  |
| EX\\_NOENTITY      | no entities of that type on database               |
| EX\\_NOTFOUND      | could not find requested variable on database      |
| EX\\_FATAL         | fatal error flag def                               |
| EX\\_NOERR         | no error flag def                                  |
| EX\\_WARN          | warning flag def                                   |
"""
@cenum ex_error_return_code::Int32 begin
    EX_MEMFAIL = 1000
    EX_BADFILEMODE = 1001
    EX_BADFILEID = 1002
    EX_WRONGFILETYPE = 1003
    EX_LOOKUPFAIL = 1004
    EX_BADPARAM = 1005
    EX_INTERNAL = 1006
    EX_DUPLICATEID = 1007
    EX_DUPLICATEOPEN = 1008
    EX_BADFILENAME = 1009
    EX_MSG = -1000
    EX_PRTLASTMSG = -1001
    EX_NOTROOTID = -1002
    EX_LASTERR = -1003
    EX_NULLENTITY = -1006
    EX_NOENTITY = -1007
    EX_NOTFOUND = -1008
    EX_INTSIZEMISMATCH = -1009
    EX_FATAL = -1
    EX_NOERR = 0
    EX_WARN = 1
end

function exi_reset_error_status()
    @ccall libexodus.exi_reset_error_status()::Cint
end

function exi_catstr(arg1, arg2)
    @ccall libexodus.exi_catstr(arg1::Cstring, arg2::Cint)::Cstring
end

function exi_catstr2(arg1, arg2, arg3, arg4)
    @ccall libexodus.exi_catstr2(arg1::Cstring, arg2::Cint, arg3::Cstring, arg4::Cint)::Cstring
end

function exi_get_varid(exoid, obj_type, id)
    @ccall libexodus.exi_get_varid(exoid::Cint, obj_type::Cint, id::Cint)::Cint
end

"""
    exi_element_type

| Enumerator         | Note                     |
| :----------------- | :----------------------- |
| EX\\_EL\\_UNK      | unknown entity           |
| EX\\_EL\\_TRIANGLE | Triangle entity          |
| EX\\_EL\\_QUAD     | Quad entity              |
| EX\\_EL\\_HEX      | Hex entity               |
| EX\\_EL\\_WEDGE    | Wedge entity             |
| EX\\_EL\\_TETRA    | Tetra entity             |
| EX\\_EL\\_TRUSS    | Truss entity             |
| EX\\_EL\\_BEAM     | Beam entity              |
| EX\\_EL\\_SHELL    | Shell entity             |
| EX\\_EL\\_SPHERE   | Sphere entity            |
| EX\\_EL\\_CIRCLE   | Circle entity            |
| EX\\_EL\\_TRISHELL | Triangular Shell entity  |
| EX\\_EL\\_PYRAMID  | Pyramid entity           |
"""
@cenum exi_element_type::Int32 begin
    EX_EL_UNK = -1
    EX_EL_NULL_ELEMENT = 0
    EX_EL_TRIANGLE = 1
    EX_EL_QUAD = 2
    EX_EL_HEX = 3
    EX_EL_WEDGE = 4
    EX_EL_TETRA = 5
    EX_EL_TRUSS = 6
    EX_EL_BEAM = 7
    EX_EL_SHELL = 8
    EX_EL_SPHERE = 9
    EX_EL_CIRCLE = 10
    EX_EL_TRISHELL = 11
    EX_EL_PYRAMID = 12
end

"""
    exi_file_item

| Field                     | Note                                                                                                                  |
| :------------------------ | :-------------------------------------------------------------------------------------------------------------------- |
| compression\\_level       | 0 (disabled) to 9 (maximum) compression level for gzip, 4..32 and even for szip; -131072..22 for zstd, NetCDF-4 only  |
| persist\\_define\\_mode   | Stay in define mode until [`exi_persist_leavedef`](@ref) is called. Set by [`exi_persist_redef`](@ref)...             |
| compression\\_algorithm   | GZIP/ZLIB, SZIP, more may be supported by NetCDF soon                                                                 |
| quantize\\_nsd            | 0 (disabled) to 15 (maximum) number of significant digits retained for lossy quanitzation compression                 |
| shuffle                   | 1 true, 0 false                                                                                                       |
| user\\_compute\\_wordsize | 0 for 4 byte or 1 for 8 byte reals                                                                                    |
| file\\_type               | 0 - classic, 1 -- 64 bit classic, 2 --NetCDF4, 3 --NetCDF4 classic                                                    |
| is\\_write                | for output or append                                                                                                  |
| is\\_parallel             | 1 true, 0 false                                                                                                       |
| is\\_hdf5                 |                                                                                                                       |
| is\\_pnetcdf              |                                                                                                                       |
| has\\_nodes               | for input only at this time                                                                                           |
| has\\_edges               |                                                                                                                       |
| has\\_faces               |                                                                                                                       |
| has\\_elems               |                                                                                                                       |
| in\\_define\\_mode        | Is the file in nc define mode...                                                                                      |
"""
struct exi_file_item
    file_id::Cint
    netcdf_type_code::Cint
    int64_status::Cint
    maximum_name_length::Cint
    time_varid::Cint
    compression_level::Cint
    assembly_count::Cuint
    blob_count::Cuint
    persist_define_mode::Cuint
    compression_algorithm::Cuint
    quantize_nsd::Cuint
    shuffle::Cuint
    user_compute_wordsize::Cuint
    file_type::Cuint
    is_write::Cuint
    is_parallel::Cuint
    is_hdf5::Cuint
    is_pnetcdf::Cuint
    has_nodes::Cuint
    has_edges::Cuint
    has_faces::Cuint
    has_elems::Cuint
    in_define_mode::Cuint
    next::Ptr{exi_file_item}
end

struct exi_elem_blk_parm
    elem_type::NTuple{33, Cchar}
    elem_blk_id::Int64
    num_elem_in_blk::Int64
    num_nodes_per_elem::Cint
    num_sides::Cint
    num_nodes_per_side::NTuple{6, Cint}
    num_attr::Cint
    elem_ctr::Int64
    elem_type_val::exi_element_type
end

@cenum exi_coordinate_frame_type::UInt32 begin
    EX_CF_RECTANGULAR = 1
    EX_CF_CYLINDRICAL = 2
    EX_CF_SPHERICAL = 3
end

struct exi_list_item
    exo_id::Cint
    value::Cint
    next::Ptr{exi_list_item}
end

struct exi_obj_stats
    id_vals::Ptr{Int64}
    stat_vals::Ptr{Cint}
    num::Csize_t
    exoid::Cint
    valid_ids::Cchar
    valid_stat::Cchar
    sequential::Cchar
    next::Ptr{exi_obj_stats}
end

function exi_iqsort(v, iv, N)
    @ccall libexodus.exi_iqsort(v::Ptr{Cint}, iv::Ptr{Cint}, N::Csize_t)::Cvoid
end

function exi_iqsort64(v, iv, N)
    @ccall libexodus.exi_iqsort64(v::Ptr{Int64}, iv::Ptr{Int64}, N::Int64)::Cvoid
end

# no prototype is found for this function at exodusII_int.h:782:21, please use with caution
function exi_dim_num_entries_in_object()
    @ccall libexodus.exi_dim_num_entries_in_object()::Cstring
end

function exi_dim_num_objects(obj_type)
    @ccall libexodus.exi_dim_num_objects(obj_type::Cint)::Cstring
end

# no prototype is found for this function at exodusII_int.h:784:21, please use with caution
function exi_name_var_of_object()
    @ccall libexodus.exi_name_var_of_object()::Cstring
end

# no prototype is found for this function at exodusII_int.h:785:21, please use with caution
function exi_name_red_var_of_object()
    @ccall libexodus.exi_name_red_var_of_object()::Cstring
end

# no prototype is found for this function at exodusII_int.h:786:21, please use with caution
function exi_name_of_map()
    @ccall libexodus.exi_name_of_map()::Cstring
end

function exi_conv_init(exoid, comp_wordsize, io_wordsize, file_wordsize, int64_status, is_parallel, is_hdf5, is_pnetcdf, is_write)
    @ccall libexodus.exi_conv_init(exoid::Cint, comp_wordsize::Ptr{Cint}, io_wordsize::Ptr{Cint}, file_wordsize::Cint, int64_status::Cint, is_parallel::Bool, is_hdf5::Bool, is_pnetcdf::Bool, is_write::Bool)::Cint
end

function exi_conv_exit(exoid)
    @ccall libexodus.exi_conv_exit(exoid::Cint)::Cvoid
end

function nc_flt_code(exoid)
    @ccall libexodus.nc_flt_code(exoid::Cint)::Cint
end

function exi_comp_ws(exoid)
    @ccall libexodus.exi_comp_ws(exoid::Cint)::Cint
end

function exi_get_cpu_ws()
    @ccall libexodus.exi_get_cpu_ws()::Cint
end

function exi_is_parallel(exoid)
    @ccall libexodus.exi_is_parallel(exoid::Cint)::Cint
end

function exi_get_counter_list(obj_type)
    @ccall libexodus.exi_get_counter_list(obj_type::Cint)::Ptr{Ptr{exi_list_item}}
end

function exi_get_file_item(arg1, arg2)
    @ccall libexodus.exi_get_file_item(arg1::Cint, arg2::Ptr{Ptr{exi_list_item}})::Cint
end

function exi_inc_file_item(arg1, arg2)
    @ccall libexodus.exi_inc_file_item(arg1::Cint, arg2::Ptr{Ptr{exi_list_item}})::Cint
end

function exi_rm_file_item(arg1, arg2)
    @ccall libexodus.exi_rm_file_item(arg1::Cint, arg2::Ptr{Ptr{exi_list_item}})::Cvoid
end

function exi_find_file_item(exoid)
    @ccall libexodus.exi_find_file_item(exoid::Cint)::Ptr{exi_file_item}
end

function exi_add_file_item(exoid)
    @ccall libexodus.exi_add_file_item(exoid::Cint)::Ptr{exi_file_item}
end

function exi_get_stat_ptr(exoid, obj_ptr)
    @ccall libexodus.exi_get_stat_ptr(exoid::Cint, obj_ptr::Ptr{Ptr{exi_obj_stats}})::Ptr{exi_obj_stats}
end

function exi_rm_stat_ptr(exoid, obj_ptr)
    @ccall libexodus.exi_rm_stat_ptr(exoid::Cint, obj_ptr::Ptr{Ptr{exi_obj_stats}})::Cvoid
end

function exi_set_compact_storage(exoid, varid)
    @ccall libexodus.exi_set_compact_storage(exoid::Cint, varid::Cint)::Cvoid
end

function exi_compress_variable(exoid, varid, type)
    @ccall libexodus.exi_compress_variable(exoid::Cint, varid::Cint, type::Cint)::Cvoid
end

function exi_id_lkup(exoid, id_type, num)
    @ccall libexodus.exi_id_lkup(exoid::Cint, id_type::Cint, num::Cint)::Cint
end

function exi_check_valid_file_id(exoid, func)
    @ccall libexodus.exi_check_valid_file_id(exoid::Cint, func::Cstring)::Cint
end

"""
    exi_check_multiple_open(path, mode, func)

Return fatal error if exoid does not refer to valid file
"""
function exi_check_multiple_open(path, mode, func)
    @ccall libexodus.exi_check_multiple_open(path::Cstring, mode::Cint, func::Cstring)::Cint
end

function exi_check_file_type(path, type)
    @ccall libexodus.exi_check_file_type(path::Cstring, type::Ptr{Cint})::Cint
end

function exi_canonicalize_filename(path)
    @ccall libexodus.exi_canonicalize_filename(path::Cstring)::Cstring
end

function exi_get_dimension(exoid, DIMENSION, label, count, dimid, routine)
    @ccall libexodus.exi_get_dimension(exoid::Cint, DIMENSION::Cstring, label::Cstring, count::Ptr{Csize_t}, dimid::Ptr{Cint}, routine::Cstring)::Cint
end

function exi_get_nodal_var_time(exoid, nodal_var_index, node_number, beg_time_step, end_time_step, nodal_var_vals)
    @ccall libexodus.exi_get_nodal_var_time(exoid::Cint, nodal_var_index::Cint, node_number::Int64, beg_time_step::Cint, end_time_step::Cint, nodal_var_vals::Ptr{Cvoid})::Cint
end

function exi_put_nodal_var_multi_time(exoid, nodal_var_index, num_nodes, beg_time_step, end_time_step, nodal_var_vals)
    @ccall libexodus.exi_put_nodal_var_multi_time(exoid::Cint, nodal_var_index::Cint, num_nodes::Int64, beg_time_step::Cint, end_time_step::Cint, nodal_var_vals::Ptr{Cvoid})::Cint
end

function exi_get_nodal_var_multi_time(exoid, nodal_var_index, node_number, beg_time_step, end_time_step, nodal_var_vals)
    @ccall libexodus.exi_get_nodal_var_multi_time(exoid::Cint, nodal_var_index::Cint, node_number::Int64, beg_time_step::Cint, end_time_step::Cint, nodal_var_vals::Ptr{Cvoid})::Cint
end

function exi_put_nodal_var_time(exoid, nodal_var_index, num_nodes, beg_time_step, end_time_step, nodal_var_vals)
    @ccall libexodus.exi_put_nodal_var_time(exoid::Cint, nodal_var_index::Cint, num_nodes::Int64, beg_time_step::Cint, end_time_step::Cint, nodal_var_vals::Ptr{Cvoid})::Cint
end

function exi_get_partial_nodal_var(exoid, time_step, nodal_var_index, start_node, num_nodes, var_vals)
    @ccall libexodus.exi_get_partial_nodal_var(exoid::Cint, time_step::Cint, nodal_var_index::Cint, start_node::Int64, num_nodes::Int64, var_vals::Ptr{Cvoid})::Cint
end

function exi_put_partial_nodal_var(exoid, time_step, nodal_var_index, start_node, num_nodes, nodal_var_vals)
    @ccall libexodus.exi_put_partial_nodal_var(exoid::Cint, time_step::Cint, nodal_var_index::Cint, start_node::Int64, num_nodes::Int64, nodal_var_vals::Ptr{Cvoid})::Cint
end

function exi_get_glob_vars(exoid, time_step, num_glob_vars, glob_var_vals)
    @ccall libexodus.exi_get_glob_vars(exoid::Cint, time_step::Cint, num_glob_vars::Cint, glob_var_vals::Ptr{Cvoid})::Cint
end

function exi_get_glob_vars_multi_time(exoid, num_glob_vars, beg_time_step, end_time_step, glob_var_vals)
    @ccall libexodus.exi_get_glob_vars_multi_time(exoid::Cint, num_glob_vars::Cint, beg_time_step::Cint, end_time_step::Cint, glob_var_vals::Ptr{Cvoid})::Cint
end

function exi_get_glob_var_time(exoid, glob_var_index, beg_time_step, end_time_step, glob_var_vals)
    @ccall libexodus.exi_get_glob_var_time(exoid::Cint, glob_var_index::Cint, beg_time_step::Cint, end_time_step::Cint, glob_var_vals::Ptr{Cvoid})::Cint
end

function exi_get_name(exoid, varid, index, name, name_size, obj_type, routine)
    @ccall libexodus.exi_get_name(exoid::Cint, varid::Cint, index::Csize_t, name::Cstring, name_size::Cint, obj_type::Cint, routine::Cstring)::Cint
end

function exi_get_names(exoid, varid, num_entity, names, obj_type, routine)
    @ccall libexodus.exi_get_names(exoid::Cint, varid::Cint, num_entity::Csize_t, names::Ptr{Cstring}, obj_type::Cint, routine::Cstring)::Cint
end

function exi_put_name(exoid, varid, index, name, obj_type, subtype, routine)
    @ccall libexodus.exi_put_name(exoid::Cint, varid::Cint, index::Csize_t, name::Cstring, obj_type::Cint, subtype::Cstring, routine::Cstring)::Cint
end

function exi_put_names(exoid, varid, num_entity, names, obj_type, subtype, routine)
    @ccall libexodus.exi_put_names(exoid::Cint, varid::Cint, num_entity::Csize_t, names::Ptr{Cstring}, obj_type::Cint, subtype::Cstring, routine::Cstring)::Cint
end

function exi_trim(name)
    @ccall libexodus.exi_trim(name::Cstring)::Cvoid
end

function exi_update_max_name_length(exoid, length)
    @ccall libexodus.exi_update_max_name_length(exoid::Cint, length::Cint)::Cvoid
end

function exi_redef(exoid, call_func)
    @ccall libexodus.exi_redef(exoid::Cint, call_func::Cstring)::Cint
end

function exi_persist_redef(exoid, call_func)
    @ccall libexodus.exi_persist_redef(exoid::Cint, call_func::Cstring)::Cint
end

function exi_leavedef(exoid, call_rout)
    @ccall libexodus.exi_leavedef(exoid::Cint, call_rout::Cstring)::Cint
end

function exi_persist_leavedef(exoid, call_rout)
    @ccall libexodus.exi_persist_leavedef(exoid::Cint, call_rout::Cstring)::Cint
end

function exi_check_version(run_version)
    @ccall libexodus.exi_check_version(run_version::Cint)::Cint
end

function exi_handle_mode(my_mode, is_parallel, run_version)
    @ccall libexodus.exi_handle_mode(my_mode::Cuint, is_parallel::Cint, run_version::Cint)::Cint
end

function exi_populate_header(exoid, path, my_mode, is_parallel, comp_ws, io_ws)
    @ccall libexodus.exi_populate_header(exoid::Cint, path::Cstring, my_mode::Cint, is_parallel::Cint, comp_ws::Ptr{Cint}, io_ws::Ptr{Cint})::Cint
end

function exi_get_block_param(exoid, id, ndim, elem_blk_parm)
    @ccall libexodus.exi_get_block_param(exoid::Cint, id::Cint, ndim::Cint, elem_blk_parm::Ptr{exi_elem_blk_parm})::Cint
end

function exi_get_file_type(exoid, ftype)
    @ccall libexodus.exi_get_file_type(exoid::Cint, ftype::Cstring)::Cint
end

function exi_put_nemesis_version(exoid)
    @ccall libexodus.exi_put_nemesis_version(exoid::Cint)::Cint
end

function exi_put_homogenous_block_params(exoid, block_count, blocks)
    @ccall libexodus.exi_put_homogenous_block_params(exoid::Cint, block_count::Csize_t, blocks::Ptr{ex_block})::Cint
end

function nei_check_file_version(exoid)
    @ccall libexodus.nei_check_file_version(exoid::Cint)::Cint
end

function nei_id_lkup(exoid, ne_var_name, idx, ne_var_id)
    @ccall libexodus.nei_id_lkup(exoid::Cint, ne_var_name::Cstring, idx::Ptr{Int64}, ne_var_id::Cint)::Cint
end

const INTER_FACE = interface

const CHACO_VERSION_MAJOR = 3

const CHACO_VERSION_MINOR = 0

const CHACO_VERSION_PATCH = 0

const EXODUS_VERSION = "9.04"

const EXODUS_VERSION_MAJOR = 9

const EXODUS_VERSION_MINOR = 4

const EXODUS_RELEASE_DATE = "November 5, 2024"

const EX_API_VERS = Float32(9.04)

const EX_API_VERS_NODOT = 100 * EXODUS_VERSION_MAJOR + EXODUS_VERSION_MINOR

const EX_VERS = EX_API_VERS

const NEMESIS_API_VERSION = EX_API_VERS

const NEMESIS_API_VERSION_NODOT = EX_API_VERS_NODOT

const NEMESIS_FILE_VERSION = 2.6

const EX_TRUE = -1

const EX_FALSE = 0

const EX_WRITE = 0x0001

const EX_READ = 0x0002

const EX_NOCLOBBER = 0x0004

const EX_CLOBBER = 0x0008

const EX_NORMAL_MODEL = 0x0010

const EX_64BIT_OFFSET = 0x0020

const EX_LARGE_MODEL = EX_64BIT_OFFSET

const EX_64BIT_DATA = 0x00400000

const EX_NETCDF4 = 0x0040

const EX_NOSHARE = 0x0080

const EX_SHARE = 0x0100

const EX_NOCLASSIC = 0x0200

const EX_DISKLESS = 0x00100000

const EX_MMAP = 0x00200000

const EX_MAPS_INT64_DB = 0x0400

const EX_IDS_INT64_DB = 0x0800

const EX_BULK_INT64_DB = 0x1000

const EX_ALL_INT64_DB = (EX_MAPS_INT64_DB | EX_IDS_INT64_DB) | EX_BULK_INT64_DB

const EX_MAPS_INT64_API = 0x2000

const EX_IDS_INT64_API = 0x4000

const EX_BULK_INT64_API = 0x8000

const EX_INQ_INT64_API = 0x00010000

const EX_ALL_INT64_API = ((EX_MAPS_INT64_API | EX_IDS_INT64_API) | EX_BULK_INT64_API) | EX_INQ_INT64_API

const EX_MPIIO = 0x00020000

const EX_MPIPOSIX = 0x00040000

const EX_PNETCDF = 0x00080000

const EX_MAX_FIELD_NESTING = 2

const EX_INVALID_ID = -1

const MAX_STR_LENGTH = Clong(32)

const MAX_NAME_LENGTH = MAX_STR_LENGTH

const MAX_LINE_LENGTH = Clong(80)

const MAX_ERR_LENGTH = 512

# Skipping MacroDefinition: EXODUS_EXPORT extern

const NC_FillValue = "_FillValue"

const MAX_VAR_NAME_LENGTH = 32

const EXODUS_DEFAULT_SIZE = 1

const EX_FILE_ID_MASK = 0xffff0000

const EX_GRP_ID_MASK = 0x0000ffff

const ATT_TITLE = "title"

const ATT_API_VERSION = "api_version"

const ATT_API_VERSION_BLANK = "api version"

const ATT_VERSION = "version"

const ATT_FILESIZE = "file_size"

const ATT_FLT_WORDSIZE = "floating_point_word_size"

const ATT_FLT_WORDSIZE_BLANK = "floating point word size"

const ATT_MAX_NAME_LENGTH = "maximum_name_length"

const ATT_INT64_STATUS = "int64_status"

const ATT_NEM_API_VERSION = "nemesis_api_version"

const ATT_NEM_FILE_VERSION = "nemesis_file_version"

const ATT_PROCESSOR_INFO = "processor_info"

const ATT_LAST_WRITTEN_TIME = "last_written_time"

const DIM_NUM_ASSEMBLY = "num_assembly"

const DIM_NUM_BLOB = "num_blob"

const DIM_NUM_NODES = "num_nodes"

const DIM_NUM_DIM = "num_dim"

const DIM_NUM_EDGE = "num_edge"

const DIM_NUM_FACE = "num_face"

const DIM_NUM_ELEM = "num_elem"

const DIM_NUM_EL_BLK = "num_el_blk"

const DIM_NUM_ED_BLK = "num_ed_blk"

const DIM_NUM_FA_BLK = "num_fa_blk"

const VAR_COORD = "coord"

const VAR_COORD_X = "coordx"

const VAR_COORD_Y = "coordy"

const VAR_COORD_Z = "coordz"

const VAR_NAME_COOR = "coor_names"

const VAR_NAME_EL_BLK = "eb_names"

const VAR_NAME_NS = "ns_names"

const VAR_NAME_SS = "ss_names"

const VAR_NAME_EM = "emap_names"

const VAR_NAME_EDM = "edmap_names"

const VAR_NAME_FAM = "famap_names"

const VAR_NAME_NM = "nmap_names"

const VAR_NAME_ED_BLK = "ed_names"

const VAR_NAME_FA_BLK = "fa_names"

const VAR_NAME_ES = "es_names"

const VAR_NAME_FS = "fs_names"

const VAR_NAME_ELS = "els_names"

const VAR_STAT_EL_BLK = "eb_status"

const VAR_STAT_ECONN = "econn_status"

const VAR_STAT_FCONN = "fconn_status"

const VAR_STAT_ED_BLK = "ed_status"

const VAR_STAT_FA_BLK = "fa_status"

const VAR_ID_EL_BLK = "eb_prop1"

const VAR_ID_ED_BLK = "ed_prop1"

const VAR_ID_FA_BLK = "fa_prop1"

const EX_ATTRIBUTE_TYPE = "_type"

const EX_ATTRIBUTE_TYPENAME = "_typename"

const EX_ATTRIBUTE_NAME = "_name"

const EX_ATTRIBUTE_ID = "_id"

const ATT_NAME_ELB = "elem_type"

const VAR_NATTRIB = "nattrb"

const VAR_NAME_NATTRIB = "nattrib_name"

const DIM_NUM_ATT_IN_NBLK = "num_att_in_nblk"

const ATT_PROP_NAME = "name"

const VAR_MAP = "elem_map"

const DIM_NUM_SS = "num_side_sets"

const VAR_SS_STAT = "ss_status"

const VAR_SS_IDS = "ss_prop1"

const DIM_NUM_ES = "num_edge_sets"

const VAR_ES_STAT = "es_status"

const VAR_ES_IDS = "es_prop1"

const DIM_NUM_FS = "num_face_sets"

const VAR_FS_STAT = "fs_status"

const VAR_FS_IDS = "fs_prop1"

const DIM_NUM_ELS = "num_elem_sets"

const VAR_ELS_STAT = "els_status"

const VAR_ELS_IDS = "els_prop1"

const DIM_NUM_NS = "num_node_sets"

const VAR_NS_STAT = "ns_status"

const VAR_NS_IDS = "ns_prop1"

const DIM_NUM_QA = "num_qa_rec"

const VAR_QA_TITLE = "qa_records"

const DIM_NUM_INFO = "num_info"

const VAR_INFO = "info_records"

const VAR_WHOLE_TIME = "time_whole"

const VAR_ASSEMBLY_TAB = "assembly_var_tab"

const VAR_BLOB_TAB = "blob_var_tab"

const VAR_ELEM_TAB = "elem_var_tab"

const VAR_EBLK_TAB = "edge_var_tab"

const VAR_FBLK_TAB = "face_var_tab"

const VAR_ELSET_TAB = "elset_var_tab"

const VAR_SSET_TAB = "sset_var_tab"

const VAR_FSET_TAB = "fset_var_tab"

const VAR_ESET_TAB = "eset_var_tab"

const VAR_NSET_TAB = "nset_var_tab"

const DIM_NUM_GLO_VAR = "num_glo_var"

const VAR_NAME_GLO_VAR = "name_glo_var"

const VAR_GLO_VAR = "vals_glo_var"

const DIM_NUM_NOD_VAR = "num_nod_var"

const VAR_NAME_NOD_VAR = "name_nod_var"

const VAR_NOD_VAR = "vals_nod_var"

const DIM_NUM_ASSEMBLY_VAR = "num_assembly_var"

const VAR_NAME_ASSEMBLY_VAR = "name_assembly_var"

const DIM_NUM_BLOB_VAR = "num_blob_var"

const VAR_NAME_BLOB_VAR = "name_blob_var"

const DIM_NUM_ELE_VAR = "num_elem_var"

const VAR_NAME_ELE_VAR = "name_elem_var"

const DIM_NUM_EDG_VAR = "num_edge_var"

const VAR_NAME_EDG_VAR = "name_edge_var"

const DIM_NUM_FAC_VAR = "num_face_var"

const VAR_NAME_FAC_VAR = "name_face_var"

const DIM_NUM_NSET_VAR = "num_nset_var"

const VAR_NAME_NSET_VAR = "name_nset_var"

const DIM_NUM_ESET_VAR = "num_eset_var"

const VAR_NAME_ESET_VAR = "name_eset_var"

const DIM_NUM_FSET_VAR = "num_fset_var"

const VAR_NAME_FSET_VAR = "name_fset_var"

const DIM_NUM_SSET_VAR = "num_sset_var"

const VAR_NAME_SSET_VAR = "name_sset_var"

const DIM_NUM_ELSET_VAR = "num_elset_var"

const VAR_NAME_ELSET_VAR = "name_elset_var"

const DIM_NUM_ASSEMBLY_RED_VAR = "num_assembly_red_var"

const VAR_NAME_ASSEMBLY_RED_VAR = "name_assembly_red_var"

const DIM_NUM_BLOB_RED_VAR = "num_blob_red_var"

const VAR_NAME_BLOB_RED_VAR = "name_blob_red_var"

const DIM_NUM_ELE_RED_VAR = "num_elem_red_var"

const VAR_NAME_ELE_RED_VAR = "name_elem_red_var"

const DIM_NUM_EDG_RED_VAR = "num_edge_red_var"

const VAR_NAME_EDG_RED_VAR = "name_edge_red_var"

const DIM_NUM_FAC_RED_VAR = "num_face_red_var"

const VAR_NAME_FAC_RED_VAR = "name_face_red_var"

const DIM_NUM_NSET_RED_VAR = "num_nset_red_var"

const VAR_NAME_NSET_RED_VAR = "name_nset_red_var"

const DIM_NUM_ESET_RED_VAR = "num_eset_red_var"

const VAR_NAME_ESET_RED_VAR = "name_eset_red_var"

const DIM_NUM_FSET_RED_VAR = "num_fset_red_var"

const VAR_NAME_FSET_RED_VAR = "name_fset_red_var"

const DIM_NUM_SSET_RED_VAR = "num_sset_red_var"

const VAR_NAME_SSET_RED_VAR = "name_sset_red_var"

const DIM_NUM_ELSET_RED_VAR = "num_elset_red_var"

const VAR_NAME_ELSET_RED_VAR = "name_elset_red_var"

const DIM_STR = "len_string"

const DIM_STR_NAME = "len_name"

const DIM_LIN = "len_line"

const DIM_N4 = "four"

const DIM_N1 = "blob_entity"

const DIM_TIME = "time_step"

const VAR_ELEM_NUM_MAP = "elem_num_map"

const VAR_FACE_NUM_MAP = "face_num_map"

const VAR_EDGE_NUM_MAP = "edge_num_map"

const VAR_NODE_NUM_MAP = "node_num_map"

const DIM_NUM_EM = "num_elem_maps"

const DIM_NUM_EDM = "num_edge_maps"

const DIM_NUM_FAM = "num_face_maps"

const DIM_NUM_NM = "num_node_maps"

const DIM_NUM_CFRAMES = "num_cframes"

const DIM_NUM_CFRAME9 = "num_cframes_9"

const VAR_FRAME_COORDS = "frame_coordinates"

const VAR_FRAME_IDS = "frame_ids"

const VAR_FRAME_TAGS = "frame_tags"

const VAR_ELBLK_IDS_GLOBAL = "el_blk_ids_global"

const VAR_ELBLK_CNT_GLOBAL = "el_blk_cnt_global"

const VAR_NS_IDS_GLOBAL = "ns_ids_global"

const VAR_NS_NODE_CNT_GLOBAL = "ns_node_cnt_global"

const VAR_NS_DF_CNT_GLOBAL = "ns_df_cnt_global"

const VAR_SS_IDS_GLOBAL = "ss_ids_global"

const VAR_SS_SIDE_CNT_GLOBAL = "ss_side_cnt_global"

const VAR_SS_DF_CNT_GLOBAL = "ss_df_cnt_global"

const VAR_FILE_TYPE = "nem_ftype"

const VAR_COMM_MAP = "comm_map"

const VAR_NODE_MAP_INT = "node_mapi"

const VAR_NODE_MAP_INT_IDX = "node_mapi_idx"

const VAR_NODE_MAP_BOR = "node_mapb"

const VAR_NODE_MAP_BOR_IDX = "node_mapb_idx"

const VAR_NODE_MAP_EXT = "node_mape"

const VAR_NODE_MAP_EXT_IDX = "node_mape_idx"

const VAR_ELEM_MAP_INT = "elem_mapi"

const VAR_ELEM_MAP_INT_IDX = "elem_mapi_idx"

const VAR_ELEM_MAP_BOR = "elem_mapb"

const VAR_ELEM_MAP_BOR_IDX = "elem_mapb_idx"

const VAR_INT_N_STAT = "int_n_stat"

const VAR_BOR_N_STAT = "bor_n_stat"

const VAR_EXT_N_STAT = "ext_n_stat"

const VAR_INT_E_STAT = "int_e_stat"

const VAR_BOR_E_STAT = "bor_e_stat"

const VAR_N_COMM_IDS = "n_comm_ids"

const VAR_N_COMM_STAT = "n_comm_stat"

const VAR_N_COMM_INFO_IDX = "n_comm_info_idx"

const VAR_E_COMM_IDS = "e_comm_ids"

const VAR_E_COMM_STAT = "e_comm_stat"

const VAR_E_COMM_INFO_IDX = "e_comm_info_idx"

const VAR_N_COMM_NIDS = "n_comm_nids"

const VAR_N_COMM_PROC = "n_comm_proc"

const VAR_N_COMM_DATA_IDX = "n_comm_data_idx"

const VAR_E_COMM_EIDS = "e_comm_eids"

const VAR_E_COMM_SIDS = "e_comm_sids"

const VAR_E_COMM_PROC = "e_comm_proc"

const VAR_E_COMM_DATA_IDX = "e_comm_data_idx"

const DIM_NUM_INT_NODES = "num_int_node"

const DIM_NUM_BOR_NODES = "num_bor_node"

const DIM_NUM_EXT_NODES = "num_ext_node"

const DIM_NUM_INT_ELEMS = "num_int_elem"

const DIM_NUM_BOR_ELEMS = "num_bor_elem"

const DIM_NUM_PROCS = "num_processors"

const DIM_NUM_PROCS_F = "num_procs_file"

const DIM_NUM_NODES_GLOBAL = "num_nodes_global"

const DIM_NUM_ELEMS_GLOBAL = "num_elems_global"

const DIM_NUM_NS_GLOBAL = "num_ns_global"

const DIM_NUM_SS_GLOBAL = "num_ss_global"

const DIM_NUM_ELBLK_GLOBAL = "num_el_blk_global"

const DIM_NUM_N_CMAPS = "num_n_cmaps"

const DIM_NUM_E_CMAPS = "num_e_cmaps"

const DIM_NCNT_CMAP = "ncnt_cmap"

const DIM_ECNT_CMAP = "ecnt_cmap"

# Skipping MacroDefinition: SEACAS_DEPRECATED __attribute__ ( ( __deprecated__ ) )

# exports
const PREFIXES = ["C", "CX", "clang_"]
for name in names(@__MODULE__; all=true), prefix in PREFIXES
    if startswith(string(name), prefix)
        @eval export $name
    end
end

end # module
