"""
    _read_contig_table(path)

Read a hicstuff `info_contigs.txt` table and return its contig names, lengths,
and full data matrix. The first two columns must contain a unique contig name
and a non-negative contig length.
"""
function _read_contig_table(path::AbstractString)
    data, _ = readdlm(path, '\t'; header=true)
    size(data, 2) >= 2 || throw(ArgumentError("contig information must have at least two columns"))
    size(data, 1) > 0 || throw(ArgumentError("contig information is empty"))

    names = string.(data[:, 1])
    lengths = Int.(data[:, 2])
    length(unique(names)) == length(names) || throw(ArgumentError("contig names must be unique"))
    all(>=(0), lengths) || throw(ArgumentError("contig lengths must be non-negative"))

    return names, lengths, data
end

"""
    _contact_index(value, name_to_index, ncontigs)

Resolve a contig reference from a hicstuff contact row. Hicstuff files may use
one-based numeric contig identifiers or the contig names themselves.
"""
function _contact_index(value, name_to_index::AbstractDict, ncontigs::Integer)
    index = if value isa Integer
        Int(value)
    elseif value isa AbstractFloat && isinteger(value)
        Int(value)
    else
        get(name_to_index, string(value), 0)
    end

    1 <= index <= ncontigs || throw(ArgumentError("unknown contig reference: $(repr(value))"))
    return index
end

"""Accumulate one chunk of contact rows in a task-local matrix."""
function _contact_counts(contacts::AbstractMatrix, rows, name_to_index::AbstractDict, ncontigs::Integer)
    counts = zeros(Float64, ncontigs, ncontigs)

    for row_index in rows
        left = _contact_index(contacts[row_index, 1], name_to_index, ncontigs)
        right = _contact_index(contacts[row_index, 4], name_to_index, ncontigs)
        weight = Float64(contacts[row_index, 7])
        isfinite(weight) && weight >= 0 || throw(ArgumentError("contact weights must be finite and non-negative"))

        counts[left, right] += weight
        left == right || (counts[right, left] += weight)
    end

    return counts
end

"""
    coltodist(rows, ntasks=Threads.nthreads())

Convert a three-column `(name_1, name_2, weight)` table to a named matrix.
Rows are applied in input order, making duplicate entries deterministic. The
`ntasks` argument is retained for API compatibility; this small conversion is
kept serial because parallel writes would race when entries are repeated.
"""
function coltodist(rows::AbstractMatrix, ntasks::Int=Threads.nthreads())
    size(rows, 2) >= 3 || throw(ArgumentError("the contact table must have at least three columns"))
    ntasks > 0 || throw(ArgumentError("ntasks must be positive"))

    labels = unique(vcat(collect(rows[:, 1]), collect(rows[:, 2])))
    label_to_index = Dict(label => index for (index, label) in enumerate(labels))
    matrix = zeros(Float64, length(labels), length(labels))

    for row_index in axes(rows, 1)
        left = label_to_index[rows[row_index, 1]]
        right = label_to_index[rows[row_index, 2]]
        matrix[left, right] = Float64(rows[row_index, 3])
    end

    return NamedArray(matrix, (labels, labels), ("contig", "contig"))
end

"""
    builddist(infofile, contactsfile, ntasks=Threads.nthreads())

Build a symmetric, named matrix of summed contact weights from hicstuff output.
Each worker task writes to its own matrix; the task-local matrices are reduced
afterward so multiple contact rows can never race on the same array cell.
"""
function builddist(infofile::AbstractString, contactsfile::AbstractString, ntasks::Int=Threads.nthreads())
    names, _, _ = _read_contig_table(infofile)
    contacts = readdlm(contactsfile, '\t')
    size(contacts, 2) >= 7 || throw(ArgumentError("the bg2 contact table must have at least seven columns"))
    ntasks > 0 || throw(ArgumentError("ntasks must be positive"))

    ncontigs = length(names)
    name_to_index = Dict(name => index for (index, name) in enumerate(names))
    nrows = size(contacts, 1)
    counts = zeros(Float64, ncontigs, ncontigs)

    if nrows > 0
        worker_count = min(ntasks, nrows)
        row_groups = collect(Iterators.partition(1:nrows, cld(nrows, worker_count)))
        tasks = map(row_groups) do rows
            Threads.@spawn _contact_counts(contacts, rows, name_to_index, ncontigs)
        end
        for task in tasks
            counts .+= fetch(task)
        end
    end

    return NamedArray(counts, (names, names), ("contig", "contig"))
end

"""
    contactdistances(contacts)

Convert contact strengths to a dissimilarity matrix suitable for hierarchical
clustering. Stronger contacts become shorter distances. Missing links receive
a distance larger than every observed link, and the diagonal is always zero.
"""
function contactdistances(contacts::AbstractMatrix)
    size(contacts, 1) == size(contacts, 2) || throw(ArgumentError("the contact matrix must be square"))
    ncontigs = size(contacts, 1)
    distances = zeros(Float64, ncontigs, ncontigs)
    linked_distances = Float64[]

    for left in 1:ncontigs, right in (left + 1):ncontigs
        weight = max(Float64(contacts[left, right]), Float64(contacts[right, left]))
        isfinite(weight) && weight >= 0 || throw(ArgumentError("contact weights must be finite and non-negative"))
        weight > 0 && push!(linked_distances, inv(weight))
    end

    missing_distance = isempty(linked_distances) ? 1.0 : 2 * maximum(linked_distances)
    fill!(distances, missing_distance)

    for left in 1:ncontigs
        distances[left, left] = 0.0
        for right in (left + 1):ncontigs
            weight = max(Float64(contacts[left, right]), Float64(contacts[right, left]))
            distance = weight > 0 ? inv(weight) : missing_distance
            distances[left, right] = distance
            distances[right, left] = distance
        end
    end

    return distances
end
