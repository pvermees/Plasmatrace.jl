const sph = 3.6e6 # seconds per hour

abstract type plasmaData end

const window = Tuple{Int,Int}

mutable struct control
    A::Union{Float64}
    B::Union{Float64}
    channels::Union{Nothing,Vector{String}}
end

mutable struct sample <: plasmaData
    sname::String
    datetime::DateTime
    labels::Vector{String}
    dat::Matrix
    bwin::Union{Nothing,Vector{window}}
    swin::Union{Nothing,Vector{window}}
end

mutable struct run <: plasmaData
    samples::Vector{sample}
    control::Union{Nothing,control}
    bpar::Union{Nothing,Vector}
    spar::Union{Nothing,Vector}
    bcov::Union{Nothing,Matrix}
    scov::Union{Nothing,Matrix}
end

sample(sname,datetime,labels,dat) = sample(sname,datetime,labels,dat,nothing,nothing)

run(samples) = run(samples,nothing,nothing,nothing,nothing,nothing)
