# TODO add relevant options to macro
# check exodiff -h for all the options from
# a regular seacas build
macro exodiff(ex_1, ex_2)
    println("ex_1 = $ex_1, ex_2 = $ex_2")
    exodiff_exe() do exe
        run(`$exe $ex_1 $ex_2`)
    end
end