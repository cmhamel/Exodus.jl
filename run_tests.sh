rm -f test/*.e
rm -f test/*.g.pex test/*.g.nem
rm -f test/example_output/*.e
julia --project=@. -e 'using Pkg; Pkg.test()'
