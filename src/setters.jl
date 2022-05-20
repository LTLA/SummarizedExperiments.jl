# export setrowdata!, setcoldata!, setassay!, setassays!, setmetadata!
# import DataFrames
# import DataStructures

function check_dataframe_in_setter(value::DataFrame, expected::Int, message::String)
    if size(value)[1] != expected
        throw(DimensionMismatch("'value' and '" * message *"(x)' should have the same number of rows"))
    end

    if !check_dataframe_has_name(value)
        throw(DimensionMismatch("first column of 'value' should exist and be called 'name'"))
    end

    if !check_dataframe_firstcol(value)
        throw(ArgumentError("first column of 'value' should contain strings or nothings"));
    end
end

"""
    setrowdata!(x, value)

Set the row annotations in `x` to `value`.

If `value` is a `DataFrame`, the first column should be called `"name"` and contain the row names of `x`;
this can either be an `AbstractVector{AbstractString}` or a `Vector{Nothing}` (if no row names are available).

If `value` is `nothing`, this is considered to be equivalent to a `DataFrame` with one `"name"` column containing `nothing`s.

The return value is a reference to the modified `x`.

# Examples
```jldoctest
julia> using SummarizedExperiments

julia> x = exampleobject(20, 10);

julia> # using DataFrames

julia> replacement = copy(rowdata(x));

julia> replacement[!,"foobar"] = [ rand() for i in 1:size(x)[1] ];

julia> setrowdata!(x, replacement);

julia> names(rowdata(x))
3-element Vector{String}:
 "name"
 "Type"
 "foobar"
```
"""    
function setrowdata!(x::SummarizedExperiment, value::Union{DataFrame,Nothing})
    if isa(value, Nothing)
        x.rowdata = DataFrame(name = Vector{Nothing}(undef, size(x)[1]))
    else
        check_dataframe_in_setter(value, size(x)[1], "rowdata")
        x.rowdata = value
    end
    return x
end 

"""
    setcoldata!(x, value)

Set the column annotations in `x` to `value`.

If `value` is a `DataFrame`, the first column should be called `"name"` and contain the column names of `x`;
this can either be a `Vector{String}` or a `Vector{Nothing}` (if no column names are available).

If `value` is `nothing`, this is considered to be equivalent to a `DataFrame` with one `"name"` column containing `nothing`s.

The return value is a reference to the modified `x`.

# Examples
```jldoctest
julia> using SummarizedExperiments

julia> x = exampleobject(20, 10);

julia> # using DataFrames

julia> replacement = copy(coldata(x));

julia> replacement[!,"foobar"] = [ rand() for i in 1:size(x)[2] ];

julia> setcoldata!(x, replacement);

julia> names(coldata(x))
4-element Vector{String}:
 "name"
 "Treatment"
 "Response"
 "foobar"
```
"""
function setcoldata!(x::SummarizedExperiment, value::Union{DataFrame,Nothing})
    if isa(value, Nothing)
        x.coldata = DataFrame(name = Vector{Nothing}(undef, size(x)[2]))
    else
        check_dataframe_in_setter(value, size(x)[2], "coldata")
        x.coldata = value
    end
    return x
end 

"""
    setassay!(x[, i], value)

Set the requested assay in `x` to any array-like `value`.
The first two dimensions of `value` must have extent equal to those of `x`.

`i` may be an integer specifying an index, in which case it must be positive and no greater than `length(assays(x))`;
or a string containing the name, in which case it may be an existing or new name.
If `i` is not supplied, `value` is set as the first assay of `x`.

# Examples
```jldoctest
julia> using SummarizedExperiments

julia> x = exampleobject(20, 10);

julia> first_sum = sum(assay(x));

julia> second_sum = sum(assay(x, 2));

julia> setassay!(x, assay(x, 2)); # Replacing the first assay with the second.

julia> first_sum == sum(assay(x))
false

julia> second_sum == sum(assay(x))
true

julia> setassay!(x, 1, assay(x, 2)); # More explicit forms of the above.

julia> setassay!(x, "foo", assay(x, 2));
```
"""
function setassay!(x::SummarizedExperiment, value::AbstractArray)
    setassay!(x, 1, value)
    return
end

function setassay!(x::SummarizedExperiment, i::Int64, value::AbstractArray)
    dim = size(value)
    xdim = size(x)
    if dim[1] != xdim[1] || dim[2] != xdim[2]
        throw(DimensionMismatch("dimensions of 'value' should be the same as those of 'x'"))
    end

    counter = 0
    for k in keys(x.assays)
        counter += 1
        if counter == i
            x.assays[k] = value
            return
        end
    end

    throw(BoundsError("'i = " * string(i) * "' is out of range of 'assays(x)'"))
end

function setassay!(x::SummarizedExperiment, i::String, value::AbstractArray)
    dim = size(value)
    xdim = size(x)
    if dim[1] != xdim[1] || dim[2] != xdim[2]
        throw(DimensionMismatch("dimensions of 'value' should be the same as those of 'x'"))
    end
    x.assays[i] = value
    return
end

"""
    setassays!(x, value)

Set assays in `x` to `value`, an `OrderedDict` where the keys are assay names and the values are arrays.
All arrays in `value` should have the same extents as `x` for the first two dimensions.

# Examples
```jldoctest
julia> using SummarizedExperiments

julia> x = exampleobject(20, 10);

julia> length(assays(x))
3

julia> refresh = copy(assays(x));

julia> delete!(refresh, "foo");

julia> setassays!(x, refresh)

julia> length(assays(x))
2
```
"""
function setassays!(x::SummarizedExperiment, value::OrderedDict{String,AbstractArray})
    xdim = size(x)
    for (name, val) in value
        dim = size(val)
        if dim[1] != xdim[1] || dim[2] != xdim[2]
            throw(DimensionMismatch("dimensions of 'value[" * repr(name) * "]' should be the same as those of 'x'"))
        end
    end
    x.assays = value
    return
end

"""
    setmetadata!(x, value)

Set metadata in `x` to `value`, a `Dict` where the keys are the metadata field names.

# Examples
```jldoctest
julia> using SummarizedExperiments

julia> x = exampleobject(20, 10);

julia> setmetadata!(x, Dict{String,Any}("foo" => 200));

julia> metadata(x)
Dict{String, Any} with 1 entry:
  "foo" => 200
```
"""
function setmetadata!(x::SummarizedExperiment, value::Dict{String,Any})
    x.metadata = value;
    return
end
