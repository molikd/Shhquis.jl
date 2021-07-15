"""
Crates a matrix from three columns: name 1, name 2, weight
"""
function DistanceMatrixFromTriColumn(r::AbstractArray)
	Names = unique(vcat(r[1],r[2]))
	Dist = NamedArray(zeros(length(Names),length(Names)),(Names,Names))
	for row in Names
		for col in Names
			Dist[row,col] = r[(r[:,1] .== row) .& (r[:,2] .== col),:3][1]
		end
	end
	return Dist
end
