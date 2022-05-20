module SummarizedExperiments
include("class.jl")
include("subset.jl")
include("assign.jl")
include("getters.jl")
include("setters.jl")
include("combine.jl")
include("miscellaneous.jl")
include("example.jl")

using Reexport
@reexport using DataStructures: OrderedDict
@reexport using DataFrames: DataFrame

end
