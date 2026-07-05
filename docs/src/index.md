# Calculus

## Overview

This repository contains a package that provides a collection of functions and documentation for learning and applying calculus concepts. The code and documentation are created as I work through various calculus textbooks, discussed below.

Besides the package documentation, you will also find in the left navigation tab links to documents explaining topics from the source books. These often provide more details than covered in the books. Currently, there is one section: Basics

The Basics documentation section covers the basic foundations of differential and integral calculus, including derivatives, curve sketching, integrals, antiderivatives and integration techniques. The source of the documents in this section is the book [_Foundations of Mathematics: A Preparatory Course_](https://link.springer.com/book/10.1007/978-3-662-67809-1). by Guido Walz, Frank Zeilfelder and Thomas Rießinger. The earlier contents of this book cover basic mathematical concepts, and documentation and code for those topics can be found in the [Math_Foundations](https://study.fourm.info/math_foundations/dev/sites/) package.

The version currently up is a summary created by Claude which has not yet been edited by me. As I go through it I will edit it carefully. Also there is no code or notebooks yet, and those will be created as I go through the text.

## Package's Module

The Calculus package contains one module, [Calculus.jl](https://github.com/FourMInfo/Calculus/blob/main/src/Calculus.jl) which essentially encapsulates and exports all aspects of code contained in this repository. The simplest way to access all its functionality is to use the Julia package manager to add the Github repository (which is open source). Then you can use the command `using Calculus` in your notebook, code or Julia REPL.

## Basic Linear Algebra

The code for this can be found in the [calculus\_basic.jl](https://github.com/FourMInfo/Calculus/blob/main/src/calculus_basic.jl) file.

```@autodocs
Modules = [Calculus]
Order   = [:function, :type]
Pages   = ["calculus_basic.jl"]
```
