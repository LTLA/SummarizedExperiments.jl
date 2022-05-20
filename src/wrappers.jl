mat1 = ones(10, 10)
mat2 = zeros(20, 5)
assays = OrderedDict{String, AbstractArray}("matrix1" => mat1,
                                            "matrix2" => mat2)

function make_assays(kwargs...)

    