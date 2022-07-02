struct Initialization <: FEMContainer
    num_dim::Int64
    num_nodes::Int64
    num_elems::Int64
    num_elem_blks::Int64
    num_node_sets::Int64
    num_side_sets::Int64
    function Initialization(exo_id::ExoID)
        num_dim = Ref{Int64}(0)
        num_nodes = Ref{Int64}(0)
        num_elems = Ref{Int64}(0)
        num_elem_blks = Ref{Int64}(0)
        num_node_sets = Ref{Int64}(0)
        num_side_sets = Ref{Int64}(0)
        error = Ref{Int64}(0)

        title = Vector{UInt8}(undef, MAX_LINE_LENGTH)
        error = ccall((:ex_get_init, libexodus), ExodusError,
                    (ExoID, Ptr{UInt8},
                    Ref{Int64}, Ref{Int64}, Ref{Int64},
                    Ref{Int64}, Ref{Int64}, Ref{Int64}),
                    exo_id, title,
                    num_dim, num_nodes, num_elems,
                    num_elem_blks, num_node_sets, num_side_sets)
        title = unsafe_string(pointer(title))
        exodus_error_check(error, "read_initialization_parameterss")
        return new(num_dim[], num_nodes[], num_elems[],
                   num_elem_blks[], num_node_sets[], num_side_sets[])
    end
end
Base.show(io::IO, init::Initialization) =
print(io, "Initialization:\n",
          "\tNumber of dim       = ", init.num_dim, "\n",
          "\tNumber of nodes     = ", init.num_nodes, "\n",
          "\tNumber of elem      = ", init.num_elems, "\n",
          "\tNumber of blocks    = ", init.num_elem_blks, "\n",
          "\tNumber of node sets = ", init.num_node_sets, "\n",
          "\tNumber of side sets = ", init.num_side_sets, "\n")

# Attempting to access parallel information
struct GlobalInitialization <: FEMContainer
    num_nodes::Int64
    num_elems::Int64
    num_elem_blks::Int64
    num_node_sets::Int64
    num_side_sets::Int64
    function GlobalInitialization(exo_id::ExoID)
        num_nodes = Ref{Int64}(0)
        num_elems = Ref{Int64}(0)
        num_elem_blks = Ref{Int64}(0)
        num_node_sets = Ref{Int64}(0)
        num_side_sets = Ref{Int64}(0)
        error = ccall((:ex_get_init_global, libexodus), ExodusError,
                      (ExoID, Ref{Int64}, Ref{Int64}, Ref{Int64}, Ref{Int64}, Ref{Int64}),
                      exo_id, num_nodes, num_elems, num_elem_blks, num_node_sets, num_side_sets)
        exodus_error_check(error, "GlobalInitialization")
        return new(num_nodes[], num_elems[], num_elem_blks[], num_node_sets[], num_side_sets[])
    end
end
Base.show(io::IO, init::GlobalInitialization) =
print(io, "GlobalInitialization:\n",
          "\tNumber of nodes     = ", init.num_nodes, "\n",
          "\tNumber of elem      = ", init.num_elems, "\n",
          "\tNumber of blocks    = ", init.num_elem_blks, "\n",
          "\tNumber of node sets = ", init.num_node_sets, "\n",
          "\tNumber of side sets = ", init.num_side_sets, "\n")

struct LoadBalanceInitialization <: FEMContainer
    num_internal_nodes::Int64
    num_border_nodes::Int64
    num_external_nodes::Int64
    num_internal_elems::Int64
    num_border_elems::Int64
    num_node_cmaps::Int64
    num_elem_cmaps::Int64
    processor::Int64
    function LoadBalanceInitialization(exo_id::ExoID, processor::Int64)
        num_internal_nodes = Ref{Int64}(0)
        num_border_nodes = Ref{Int64}(0)
        num_external_nodes = Ref{Int64}(0)
        num_internal_elems = Ref{Int64}(0)
        num_border_elems = Ref{Int64}(0)
        num_node_cmaps = Ref{Int64}(0)
        num_elem_cmaps = Ref{Int64}(0)
        # processor = 1
        error = ccall((:ex_get_loadbal_param, libexodus), ExodusError,
                      (ExoID, 
                       Ref{Int64}, Ref{Int64}, Ref{Int64}, Ref{Int64},
                       Ref{Int64}, Ref{Int64}, Ref{Int64}, Int64),
                      exo_id, 
                      num_internal_nodes, num_border_nodes, num_external_nodes, 
                      num_internal_elems, num_border_elems,
                      num_node_cmaps, num_elem_cmaps, processor)
        exodus_error_check(error, "LoadBalanceInitialization")
        return new(num_internal_nodes[], num_border_nodes[], num_external_nodes[],
                   num_internal_elems[], num_border_elems[],
                   num_node_cmaps[], num_elem_cmaps[], processor)
    end
end
Base.show(io::IO, init::LoadBalanceInitialization) =
print(io, "Initialization:\n",
          "\tNumber of internal nodes             = ", init.num_internal_nodes, "\n",
          "\tNumber of border nodes               = ", init.num_border_nodes, "\n",
          "\tNumber of external nodes             = ", init.num_external_nodes, "\n",
          "\tNumber of internal elements          = ", init.num_internal_elems, "\n",
          "\tNumber of border elements            = ", init.num_border_elems, "\n",
          "\tNumber of node communication maps    = ", init.num_node_cmaps, "\n",
          "\tNumber of element communication maps = ", init.num_elem_cmaps, "\n",
          "\tProcessor number                     = ", init.processor, "\n")
number_of_total_nodes(init::LoadBalanceInitialization) = init.num_internal_nodes + init.num_border_nodes + init.num_external_nodes
number_of_total_elements(init::LoadBalanceInitialization) = init.num_internal_elems + init.num_border_elems

struct ParallelInitialization <: FEMContainer
    number_of_procesors::Int64
    number_of_procesors_in_file::Int64
    function ParallelInitialization(exo_id::ExoID)
        num_procs = Ref{Int64}(0)
        num_procs_in_file = Ref{Int64}(0)
        info = Vector{UInt8}(undef, MAX_LINE_LENGTH)
        error = ccall((:ex_get_init_info, libexodus), ExodusError,
                      (ExoID, Ref{Int64}, Ref{Int64}, Ptr{UInt8}),
                      exo_id, num_procs, num_procs_in_file, info)
        info = unsafe_string(pointer(info))
        @show info
        exodus_error_check(error, "ParallelInitialization")
        return new(num_procs[], num_procs_in_file[])
    end
end
Base.show(io::IO, init::ParallelInitialization) = 
print(io, "ParallelInitialization:\n",
          "\tNumber of processors         = ", init.number_of_procesors, "\n",
          "\tNumber of processors in file = ", init.number_of_procesors_in_file, "\n")
