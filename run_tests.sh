rm -f test/*.g
rm -f test/*.g.*.*
rm -f test/*.g.pex test/*.g.nem
rm -f test/*.e
rm -f test/example_output/*.e
rm -f test/epu_mesh_test.g
rm -f *.log
rm -f test/*.log
julia --project=@. -e 'using Pkg; Pkg.test()'
