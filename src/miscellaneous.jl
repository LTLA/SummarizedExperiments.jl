function Base.copy(x::SummarizedExperiment)
    return SummarizedExperiment(
        copy(x.assays), 
        copy(x.rowdata), 
        copy(x.coldata), 
        copy(x.metadata)
    )
end

function Base.deepcopy(x::SummarizedExperiment)
    return SummarizedExperiment(
        deepcopy(x.assays), 
        deepcopy(x.rowdata), 
        deepcopy(x.coldata), 
        deepcopy(x.metadata)
    )
end

function scat(io::IO, names::Vector{String})
    if length(names) < 5
        for n in names
            print(io, " " * n)
        end
    else
        print(io, " " * names[1])
        print(io, " " * names[2])
        print(io, " ... ")
        print(io, " " * names[length(names)-1])
        print(io, " " * names[length(names)])
    end
end

function Base.show(io::IO, x::SummarizedExperiment)
    xdim = size(x)
    print(io, string(xdim[1]) * "x" * string(xdim[2]) * " " * string(typeof(x)) * "\n")

    print(io, "  " * "assays(" * string(length(assays(x))) * "):")
    scat(io, collect(keys(assays(x))))
    print(io, "\n")

    print(io, "  " * "rowdata(" * string(size(rowdata(x))[2]) * "):")
    scat(io, names(rowdata(x)))
    print(io, "\n")

    print(io, "  " * "coldata(" * string(size(coldata(x))[2]) * "):")
    scat(io, names(coldata(x)))
    print(io, "\n")

    print(io, "  " * "metadata(" * string(length(metadata(x))) * "):")
    scat(io, collect(keys(metadata(x))))
end 
