# export size, rowdata, coldata, assay, assays, metadata
# import DataFrames
# import DataStructures

"""
    size(x::SummarizedExperiment)

Return a 2-tuple containing the number of rows and columns in `x`.

# Examples
```jldoctest
julia> using SummarizedExperiments

julia> x = exampleobject(20, 10);

julia> size(x)
(20, 10)
```
"""
function Base.size(x::SummarizedExperiment)
    return (size(x.rowdata)[1], size(x.coldata)[1])
end

function check_dataframe_in_getter(value::DataFrames.DataFrame, expected::Int, message::String)
    if expected != size(value)[1]
        @warn "'" * message * "(x)' has a different number of rows than 'x'"
        return
    end

    if !check_dataframe_has_name(value)
        @warn "first column of '" * message * "(x)' should exist and be called 'name'"
        return
    end

    if !check_dataframe_firstcol(value)
        @warn "first column of '" * message * "(x)' should be a vector of strings or nothings" 
        return
    end
end

"""
    rowdata(x; check = true)

Return the row annotations as a `DataFrame` with number of rows equal to the number of rows in `x`.
The first column is called `"name"` and contains the row names of `x`;
this can either be an `AbstractVector{AbstractString}` or a `Vector{Nothing}` (if no row names are available).

If `check = true`, this function will verify that the above expectations on the returned `DataFrame` are satisfied.
Any failures will cause warnings to be emitted.

# Examples
```jldoctest
julia> using SummarizedExperiments

julia> x = exampleobject(20, 10);

julia> names(rowdata(x))
2-element Vector{String}:
 "name"
 "Type"

julia> size(rowdata(x))
(20, 2)
```
"""
function rowdata(x::SummarizedExperiment; check = true)
    output = x.rowdata
    if check
        check_dataframe_in_getter(output, size(x)[1], "rowdata")
    end
    return output
end

"""
    coldata(x, check = true)

Return the column annotations as a `DataFrame` with number of rows equal to the number of columns in `x`.
The first column is called `"name"` and contains the column names of `x`;
this can either be a `Vector{String}` or a `Vector{Nothing}` (if no column names are available).

If `check = true`, this function will verify that the expectations on the returned `DataFrame` are satisfied.
Any failures will cause warnings to be emitted.

# Examples
```jldoctest
julia> using SummarizedExperiments

julia> x = exampleobject(20, 10);

julia> names(coldata(x))
3-element Vector{String}:
 "name"
 "Treatment"
 "Response"

julia> size(coldata(x))
(10, 3)
```
"""
function coldata(x::SummarizedExperiment; check = true)
    output = x.coldata
    if check
        check_dataframe_in_getter(output, size(x)[2], "coldata")
    end
    return output
end

"""
    assay(x[, i]; check = true)

Return the requested assay in `x`.
`i` may be an integer specifying an index or a string containing the name.
If `i` is not supplied, the first assay is returned. 

The returned assay should have the same extents as `x` for the first two dimensions.
If `check = true`, this function will verify that this expectation is satisfied.
Any failures will cause warnings to be emitted.

# Examples
```jldoclist
julia> using SummarizedExperiments

julia> x = exampleobject(20, 10);

# All of these give the same value.
julia> assay(x);

julia> assay(x, 1);

julia> assay(x, "foo");
```
"""
function assay(x::SummarizedExperiment; check = true)
    return assay(x, 1; check = check)
end

function assay(x::SummarizedExperiment, i::Int64; check = true)
    counter = 0

    for val in values(x.assays)
        counter += 1
        if counter == i
            if check
                if !check_assay_dimensions(size(val), size(x))
                    @warn "dimensions of assay '" * string(i) * "' do not match those of 'x'"
                end
            end
            return val
        end
    end

    throw(BoundsError("'i = " * string(i) * "' is out of range of 'assays(x)'"))
end

function assay(x::SummarizedExperiment, i::String; check = true)
    if !haskey(x.assays, i)
        throw(KeyError("'" * i * "' is not present in 'assays(x)'"))
    end

    val = x.assays[i]
    if check
        if !check_assay_dimensions(size(val), size(x))
            @warn "dimensions of assay '" * i * "' do not match those of 'x'"
        end
    end

    return val
end

"""
    assays(x; check = true)

Return all assays from `x` as an `OrderedDict` where the keys are the assay names.
Each returned assay should have the same extents as `x` for the first two dimensions.
If `check = true`, this function will verify that this expectation is satisfied.
Any failures will cause warnings to be emitted.

# Examples
```jldoctest
julia> using SummarizedExperiments

julia> x = exampleobject(20, 10);

julia> collect(keys(assays(x)))
3-element Vector{String}:
 "foo"
 "bar"
 "whee"
```
"""
function assays(x::SummarizedExperiment; check = true)
    if check
        for (k, v) in x.assays
            if !check_assay_dimensions(size(v), size(x))
                @warn "dimensions of assay '" * k * "' do not match those of 'x'"
            end
        end
    end
    return x.assays
end

"""
    metadata(x)

Return metadata from `x` as a `Dict` where the keys are the metadata field names.

# Examples
```jldoctest
julia> using SummarizedExperiments

julia> x = exampleobject(20, 10);

julia> metadata(x)
Dict{String, Any} with 1 entry:
  "version" => "1.1.0"
```
"""
function metadata(x::SummarizedExperiment)
    return x.metadata;
end
