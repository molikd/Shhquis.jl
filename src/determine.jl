"""
given the Contacts and Framgents files stream in the contacts and determine low contact fragments
"""
function lowcontctfrags(contctsfile::AbstractString, fragfile::AbstractString)
  fraginfo = readdlm(fragfile, '\t', header=true)  

  for line in eachline(contactsfile)

  end

end

"""
given the contacts and Fragments files stream in the contacts and dertermine low contact fragments, all while utilizing the new positioning info (update the positions)
"""
function write_reorient_fragments(genomefile::AbstractString,genomefileout::AbstractString,frinfo::AbstractArray,genomefaifile::AbstractString,positions::AbstractArray)
end

"""
given a list of positions and contigs write out a fasta of the portions of the contigs
"""
function postoseq(positions::AbstractArray, genomeinfile::AbstractString)
end
