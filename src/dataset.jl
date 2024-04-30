
#%%
struct CoNLLUDataset
    datafile::String
    fd::IOStream
end

#%% 

function CoNLLUDataset(datafile::String)
    fd = open(datafile, "r")
    return CoNLLUDataset(datafile, fd)
end


function Base.iterate(d::CoNLLUDataset, state=0)
    txt = ""
    inblock = false

    if state == 0
        seekstart(d.fd)
    end

    while true
        line = readline(d.fd, keep=true)

        if (inblock == false) && (strip(line) != "") # start of a new block
            inblock = true
            txt = txt * '\n' * rstrip(line)
            continue

        elseif (inblock == true) && (strip(line) != "") # continuing block
            txt = txt * '\n' * rstrip(line)
            continue

        elseif (inblock == true) && (line == "\n") # end of block
            break

        elseif (line == "") # end of iterator
            return nothing
        end
    end

    r = CoNLLUSentence(txt)
    return (r, state+1)
end

function Base.close(d::CoNLLUDataset)
    close(d.fd)
end


Base.IteratorSize(::CoNLLUDataset) = Base.SizeUnknown()
Base.IteratorEltype(::CoNLLUDataset) = Base.HasEltype()
Base.eltype(::CoNLLUDataset) = CoNLLUSentence
