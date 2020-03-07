# A few example implementations in Julia

Author: Markus Konrad <post@mkonrad.net>

## Overview

This repository contains code for some small projects that I implement with the programming language [Julia](https://julialang.org/) in order to learn that language. It's an ongoing effort.

## Requirements

- Julia 1.3 with the following packages:
    - [Cairo](https://github.com/JuliaGraphics/Cairo.jl/)
    - [IJulia](https://github.com/JuliaLang/IJulia.jl) (for Jupyter notebooks)

## Project sources

Each small project lives in its own folder. Common utilities, that are used in all projects, live in files in the root directory such as `cmap.jl`.

- `gcd`: simple and extended [Euclidian algorithm](https://en.wikipedia.org/wiki/Euclidean_algorithm) to find the greatest common divisor of two integers
- `residueclasses`: code to represent and visualize [residue or congruence classes](https://en.wikipedia.org/wiki/Modular_arithmetic#Congruence_classes) in modular arithmetic

Each project also contains automated tests in a `tests.jl` file.

## Jupyter notebooks

For most projects, I provide a [Jupyter notebook](https://jupyter.org/) that shows how to use the implemented functions and types:

- [`residueclasses.ipynb`](residueclasses.ipynb)


## License

The source-code is provided under [Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0) (see `LICENSE` file).
 
