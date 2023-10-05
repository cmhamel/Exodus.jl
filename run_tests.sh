rm -f test/*.g
rm -f test/*.g.*.*
rm -f test/*.e
rm -f test/*.g.pex test/*.g.nem
rm -f test/example_output/*.e
rm -f test/epu_mesh_test.g
julia --project=@. -e 'using Pkg; Pkg.test()'
