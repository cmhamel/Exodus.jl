using Exodus
using IterativeSolvers
using LinearAlgebra
using PartitionedArrays

###############################################
# setup and helpers
###############################################
u(x) = x[1] + x[2]
h = 0.1
Ae = (h^2 / 6) * [
    4.0  -1.0  -1.0  -2.0
    -1.0   4.0  -2.0  -1.0
    -1.0  -2.0   4.0  -1.0
    -2.0  -1.0  -1.0   4.0
]

mesh_file = "./square.g"
num_procs = 4

###############################################
# setup, can't be with MPI otherwise decomp will
# run on each rank
###############################################

decomp(mesh_file, num_procs)

nemesis_file = mesh_file * ".nem"
nem = ExodusDatabase(nemesis_file, "r")
num_proc, _, _ = Exodus.read_init_info(nem)
init_global = Exodus.InitializationGlobal(nem)
n_nodes_global = Exodus.num_nodes(init_global) |> Int64
close(nem)

colors = Exodus.collect_global_node_to_color(mesh_file, num_procs)
# display(colors)
###############################################
# partitioning
###############################################

ranks = LinearIndices((num_procs,))

exos = map(ranks) do rank
    file_name = mesh_file * ".4.$(rank - 1)"
    ExodusDatabase(file_name, "r")
end

parts = map(ranks, exos) do rank, exo
    node_maps = read_id_map(exo, NodeMap)

    ghost_nodes, ghost_procs = Exodus.read_ghost_nodes_and_procs(rank, exo)

    own_nodes = filter(x -> x ∉ ghost_nodes, node_maps)
    own_nodes = convert(Vector{Int64}, own_nodes)

    ghost_indices = GhostIndices(n_nodes_global, ghost_nodes, ghost_procs)
    own_indices = OwnIndices(n_nodes_global, rank, own_nodes)

    return OwnAndGhostIndices(own_indices, ghost_indices, colors)
end

conns = map(exos) do exo
    read_sets(exo, Block)[1].conn
end

coords = map(exos) do exo
    read_coordinates(exo)
end

boundary_nodes = map(exos) do exo
    # nsets = read_sets(exo, NodeSet)
    # display(nsets)
    nodes = read_sets(exo, NodeSet)
    nodes = mapreduce(x -> x.nodes, vcat, nodes)
end

# setup rhs vector
function setup_matrix(conn, part)
    Is = Int[]
    Js = Int[]
    Vs = Float64[]
    dofs = local_to_global(part)
    for e in axes(conn, 2)
        for i in axes(conn, 1)
            for j in axes(conn, 1)
                push!(Is, dofs[conn[i, e]])
                push!(Js, dofs[conn[j, e]])
                push!(Vs, Ae[i, j])
            end
        end
    end
    return Is, Js, Vs
end

function setup_rhs(boundary, conn, coord, part)
    Is = Int[]
    Vs = Float64[]
    ue = zeros(size(Ae,2))
    ge = similar(ue)
    dofs = local_to_global(part)
    for e in axes(conn, 2)
        X = coord[:, conn[:, e]]
        fill!(ue, zero(eltype(ue)))
        for n in axes(conn, 1)
            # local_dof = dofs[conn[n, e]]
            local_dof = conn[n, e]
            if local_dof in boundary
                ue[n] = u(X[:, n])
            end
            # push!(Is, local_dof)
        end

        mul!(ge, Ae, ue)
        for n in axes(conn, 1)
            global_dof = dofs[conn[n, e]]
            push!(Is, global_dof)
            push!(Vs, -ge[n])
        end
    end

    return Is, Vs
end

Is, Js, Vs = tuple_of_arrays(map(conns, parts) do conn, part
    setup_matrix(conn, part)
end)
A = psparse(Is, Js, Vs, parts, parts) |> fetch

IIs, VVs = tuple_of_arrays(map(boundary_nodes, conns, coords, parts) do boundary, conn, coord, part
    setup_rhs(boundary, conn, coord, part)
end)
b = pvector(IIs, VVs, parts) |> fetch

x = IterativeSolvers.cg(A, b, verbose=i_am_main(rank))
# assemble!(rhs) |> wait
# rhs
# a = pzeros(parts)

# test assembly
