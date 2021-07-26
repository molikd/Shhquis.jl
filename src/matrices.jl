"""
Crates a matrix from three columns: name 1, name 2, weight
special thanks to user cbk (13639734) on StackExchange on a faster design on this
"""
function coltodist(r::AbstractArray)
    names = unique(view(r,:,1))
    dist = NamedArray(zeros(length(names),length(names)),(names,names))
    for i = 1:size(r,1)
        row = Int(r[i,1])
        col = Int(r[i,2])
        dist[row,col] = r[i,3]
    end
    return dist
end


"""
Takes ouput of a HiC run and turns it into a distance matrix
"""
function builddist(infofile::AbstractString,contctsfile::AbstractString)
    contiginfo = readdlm(infofile, '\t', header=true)
    contcts = readdlm(contctcsfile, '\t', header=false)
    names = view(contiginfo[1,][:, 1])
    dist = NamedArray(zeros(Int32,length(names),length(names)),(names,names))
    for row in eachrow(contcts)
        dist[row[1],row[4]] += row[7] 
        if row[1] != row[4]
            dist[row[4],row[1]] += row[7]
        end
    end
    return dist 
end


