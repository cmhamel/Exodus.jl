using Exodus
using PartitionedArrays

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

n_nodes_global = Exodus.num_nodes(init_global)
n_elems_global = Exodus.num_elements(init_global)
close(nem)

###############################################
# partitioning
###############################################
ranks = LinearIndices((num_procs,))

# easy
dof_partition = uniform_partition(ranks, Int64(n_nodes_global))
# harder
# global_to_color = Exodus.collect_global_element_to_color(mesh_file, num_procs)
global_to_color = Exodus.collect_global_node_to_color(mesh_file, num_procs)
cell_partition = partition_from_color(ranks, mesh_file, global_to_color)

# setting stuff up
exos = map(ranks) do rank
    ExodusDatabase(mesh_file * ".4.$(rank - 1)", "r")
end

elem_maps, node_maps = tuple_of_arrays(map(exos) do exo
    elem_maps = read_id_map(exo, ElementMap)
    node_maps = read_id_map(exo, NodeMap)
    elem_maps, node_maps
end)

# need to get number of nodes local to each element
jag_arrs = map(exos) do exo
    block_ids = read_ids(exo, Block)
    block_params = Exodus.read_block_parameters.((exo,), block_ids)
    n_nodes_per_el = mapreduce(x -> x[3] * ones(Int, x[2]), vcat, block_params)
    n_local_els = mapreduce(x -> x[2], sum, block_params)

    ptrs = zeros(Int, n_local_els + 1)
    ptrs[2:end] .= n_nodes_per_el
    length_to_ptrs!(ptrs)

    total_entries = sum(n_nodes_per_el)
    data = zeros(Int, total_entries)
    JaggedArray(data, ptrs)
end

map(elem_maps, jag_arrs) do elem_map, jag_arr
    # display(elem_map)
    for elem in axes(elem_map, 1)

    end
    display(jag_arr)
end

cmaps = map(ranks, exos) do rank, exo
    Exodus.read_node_cmaps(rank, exo)
end

# ptrs = zeros(Int, n_node)

# owners = find_owner(dof_partition, global_ids)

# a = pones(dof_partition)
# neighbors = assembly_local_indices(cell_partition)
# map(neighbors) do neigh
#     neigh
# end

# TODO
# 1. need to convert the cell_partition to procs for each dof


# 2. setup up neighbor graph

# map(local_to_own, dof_partition)
# map(local_values(a), cell_partition, dof_partition) do a_part, cell_part, dof_part
#     # a_part
#     dof_owners = own_to_owner(dof_part)

# end


# a = pones(dof_partition)

# map(local_values(a), cell_partition, dof_partition) do a_part, cell_part, dof_part
#     a_part
# end

# a = pones(parts)

# t = assemble!(PartitionedArrays.insert, partition(a), a.cache)
