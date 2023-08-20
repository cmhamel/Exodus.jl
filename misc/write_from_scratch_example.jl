using Exodus

# data to write
coords = [
  1.0 0.5 0.5 1.0 0.0 0.0 0.5 1.0 0.0
  1.0 1.0 0.5 0.5 1.0 0.5 0.0 0.0 0.0
]

conn = [
  1 2 4 3
  2 5 3 6
  3 6 7 9
  4 3 8 7
]

# make some hack variables to write
v_nodal_1 = rand(9)
v_nodal_2 = rand(9)

v_elem_1 = rand(4)
v_elem_2 = rand(4)

# set the types
maps_int_type = Int32
ids_int_type  = Int32
bulk_int_type = Int32
float_type    = Float64

# initialization parameters
num_dim, num_nodes = size(coords)
num_elems          = size(conn, 2)
num_elem_blks      = 1
num_side_sets      = 0
num_node_sets      = 0

# make init
init = Initialization{bulk_int_type}(
  num_dim, num_nodes, num_elems,
  num_elem_blks, num_side_sets, num_node_sets
)

# finally make empty exo database
exo = ExodusDatabase(
  "test_write.e", "w", init,
  maps_int_type, ids_int_type, bulk_int_type, float_type
)

# how to write coordinates
write_coordinates(exo, coords)
# how to write a block
write_block(exo, 1, "QUAD4", conn)
# need at least one timestep to output variables
write_time(exo, 1, 0.0)
# write number of variables and their names
write_number_of_variables(exo, NodalVariable, 2)
write_names(exo, NodalVariable, ["v_nodal_1", "v_nodal_2"])
write_number_of_variables(exo, ElementVariable, 2)
write_names(exo, ElementVariable, ["v_elem_1", "v_elem_2"])
# write variable values the 1 is for the time step
write_values(exo, NodalVariable, 1, "v_nodal_1", v_nodal_1)
write_values(exo, NodalVariable, 1, "v_nodal_2", v_nodal_2)
# the first 1 is for the time step 
# and the second 1 is for the block number
write_values(exo, ElementVariable, 1, 1, "v_elem_1", v_elem_1)
write_values(exo, ElementVariable, 1, 1, "v_elem_2", v_elem_2)
# don't forget to close the exodusdatabase, it can get corrupted otherwise if you're writing
close(exo)
