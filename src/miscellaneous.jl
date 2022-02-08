"""
    copy(x::SummarizedExperiment)

Return a copy of `x`, where all components are identically-same as those in `x`.

# Examples
```jldoctest
julia> using SummarizedExperiments, DataFrames

julia> x = exampleobject(20, 10);

julia> x2 = copy(x);

julia> setrowdata!(x2, DataFrame());

julia> size(rowdata(x)) # Change to reference is only reflected in x2.
(20, 2)

julia> size(rowdata(x2))
(0, 0)

julia> insertcols!(coldata(x), 1, "WHEE" => 1:10); # Otherwise, references point to the same object.

julia> names(coldata(x2))
4-element Array{String,1}:
 "WHEE"
 "ID"
 "Treatment"
 "Response"
```
"""
function Base.copy(x::SummarizedExperiment)
    output = SummarizedExperiment()

    output.assays = x.assays
    output.rowdata = x.rowdata
    output.coldata = x.coldata
    output.metadata = x.metadata

    return output
end

"""
    deepcopy(x::SummarizedExperiment)

Return a deep copy of `x` and all of its components.

# Examples
```jldoctest
julia> using SummarizedExperiments, DataFrames

julia> x = exampleobject(20, 10);

julia> x2 = deepcopy(x);

julia> setrowdata!(x2, DataFrame());

julia> size(rowdata(x)) # Change to reference is only reflected in x2.
(20, 2)

julia> size(rowdata(x2))
(0, 0)

julia> insertcols!(coldata(x), 1, "WHEE" => 1:10); # References now point to different objects.

julia> names(coldata(x2))
3-element Array{String,1}:
 "ID"
 "Treatment"
 "Response"
```
"""
function Base.deepcopy(x::SummarizedExperiment)
    output = SummarizedExperiment()

    output.assays = deepcopy(x.assays)
    output.rowdata = deepcopy(x.rowdata)
    output.coldata = deepcopy(x.coldata)
    output.metadata = deepcopy(x.metadata)

    return output
end

function scat(io::IO, names::Vector{String})
    if length(names) < 5
        for n in names
            print(io, " " * n)
        end
    else
        print(io, " " * names[1])
        print(io, " " * names[2])
        print(io, " ...")
        print(io, " " * names[length(names)-1])
        print(io, " " * names[length(names)])
    end
end

"""
    print(io::IO, x::SummarizedExperiment)

Print a summary of `x`.
"""
function Base.show(io::IO, x::SummarizedExperiment)
    xdim = size(x)
    print(io, string(xdim[1]) * "x" * string(xdim[2]) * " " * string(typeof(x)) * "\n")

    print(io, "  assays(" * string(length(assays(x))) * "):")
    scat(io, collect(keys(assays(x))))
    print(io, "\n")

    print(io, "  rownames:")
    rn = rowdata(x)[!,1]
    if isa(rn, Vector{String})
        scat(io, rn)
    end
    print(io, "\n")

    print(io, "  rowdata(" * string(size(rowdata(x))[2]) * "):")
    scat(io, names(rowdata(x)))
    print(io, "\n")

    print(io, "  colnames:")
    cn = coldata(x)[!,1]
    if isa(cn, Vector{String})
        scat(io, cn)
    end
    print(io, "\n")

    print(io, "  " * "coldata(" * string(size(coldata(x))[2]) * "):")
    scat(io, names(coldata(x)))
    print(io, "\n")

    print(io, "  " * "metadata(" * string(length(metadata(x))) * "):")
    scat(io, collect(keys(metadata(x))))
end 
