# const exo_lib_path = ENV["EXODUS_LIB_PATH"] # TODO: this needs to be set in ~/.bashrc

const EX_WRITE = 0x0001
const EX_READ = 0x0002
const EX_NOCLOBBER = 0x0004
const EX_CLOBBER = 0x0008

const EX_ELEM_BLOCK = 1
const EX_NODE_SET = 2

const MAX_LINE_LENGTH = 80
const MAX_STR_LENGTH = 32

const cpu_word_size = Ref{Int64}(sizeof(Float64))
const IO_word_size = Ref{Int64}(8)

# TODO: make this be read in from the OS or something like that
#
const version_number_1 = 8
const version_number_2 = 15
const version_number = 8.15


# TODO: add the entirity from the exoudsII header
