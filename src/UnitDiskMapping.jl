# Copyright 2021 QuEra Computing Inc. All rights reserved.

module UnitDiskMapping

using Graphs

export UGrid, apply_gadgets!, apply_gadget!, embed_graph, unitdisk_graph
export unapply_gadgets!, unmatch
export Pattern, TShape, Corner, Turn, Cross, source_graph, mapped_graph
export mapped_entry_to_compact, source_entry_to_configs

include("mapping.jl")
include("gadgets.jl")
include("extracting_results.jl")

end
