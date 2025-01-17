# UnitDiskMapping (Expansion on gadgets and optimisation)

[![CI](https://github.com/QuEraComputing/UnitDiskMapping.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/QuEraComputing/UnitDiskMapping.jl/actions/workflows/ci.yml)
[![codecov](https://codecov.io/github/QuEraComputing/UnitDiskMapping.jl/branch/main/graph/badge.svg?token=fwlEQnQICw)](https://codecov.io/github/QuEraComputing/UnitDiskMapping.jl)

## Installation
<p>
<code>UnitDiskMapping</code> is a &nbsp;
    <a href="https://julialang.org">
        <img src="https://raw.githubusercontent.com/JuliaLang/julia-logo-graphics/master/images/julia.ico" width="16em">
        Julia Language
    </a>
    &nbsp; package for reducing a <a href="https://en.wikipedia.org/wiki/Independent_set_(graph_theory)">generic maximum (weighted) independent set problem</a>, <a href="https://en.wikipedia.org/wiki/Quadratic_unconstrained_binary_optimization"> quadratic unconstrained binary optimization (QUBO) problem</a> or <a href="https://en.wikipedia.org/wiki/Integer_factorization">integer factorization problem</a> to a maximum independent set problem on a unit disk grid graph (or hardcore lattice gas in physics), which can then be naturally encoded in neutral-atom quantum computers. To install <code>UnitDiskMapping</code>,
    please <a href="https://docs.julialang.org/en/v1/manual/getting-started/">open
    Julia's interactive session (known as REPL)</a> and press the <kbd>]</kbd> key in the REPL to use the package mode, and then type the commands below.
</p>

For installing the current master branch, please type:

```julia
pkg> add https://github.com/QuEraComputing/UnitDiskMapping.jl.git
```

For stable release (not yet ready):

```julia
pkg> add UnitDiskMapping
```

## Examples

Please check this [notebook](https://queracomputing.github.io/UnitDiskMapping.jl/notebooks/tutorial.html), which contains the following examples:

* Reduction from a generic weighted or unweighted maximum independent set (MIS) problem to that on a diagonal coupled unit-disk grid graph (DUGG).
* Reduction from a generic or square-lattice QUBO problem to an MIS problem on a unit-disk grid graph.
* Reduction from an integer factorization problem to an MIS problem on a unit-disk grid graph.

![](https://user-images.githubusercontent.com/6257240/198861111-4499c17d-9938-406b-8253-943b01f4633c.png)

To run the notebook locally, you will need the [Pluto](https://github.com/fonsp/Pluto.jl) and [GenericTensorNetworks](https://github.com/QuEraComputing/GenericTensorNetworks.jl) Julia packages installed. You can run the following after entering the Package mode:

```
pkg> add Pluto
pkg> add GenericTensorNetworks
```

and returning to the Julia REPL (you can do this by hitting Backspace in the Package mode) to run:

```
julia> import Pluto; Pluto.run()
```
in the `notebooks` directory of this project. At this point, your browser should automatically launch and display a list of available notebooks you can run. You should just see `tutorial.jl` listed.


## Supporting and Citing
Much of the software in this ecosystem was developed as a part of an academic research project. If you would like to help support it, please star the repository. If you use our software as part of your research, teaching, or other activities, we would like to request you to cite our [work](https://arxiv.org/abs/2209.03965). The [CITATION.bib](CITATION.bib) file in the root of this repository lists the relevant papers.
