struct Initialization <: FEMContainer
    num_dim::Int64
    num_nodes::Int64
    num_elem::Int64
    num_elem_blk::Int64
    num_node_sets::Int64
    num_side_sets::Int64
end
Base.show(io::IO, init::Initialization) =
print(io, "Initialization:\n",
          "\tNum dim       = ", init.num_dim, "\n",
          "\tNum nodes     = ", init.num_nodes, "\n",
          "\tNum elem      = ", init.num_elem, "\n",
          "\tNum blocks    = ", init.num_elem_blk, "\n",
          "\tNum node sets = ", init.num_node_sets, "\n",
          "\tNum side sets = ", init.num_side_sets, "\n")

function get_initialization(exo_id::ExoID)
    num_dim, num_nodes, num_elem,
    num_elem_blk, num_node_sets, num_side_sets, title =
    read_initialization_parameters(exo_id)
    return Initialization(num_dim, num_nodes, num_elem,
                          num_elem_blk, num_node_sets, num_side_sets)
end

function read_initialization_parameters(exo_id::ExoID)
    num_dim = Ref{Int64}(0)
    num_nodes = Ref{Int64}(0)
    num_elem = Ref{Int64}(0)
    num_elem_blk = Ref{Int64}(0)
    num_node_sets = Ref{Int64}(0)
    num_side_sets = Ref{Int64}(0)
    error = Ref{Int64}(0)

    # title = "" # TODO: fix this to behave like Vector{UInt8}(undef, MAX_STR_LENGTH)
    title = Vector{UInt8}(undef, MAX_LINE_LENGTH)
    error = ccall((:ex_get_init, exo_lib_path), Int64,
                  (ExoID, Ptr{UInt8},
                   Ref{Int64}, Ref{Int64}, Ref{Int64},
                   Ref{Int64}, Ref{Int64}, Ref{Int64}),
                  exo_id, title,
                  num_dim, num_nodes, num_elem,
                  num_elem_blk, num_node_sets, num_side_sets)

    title = unsafe_string(pointer(title))
    exodus_error_check(error, "read_initialization_parameterss")

    return num_dim[], num_nodes[], num_elem[],
           num_elem_blk[], num_node_sets[], num_side_sets[], title
end
