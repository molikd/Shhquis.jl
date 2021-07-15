function firstindexin(a::AbstractArray, b::AbstractArray)
	bdict = Dict{eltype(b), Int}()
	for i=length(b):-1:1
		bdict[b[i]] = i
	end
	[get(bdict, i, 0) for i in a]
end


"""
Crates a matrix from three columns: name 1, name 2, weight
"""
funciton DistanceMatrixFromTriColumn(r::AbstractArray)
	Names = unique(vcat(r[1],r[2]))
	Dist = NamedArray(zeros(length(Names),length(Names)),(Names,Names))
	IdxOne = [firstindexin(r[1],Names),firstindexin(r[2],Names)]
	IdxTwo = [firstindexin(r[2],Names),firstindexin(r[1],Names)]
	
end
