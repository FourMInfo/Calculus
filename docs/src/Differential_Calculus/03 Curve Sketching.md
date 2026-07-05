# Curve Sketching

_Curve sketching_ combines the tools of differential calculus to draw the graph of a function faithfully. This page follows Walz, _Foundations of Mathematics_, the second part of Section 6.2: it studies convexity and concavity, [inflection points](https://mathworld.wolfram.com/InflectionPoint.html), zeros, symmetry, and behaviour for large $x$, and then assembles these into a complete analysis.

It builds directly on [Applications of Derivatives and Extrema](02 Applications and Extrema.md), where extrema and higher derivatives were introduced.

## Convexity and Concavity

A region of the graph of $f$ is _convex_ if, for every pair of points $x < y$ in it, the curve between $(x \mid f(x))$ and $(y \mid f(y))$ lies _below_ the secant through those points; it is _concave_ if the curve lies _above_ the secant. Reflecting the graph in the $x$-axis (replacing $f$ by $-f$) turns a concave region into a convex one and vice versa.

For twice-differentiable functions these geometric notions are captured by the sign of the _second derivative_.

**Convexity and the sign of $f''$.** The graph of a twice-differentiable function $f$ is convex exactly where $f''(x) \ge 0$, and concave exactly where $f''(x) \le 0$.

The reason is that the convex regions are precisely where the first derivative $f'$ is monotonically increasing, i.e. where $(f')' = f'' \ge 0$. For example $f(x) = \tfrac{1}{3}x^3 - x^2 + \tfrac{2}{3}$ has $f''(x) = 2x - 2$, so its graph is concave for $x \le 1$ and convex for $x \ge 1$.

## Inflection Points

An [inflection point](https://mathworld.wolfram.com/InflectionPoint.html) is a location $x_0$ where the graph changes between convex and concave. Equivalently:

**Inflection points.** A point $x_0$ is an inflection point of $f$ if $f'$ has a local extremum at $x_0$. The point $(x_0 \mid f(x_0))$ is then the _turning point_ of the graph.

Because inflection points of $f$ are local extrema of $f'$, the extremum criteria from the previous page apply to $f'$:

**Criteria for inflection points.**

- _Necessary:_ if a twice-differentiable $f$ has an inflection point at $x_0$, then $f''(x_0) = 0$.
- _Sufficient:_ if $f$ is three times differentiable with $f''(x_0) = 0$ and $f'''(x_0) \neq 0$, then $x_0$ is an inflection point.

For $f(x) = \tfrac{1}{3}x^3 - x^2 + \tfrac{2}{3}$ we have $f''(x) = 2x - 2$, so $f''(1) = 0$, and $f'''(x) = 2 \neq 0$; hence $x_0 = 1$ is an inflection point, where the graph passes from concave to convex.

An inflection point at which the first derivative _also_ vanishes ($f'(x_0) = 0$) is called a _saddle point_. The standard example is $f(x) = \tfrac{1}{3}x^3$ at $x_0 = 0$, where $f'(0) = f''(0) = 0$ but $f'''(0) = 2 \neq 0$.

## Additional Sources of Information

Beyond derivatives, several other features help pin down the shape of a graph.

### Zeros

The [zeros](https://mathworld.wolfram.com/Root.html) of $f$ are the locations $x_0$ with $f(x_0) = 0$. They are found with the equation-solving methods of algebra: factoring out common terms, splitting off known linear factors, and applying the quadratic formula. For example $g(x) = x^2 - 2x = x(x - 2)$ has zeros $x_0 = 0$ and $x_1 = 2$.

### Symmetry

- The graph is _axisymmetric_ about the vertical line $x = a$ if $f(a + x) = f(a - x)$ for all $x$. For example $f(x) = x^2$ is symmetric about the $y$-axis, since $f(-x) = f(x)$.
- The graph is _point-symmetric_ about a point $(a \mid b)$ if $f(a + x) = -f(a - x) + 2b$ for all $x$. For example $f(x) = \tfrac{1}{3}x^3$ and $f(x) = \dfrac{x}{x^2 + 1}$ are point-symmetric about the origin, since $f(-x) = -f(x)$.

### Behaviour for Large $x$

Investigating $\lim_{x \to \infty} f(x)$ reveals the long-range behaviour. If the limit is a real number $S$, the constant function $a_f(x) = S$ is a _horizontal asymptote_; otherwise there is none. For a rational function, factor out the highest power in numerator and denominator, then compare degrees:

- If the numerator has smaller degree, e.g. $\dfrac{x}{x^2 + 1} \to 0$, the asymptote is the $x$-axis.
- If the degrees are equal, e.g. $\dfrac{x^2}{x^2 + 1} \to 1$, the asymptote is $y = 1$.
- If the numerator has larger degree, e.g. $\dfrac{x^3}{x^2 + 1} \to \infty$, there is no horizontal asymptote.

## A Complete Curve Discussion

A full curve sketch collects: domain, zeros, symmetry, monotonicity regions, local and global extrema, convexity and inflection points, and behaviour for large $x$. Two representative examples from Walz illustrate the process.

- **A family of cubics.** For $f_t(x) = \tfrac{1}{t^2}x^3 - x$ with parameter $t > 0$, factoring gives zeros $x = 0, \pm t$; the graph is point-symmetric about the origin; the extrema are $x_{3,4} = \pm\tfrac{\sqrt{3}}{3}\,t$ (a minimum and a maximum, by the second-derivative test); and the single inflection point is $x_0 = 0$. As $t$ varies, the extreme points trace the line $g(x) = -\tfrac{2}{3}x$.
- **An optimisation problem.** To minimise the surface area of a cylindrical can of fixed volume $V = 1$, express the area as $O(r) = 2\bigl(\pi r^2 + \tfrac{1}{r}\bigr)$ for $r > 0$. Then $O'(r) = 0$ gives $r_0 = \sqrt[3]{1/(2\pi)} \approx 0.54$, and $O''(r_0) = 12\pi > 0$ confirms a minimum. Checking $O(r) \to \infty$ as $r \to 0^+$ and $r \to \infty$ shows this local minimum is the unique global minimum.

## Where This Leads

Differential calculus answers "how steep?" and "where largest?". The companion topic, integral calculus, answers "how much area?". The page [The Definite Integral](../Integral_Calculus/01 Definite Integral.md) begins that development, which the [Main Theorem](../Integral_Calculus/02 Antiderivatives and Main Theorem.md) will connect back to differentiation.
