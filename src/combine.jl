import DataFrames
import DataStructures

function collapse_data(x::Vector{DataFrames.DataFrame})
    base = copy(x[1])
    refnames = Set(names(base))

    # The first instance of each key is always taken. For the sake of speed, we
    # don't bother checking for equality or any of that crap.
    for i in 2:length(x)
        current = x[i]
        for n in names(current)
            if !(n in refnames)
                insertcols!(base, n => current[!,n])
            end
        end
    end

    return base
end

function collapse_data(x::Vector{Dict{String,Any}})
    base = copy(x[1])

    # The first instance of each key is always taken. For the sake of speed, we
    # don't bother checking for equality or any of that crap.
    for i in 2:length(x)
        current = x[i]
        for (key, val) in current
            if !haskey(base, key)
                base[key] = val
            end
        end
    end

    return base
end

"""
    vcat(A::Vararg{SummarizedExperiment})

Vertically concatenate one or more `SummarizedExperiment` objects.
The input objects must satisfy the following constraints:

- All objects must have the same number of columns, which are assumed to be in the same order.
- All objects must have `DataFrame`s in their `rowdata` with the same type and names of all columns (though they may be ordered differently).
- All objects must have the same names and types of assays;
  for a given assay name, the dimensions of the corresponding arrays across all `A` should be the same except for the first dimension. 

This function returns a single `SummarizedExperiment` instance where the number of rows is equal to the sum of the number of rows across all objects in `A`.
The number of columns in the output object is the same as the number of columns in any object in `A`.
The order of columns in the output `rowdata` is the same as that of the first object.
The output `coldata` is created by combining columns horizontally across `coldata` of all objects in `A`;
if columns have duplicate names, only the first instance of each column is retained.

# Examples
```jldoctest
julia> using SummarizedExperiments

julia> x = exampleobject(20, 10);

julia> y = exampleobject(30, 10);

julia> z = vcat(x, y)
50x10 SummarizedExperiment
  assays(3): foo bar whee
  rownames: Gene1 Gene2 ... Gene29 Gene30
  rowdata(2): name Type
  colnames: Patient1 Patient2 ... Patient9 Patient10
  coldata(3): name Treatment Response
  metadata(1): version
```
"""
function Base.vcat(A::Vararg{SummarizedExperiment})
    if length(A) < 2
        return A[1] # no-op in this case.
    end

    collected_rowdata = [rowdata(A[1])];
    collected_coldata = [coldata(A[1])];
    collected_metadata = [metadata(A[1])];
    collected_assays = DataStructures.OrderedDict{String,Vector{AbstractArray}}();
    for (key, val) in assays(A[1])
        collected_assays[key] = AbstractArray[val]
    end

    for i in 2:length(A)
        push!(collected_rowdata, rowdata(A[i]))
        push!(collected_coldata, coldata(A[i]))

        for (key, val) in assays(A[i])
            if !haskey(collected_assays, key)
                throw(KeyError("could not find '" * key * "' in assays of object " * string(i)))
            end
            
            ref = collected_assays[key][1]
            if length(size(ref)) != length(size(val)) || size(ref)[2] != size(val)[2]
                throw(DimensionMismatch("inconsistent dimensions for assay '" * key * "' in object " * string(i)))
            end
            
            push!(collected_assays[key], val)
        end
    end

    full_rowdata = vcat(collected_rowdata...)
    full_assays = DataStructures.OrderedDict{String,AbstractArray}()
    for (key, val) in collected_assays
        full_assays[key] = vcat(val...)
    end

    full_coldata = collapse_data(collected_coldata)
    full_metadata = collapse_data(collected_metadata)

    return SummarizedExperiment(full_assays, full_rowdata, full_coldata, full_metadata)
end

"""
    hcat(A::Vararg{SummarizedExperiment})

Horizontally concatenate one or more `SummarizedExperiment` objects.
The input objects must satisfy the following constraints:

- All objects must have the same number of rows, which are assumed to be in the same order.
- All objects must have `DataFrame`s in their `coldata` with the same type and names of all columns (though they may be ordered differently).
- All objects must have the same names and types of assays;
  for a given assay name, the dimensions of the corresponding arrays across all `A` should be the same except for the second dimension. 

This function returns a single `SummarizedExperiment` instance where the number of columns is equal to the sum of the number of columns across all objects in `A`.
The number of rows in the output object is the same as the number of rows in any object in `A`.
The order of columns in the output `coldata` is the same as that of the first object.
The output `rowdata` is created by combining columns horizontally across `rowdata` of all objects in `A`;
if columns have duplicate names, only the first instance of each column is retained.

# Examples
```jldoctest
julia> using SummarizedExperiments

julia> x = exampleobject(20, 20);

julia> y = exampleobject(20, 30);

julia> z = hcat(x, y)
20x50 SummarizedExperiment
  assays(3): foo bar whee
  rownames: Gene1 Gene2 ... Gene19 Gene20
  rowdata(2): name Type
  colnames: Patient1 Patient2 ... Patient29 Patient30
  coldata(3): name Treatment Response
  metadata(1): version
```
"""
function Base.hcat(A::Vararg{SummarizedExperiment})
    if length(A) < 2
        return A[1] # no-op in this case.
    end

    collected_rowdata = [rowdata(A[1])];
    collected_coldata = [coldata(A[1])];
    collected_metadata = [metadata(A[1])];
    collected_assays = DataStructures.OrderedDict{String,Vector{AbstractArray}}();
    for (key, val) in assays(A[1])
        collected_assays[key] = AbstractArray[val]
    end

    for i in 2:length(A)
        push!(collected_rowdata, rowdata(A[i]))
        push!(collected_coldata, coldata(A[i]))

        for (key, val) in assays(A[i])
            if !haskey(collected_assays, key)
                throw(KeyError("could not find '" * key * "' in assays of object " * string(i)))
            end
            
            ref = collected_assays[key][1]
            if length(size(ref)) != length(size(val)) || size(ref)[1] != size(val)[1]
                throw(DimensionMismatch("inconsistent dimensions for assay '" * key * "' in object " * string(i)))
            end
            
            push!(collected_assays[key], val)
        end
    end

    full_coldata = vcat(collected_coldata...)
    full_assays = DataStructures.OrderedDict{String,AbstractArray}()
    for (key, val) in collected_assays
        full_assays[key] = hcat(val...)
    end

    full_rowdata = collapse_data(collected_rowdata)
    full_metadata = collapse_data(collected_metadata)

    return SummarizedExperiment(full_assays, full_rowdata, full_coldata, full_metadata)
end
