# Applications of Derivatives and Extrema

The [first derivative](https://mathworld.wolfram.com/Derivative.html) is a powerful tool for analysing the shape of a graph. This page follows Walz, _Foundations of Mathematics_, the first part of Section 6.2: it connects the sign of the derivative to whether a function rises or falls, and uses the first and second derivatives to locate the largest and smallest values of a function — its [extrema](https://mathworld.wolfram.com/Extremum.html).

Throughout we build on the derivatives and rules developed on the page [Derivatives and Derivative Rules](01 Derivatives and Rules.md).

## Monotonicity and the Sign of the First Derivative

A function is _monotonically increasing_ if $x_1 < x_2$ always implies $f(x_1) \le f(x_2)$, and _strictly monotonically increasing_ if $x_1 < x_2$ implies $f(x_1) < f(x_2)$; the decreasing cases are defined analogously. For differentiable functions there is a simple criterion in terms of the derivative.

**Monotonicity and the sign of $f'$.** A differentiable function $f$ is monotonically increasing if and only if $f'(x) \ge 0$ for all $x$, and monotonically decreasing if and only if $f'(x) \le 0$ for all $x$.

For example $g(x) = x^2 - 2x$ has $g'(x) = 2x - 2$, so $g$ is decreasing for $x \le 1$ (there $g'(x) \le 0$) and increasing for $x \ge 1$ (there $g'(x) \ge 0$). A graph generally consists of several such _monotonicity regions_.

**Strict monotonicity.** A differentiable function $f$ with $f'(x) > 0$ for all $x$ is strictly monotonically increasing; if $f'(x) < 0$ for all $x$, it is strictly monotonically decreasing.

The converse of the strict statement fails: the strictly increasing function $f(x) = \tfrac{1}{3}x^3$ has $f'(x) = x^2 \ge 0$, with equality at $x = 0$. So $f' > 0$ everywhere is sufficient but not necessary for strict monotonicity.

## The Derivative of an Inverse Function

Strictly monotonic functions are invertible. If $f$ is differentiable with $f'(x) \neq 0$ throughout, then its inverse $f^{-1}$ is differentiable, and differentiating $f^{-1}(f(x)) = x$ with the chain rule gives:

**Derivative of the inverse function.** $$\bigl(f^{-1}\bigr)'(\bar{x}) = \frac{1}{f'(x)}, \qquad \text{where } \bar{x} = f(x).$$

For example, from $f(x) = x^2$ (with $x > 0$) and $f'(x) = 2x$ we recover $\bigl(\sqrt{\bar{x}}\bigr)' = \tfrac{1}{2\sqrt{\bar{x}}}$; and from $\exp'(x) = e^x$ we obtain the derivative of the natural logarithm $$\ln'(\bar{x}) = \frac{1}{\bar{x}}, \qquad \bar{x} > 0.$$

## Global Extrema

A location $x_0$ is a [global maximum](https://mathworld.wolfram.com/GlobalMaximum.html) of $f$ if $f(x) \le f(x_0)$ for _all_ $x$, and a [global minimum](https://mathworld.wolfram.com/GlobalMinimum.html) if $f(x) \ge f(x_0)$ for all $x$. Either kind is called a _global extremum_.

**Global extrema of monotone functions.** If $f : \lbrack a, b \rbrack \to \mathbb{R}$ is monotone on a closed interval, then the endpoints $a$ and $b$ are its global extrema.

For functions that are not monotone as a whole — the typical case — global extrema may occur in the interior of the interval, and we must also examine local extrema.

## Local Extrema

A point $x_0$ is a [local maximum](https://mathworld.wolfram.com/LocalMaximum.html) of $f$ if there is a surrounding interval $(x_0 - c, x_0 + c)$ with $c > 0$ on which $f(x) \le f(x_0)$, and a [local minimum](https://mathworld.wolfram.com/LocalMinimum.html) if $f(x) \ge f(x_0)$ there. Either kind is a _local extremum_, and $(x_0 \mid f(x_0))$ is the corresponding _extreme point_ of the graph.

### Necessary Criterion

At a local extremum of a differentiable function, the graph has a _horizontal tangent_.

**Necessary criterion for local extrema.** If a differentiable function $f$ has a local extremum at $x_0$, then $$f'(x_0) = 0.$$

The condition is _necessary but not sufficient_: for $f(x) = \tfrac{1}{3}x^3$ we have $f'(0) = 0$, yet $x_0 = 0$ is not an extremum, because $f'$ does not change sign there.

### Sufficient Criterion via Sign Change

The candidates found from $f'(x_0) = 0$ are genuine extrema precisely when the derivative changes sign there.

- If $f'$ changes sign from $+$ to $-$ at $x_0$, then $x_0$ is a local maximum.
- If $f'$ changes sign from $-$ to $+$ at $x_0$, then $x_0$ is a local minimum.

For the cubic $f(x) = \tfrac{1}{4}x^3 + \tfrac{3}{4}x^2 - \tfrac{3}{2}x - 2$, solving $f'(x) = \tfrac{3}{4}(x^2 + 2x - 2) = 0$ gives the candidates $x_1 = -1 + \sqrt{3}$ and $x_2 = -1 - \sqrt{3}$; checking the sign of the factored derivative shows $x_2$ is a local maximum and $x_1$ a local minimum.

## Higher Derivatives

If the derivative $f'$ is itself differentiable, its derivative $(f')'$ is the _second derivative_ $f''$ (read "f two dash"). More generally, the $i$-th derivative $f^{(i)}$ is the derivative of $f^{(i-1)}$, and $f$ is _infinitely often differentiable_ if $f^{(i)}$ exists for all $i \in \mathbb{N}$.

**Higher derivatives of polynomials.** Every polynomial of degree $n$ can be differentiated infinitely often; its $i$-th derivative is a polynomial of degree $n - i$ for $i \le n$, and vanishes for $i \ge n + 1$.

Not every once-differentiable function can be differentiated repeatedly: $f(x) = x^{5/2}$ ($x \ge 0$) has $f''(x) = \tfrac{15}{4}\sqrt{x}$, but $f''$ is not differentiable at $x = 0$, so $f$ is twice but not three times differentiable.

### Sufficient Criterion via the Second Derivative

The second derivative provides a more convenient test than checking sign changes directly.

**Sufficient criterion for local extrema.** Let $f$ be twice differentiable with $f'(x_0) = 0$. If in addition $f''(x_0) \neq 0$, then $f$ has a local extremum at $x_0$:

- If $f''(x_0) < 0$, then $x_0$ is a local maximum.
- If $f''(x_0) > 0$, then $x_0$ is a local minimum.

For the cubic above, $f''(x) = \tfrac{3}{2}(x + 1)$ gives $f''(x_1) = \tfrac{3\sqrt{3}}{2} > 0$ and $f''(x_2) = -\tfrac{3\sqrt{3}}{2} < 0$, confirming that $x_1$ is a local minimum and $x_2$ a local maximum.

### The Higher-Order Test

If $f''(x_0) = 0$ as well, one can sometimes decide using still higher derivatives.

**Higher-order criterion.** Suppose $f$ is $i$-times differentiable with $$f'(x_0) = f''(x_0) = \cdots = f^{(i-1)}(x_0) = 0 \quad\text{and}\quad f^{(i)}(x_0) \neq 0.$$ If $i$ is _even_, then $f$ has a local extremum at $x_0$ — a local maximum if $f^{(i)}(x_0) < 0$, a local minimum if $f^{(i)}(x_0) > 0$. If $i$ is _odd_, this test does not apply.

For $f(x) = \tfrac{1}{12}x^4$ we have $f'(0) = f''(0) = f'''(0) = 0$ but $f''''(0) = 2 > 0$; since $i = 4$ is even, $x_0 = 0$ is a local minimum. For $f(x) = \tfrac{1}{3}x^3$ the first non-zero derivative at $0$ is $f'''(0) = 2$ with $i = 3$ odd, and indeed $0$ is not an extremum.

## Where This Leads

Having located maxima and minima, the next page, [Curve Sketching](03 Curve Sketching.md), studies the remaining features of a graph — convexity, inflection points, zeros, symmetry, and asymptotic behaviour — and combines all of these tools to sketch a function completely.
