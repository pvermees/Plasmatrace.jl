"""
plot

Plot selected channels for a sample or a vector of samples

# Methods

- `plot(samp::Sample,
        method::AbstractString,
        channels::Union{AbstractVector,AbstractDict},
        blank::AbstractDataFrame,
        pars::NamedTuple,
        standards::Union{AbstractVector,AbstractDict},
        glass::Union{AbstractVector,AbstractDict},
        num=nothing,den=nothing,
        transformation=nothing,
        seriestype=:scatter,
        ms=2,ma=0.5,xlim=:auto,ylim=:auto,
        linecol="black",linestyle=:solid,
        legend=:topleft,show_title=true,
        titlefontsize=10)`
- `plot(samp::Sample,
        channels::Union{AbstractVector,AbstractDict};
        num=nothing,den=nothing,
        transformation=nothing,offset=nothing,
        seriestype=:scatter,ms=2,ma=0.5,
        xlim=:auto,ylim=:auto,
        legend=:topleft,show_title=true,
        titlefontsize=10)`
- `plot(samp::Sample;
        num=nothing,den=nothing,
        transformation=nothing,offset=nothing,
        seriestype=:scatter,ms=2,ma=0.5,
        xlim=:auto,ylim=:auto,
        legend=:topleft,show_title=true,
        titlefontsize=10)`
- `plot(samp::Sample,
        channels::AbstractDict,
        blank::AbstractDataFrame,
        pars::NamedTuple,
        anchors::AbstractDict;
        num=nothing,den=nothing,
        transformation=nothing,
        seriestype=:scatter,ms=2,ma=0.5,
        xlim=:auto,ylim=:auto,
        linecol="black",linestyle=:solid,
        legend=:topleft,show_title=true,
        titlefontsize=10)`
- `plot(samp::Sample,
        blank::AbstractDataFrame,
        pars::AbstractVector,
        elements::AbstractDataFrame,
        internal::AbstractString;
        num=nothing,den=nothing,
        transformation=nothing,
        seriestype=:scatter,ms=2,ma=0.5,
        xlim=:auto,ylim=:auto,
        linecol="black",linestyle=:solid,
        legend=:topleft,show_title=true,
        titlefontsize=10)`
- `plot(samp::Sample,
        blank::AbstractDataFrame,
        pars::AbstractVector,
        internal::AbstractString;
        num=nothing,den=nothing,
        transformation=nothing,
        seriestype=:scatter,ms=2,ma=0.5,
        xlim=:auto,ylim=:auto,
        linecol="black",linestyle=:solid,
        legend=:topleft,show_title=true,
        titlefontsize=10)`

# Arguments

- `method`: either "U-Pb", "Lu-Hf", "Rb-Sr" or "concentrations"
- `channels`: dictionary of the type Dict("P" => "parent", "D" => "daughter", "d" => "sister")
              or a vector of channel names (e.g., the keys of a channels Dict)
- `blank`: the output of fitBlanks()p
- `pars`: the output of fractionation() or process!()
- `standards`: dictionary of the type Dict("prefix" => "mineral standard")
- `glass`: dictionary of the type Dict("prefix" => "reference glass")
- `num`: optional vector of name of the data column to use as the numerator
- `den`: optional name of the data column to use as the denominator
- `transformation`: "sqrt", "log" or nothing
- `seriestype`: :scatter or :path
- `titlefontsize`, `legend`, `ms`, `xlim`, `ylim`: see the generic Plot.plot function
- `anchors`: the output of getAnchors()
- `elements`: a 1-row dataframe with the elements corresponding to each channel
- `i`: (optional) sample number
- `show_title`: self explanatory

# Examples

```julia
myrun = load("data/Lu-Hf";instrument="Agilent")
p = plot(myrun[1],["Hf176 -> 258","Hf178 -> 260"])
display(p)
```
"""
function plot(samp::Sample,
              method::AbstractString,
              channels::AbstractDict,
              blank::AbstractDataFrame,
              pars::NamedTuple,
              standards::AbstractVector,
              glass::AbstractVector;
              num=nothing,den=nothing,
              transformation=nothing,
              seriestype=:scatter,
              ms=2,ma=0.5,xlim=:auto,ylim=:auto,
              linecol="black",linestyle=:solid,
              i=nothing,legend=:topleft,
              show_title=true,
              titlefontsize=10)
    Sanchors = getAnchors(method,standards,false)
    Ganchors = getAnchors(method,glass,true)
    anchors = merge(Sanchors,Ganchors)
    return plot(samp,channels,blank,pars,anchors;
                num=num,den=den,transformation=transformation,
                seriestype=seriestype,
                ms=ms,ma=ma,xlim=xlim,ylim=ylim,i=i,
                legend=legend,show_title=show_title,
                titlefontsize=titlefontsize)
end
function plot(samp::Sample,
              method::AbstractString,
              channels::AbstractDict,
              blank::AbstractDataFrame,
              pars::NamedTuple,
              standards::AbstractDict,
              glass::AbstractDict;
              num=nothing,den=nothing,
              transformation=nothing,
              seriestype=:scatter,
              ms=2,ma=0.5,xlim=:auto,ylim=:auto,
              linecol="black",linestyle=:solid,i=nothing,
              legend=:topleft,
              show_title=true,
              titlefontsize=10)
    return plot(samp,method,channels,blank,pars,
                collect(keys(standards)),collect(keys(glass));
                num=num,den=den,transformation=transformation,
                seriestype=seriestype,ms=ms,ma=ma,
                xlim=xlim,ylim=ylim,
                linecol=linecol,linestyle=linestyle,i=i,
                legend=legend,show_title=show_title,
                titlefontsize=titlefontsize)
end
function plot(samp::Sample,
              channels::AbstractDict;
              num=nothing,den=nothing,
              transformation=nothing,offset=nothing,
              seriestype=:scatter,
              ms=2,ma=0.5,xlim=:auto,ylim=:auto,
              i=nothing,legend=:topleft,
              show_title=true,titlefontsize=10)
    return plot(samp,collect(values(channels));
                num=num,den=den,transformation=transformation,
                offset=offset,seriestype=seriestype,
                ms=ms,ma=ma,xlim=xlim,ylim=ylim,i=i,
                legend=legend,show_title=show_title,
                titlefontsize=titlefontsize)
end
function plot(samp::Sample;
              num=nothing,den=nothing,
              transformation=nothing,offset=nothing,
              seriestype=:scatter,
              ms=2,ma=0.5,xlim=:auto,ylim=:auto,
              i=nothing,legend=:topleft,
              show_title=true,titlefontsize=10)
    return plot(samp,getChannels(samp);
                num=num,den=den,transformation=transformation,
                offset=offset,seriestype=seriestype,
                ms=ms,ma=ma,
                xlim=xlim,ylim=ylim,i=i,
                legend=legend,show_title=show_title,
                titlefontsize=titlefontsize)
end
function plot(samp::Sample,
              channels::AbstractDict,
              blank::AbstractDataFrame,
              pars::NamedTuple,
              anchors::AbstractDict;
              num=nothing,den=nothing,
              transformation=nothing,
              seriestype=:scatter,
              ms=2,ma=0.5,
              xlim=:auto,ylim=:auto,
              linecol="black",
              linestyle=:solid,
              i=nothing,
              legend=:topleft,
              show_title=true,
              titlefontsize=10)

    if samp.group == "sample"

        p = plot(samp,channels;
                 num=num,den=den,transformation=transformation,
                 seriestype=seriestype,ms=ms,ma=ma,
                 xlim=xlim,ylim=ylim,i=i,
                 legend=legend,show_title=show_title,
                 titlefontsize=titlefontsize)
        
    else

        offset = getOffset(samp,channels,blank,pars,anchors,transformation;
                           num=num,den=den)

        p = plot(samp,channels;
                 num=num,den=den,transformation=transformation,offset=offset,
                 seriestype=seriestype,ms=ms,ma=ma,xlim=xlim,ylim=ylim,
                 i=i,legend=legend,show_title=show_title,
                 titlefontsize=titlefontsize)

        plotFitted!(p,samp,blank,pars,channels,anchors;
                    num=num,den=den,transformation=transformation,
                    offset=offset,linecolor=linecol,linestyle=linestyle)
        
    end
    return p
end
# concentrations
function plot(samp::Sample,
              blank::AbstractDataFrame,
              pars::AbstractVector,
              elements::AbstractDataFrame,
              internal::AbstractString;
              num=nothing,den=nothing,
              transformation=nothing,
              seriestype=:scatter,
              ms=2,ma=0.5,xlim=:auto,ylim=:auto,
              linecol="black",linestyle=:solid,i=nothing,
              legend=:topleft,show_title=true,titlefontsize=10)
    if samp.group == "sample"

        p = plot(samp;
                 num=num,den=den,transformation=transformation,
                 seriestype=seriestype,ms=ms,ma=ma,
                 xlim=xlim,ylim=ylim,i=i,
                 legend=legend,show_title=show_title,
                 titlefontsize=titlefontsize)
        
    else

        offset = getOffset(samp,blank,pars,elements,internal,transformation;
                           num=num,den=den)

        p = plot(samp;
                 num=num,den=den,transformation=transformation,offset=offset,
                 seriestype=seriestype,ms=ms,ma=ma,xlim=xlim,ylim=ylim,
                 i=i,legend=legend,show_title=show_title,
                 titlefontsize=titlefontsize)

        plotFitted!(p,samp,blank,pars,elements,internal;
                     num=num,den=den,transformation=transformation,
                     offset=offset,linecolor=linecol,linestyle=linestyle)
        
    end
    return p
end
function plot(samp::Sample,
              blank::AbstractDataFrame,
              pars::AbstractVector,
              internal::AbstractString;
              num=nothing,den=nothing,
              transformation=nothing,
              seriestype=:scatter,
              ms=2,ma=0.5,xlim=:auto,ylim=:auto,
              linecol="black",linestyle=:solid,i=nothing,
              legend=:topleft,show_title=true,titlefontsize=10)
    elements = channels2elements(samp)
    return plot(samp,blank,pars,elements,internal;
                num=num,den=den,transformation=transformation,
                seriestype=seriestype,ms=ms,ma=ma,xlim=xlim,ylim=ylim,
                linecol=linecol,linestyle=linestyle,i=i,
                legend=legend,show_title=show_title,
                titlefontsize=titlefontsize)
end
function plot(samp::Sample,
              channels::AbstractVector;
              num=nothing,den=nothing,
              transformation=nothing,offset=nothing,
              seriestype=:scatter,ms=2,ma=0.5,
              xlim=:auto,ylim=:auto,
              i::Union{Nothing,Integer}=nothing,
              legend=:topleft,
              show_title=true,
              titlefontsize=10)
    xlab = names(samp.dat)[1]
    x = samp.dat[:,xlab]
    meas = samp.dat[:,channels]
    y = (isnothing(num) && isnothing(den)) ? meas : formRatios(meas,num,den)
    if isnothing(offset)
        offset = Dict(zip(names(y),fill(0.0,size(y,2))))
    end
    ty = transformeer(y;transformation=transformation,offset=offset)
    ratsig = isnothing(den) ? "signal" : "ratio"
    ylab = isnothing(transformation) ? ratsig : transformation*"("*ratsig*")"
    p = Plots.plot(x,Matrix(ty);
                   ms=ms,ma=ma,seriestype=seriestype,
                   label=permutedims(names(y)),
                   legend=legend,xlimits=xlim,ylimits=ylim)
    Plots.xlabel!(xlab)
    Plots.ylabel!(ylab)
    if show_title
        title = samp.sname*" ["*samp.group*"]"
        if !isnothing(i)
            title = string(i) * ". " * title
        end
        Plots.title!(title;titlefontsize=titlefontsize)
    end
    dy = Plots.ylims(p)
    # plot t0:
    Plots.plot!(p,[samp.t0,samp.t0],collect(dy[[1,2]]);
                linecolor="grey",linestyle=:dot,label="")
    # plot selection windows:
    for win in [samp.bwin,samp.swin]
        for w in win
            from = x[w[1]]
            to = x[w[2]]
            Plots.plot!(p,[from,from,to,to,from],collect(dy[[1,2,2,1,1]]);
                        linecolor="black",linestyle=:dot,label="")
        end
    end
    return p
end
export plot

function plotFitted!(p,
                     samp::Sample,
                     blank::AbstractDataFrame,
                     pars::NamedTuple,
                     channels::AbstractDict,
                     anchors::AbstractDict;
                     num=nothing,den=nothing,transformation=nothing,
                     offset::AbstractDict,linecolor="black",linestyle=:solid)
    pred = predict(samp,pars,blank,channels,anchors)
    rename!(pred,[channels[i] for i in names(pred)])
    plotFitted!(p,samp,pred;
                num=num,den=den,transformation=transformation,
                offset=offset,linecolor=linecolor,linestyle=linestyle)
end
function plotFitted!(p,
                     samp::Sample,
                     blank::AbstractDataFrame,
                     pars::AbstractVector,
                     elements::AbstractDataFrame,
                     internal::AbstractString;
                     num=nothing,den=nothing,transformation=nothing,
                     offset::AbstractDict,linecolor="black",linestyle=:solid)
    pred = predict(samp,pars,blank,elements,internal)
    plotFitted!(p,samp,pred;
                num=num,den=den,transformation=transformation,
                offset=offset,linecolor=linecolor,linestyle=linestyle)
end
function plotFitted!(p,
                     samp::Sample,
                     pred::AbstractDataFrame;
                     num=nothing,den=nothing,transformation=nothing,
                     offset::AbstractDict,linecolor="black",linestyle=:solid)
    x = windowData(samp,signal=true)[:,1]
    y = formRatios(pred,num,den)
    ty = transformeer(y;transformation=transformation,offset=offset)
    for tyi in eachcol(ty)
        Plots.plot!(p,x,tyi;linecolor=linecolor,linestyle=linestyle,label="")
    end
end
export plotFitted!
