# TODO: cleanup up below
#
const MAX_LINE_LENGTH = Int32(80)
const MAX_STR_LENGTH = Int32(32)
const MAX_NAME_LENGTH = Int32(256)

# TODO maybe make this non-constant?
const cpu_word_size = Int32(sizeof(Float64)) # TODO make parametric so we can have float models
const IO_word_size = Int32(8)                # This was what we did before

# TODO: make this be read in from the OS or something like that
#
const version_number_1 = Int32(8)
const version_number_2 = Int32(19)
const version_number = Float32(8.19)
const version_number_int = Int32(100 * version_number_1 + version_number_2)

const EX_API_VERS = Float32(8.19)
const EX_API_VERS_NODOT = Int32(100 * version_number_1 + version_number_2)
const EX_VERS = EX_API_VERS

# TODO: add the entirity from the exoudsII header
#
const EX_WRITE         = 0x0001          #< ex_open(): open existing file for appending. */
const EX_READ          = 0x0002          #< ex_open(): open file for reading (default) */

const EX_NOCLOBBER     = 0x0004          #< Don't overwrite existing database, default */
const EX_CLOBBER       = 0x0008          #< Overwrite existing database if it exists */
const EX_NORMAL_MODEL  = 0x0010          #< disable mods that permit storage of larger models */
const EX_64BIT_OFFSET  = 0x0020          #< enable mods that permit storage of larger models */
const EX_LARGE_MODEL   = EX_64BIT_OFFSET #< enable mods that permit storage of larger models */
const EX_64BIT_DATA    = 0x400000        #< CDF-5 format: classic model but 64 bit dimensions and sizes */
const EX_NETCDF4       = 0x0040          #< use the hdf5-based netcdf4 output */
const EX_NOSHARE       = 0x0080          #< Do not open netcdf file in "share" mode */
const EX_SHARE         = 0x0100          #< Do open netcdf file in "share" mode */
const EX_NOCLASSIC     = 0x0200          #< Do not force netcdf to classic mode in netcdf4 mode */

const EX_DISKLESS      = 0x100000        #< Experimental */
const EX_MMAP          = 0x200000        #< Experimental */

const EX_MAPS_INT64_DB = 0x0400          #< All maps (id, order, ...) store int64_t values */
const EX_IDS_INT64_DB  = 0x0800          #< All entity ids (sets, blocks, maps) are int64_t values */
const EX_BULK_INT64_DB = 0x1000          #< All integer bulk data (local indices, counts, maps); not ids                         \*/
const EX_ALL_INT64_DB  = EX_MAPS_INT64_DB | EX_IDS_INT64_DB | EX_BULK_INT64_DB

const EX_MAPS_INT64_API = 0x2000         #< All maps (id, order, ...) store int64_t values */
const EX_IDS_INT64_API  = 0x4000         #< All entity ids (sets, blocks, maps) are int64_t values */
const EX_BULK_INT64_API = 0x8000         #< All integer bulk data (local indices, counts, maps); not ids */
const EX_INQ_INT64_API  = 0x10000        #< Integers passed to/from ex_inquire() are int64_t */
const EX_ALL_INT64_API  = EX_MAPS_INT64_API | EX_IDS_INT64_API | EX_BULK_INT64_API | EX_INQ_INT64_API

# Parallel IO mode flags
#
const EX_MPIIO          = 0x20000
const EX_MPIPOSIX       = 0x40000        #< \deprecated As of libhdf5 1.8.13. */
const EX_PNETCDF        = 0x80000

# ex_inquire() stuff
#
"""
    ex_inquiry
Inquiry enums (ex_inquiry in exodusII.h).
"""
@enum ex_inquiry begin
    EX_INQ_FILE_TYPE                  = 1  #< EXODUS file type (deprecated) */
    EX_INQ_API_VERS                   = 2  #< API version number (float) */
    EX_INQ_DB_VERS                    = 3  #< database version number (float) */
    EX_INQ_TITLE                      = 4  #< database title. MAX_LINE_LENGTH+1 char* size */
    EX_INQ_DIM                        = 5  #< number of dimensions */
    EX_INQ_NODES                      = 6  #< number of nodes    */
    EX_INQ_ELEM                       = 7  #< number of elements */
    EX_INQ_ELEM_BLK                   = 8  #< number of element blocks */
    EX_INQ_NODE_SETS                  = 9  #< number of node sets*/
    EX_INQ_NS_NODE_LEN                = 10 #< length of node set node list */
    EX_INQ_SIDE_SETS                  = 11 #< number of side sets*/
    EX_INQ_SS_NODE_LEN                = 12 #< length of side set node list */
    EX_INQ_SS_ELEM_LEN                = 13 #< length of side set element list */
    EX_INQ_QA                         = 14 #< number of QA records */
    EX_INQ_INFO                       = 15 #< number of info records */
    EX_INQ_TIME                       = 16 #< number of time steps in the database */
    EX_INQ_EB_PROP                    = 17 #< number of element block properties */
    EX_INQ_NS_PROP                    = 18 #< number of node set properties */
    EX_INQ_SS_PROP                    = 19 #< number of side set properties */
    EX_INQ_NS_DF_LEN                  = 20 #< length of node set distribution factor list*/
    EX_INQ_SS_DF_LEN                  = 21 #< length of side set distribution factor list*/
    EX_INQ_LIB_VERS                   = 22 #< API Lib vers number (float) */
    EX_INQ_EM_PROP                    = 23 #< number of element map properties */
    EX_INQ_NM_PROP                    = 24 #< number of node map properties */
    EX_INQ_ELEM_MAP                   = 25 #< number of element maps */
    EX_INQ_NODE_MAP                   = 26 #< number of node maps*/
    EX_INQ_EDGE                       = 27 #< number of edges    */
    EX_INQ_EDGE_BLK                   = 28 #< number of edge blocks */
    EX_INQ_EDGE_SETS                  = 29 #< number of edge sets   */
    EX_INQ_ES_LEN                     = 30 #< length of concat edge set edge list       */
    EX_INQ_ES_DF_LEN                  = 31 #< length of concat edge set dist factor list*/
    EX_INQ_EDGE_PROP                  = 32 #< number of properties stored per edge block    */
    EX_INQ_ES_PROP                    = 33 #< number of properties stored per edge set      */
    EX_INQ_FACE                       = 34 #< number of faces */
    EX_INQ_FACE_BLK                   = 35 #< number of face blocks */
    EX_INQ_FACE_SETS                  = 36 #< number of face sets */
    EX_INQ_FS_LEN                     = 37 #< length of concat face set face list */
    EX_INQ_FS_DF_LEN                  = 38 #< length of concat face set dist factor list*/
    EX_INQ_FACE_PROP                  = 39 #< number of properties stored per face block */
    EX_INQ_FS_PROP                    = 40 #< number of properties stored per face set */
    EX_INQ_ELEM_SETS                  = 41 #< number of element sets */
    EX_INQ_ELS_LEN                    = 42 #< length of concat element set element list       */
    EX_INQ_ELS_DF_LEN                 = 43 #< length of concat element set dist factor list*/
    EX_INQ_ELS_PROP                   = 44 #< number of properties stored per elem set      */
    EX_INQ_EDGE_MAP                   = 45 #< number of edge maps                     */
    EX_INQ_FACE_MAP                   = 46 #< number of face maps                     */
    EX_INQ_COORD_FRAMES               = 47 #< number of coordinate frames */
    EX_INQ_DB_MAX_ALLOWED_NAME_LENGTH = 48 #< size of MAX_NAME_LENGTH dimension on database */
    EX_INQ_DB_MAX_USED_NAME_LENGTH    = 49 #< size of MAX_NAME_LENGTH dimension on database */
    EX_INQ_MAX_READ_NAME_LENGTH       = 50 #< client-specified max size of returned names */
    EX_INQ_DB_FLOAT_SIZE              = 51 #< size of floating-point values stored on database */
    EX_INQ_NUM_CHILD_GROUPS           = 52 #< number of groups contained in this (exoid) group */
    EX_INQ_GROUP_PARENT               = 53 #< id of parent of this (exoid) group; returns exoid if at root */
    EX_INQ_GROUP_ROOT                 = 54 #< id of root group "/" of this (exoid) group; returns exoid if at root */
    EX_INQ_GROUP_NAME_LEN             = 55 #< length of name of group exoid */
    EX_INQ_GROUP_NAME                 = 56 #< name of group exoid. "/" returned for root group (char* GROUP_NAME_LEN+1 size) */
    EX_INQ_FULL_GROUP_NAME_LEN        = 57 #< length of full path name of this (exoid) group */
    EX_INQ_FULL_GROUP_NAME            = 58 #< full "/"-separated path name of this (exoid) group */
    EX_INQ_THREADSAFE                 = 59 #< Returns 1 if library is thread-safe; 0 otherwise */
    EX_INQ_ASSEMBLY                   = 60 #< number of assemblies */
    EX_INQ_BLOB                       = 61 #< number of blobs */
    EX_INQ_NUM_NODE_VAR               = 62 #< number of nodal variables */
    EX_INQ_NUM_EDGE_BLOCK_VAR         = 63 #< number of edge block variables */
    EX_INQ_NUM_FACE_BLOCK_VAR         = 64 #< number of face block variables */
    EX_INQ_NUM_ELEM_BLOCK_VAR         = 65 #< number of element block variables */
    EX_INQ_NUM_NODE_SET_VAR           = 66 #< number of node set variables */
    EX_INQ_NUM_EDGE_SET_VAR           = 67 #< number of edge set variables */
    EX_INQ_NUM_FACE_SET_VAR           = 68 #< number of face set variables */
    EX_INQ_NUM_ELEM_SET_VAR           = 69 #< number of element set variables */
    EX_INQ_NUM_SIDE_SET_VAR           = 70 #< number of sideset variables */
    EX_INQ_NUM_GLOBAL_VAR             = 71 #< number of global variables */
    EX_INQ_INVALID                    = -1
end

# TODO: finish below
# options type
#
# @enum ExOptionType begin
    
# end

# TODO figure out how to get | to work with enums, probably a new method dispatch
# @enum ex_options begin
EX_DEFAULT     = Int32(0)
EX_VERBOSE     = Int32(1) # verbose mode message flag
EX_DEBUG       = Int32(2) # debug mode def
EX_ABORT       = Int32(4) # abort mode flag def
EX_NULLVERBOSE = Int32(8) # verbose mode for null entity detection warning
# end

# entities
#
"""
    ex_entity_type
Entity type enums (ex_entity_type in exodusII.h)
"""
@enum ex_entity_type begin
    EX_NODAL      = 14 #< nodal "block" for variables*/
    # TODO: figure out how to enable below enum
    # TODO: julia enum won't let you define something
    # TODO: with the same value
    # EX_NODE_BLOCK = 14 #< alias for EX_NODAL         */
    EX_NODE_SET   = 2  #< node set property code     */
    EX_EDGE_BLOCK = 6  #< edge block property code   */
    EX_EDGE_SET   = 7  #< edge set property code     */
    EX_FACE_BLOCK = 8  #< face block property code   */
    EX_FACE_SET   = 9  #< face set property code     */
    EX_ELEM_BLOCK = 1  #< element block property code*/
    EX_ELEM_SET   = 10 #< face set property code     */

    EX_SIDE_SET   = 3  #< side set property code     */

    EX_ELEM_MAP   = 4  #< element map property code  */
    EX_NODE_MAP   = 5  #< node map property code     */
    EX_EDGE_MAP   = 11 #< edge map property code     */
    EX_FACE_MAP   = 12 #< face map property code     */

    EX_GLOBAL     = 13 #< global "block" for variables*/
    EX_COORDINATE = 15 #< kluge so some internal wrapper functions work */
    EX_ASSEMBLY   = 16 #< assembly property code */
    EX_BLOB       = 17 #< blob property code */
    EX_INVALID    = -1
end
