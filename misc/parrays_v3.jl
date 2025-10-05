using Exodus
using IterativeSolvers
using LinearAlgebra
using PartitionedArrays

h = 0.1
Ae = (h^2/6)* [
    4.0  -1.0  -1.0  -2.0
    -1.0   4.0  -2.0  -1.0
    -1.0  -2.0   4.0  -1.0
    -2.0  -1.0  -1.0   4.0
]
u(x) = x[1] + x[2]

mesh_file = "./square.g"
num_procs = 4
decomp(mesh_file, num_procs; use_nodal=false)
ranks = LinearIndices((num_procs,))

global_elems, global_nodes = Exodus.collect_global_element_and_node_numberings(mesh_file, num_procs)
exos, inits = ExodusDatabase(ranks, mesh_file)

dof_parts, elem_parts = partition_from_color(
    ranks, exos, global_elems, global_nodes
)

coords = map(exos) do exo
    read_coordinates(exo)
end

conns = map(exos) do exo
    read_sets(exo, Block)[1].conn
end

nset_nodes = map(exos) do exo
    read_set(exo, NodeSet, "boundary").nodes
end

Is, Vs = tuple_of_arrays(map(dof_parts, conns, coords, nset_nodes) do part, conn, coord, nset_node
    Is = Int[]
    Vs = Float64[]
    conn = local_to_global(part)[conn]
    ue = zeros(size(Ae, 2))
    ge = similar(ue)
    for e in axes(conn, 2)
        fill!(ue, 0.0)
        for n in axes(conn, 1)
            ue[n] = u(coord[:, n])
        end
        mul!(ge, Ae, ue)
        for n in axes(conn, 1)
            push!(Is, conn[n, e])

            if conn[n, e] in nset_node
                push!(Vs, 0.)
            else
                push!(Vs, -ge[n])
            end
        end
    end
    Is, Vs
end)

IIs, JJs, VVs = tuple_of_arrays(map(dof_parts, conns, nset_nodes) do part, conn, nset_node
    IIs, JJs = Int[], Int[]
    VVs = Float64[]
    conn = local_to_global(part)[conn]
    for e in axes(conn, 2)
        for i in axes(conn, 1)
            for j in axes(conn, 1)
                # if !((conn[i, e] in part.own.own_to_global) && 
                #      (conn[j, e] in part.own.own_to_global))
                #     continue
                # end

                # if !(conn[j, e] in part.own.own_to_global)
                #     continue
                # end

                push!(IIs, conn[i, e])
                push!(JJs, conn[j, e])

                if conn[i, e] in nset_node
                    if i == j
                        push!(VVs, 1.)
                    else
                        push!(VVs, 0.)
                    end
                else
                    push!(VVs, Ae[i, j])
                end
            end
        end
    end
    IIs, JJs, VVs
end)

b = pvector(Is, Vs, dof_parts) |> fetch
A = psparse(IIs, JJs, VVs, dof_parts, dof_parts; restore_ids=false) |> fetch

x = IterativeSolvers.cg(A, b, verbose=i_am_main(ranks))

r = A * x - b

p_coords_x = pzeros(dof_parts)
p_coords_y = pzeros(dof_parts)
p_parts_x, p_parts_y = tuple_of_arrays(map(local_values(p_coords_x), local_values(p_coords_y), coords) do p_part_x, p_part_y, coord
    p_part_x .= coord[1, :]
    p_part_y .= coord[2, :]
    p_part_x, p_part_y
end)
p_coord_x = PVector(p_parts_x, dof_parts)
p_coord_y = PVector(p_parts_y, dof_parts)

consistent!(p_coord_x)
consistent!(p_coord_y)

# norm(r)
map(partition(x), partition(p_coord_x), partition(p_coord_y), ranks) do x_part, coord_x, coord_y, rank
    # old_file = mesh_file * ".4.$(rank - 1)"
    # new_file = "output-" * strip(old_file, '/')[1]
    # @show new_file
    old_file = mesh_file * ".4.$(rank - 1)"
    new_file = "output.e.4.$(rank - 1)" 
    copy_mesh(old_file, new_file)
    exo = ExodusDatabase(new_file, "rw")
    write_time(exo, 1, 0.)
    write_names(exo, NodalVariable, ["x", "y"])
    # @show typeof(coord[1, :])
    write_values(exo, NodalVariable, 1, "x", coord_x)
    write_values(exo, NodalVariable, 1, "y", coord_y)
    close(exo)

    # epu("output.e")
end

epu("output.e")