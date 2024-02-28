function PT(logbook="",debug=false)
    welcome()
    ctrl = Dict(
        "priority" => Dict("load" => true, "method" => true,
                           "standards" => true, "process" => true),
        "history" => DataFrame(task=String[],action=String[]),
        "chain" => ["top"],
        "i" => 1,
        "den" => nothing,
        "options" => Dict("blank" => 2, "drift" => 1, "down" => 1),
        "mf" => nothing
    )
    if logbook != ""
        TUIimport!(ctrl,logbook)
    end
    while true
        if length(ctrl["chain"])<1 return end
        dispatch!(ctrl)
        if debug
            println(ctrl["history"])
            println(ctrl["chain"])
            println(keys(ctrl))
        end
    end
end
export PT

function dispatch!(ctrl::AbstractDict;key=nothing,response=nothing)
    if isnothing(key) key = ctrl["chain"][end] end
    (message,action) = tree(key,ctrl)
    if isa(message,Function)
        println("\n"*message(ctrl))
    else
        println("\n"*message)
    end
    if isnothing(response) response = readline() end
    if isa(action,Function)
        next = action(ctrl,response)
    else
        next = action[response]
    end
    if isa(next,Function)
        next(ctrl)
    elseif next == "x"
        if length(ctrl["chain"])<1 return end
        pop!(ctrl["chain"])
    elseif next == "xx"
        if length(ctrl["chain"])<2 return end
        pop!(ctrl["chain"])
        pop!(ctrl["chain"])
    elseif isnothing(next)
        if length(ctrl["chain"])<1 return end
    else
        push!(ctrl["chain"],next)
    end
    if key != "import"
        push!(ctrl["history"],[key,response])
    end
end

function tree(key::AbstractString,ctrl::AbstractDict)
    branches = Dict(
        "top" => (
            message =
            "r: Read data files"*check(ctrl,"load")*"\n"*
            "m: Specify the method"*check(ctrl,"method")*"\n"*
            "t: Tabulate the samples\n"*
            "s: Mark standards"*check(ctrl,"standards")*"\n"*
            "v: View and adjust each sample\n"*
            "p: Process the data"*check(ctrl,"process")*"\n"*
            "e: Export the isotope ratios\n"*
            "l: Import/export a session log\n"*
            "o: Options\n"*
            "x: Exit",
            action = Dict(
                "r" => "instrument",
                "m" => "method",
                "t" => TUItabulate,
                "s" => "standards",
                "v" => TUIviewer!,
                "p" => "process",
                "e" => "export",
                "l" => "log",
                "o" => "options",
                "x" => "x"
            )
        ),
        "instrument" => (
            message =
            "Choose a file format:\n"*
            "1. Agilent\n"*
            "x. Exit",
            action = TUIinstrument!
        ),
        "load" => (
            message = "Enter the full path of the data directory:",
            action = TUIload!,
        ),
        "method" => (
            message =
            "Choose a method:\n"*
            "1. Lu-Hf\n"*
            "x. Exit",
            action = TUImethod!
        ),
        "columns" => (
            message = TUIcolumnMessage,
            action = TUIcolumns!
        ),
        "standards" => (
            message =
            "Choose an option:\n"*
            "p. Add a standard by prefix\n"*
            "n. Add a standard by number\n"*
            "N. Remove a standard by number\n"*
            "r. Remove all standards\n"*
            "t. Tabulate all the samples\n"*
            "x. Exit",
            action = Dict(
                "p" => "addStandardsByPrefix",
                "n" => "addStandardsByNumber",
                "N" => "removeStandardsByNumber",
                "r" => TUIresetStandards!,
                "t" => TUItabulate,
                "x" => "x"
            )
        ),
        "addStandardsByPrefix" => (
            message = "Specify the prefix of the standard:",
            action = TUIaddStandardsByPrefix!
        ),
        "addStandardsByNumber" => (
            message = "Select the standards as a comma-separated list of numbers:",
            action = TUIaddStandardsByNumber!
        ),
        "removeStandardsByNumber" => (
            message = "Select the standards as a comma-separated list of numbers:",
            action = TUIremoveStandardsByNumber!
        ),
        "refmat" => (
            message = TUIshowRefmats,
            action = TUIsetStandards!
        ),
        "view" => (
            message = 
            "n: Next\n"*
            "p: Previous\n"*
            "g: Go to\n"*
            "t: Tabulate all the samples in the session\n"*
            "r: Plot signals or ratios?\n"*
            "b: Select blank window(s)\n"*
            "s: Select signal window(s)\n"*
            "x: Exit",
            action = Dict(
                "n" => TUInext!,
                "p" => TUIprevious!,
                "g" => "goto",
                "t" => TUItabulate,
                "r" => "setDen",
                "b" => "Bwin",
                "s" => "Swin",
                "x" => "x"
            )
        ),
        "goto" => (
            message = "Enter the number of the sample to plot:",
            action = TUIgoto!
        ),
        "setDen" => (
            message = TUIratioMessage,
            action = TUIratios!
        ),
        "Bwin" => (
            message =
            "Choose an option to set the blank window(s):\n"*
            "a: Automatic (current sample)\n"*
            "s: Manually set a one-part window (current sample)\n"*
            "m: Manually set a multi-part window (current sample)\n"*
            "A: Automatic (all samples)\n"*
            "S: Manually set a one-part window (all samples)\n"*
            "M: Manually set a multi-part window (all samples)\n"*
            "x: Exit",
            action = Dict(
                "a" => TUIoneAutoBlankWindow!,
                "s" => "oneSingleBlankWindow",
                "m" => "oneMultiBlankWindow",
                "A" => TUIallAutoBlankWindow!,
                "S" => "allSingleBlankWindow",
                "M" => "allMultiBlankWindow",
                "x" => "x"
            )
        ),
        "Swin" => (
            message =
            "Choose an option to set the signal window(s):\n"*
            "a: Automatic (current sample)\n"*
            "s: Manually set a one-part window (current sample)\n"*
            "m: Manually set a multi-part window (current sample)\n"*
            "A: Automatic (all samples)\n"*
            "S: Manually set a one-part window (all samples)\n"*
            "M: Manually set a multi-part window (all samples)\n"*
            "x: Exit",
            action = Dict(
                "a" => TUIoneAutoSignalWindow!,
                "s" => "oneSingleSignalWindow",
                "m" => "oneMultiSignalWindow",
                "A" => TUIallAutoSignalWindow!,
                "S" => "allSingleSignalWindow",
                "M" => "allMultiSignalWindow",
                "x" => "x"
            )
        ),
        "oneSingleBlankWindow" => (
            message =
            "Enter the start and end point of the selection window (in seconds)\n"*
            "Type 'h' for help.",
            action = TUIoneSingleBlankWindow!
        ),
        "oneMultiBlankWindow" => (
            message =
            "Enter the start and end points of the multi-part "*
            "selection window (in seconds)\n"*
            "Type 'h' for help.",
            action = TUIoneMultiBlankWindow!
        ),
        "allSingleBlankWindow" => (
            message =
            "Enter the start and end point of the selection window (in seconds)\n"*
            "Type 'h' for help.",
            action = TUIallSingleBlankWindow!
        ),
        "allMultiBlankWindow" => (
            message =
            "Enter the start and end points of the multi-part "*
            "selection window (in seconds)\n"*
            "Type 'h' for help.",
            action = TUIallMultiBlankWindow!
        ),
        "oneSingleSignalWindow" => (
            message =
            "Enter the start and end point of the selection window (in seconds)\n"*
            "Type 'h' for help.",
            action = TUIoneSingleSignalWindow!
        ),
        "oneMultiSignalWindow" => (
            message =
            "Enter the start and end points of the multi-part "*
            "selection window (in seconds)\n"*
            "Type 'h' or help.",
            action = TUIoneMultiSignalWindow!
        ),
        "allSingleSignalWindow" => (
            message =
            "Enter the start and end point of the selection windows (in seconds)\n"*
            "Type 'h' for help.",
            action = TUIallSingleSignalWindow!
        ),
        "allMultiSignalWindow" => (
            message =
            "Enter the start and end points of the multi-part "*
            "selection windows (in seconds)\n"*
            "Type 'h' for help.",
            action = TUIallMultiSignalWindow!
        ),
        "options" => (
            message =
            "Set one of the following parameters:\n"*
            "b. Polynomial order of the blank correction (current value = "*
            string(ctrl["options"]["blank"])*")\n"*
            "d. Polynomial order of the drift correction (current value = "*
            string(ctrl["options"]["drift"])*")\n"*
            "h. Polynomial order of the down hole fractionation correction "*
            "(current value = "*string(ctrl["options"]["drift"])*")\n"*
            "f. Fix or fit the fractionation factor (currently "*
            (isnothing(ctrl["mf"]) ? "fitted" : "fixed at "*string(ctrl["mf"]))*")\n"*
            "x. Exit",
            action = Dict(
                "b" => "setNblank",
                "d" => "setNdrift",
                "h" => "setNdown",
                "f" => "setmf",
                "x" => "x"
            )
        ),
        "log" => (
            message =
            "Choose an option:\n"*
            "i. Import a session log\n"*
            "e. Export the session log\n"*
            "x. Exit",
            action = Dict(
                "i" => "import",
                "e" => "export",
                "x" => "x"
            )
        ),
        "import" => (
            message = "Enter the path and name of the log file:",
            action = TUIimport!
        ),
        "export" => (
            message = "Enter the path and name of the log file:",
            action = TUIexport
        )
    )
    return branches[key]
end

function welcome()
    version = string(pkgversion(@__MODULE__))
    title = " Plasmatrace "*version*" \n"
    width = Base.length(title)-1
    println('-'^width*"\n"*title*'-'^width)
end

function check(ctrl::AbstractDict,action::AbstractString)
    return ctrl["priority"][action] ? "[*]" : ""
end

function TUIinstrument!(ctrl::AbstractDict,response::AbstractString)
    if response=="1"
        ctrl["instrument"] = "Agilent"
    else
        return "x"
    end
    return "load"
end

function TUIload!(ctrl::AbstractDict,response::AbstractString)
    ctrl["run"] = load(response,instrument=ctrl["instrument"])
    ctrl["priority"]["load"] = false
    return "xx"
end

function TUImethod!(ctrl::AbstractDict,response::AbstractString)
    if response=="1"
        ctrl["method"] = "Lu-Hf"
        ctrl["mf"] = 1.4671
    else
        return "x"
    end
    return "columns"
end

function TUIcolumnMessage(ctrl::AbstractDict)
    msg = "Choose from the following list of channels:\n"
    labels = names(ctrl["run"][1].dat)[3:end]
    for i in eachindex(labels)
        msg *= string(i)*". "*labels[i]*"\n"
    end
    msg *= "and select the channels corresponding to "*
    "the following isotopes or their proxies:\n"
    if ctrl["method"]=="Lu-Hf"
        msg *= "176Lu, 176Hf, 177Hf\n"
    end
    msg *= "Specify your selection as a "*
    "comma-separated list of numbers:\n"
    return msg
end

function TUIcolumns!(ctrl::AbstractDict,response::AbstractString)
    labels = names(ctrl["run"][1].dat)[3:end]
    selected = parse.(Int,split(response,","))
    PDd = labels[selected]
    if ctrl["method"]=="Lu-Hf"
        ctrl["channels"] = Dict("d" => PDd[3], "D" => PDd[2], "P" => PDd[1])
        ctrl["priority"]["method"] = false
    end
    return "xx"
end

function TUItabulate(ctrl::AbstractDict)
    summarise(ctrl["run"])
end

function TUIaddStandardsByPrefix!(ctrl::AbstractDict,response::AbstractString)
    snames = getSnames(ctrl["run"])
    ctrl["selection"] = findall(contains(response),snames)
    return "refmat"
end

function TUIaddStandardsByNumber!(ctrl::AbstractDict,response::AbstractString)
    ctrl["selection"] = parse.(Int,split(response,","))
    return "refmat"    
end

function TUIremoveStandardsByNumber!(ctrl::AbstractDict,response::AbstractString)
    selection = parse.(Int,split(response,","))
    resetStandards!(ctrl["run"],selection)
    return "x"
end

function TUIresetStandards!(ctrl::AbstractDict)
    setStandards!(ctrl["run"])
    return "x"
end

function TUIshowRefmats(ctrl::AbstractDict)
    if ctrl["method"]=="Lu-Hf"
        msg = "Which of the following standards did you select?\n"*
        "1. Hogsbo\n"*
        "2. BP"
    end
    return msg
end

function TUIsetStandards!(ctrl::AbstractDict,response::AbstractString)
    if ctrl["method"]=="Lu-Hf"
        if response=="1"
            setStandards!(ctrl["run"],ctrl["selection"],"Hogsbo")
        elseif response=="2"
            setStandards!(ctrl["run"],ctrl["selection"],"BP")
        end
    end
    ctrl["priority"]["standards"] = false
    return "xx"
end

function TUIviewer!(ctrl::AbstractDict)
    TUIplotter(ctrl)
    push!(ctrl["chain"],"view")
end

function TUInext!(ctrl::AbstractDict)
    ctrl["i"] += 1
    if ctrl["i"]>length(ctrl["run"]) ctrl["i"] = 1 end
    TUIplotter(ctrl)
end

function TUIprevious!(ctrl::AbstractDict)
    ctrl["i"] -= 1
    if ctrl["i"]<1 ctrl["i"] = length(ctrl["run"]) end
    TUIplotter(ctrl)
end

function TUIgoto!(ctrl::AbstractDict,response::AbstractString)
    ctrl["i"] = parse(Int,response)
    if ctrl["i"]>length(ctrl["run"]) ctrl["i"] = 1 end
    if ctrl["i"]<1 ctrl["i"] = length(ctrl["run"]) end
    TUIplotter(ctrl)
    return "x"
end

function TUIplotter(ctrl::AbstractDict)
    p = plot(ctrl["run"][ctrl["i"]],ctrl["channels"],den=ctrl["den"])
    display(p)
end

function TUIratioMessage(ctrl::AbstractDict)
    channels = collect(values(ctrl["channels"]))
    msg = "Choose one of the following denominators:\n"
    for i in 1:length(channels)
        msg *= string(i)*". "*channels[i]*"\n"
    end
    msg *= "or\n"
    msg *= "n. No denominator. Plot the raw signals"
end

function TUIratios!(ctrl::AbstractDict,response::AbstractString)
    if response=="n"
        ctrl["den"] = nothing
    else
        i = parse(Int,response)
        channels = collect(values(ctrl["channels"]))
        ctrl["den"] = [channels[i]]
    end
    TUIplotter(ctrl)
    return "x"
end

function TUIoneAutoBlankWindow!(ctrl::AbstractDict)
    setBwin!(ctrl["run"][ctrl["i"]])
    TUIplotter(ctrl)
end

function TUIoneSingleBlankWindow!(ctrl::AbstractDict,response::AbstractString)
    if response=="h"
        println("Specify the start and end point of the blank window "*
                "as a comma-separated pair of numbers. For example: 0,20 marks "*
                "a blank window from 0 to 20 seconds.")
        response = readline()
    end
    samp = ctrl["run"][ctrl["i"]]
    bwin = string2windows(samp,text=response,single=true)
    setBwin!(samp,bwin)
    TUIplotter(ctrl)
    return "xx"
end

function TUIoneMultiBlankWindow!(ctrl::AbstractDict,response::AbstractString)
    if response=="h"
        println("Specify the start and end points of the blank window "*
                "as a comma-separated list of bracketed pairs "*
                " of numbers. For example: (0,20),(25,30) marks a two-part "*
                "selection window from 0 to 20s, and from 25 to 30s.")
        response = readline()
    end
    samp = ctrl["run"][ctrl["i"]]
    bwin = string2windows(samp,text=response,single=false)
    setBwin!(samp,bwin)
    TUIplotter(ctrl)
    return "xx"
end

function TUIallAutoBlankWindow!(ctrl::AbstractDict)
    setBwin!(ctrl["run"])
    TUIplotter(ctrl)
end

function TUIallSingleBlankWindow!(ctrl::AbstractDict,response::AbstractString)
    if response=="h"
        println("Specify the start and end point of the blank windows "*
                "as a comma-separated pair of numbers. For example: 0,20 marks "*
                "a blank window from 0 to 20 seconds.")
        response = readline()
    end
    for i in eachindex(ctrl["run"])
        samp = ctrl["run"][i]
        bwin = string2windows(samp,text=response,single=true)
        setBwin!(samp,bwin)
    end
    TUIplotter(ctrl)
    return "xx"
end

function TUIallMultiBlankWindow!(ctrl::AbstractDict,response::AbstractString)
    if response=="h"
        println("Specify the start and end points of the blank windows "*
                "as a comma-separated list of bracketed pairs "*
                " of numbers. For example: (0,20),(25,30) marks a two-part "*
                "selection window from 0 to 20s, and from 25 to 30s.")
        response = readline()
    end
    for i in eachindex(ctrl["run"])
        samp = ctrl["run"][i]
        bwin = string2windows(samp,text=response,single=false)
        setBwin!(samp,bwin)
    end
    TUIplotter(ctrl)
    return "xx"
end

function TUIoneAutoSignalWindow!(ctrl::AbstractDict)
    setSwin!(ctrl["run"][ctrl["i"]])
    TUIplotter(ctrl)
end

function TUIoneSingleSignalWindow!(ctrl::AbstractDict,response::AbstractString)
    if response=="h"
        println("Specify the start and end points of the signal window "*
                "as a comma-separated pair of numbers. For example: 30,60 marks "*
                "a signal window from 30 to 60 seconds.")
        response = readline()
    end
    samp = ctrl["run"][ctrl["i"]]
    swin = string2windows(samp,text=response,single=true)
    setSwin!(samp,swin)
    TUIplotter(ctrl)
    return "xx"
end

function TUIoneMultiSignalWindow!(ctrl::AbstractDict,response::AbstractString)
    if response=="h"
        println("Specify the start and end points of the signal window "*
                "as a comma-separated list of bracketed pairs "*
                "of numbers. For example: (40,45),(50,60) marks a two-part "*
                "signal window from 40 to 45s, and from 50 to 60s.")
        response = readline()
    end
    samp = ctrl["run"][ctrl["i"]]
    swin = string2windows(samp,text=response,single=false)
    setSwin!(samp,swin)
    TUIplotter(ctrl)
    return "xx"
end

function TUIallAutoSignalWindow!(ctrl::AbstractDict)
    setSwin!(ctrl["run"])
    TUIplotter(ctrl)
end

function TUIallSingleSignalWindow!(ctrl::AbstractDict,response::AbstractString)
    if response=="h"
        println("Specify the start and end points of the signal windows "*
                "as a comma-separated pair of numbers. For example: 30,60 marks "*
                "a signal window from 30 to 60 seconds.")
        response = readline()
    end
    for i in eachindex(ctrl["run"])
        samp = ctrl["run"][i]
        swin = string2windows(samp,text=response,single=true)
        setSwin!(samp,swin)
    end
    TUIplotter(ctrl)
    return "xx"
end

function TUIallMultiSignalWindow!(ctrl::AbstractDict,response::AbstractString)
    if response=="h"
        println("Specify the start and end points of the signal windows "*
                "as a comma-separated list of bracketed pairs "*
                "of numbers. For example: (40,45),(50,60) marks a two-part "*
                "signal window from 40 to 45s, and from 50 to 60s.")
        response = readline()
    end
    for i in eachindex(ctrl["run"])
        samp = ctrl["run"][i]
        swin = string2windows(samp,text=response,single=false)
        setSwin!(samp,swin)
    end
    TUIplotter(ctrl)
    return "xx"
end

function TUIimport!(ctrl::AbstractDict,response::AbstractString)
    history = CSV.read(response,DataFrame)
    ctrl["history"] = DataFrame(task=String[],action=String[])
    for row in eachrow(history)
        dispatch!(ctrl,key=row[1],response=row[2])
    end
    return nothing
end

function TUIexport(ctrl::AbstractDict,response::AbstractString)
    pop!(ctrl["history"])
    pop!(ctrl["history"])
    CSV.write(response,ctrl["history"])
    return "xx"
end
