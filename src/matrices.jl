"""
Crates a matrix from three columns: name 1, name 2, weight
special thanks to user cbk (13639734) on StackExchange on a faster design on this
"""
function coltodist(r::AbstractArray,nthreads::Int=4)
    names = unique(view(r,:,1))
    dist = NamedArray(zeros(length(names),length(names)),(names,names))
    @threads for i = 1:size(r,1)
        row = Int(r[i,1])
        col = Int(r[i,2])
        dist[row,col] = r[i,3]
    end
    return dist
end


"""
Takes ouput of a HiC run and turns it into a distance matrix
"""
function builddist(infofile::AbstractString,contctsfile::AbstractString,nthreads::Int=4)
    contiginfo = readdlm(infofile, '\t', header=true)
    contcts = readdlm(contctsfile, '\t', header=false)
    names = @view contiginfo[1,][:, 1]
    dist = NamedArray(zeros(Int32,length(names),length(names)),(names,names))
    
    num_rows = size(contcts, 1)
    @threads for i in 1:num_rows
        dist[contcts[i,1],contcts[i,4]] += contcts[i,7]
        if contcts[i,1] != contcts[i,4]
            dist[contcts[i,4],contcts[i,1]] += contcts[i,7]
        end
    end
    return dist
end
