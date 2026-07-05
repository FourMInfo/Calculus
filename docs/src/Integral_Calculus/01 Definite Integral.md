# The Definite Integral

Integration is the second key tool of calculus: it determines the area enclosed between the graph of a function and the $x$-axis. This page follows Walz, _Foundations of Mathematics_, the first part of Section 6.3: it introduces the [definite integral](https://mathworld.wolfram.com/DefiniteIntegral.html) as a limit of rectangular approximations, states when a function is integrable, and collects the basic properties and rules of the definite integral.

## Areas Under Simple Graphs

Write $F_a(b)$ for the area that the graph of $f$ encloses with the $x$-axis as $x$ runs over $\lbrack a, b \rbrack$. For the simplest functions this area is elementary geometry:

- For the constant function $f(x) = 1$, the region is a rectangle: $$\int_a^b 1\,dx = F(b) - F(a) = b - a.$$
- For the identity $f(x) = x$, the region is a triangle: $$\int_a^b x\,dx = F(b) - F(a) = \frac{b^2}{2} - \frac{a^2}{2}.$$

Here $F(b)$ and $F(a)$ are the areas over $\lbrack 0, b \rbrack$ and $\lbrack 0, a \rbrack$, and the enclosed area is their difference — a pattern that will recur throughout.

## A Curved Graph: the Parabola

For $f(x) = x^2$ the region is bounded by a curve, so we approximate. Divide $\lbrack 0, b \rbrack$ into $n$ subintervals of width $b/n$ and, on each, replace $f$ by its value at the right endpoint. Summing the resulting rectangles gives a [Riemann sum](https://mathworld.wolfram.com/RiemannSum.html) $$\mathcal{F}_n = \sum_{j=0}^{n-1} (j+1)^2 \left(\frac{b}{n}\right)^3 = \frac{n(n+1)(2n+1)}{6}\left(\frac{b}{n}\right)^3 = \frac{b^3}{6}\left(1 + \frac{1}{n}\right)\left(2 + \frac{1}{n}\right).$$

As the subdivision is refined ($n \to \infty$) the approximation converges: $$\lim_{n \to \infty} \mathcal{F}_n = \frac{b^3}{6} \cdot 2 = \frac{b^3}{3}.$$

Thus $F(b) = b^3/3$, and the enclosed area over $\lbrack a, b \rbrack$ is $$\int_a^b x^2\,dx = \frac{b^3}{3} - \frac{a^3}{3}.$$

The same reasoning gives the general power function:

**Integration of the power function.** For $p_i(x) = x^i$ with $i \in \mathbb{N} \cup \{0\}$: $$\int_a^b x^i\,dx = \frac{b^{i+1} - a^{i+1}}{i + 1}.$$

This is the "reverse" of the differentiation rule: raise the exponent by one and divide by the new exponent.

## Integrability and the Definite Integral

The construction generalises to arbitrary functions through limits of Riemann sums.

**Integrability and the definite integral.** A function $f$ is _integrable_ on $\lbrack a, b \rbrack$ if, for every partition into subintervals $I_{j,n} = \lbrack x_{j,n}, x_{j+1,n} \rbrack$ whose widths tend to $0$ as $n \to \infty$ and for every choice of sample points $\tilde{x}_{j,n} \in I_{j,n}$, the sums $$\mathcal{F}_n = \sum_{j=0}^{n-1} f(\tilde{x}_{j,n})\,(x_{j+1,n} - x_{j,n})$$ converge to one and the same limit. That limit is the _definite integral_ $$\int_a^b f(x)\,dx = \lim_{n \to \infty} \mathcal{F}_n.$$

Here $f$ is the _integrand_, $x$ the _integration variable_, and $a, b$ the _integration bounds_. The integral sign $\int$ is a stylised sum $\sum$, reflecting that the integral is a limit of sums of rectangular areas $f(\tilde{x}_{j,n})\,(x_{j+1,n} - x_{j,n})$.

Fortunately, almost every function encountered in practice is integrable:

- Monotone functions are always integrable.
- [Continuous functions](https://mathworld.wolfram.com/ContinuousFunction.html) — those whose graph can be drawn without lifting the pen — are always integrable, and this class is broad.

A function must be quite pathological to fail: the function equal to $0$ on the rationals and $1$ on the irrationals of $\lbrack 0, 1 \rbrack$ is not integrable.

## Properties of the Definite Integral

For integrable functions the definite integral satisfies the following, all read off from the defining sums.

- **Additivity of intervals:** $$\int_a^b f(x)\,dx = \int_a^c f(x)\,dx + \int_c^b f(x)\,dx.$$
- **Change of bounds:** $$\int_a^b f(x)\,dx = -\int_b^a f(x)\,dx.$$
- **Empty integral:** $$\int_a^a f(x)\,dx = 0.$$
- **Positivity:** if $f(x) \ge 0$ on $\lbrack a, b \rbrack$, then $\displaystyle\int_a^b f(x)\,dx \ge 0$.

## Oriented Versus Absolute Area

Because the integrand's sign carries into the integral, the definite integral gives the _oriented_ (signed) area, not the absolute area. For $f(x) = x$ on $\lbrack -1, 1 \rbrack$ the negative and positive parts cancel: $$\int_{-1}^{1} x\,dx = 0.$$

To obtain the _absolute_ area, integrate the absolute value $\lvert f \rvert$ — equivalently, integrate $-f$ wherever $f$ is negative: $$\int_{-1}^{1} \lvert x \rvert\,dx = -\int_{-1}^{0} x\,dx + \int_{0}^{1} x\,dx = \tfrac{1}{2} + \tfrac{1}{2} = 1.$$

## Integration Rules and Polynomials

Just as for derivatives, factor and sum rules simplify integration.

**Factor and sum rules.** For a real constant $\lambda$ and integrable $f$, $g$: $$\int_a^b (\lambda f)(x)\,dx = \lambda \int_a^b f(x)\,dx, \qquad \int_a^b (f + g)(x)\,dx = \int_a^b f(x)\,dx + \int_a^b g(x)\,dx.$$

Combined with the power-function rule, these integrate any [polynomial](https://mathworld.wolfram.com/Polynomial.html):

**Integration of polynomials.** For $p(x) = a_n x^n + \cdots + a_1 x + a_0$: $$\int_a^b p(x)\,dx = a_n\,\frac{b^{n+1} - a^{n+1}}{n+1} + \cdots + a_1\,\frac{b^2 - a^2}{2} + a_0\,(b - a).$$

For example $\displaystyle\int_0^2 (2x - x^2)\,dx = 2 \cdot 2 - \tfrac{8}{3} = \tfrac{4}{3}$.

## Where This Leads

So far the definite integral is defined through limits of sums, which are laborious to evaluate. The next page, [Antiderivatives and the Main Theorem](02 Antiderivatives and Main Theorem.md), reveals the deep connection between integration and differentiation that turns integral evaluation into a matter of finding antiderivatives.
