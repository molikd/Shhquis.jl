"""
Given an order and names return the reodered names
"""
function ordernames(neworder::AbstractArray,oldnames::AbstractArray)
    return oldnames[neworder]
end



"""
Given a new order to chromosomes decide on the orientation based on the number of contacts
"""
function reorient(infofile::AbstractString,contctsfile::AbstractString,orderednames::AbstractArray,)
    contiginfo = readdlm(infofile, '\t', header=true)
    frinfo = NamedArray(zeros(length(Int32,orderednames),2), (orderednames,["splitp","f/r"]),("contig","contct"))
    frnames = @view allnames(frinfo)[1][:,]
    contiginfo = NamedArray(contiginfo[1,],(contiginfo[1,][:,1],contiginfo[2,][1,:]))
    contcts = readdlm(contctsfile, '\t', header=false)
 
    function builddist_pivot(frinfo::AbstractArray,contcts::AbstractArray)
        names = allnames(frinfo)[1]
        distf = NamedArray(zeros(Int32,length(names),length(names)),(names,names))
        distb = NamedArray(zeros(Int32,length(names),length(names)),(names,names))
        
        for row in eachrow(contcts)
            if row[2] < frinfo[row[1],"splitp"] && row[5] < frinfo[row[4],"splitp"]
                distf[row[1],row[4]] += row[7]
                if row[1] != row[4]
                    distf[row[4],row[1]] += row[7]
                end
            elseif row[2] > frinfo[row[1],"splitp"] && row[5] > frinfo[row[4],"splitp"] 
                distb[row[1],row[4]] += row[7]
                if row[1] != row[4]
                    distb[row[4],row[1]] += row[7]
                end
            end
        end
        
        return distf,distb
    end 

    for i = 1:size(orderednames,1)
        frinfo[orderednames[i],"splitp"] = floor(Int32,contiginfo[orderednames[i],"length"] / 2)
    end
   
    dist_front,dist_back = buildist_pivot(frinfo,contcts)
    flip_forward = false

    for i = 2:size(frinfo,1)
        if dist_front[frnames[i],frnames[i-1]] < dist_back[frnames[i],frnames[i-1]] && flip_forward == false
            frinfo[frnames[i],"f/r"] = 1
            flip_forward = true 
        elseif dist_front[frnames[i],frnames[i-1]] < dist_back[frnames[i],frnames[i-1]] && flip_forward == true
            frinfo[frnames[i],"f/r"] = 0
            flip_forward = false
        elseif dist_front[frnames[i],frnames[i-1]] > dist_back[frnames[i],frnames[i-1]] && flip_forward == false
            frinfo[frnames[i],"f/r"] = 0
            flip_forward = false
        elseif dist_front[frnames[i],frnames[i-1]] > dist_back[frnames[i],frnames[i-1]] && flip_forward == true
            frinfo[frnames[i],"f/r"] = 1
            flip_forward = true
        else
            frinfo[frnames[i],"f/r"] = 0
        end
    end

    return frinfo
end

function write_reorient(genomefile::AbstractString,genomefileout::AbstractString,frinfo::AbstractArray,genomefaifile::AbstractString)
    genomein = genome = open(FASTA.Reader, genomefile, index = genomefaifile)
    genomeout = open(FASTA.Writer, genomefileout)
    frnames = @view allnames(frinfo)[1][:,]

    for i = 1:size(frinfo,1)
      if frinfo[i,4] == 1
          write(genomeout,  FASTA.Record(identifier(genomein[frnames[i]]),reverse(sequence(genomein[frnames[i]]))))
      else
          write(genomeout, genomein[frnames[i]])
      end
    end
end
