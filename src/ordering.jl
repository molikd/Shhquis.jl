"""Return connected components for the non-zero, off-diagonal contact graph."""
function _contact_components(contacts::AbstractMatrix)
    ncontigs = size(contacts, 1)
    visited = falses(ncontigs)
    components = Vector{Vector{Int}}()

    for start in 1:ncontigs
        visited[start] && continue
        component = Int[]
        stack = [start]
        visited[start] = true

        while !isempty(stack)
            current = pop!(stack)
            push!(component, current)
            for neighbor in 1:ncontigs
                linked = neighbor != current &&
                    (contacts[current, neighbor] > 0 || contacts[neighbor, current] > 0)
                if linked && !visited[neighbor]
                    visited[neighbor] = true
                    push!(stack, neighbor)
                end
            end
        end

        push!(components, component)
    end

    return components
end

"""
    order_contigs(contacts, clustering_order, names, lengths)

Create a deterministic output order from a contact matrix and a hierarchical
clustering order.

Contigs connected by one or more contact links stay in the same component.
Components are emitted from greatest to least total sequence length, while the
hierarchical-clustering order is retained within each linked component. A
contig with no links forms a one-contig component, so unlinked contigs naturally
fall into longest-to-shortest order.
"""
function order_contigs(
    contacts::AbstractMatrix,
    clustering_order::AbstractVector{<:Integer},
    names::AbstractVector,
    lengths::AbstractVector,
)
    ncontigs = length(names)
    size(contacts) == (ncontigs, ncontigs) || throw(ArgumentError("contact matrix dimensions must match the contig names"))
    length(lengths) == ncontigs || throw(ArgumentError("contig lengths must match the contig names"))
    sort(Int.(clustering_order)) == collect(1:ncontigs) || throw(ArgumentError("clustering_order must be a permutation of all contig indices"))

    numeric_lengths = Float64.(lengths)
    all(>=(0), numeric_lengths) || throw(ArgumentError("contig lengths must be non-negative"))

    cluster_rank = zeros(Int, ncontigs)
    for (rank, contig_index) in enumerate(clustering_order)
        cluster_rank[contig_index] = rank
    end

    components = _contact_components(contacts)
    for component in components
        sort!(component; by=contig_index -> cluster_rank[contig_index])
    end

    # The secondary keys make equal-sized components stable and reproducible.
    sort!(components; by=component -> (
        -sum(numeric_lengths[component]),
        -maximum(numeric_lengths[component]),
        minimum(cluster_rank[component]),
        minimum(component),
    ))

    ordered_indices = reduce(vcat, components; init=Int[])
    return [names[index] for index in ordered_indices]
end
