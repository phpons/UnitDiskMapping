"""
### Provides
1. visualization of mapping
2. the script for generating backward mapping (project/createmap.jl)
3. the script for tikz visualization (project/vizgadget.jl)
"""
abstract type Pattern end
"""
### Properties
* size
* cross_location
* source: (locs, graph, pins/auto)
* mapped: (locs, graph/auto, pins/auto)

### Requires
1. equivalence in MIS-compact tropical tensor (you can check it with tests),
2. the size is <= [-2, 2] x [-2, 2] at the cross (not checked, requires cross offset information),
3. ancillas does not appear at the boundary (not checked),
"""
abstract type CrossPattern <: Pattern end

function source_matrix(p::Pattern)
    m, n = size(p)
    locs, _, _ = source_graph(p)
    a = locs2matrix(m, n, locs)
    if iscon(p)
        for i in connected_nodes(p)
            connect_cell!(a, locs[i]...)
        end
    end
    return a
end

function mapped_matrix(p::Pattern)
    m, n = size(p)
    locs, _, _ = mapped_graph(p)
    locs2matrix(m, n, locs)
end

function locs2matrix(m, n, locs::AbstractVector{NT}) where NT <: Node
    a = fill(empty(cell_type(NT)), m, n)
    for loc in locs
        add_cell!(a, loc)
    end
    return a
end

function Base.match(p::Pattern, matrix, i, j)
    a = source_matrix(p)
    m, n = size(a)
    all(ci->safe_get(matrix, i+ci.I[1]-1, j+ci.I[2]-1) == a[ci], CartesianIndices((m, n)))
end

function unmatch(p::Pattern, matrix, i, j)
    a = mapped_matrix(p)
    m, n = size(a)
    all(ci->safe_get(matrix, i+ci.I[1]-1, j+ci.I[2]-1) == a[ci], CartesianIndices((m, n)))
end

function safe_get(matrix, i, j)
    m, n = size(matrix)
    (i<1 || i>m || j<1 || j>n) && return 0
    return matrix[i, j]
end

function safe_set!(matrix, i, j, val)
    m, n = size(matrix)
    if i<1 || i>m || j<1 || j>n
        @assert val == 0
    else
        matrix[i, j] = val
    end
    return val
end

Base.show(io::IO, ::MIME"text/plain", p::Pattern) = Base.show(io, p)
function Base.show(io::IO, p::Pattern)
    print_grid(io, source_matrix(p))
    println(io)
    println(io, " "^(size(p)[2]-1) * "↓")
    print_grid(io, mapped_matrix(p))
end

function apply_gadget!(p::Pattern, matrix, i, j)
    a = mapped_matrix(p)
    m, n = size(a)
    for ci in CartesianIndices((m, n))
        safe_set!(matrix, i+ci.I[1]-1, j+ci.I[2]-1, a[ci])  # e.g. the Truncated gadget requires safe set
    end
    return matrix
end

function unapply_gadget!(p, matrix, i, j)
    a = source_matrix(p)
    m, n = size(a)
    for ci in CartesianIndices((m, n))
        safe_set!(matrix, i+ci.I[1]-1, j+ci.I[2]-1, a[ci])  # e.g. the Truncated gadget requires safe set
    end
    return matrix
end

struct Cross{CON} <: CrossPattern end
iscon(::Cross{CON}) where {CON} = CON
# ⋅ ● ⋅
# ◆ ◉ ●
# ⋅ ◆ ⋅
function source_graph(::Cross{true})
    locs = Node.([(2,1), (2,2), (2,3), (1,2), (2,2), (3,2)])
    g = simplegraph([(1,2), (2,3), (4,5), (5,6), (1,6)])
    return locs, g, [1,4,6,3]
end

# ⋅ ● ⋅
# ● ● ●
# ⋅ ● ⋅
function mapped_graph(::Cross{true})
    locs = Node.([(2,1), (2,2), (2,3), (1,2), (3,2)])
    locs, unitdisk_graph(locs, 1.5), [1,4,5,3]
end
Base.size(::Cross{true}) = (3, 3)
cross_location(::Cross{true}) = (2,2)
connected_nodes(::Cross{true}) = [1, 6]

# ⋅ ⋅ ● ⋅ ⋅
# ● ● ◉ ● ●
# ⋅ ⋅ ● ⋅ ⋅
# ⋅ ⋅ ● ⋅ ⋅
function source_graph(::Cross{false})
    locs = Node.([(2,1), (2,2), (2,3), (2,4), (2,5), (1,3), (2,3), (3,3), (4,3)])
    g = simplegraph([(1,2), (2,3), (3,4), (4,5), (6,7), (7,8), (8,9)])
    return locs, g, [1,6,9,5]
end

# ⋅ ⋅ ● ⋅ ⋅
# ● ● ● ● ●
# ⋅ ● ● ● ⋅
# ⋅ ⋅ ● ⋅ ⋅
function mapped_graph(::Cross{false})
    locs = Node.([(2,1), (2,2), (2,3), (2,4), (2,5), (1,3), (3,3), (4,3), (3, 2), (3,4)])
    locs, unitdisk_graph(locs, 1.5), [1,6,8,5]
end
Base.size(::Cross{false}) = (4, 5)
cross_location(::Cross{false}) = (2,3)

struct Turn <: CrossPattern end
iscon(::Turn) = false
# ⋅ ● ⋅ ⋅
# ⋅ ● ⋅ ⋅
# ⋅ ● ● ●
# ⋅ ⋅ ⋅ ⋅
function source_graph(::Turn)
    locs = Node.([(1,2), (2,2), (3,2), (3,3), (3,4)])
    g = simplegraph([(1,2), (2,3), (3,4), (4,5)])
    return locs, g, [1,5]
end

# ⋅ ● ⋅ ⋅
# ⋅ ⋅ ● ⋅
# ⋅ ⋅ ⋅ ●
# ⋅ ⋅ ⋅ ⋅
function mapped_graph(::Turn)
    locs = Node.([(1,2), (2,3), (3,4)])
    locs, unitdisk_graph(locs, 1.5), [1,3]
end
Base.size(::Turn) = (4, 4)
cross_location(:
    return locs, unitdisk_graph(locs, 1.5), [1]
end
Base.size(::EndTurn) = (3,4)
cross_location(::EndTurn) = (2,2)
iscon(::EndTurn) = false

#---------- Add end gadgets --------------------
struct EndTurnD <: CrossPattern end
# ⋅ ⋅ ⋅ ⋅
# ⋅ ● ⋅ ⋅
# ⋅ ⋅ ● ⋅
# ⋅ ⋅ ● ⋅ 
function source_graph(::EndTurnD)
    locs = Node.([(2,2), (3,3), (4,3)])
    g = simplegraph([(1,2), (2,3)])
    return locs, g, [3]
end
# ⋅ ⋅ ⋅ ⋅
# ⋅ ⋅ ⋅ ⋅
# ⋅ ⋅ ⋅ ⋅
# ⋅ ⋅ ● ⋅ 
function mapped_graph(::EndTurnD)
    locs = Node.([(4,3)])
    return locs, unitdisk_graph(locs, 1.5), [1]
end
Base.size(::EndTurnD) = (4,4)
cross_location(::EndTurnD) = (3,3)
iscon(::EndTurnD) = false

############## Rotation and Flip ###############
struct RotatedGadget{GT} <: Pattern
    gadget::GT
    n::Int
end
function Base.size(r::RotatedGadget)
    m, n = size(r.gadget)
    return r.n%2==0 ? (m, n) : (n, m)
end
struct ReflectedGadget{GT} <: Pattern
    gadget::GT
    mirror::String
end
function Base.size(r::ReflectedGadget)
    m, n = size(r.gadget)
    return r.mirror == "x" || r.mirror == "y" ? (m, n) : (n, m)
end

for T in [:RotatedGadget, :ReflectedGadget]
    @eval function source_graph(r::$T)
        locs, graph, pins = source_graph(r.gadget)
        center = cross_location(r.gadget)
        locs = map(loc->offset(loc, _get_offset(r)), _apply_transform.(Ref(r), locs, Ref(center)))
        return locs, graph, pins
    end
    @eval function mapped_graph(r::$T)
        locs, graph, pins = mapped_graph(r.gadget)
        center = cross_location(r.gadget)
        locs = map(loc->offset(loc, _get_offset(r)), _apply_transform.(Ref(r), locs, Ref(center)))
        return locs, graph, pins
    end
    @eval cross_location(r::$T) = cross_location(r.gadget) .+ _get_offset(r)
    @eval function _get_offset(r::$T)
        m, n = size(r.gadget)
        a, b = _apply_transform.(Ref(r), Node.([(1,1), (m,n)]), Ref(cross_location(r.gadget)))
        return 1-min(a[1], b[1]), 1-min(a[2], b[2])
    end
    @eval iscon(r::$T) = iscon(r.gadget)
    @eval connected_nodes(r::$T) = connected_nodes(r.gadget)
    @eval vertex_overhead(p::$T) = vertex_overhead(p.gadget)
    @eval function mapped_entry_to_compact(r::$T)
        return mapped_entry_to_compact(r.gadget)
    end
    @eval function source_entry_to_configs(r::$T)
        return source_entry_to_configs(r.gadget)
    end
    @eval mis_overhead(p::$T) = mis_overhead(p.gadget)
end

for T in [:RotatedGadget, :ReflectedGadget]
    @eval _apply_transform(r::$T, node::Node, center) = chxy(node, _apply_transform(r, getxy(node), center))
end
function _apply_transform(r::RotatedGadget, loc::Tuple{Int,Int}, center)
    for _=1:r.n
        loc = rotate90(loc, center)
    end
    return loc
end

function _apply_transform(r::ReflectedGadget, loc::Tuple{Int,Int}, center)
    loc = if r.mirror == "x"
        reflectx(loc, center)
    elseif r.mirror == "y"
        reflecty(loc, center)
    elseif r.mirror == "diag"
        reflectdiag(loc, center)
    elseif r.mirror == "offdiag"
        reflectoffdiag(loc, center)
    else
        throw(ArgumentError("reflection direction $(r.direction) is not defined!"))
    end
    return loc
end

function vertex_overhead(p::Pattern)
    nv(mapped_graph(p)[2]) - nv(source_graph(p)[1])
end

function mapped_boundary_config(p::Pattern, config)
    _boundary_config(mapped_graph(p)[3], config)
end
function source_boundary_config(p::Pattern, config)
    _boundary_config(source_graph(p)[3], config)
end
function _boundary_config(pins, config)
    res = 0
    for (i,p) in enumerate(pins)
        res += Int(config[p]) << (i-1)
    end
    return res
end

function rotated_and_reflected(p::Pattern)
    patterns = Pattern[p]
    source_matrices = [source_matrix(p)]
    for pi in [[RotatedGadget(p, i) for i=1:3]..., [ReflectedGadget(p, axis) for axis in ["x", "y", "diag", "offdiag"]]...]
        m = source_matrix(pi)
        if m ∉ source_matrices
            push!(patterns, pi)
            push!(source_matrices, m)
        end
    end
    return patterns
end