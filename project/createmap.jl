using UnitDiskMapping, GraphTensorNetworks, Graphs

function mapped_entry_to_compact(s::Pattern)
    locs, g, pins = mapped_graph(s)
    a = solve(Independence(g; openvertices=pins), "size max")
    b = mis_compactify!(copy(a))
    n = length(a)
    d = Dict{Int,Int}()  # the mapping from bad to good
    for i=1:n
        val_a = a[i]
        if iszero(b[i]) && !iszero(val_a)
            bs_a = i-1
            for j=1:n # search for the entry b[j] compactify a[i]
                bs_b = j-1
                if b[j] == val_a && (bs_b & bs_a) == bs_b  # find you!
                    d[bs_a] = bs_b
                    break
                end
            end
        else
            d[i-1] = i-1
        end
    end
    return d
end

# from mapped graph bounary configuration to compact bounary configuration
function source_entry_to_configs(s::Pattern)
    locs, g, pins = source_graph(s)
    a = solve(Independence(g, openvertices=pins), "configs max")
    d = Dict{Int,Vector{BitVector}}()  # the mapping from bad to good
    for i=1:length(a)
        d[i-1] = [BitVector(s) for s in a[i].c.data]
    end
    return d
end

function compute_mis_overhead(s)
    locs1, g1, pins1 = source_graph(s)
    locs2, g2, pins2 = mapped_graph(s)
    m1 = mis_compactify!(solve(Independence(g1, openvertices=pins1), "size max"))
    m2 = mis_compactify!(solve(Independence(g2, openvertices=pins2), "size max"))
    @assert nv(g1) == length(locs1) && nv(g2) == length(locs2)
    sig, diff = UnitDiskMapping.is_diff_by_const(GraphTensorNetworks.content.(m1), GraphTensorNetworks.content.(m2))
    @assert sig
    return diff
end


# from bounary configuration to MISs.
function generate_mapping(s::Pattern)
    d1 = mapped_entry_to_compact(s)
    d2 = source_entry_to_configs(s)
    diff = compute_mis_overhead(s)
    s = """function mapped_entry_to_compact(::$(typeof(s)))
    return Dict($(collect(d1)))
end

function source_entry_to_configs(::$(typeof(s)))
    return Dict($(collect(d2)))
end

mis_overhead(::$(typeof(s))) = $(-Int(diff))
"""
end

function dump_mapping_to_julia(filename, patterns)
    s = join([generate_mapping(p) for p in patterns], "\n\n")
    open(filename, "w") do f
        write(f, "# Do not modify this file, because it is automatically generated by `project/createmap.jl`\n\n" * s)
    end
end

dump_mapping_to_julia(joinpath(@__DIR__, "..", "src", "extracting_results.jl"),
    (Cross{false}(), Cross{true}(),
    Turn(), WTurn(), Branch(), BranchFix(), TrivialTurn(), TCon(), BranchFixB(),
    EndTurn(),
    UnitDiskMapping.simplifier_ruleset...))
