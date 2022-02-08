export size, rowdata, setrowdata!, coldata, setcoldata!, assay, setassay!, assays, setassays!, metadata, setmetadata!
import DataFrames
import DataStructures

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
    rowdata(x, check = true)

Return the row annotations as a `DataFrame` with number of rows equal to the number of rows in `x`.
The first column is called `"name"` and contains the row names of `x`;
this can either be a `Vector{String}` or a `Vector{Nothing}` (if no row names are available).

If `check = true`, this function will verify that the expectations on the returned `DataFrame` are satisfied.
Any failures will cause warnings to be emitted.

# Examples
```jldoctest
julia> using SummarizedExperiments

julia> x = exampleobject(20, 10);

julia> names(rowdata(x))
2-element Array{String,1}:
 "name"
 "Type"

julia> size(rowdata(x))
(20, 2)
```
"""
function rowdata(x::SummarizedExperiment, check::Bool = true)
    output = x.rowdata
    if check
        check_dataframe_in_getter(output, size(x)[1], "rowdata")
    end
    return output
end

function check_dataframe_in_setter(value::DataFrames.DataFrame, expected::Int, message::String)
    if size(value)[1] != expected
        throw(DimensionMismatch("'value' and '" * message *"(x)' should have the same number of rows"))
    end

    if size(value)[2] < 1 || names(value)[1] != "name"
        throw(DimensionMismatch("first column of 'value' should exist and be called 'name'"))
    end

    firstcol = value[!,1]
    if !isa(firstcol, Vector{String}) && !isa(firstcol, Vector{Nothing})
        throw(ArgumentError("first column of 'value' should contain strings or nothings"));
    end
end

"""
    setrowdata!(x, value)

Set the row annotations in `x` to `value`.

If `value` is a `DataFrame`, the first column should be called `"name"` and contain the row names of `x`;
this can either be a `Vector{String}` or a `Vector{Nothing}` (if no row names are available).

If `value` is `nothing`, this is considered to be equivalent to a `DataFrame` with one `"name"` column containing `nothing`s.

The return value is a reference to the modified `x`.

# Examples
```jldoctest
julia> using SummarizedExperiments

julia> x = exampleobject(20, 10);

julia> using DataFrames

julia> replacement = copy(rowdata(x));

julia> replacement[!,"foobar"] = [ rand() for i in 1:size(x)[1] ];

julia> setrowdata!(x, replacement);

julia> names(rowdata(x))
2-element Array{String,1}:
 "name"
 "Type"
 "foobar"
```
"""    
function setrowdata!(x::SummarizedExperiment, value::Union{DataFrames.DataFrame,Nothing})
    if isa(value, Nothing)
        x.rowdata = DataFrames.DataFrame(name = Vector{Nothing}(undef, size(x)[1]))
    else
        check_dataframe_in_setter(value, size(x)[1], "rowdata")
        x.rowdata = value
    end
    return x
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
3-element Array{String,1}:
 "name"
 "Treatment"
 "Response"

julia> size(coldata(x))
(10, 3)
```
"""
function coldata(x::SummarizedExperiment, check::Bool = true)
    output = x.coldata
    if check
        check_dataframe_in_getter(output, size(x)[2], "coldata")
    end
    return output
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

julia> using DataFrames

julia> replacement = copy(coldata(x));

julia> replacement[!,"foobar"] = [ rand() for i in 1:size(x)[2] ];

julia> setcoldata!(x, replacement);

julia> names(coldata(x))
4-element Array{String,1}:
 "name"
 "Treatment"
 "Response"
 "foobar"
```
"""
function setcoldata!(x::SummarizedExperiment, value::Union{DataFrames.DataFrame,Nothing})
    if isa(value, Nothing)
        x.coldata = DataFrames.DataFrame(name = Vector{Nothing}(undef, size(x)[2]))
    else
        check_dataframe_in_setter(value, size(x)[2], "coldata")
        x.coldata = value
    end
    return x
end 

"""
    assay(x[, i], check = true)

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
function assay(x::SummarizedExperiment, check::Bool = true)
    return assay(x, 1, check)
end

function assay(x::SummarizedExperiment, i::Int64, check::Bool = true)
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

function assay(x::SummarizedExperiment, i::String, check::Bool = true)
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
    setassay!(x[, i], value)

Set the requested assay in `x` to `value`.
The first two dimensions of `value` must have extent equal to those of `x`.
`i` may be an integer specifying an index, in which case it must be positive and no greater than `length(assays(x))`;
or a string containing the name, in which case it may be an existing or new name.
If `i` is not supplied, `value` is set to the first assay.

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
    if dim[1] != x.nrow || dim[2] != x.ncol
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
    if dim[1] != x.nrow || dim[2] != x.ncol
        throw(DimensionMismatch("dimensions of 'value' should be the same as those of 'x'"))
    end
    x.assays[i] = value
    return
end

"""
    assays(x, check = true)

Return all assays from `x`.
Each returned assay should have the same extents as `x` for the first two dimensions.
If `check = true`, this function will verify that this expectation is satisfied.
Any failures will cause warnings to be emitted.

# Examples
```jldoctest
julia> using SummarizedExperiments

julia> x = exampleobject(20, 10);

julia> collect(keys(assays(x)))
3-element Array{String,1}:
 "foo"
 "bar"
 "whee"
```
"""
function assays(x::SummarizedExperiment, check::Bool = true)
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
    setassays!(x, value)

Set assays in `x` to `value`.
All values in `value` should have the same extents for the first two dimensions.

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
function setassays!(x::SummarizedExperiment, value::DataStructures.OrderedDict{String,AbstractArray})
    for (name, val) in value
        dim = size(val)
        if dim[1] != x.nrow || dim[2] != x.ncol
            throw(DimensionMismatch("dimensions of 'value[" * repr(name) * "]' should be the same as those of 'x'"))
        end
    end
    x.assays = value
    return
end

"""
    metadata(x)

Return all metadata from `x`.

# Examples
```jldoctest
julia> using SummarizedExperiments

julia> x = exampleobject(20, 10);

julia> metadata(x)
Dict{String,Any} with 1 entry:
  "version" => "1.1.0"
```
"""
function metadata(x::SummarizedExperiment)
    return x.metadata;
end

"""
    setmetadata!(x, value)

Set metadata in `x` to `value`.

# Examples
```jldoctest
julia> using SummarizedExperiments

julia> x = exampleobject(20, 10);

julia> setmetadata!(x, Dict{String,Any}("foo" => 200));

julia> metadata(x)
Dict{String,Any} with 1 entry:
  "foo" => 200
```
"""
function setmetadata!(x::SummarizedExperiment, value::Dict{String,Any})
    x.metadata = value;
    return
end
