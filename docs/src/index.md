# Calculus

## Overview

This repository contains a package that provides a collection of functions and documentation for learning and applying calculus concepts. The code and documentation are created as I work through various calculus textbooks, discussed below.

Besides the package documentation, in the left-hand sidebar menu you will also find  links to documents explaining topics from the source books. These often provide more details than covered in the books.

The Basics documentation section covers the basic foundations of differential and integral calculus, including derivatives, curve sketching, integrals, antiderivatives and integration techniques. The source of the documents in this section is the book [_Foundations of Mathematics: A Preparatory Course_](https://link.springer.com/book/10.1007/978-3-662-67809-1). by Guido Walz, Frank Zeilfelder and Thomas Rießinger. The earlier contents of this book cover basic mathematical concepts, and documentation and code for those topics can be found in the [Math_Foundations](https://fourm.info/math_foundations/dev/sites/) package.

The version currently up started as a summary created by Claude. Thus far I have only edited the first chapter on derivatives. As I progress, I will go through each chapter and edit it carefully. Code and notebooks are also being added as I go through the text.

## Calculus with Julia Squared

A while back I  came across John Verzani's excellent [Calculus with Julia Notes](https://calculuswithjulia.github.io) which makes use of his [Calculus with Julia package](https://jverzani.github.io/CalculusWithJulia.jl/dev/). Since I enjoy using Julia and have committed to it, and want to avoid context switching to Python unless absolutely necessary, I focus on using [Julia Symbolics](https://docs.sciml.ai/Symbolics/stable/) and [Nemo](https://nemo.readthedocs.io/en/latest/) instead of SymPy. So while I want to use Verzani's work, it is heavily dependent on SymPy.

So I decided to go down the quixotic path of porting Verzani's repos to be pure Julia. I would never have attempted this in the pre-LLMs day. My knowledge of Julia, Python and calculus is just not good enough. But with the help of Claude, _Calculus with Julia_ became _Calculus with Julia with Julia not Python_. More succinctly: _Calculus with Julia Squared_ (CWJS). I am also in the process of porting a new version of _Calculus with Julia Squared_ notes. Eventually I will write up a blog post on the port experience.

Since I will be making extensive use of CWJS in my package code, I have also added CWJS as a re-export to this package. You can see the documentation in the CWJS API link in the left-hand sidebar menu.

## Notebooks

Since I invested a lot of time in the port, I decided to go through my own version, the [Calculus with Julia Squared notes (CWJSN),](https://fourm.info/cwjsn/) and add my own notebooks, which supplement the materials Verzani provides.

### Precalculus

The opening chapters of CWJSN are the _Mathematical Basics_ and _Precalculus_ sections, starting with [From calculator to computer](https://fourm.info/cwjsn/basics/calculator.html). Most of this material is already covered, often in more depth, in my [Math_Foundations](https://fourm.info/math_foundations/) package and its [Basics notebook](https://github.com/FourMInfo/Math_Foundations/blob/main/notebooks/Basics.ipynb), so I do not repeat it here. You can go through that repo to cover much of the same material.

Hence the [PreCalc notebook](https://github.com/FourMInfo/Calculus/blob/main/notebooks/PreCalc.ipynb) only includes material that is new to me in either Julia or the math (or both), along with comments on and/or expansion of points in CWJSN which I feel need further clarification.

## Package's Module

The Calculus package contains one module, [Calculus.jl](https://github.com/FourMInfo/Calculus/blob/main/src/Calculus.jl) which essentially encapsulates and exports all aspects of code contained in this repository. The simplest way to access all its functionality is to use the Julia package manager to add the GitHub repository (which is open source). Then you can use the command `using Calculus` in your notebook, code or Julia REPL.

## Basic Calculus

The code for this can be found in the [calculus\_basic.jl](https://github.com/FourMInfo/Calculus/blob/main/src/calculus_basic.jl) file. Unlike earlier repositories, some of the included functions (mostly helper functions) are written by Claude. Those are clearly marked with Claude as author.

```@autodocs
Modules = [Calculus]
Order   = [:function, :type]
Pages   = ["calculus_basic.jl"]
```
