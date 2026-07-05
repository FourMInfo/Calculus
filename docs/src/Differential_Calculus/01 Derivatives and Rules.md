# Derivatives and Derivative Rules

The [derivative](https://mathworld.wolfram.com/Derivative.html) is the central tool of differential calculus. It measures how steeply the graph of a function rises or falls — the _slope_ of the function — at each point of its domain. This page follows Walz, _Foundations of Mathematics_, Section 6.1: it builds the derivative from the intuitive notion of slope, gives its precise definition as a limit of difference quotients, and then develops the rules that let us differentiate large classes of functions without returning to that limit each time.

## The Slope of a Function

Imagine a hike through mountainous terrain, modelled as a function $f : \lbrack a, b \rbrack \to \mathbb{R}$ that assigns to each location $x$ a height $f(x)$. The steepness we must overcome depends on _where_ we are: the slope is generally not constant but varies with $x$. These varying slope values are themselves described by a new function, the _first derivative_ of $f$, written $f'$ (read "f dash").

Before giving the general definition, we compute the derivatives of a few simple functions directly.

### Constant Functions

A constant function $f(x) = c$ has a horizontal graph, so its slope is $0$ everywhere.

**First derivative of a constant function.** For $f(x) = c$ the first derivative vanishes for all $x$: $$f'(x) = 0.$$

### Linear Functions

For a linear function $f(x) = cx + d$ the graph is a straight line, whose slope is constant. Moving a small step $h \neq 0$ from $x$ to $x + h$ changes the value by $f(x+h) - f(x) = c\,h$, so the ratio of the change in value to the change in position is $$\frac{f(x+h) - f(x)}{(x+h) - x} = \frac{c\,h}{h} = c.$$

**First derivative of a linear function.** For $f(x) = cx + d$ the first derivative is the constant $c$: $$f'(x) = c.$$

In particular the _identity_ $f(x) = x$ (with $c = 1$, $d = 0$) has $f'(x) = 1$.

### The Quadratic Power Function

For $f(x) = x^2$ the slope is _not_ constant. Using the binomial formula, the ratio of the change in value to the change in position between $x$ and $x + h$ is $$\frac{f(x+h) - f(x)}{(x+h) - x} = \frac{(x+h)^2 - x^2}{h} = \frac{2hx + h^2}{h} = 2x + h.$$

This ratio still depends on $h$: it is the slope of the [secant line](https://mathworld.wolfram.com/SecantLine.html) through the two points $(x \mid x^2)$ and $(x+h \mid (x+h)^2)$. To obtain the _actual_ slope at $x$ we let $h$ shrink towards $0$ (written $h \to 0$), which sends the secant into the [tangent line](https://mathworld.wolfram.com/TangentLine.html). Taking this [limit](https://mathworld.wolfram.com/Limit.html) gives $$\lim_{h \to 0} (2x + h) = 2x.$$

**First derivative of the quadratic power function.** For $f(x) = x^2$: $$f'(x) = 2x.$$

### The General Power Function

The same pattern holds for every power $p_i(x) = x^i$ with $i \in \mathbb{N}$: bring the exponent down as a factor and reduce it by one.

**First derivative of the power function.** For $p_i(x) = x^i$: $$p_i'(x) = i\,x^{i-1}.$$

For example $(x^{128})' = 128\,x^{127}$ and $(x^7)' = 7 x^6$. As we will see below, this "rough rule" also extends to negative and fractional exponents.

## The Derivative as a Limit

We now make the procedure above precise for a general function $f$. Fix a point $x$ and a small $h \neq 0$ such that both $x$ and $x + h$ lie in the domain of $f$.

- The [secant line](https://mathworld.wolfram.com/SecantLine.html) of $f$ through $x$ and $x + h$ is the straight line through $(x \mid f(x))$ and $(x+h \mid f(x+h))$.
- Its slope is the _difference quotient_ $$\frac{f(x+h) - f(x)}{h}.$$

The difference quotient is only an _approximation_ to the actual slope at $x$. Passing to the limit $h \to 0$ gives the exact value.

**Differential quotient and first derivative.** If the limit of the difference quotients $$f'(x) = \lim_{h \to 0} \frac{f(x+h) - f(x)}{h}$$ exists, then $f'(x)$ is the value of the slope of $f$ at $x$, called the _first derivative_ of $f$ at $x$. In that case $f$ is said to be _differentiable_ at $x$.

**Tangent of $f$ at $x$.** The linear function through $(x \mid f(x))$ with slope $f'(x)$ is the [tangent line](https://mathworld.wolfram.com/TangentLine.html) of $f$ at $x$: $$t(\bar{x}) = f'(x)\,\bar{x} - f'(x)\,x + f(x).$$

If $f$ is differentiable at _every_ point of its domain, the assignment $x \mapsto f'(x)$ defines a new function, the _derivative function_ (or simply the _derivative_) of $f$.

## Derivatives of Standard Functions

The limit procedure yields the following derivatives of the standard functions. Each can be derived from the definition using the appropriate limit laws.

- The [exponential function](https://mathworld.wolfram.com/ExponentialFunction.html) is its own derivative: for $\exp(x) = e^x$, $$\exp'(x) = e^x.$$ The key step uses $\lim_{h \to 0} \dfrac{e^h - 1}{h} = 1$.
- The sine and cosine functions satisfy $$\sin'(x) = \cos(x), \qquad \cos'(x) = -\sin(x).$$
- The root function $f(x) = \sqrt{x}$ on an interval $\lbrack a, b \rbrack$ with $a > 0$ has $$f'(x) = \frac{1}{2\sqrt{x}}.$$ Equivalently $(x^{1/2})' = \tfrac{1}{2} x^{-1/2}$, so the power rule extends to fractional exponents.

## When Differentiation Fails

Not every function is differentiable. The limit of the difference quotients can fail to exist in two characteristic ways.

- The root function $f(x) = \sqrt{x}$ is _not_ differentiable at $x = 0$: as $x \to 0^+$ the slope grows beyond every bound, $\lim_{h \to 0^+} \tfrac{1}{\sqrt{h}} = \infty$. It is differentiable at every $x > 0$.
- The [absolute value](https://mathworld.wolfram.com/AbsoluteValue.html) function $f(x) = \lvert x \rvert$ is not differentiable at $x = 0$: approaching from the right gives slope $+1$, from the left gives $-1$. With two conflicting candidates the limit cannot be uniquely determined, and the graph shows a "kink".

Differentiable functions, by contrast, have _smooth_ graphs without kinks or vertical tangents.

## Derivative Rules

Returning to difference quotients for every function is tedious. The following rules let us differentiate combinations of known functions directly.

### Factor Rule

For a differentiable $f$ and a real constant $\lambda$, the product $\lambda \cdot f$ is differentiable and $$(\lambda f)'(x) = \lambda\,f'(x).$$

For example $(4\sqrt{x})' = 4 \cdot \tfrac{1}{2\sqrt{x}} = \tfrac{2}{\sqrt{x}}$.

### Sum and Difference Rules

For differentiable $f$ and $g$, the sum $f + g$ is differentiable and $$(f + g)'(x) = f'(x) + g'(x).$$

Writing $f - g = f + (-1)\cdot g$ and combining with the factor rule gives the difference rule $$(f - g)'(x) = f'(x) - g'(x).$$

**Derivative of polynomial functions.** Applying the factor and sum rules to a [polynomial](https://mathworld.wolfram.com/Polynomial.html) $p(x) = a_n x^n + \cdots + a_1 x + a_0$ gives the polynomial of degree $n - 1$: $$p'(x) = n\,a_n x^{n-1} + \cdots + i\,a_i x^{i-1} + \cdots + a_1.$$

For example $p(x) = 3x^5 - \sqrt{2}\,x^3 + \tfrac{8}{7} x^2 - 3$ has $p'(x) = 15 x^4 - 3\sqrt{2}\,x^2 + \tfrac{16}{7} x$.

### Product Rule

The derivative of a product is _not_ the product of the derivatives. Instead:

**[Product rule](https://mathworld.wolfram.com/ProductRule.html).** For differentiable $f$ and $g$, the product $f \cdot g$ is differentiable and $$(f \cdot g)'(x) = f'(x)\,g(x) + g'(x)\,f(x).$$

For example, with $f(x) = g(x) = \sin(x)$ we get $\bigl(\sin^2(x)\bigr)' = 2\cos(x)\sin(x)$.

### Chain Rule

To differentiate a composition $f \circ g$ (first apply $g$, then $f$):

**[Chain rule](https://mathworld.wolfram.com/ChainRule.html).** For differentiable $f$ and $g$, the composition $f \circ g$ is differentiable and $$(f \circ g)'(x) = g'(x)\,f'\bigl(g(x)\bigr).$$

For example, with $g(x) = 3x^2 + 1$ and $f(\bar{x}) = \bar{x}^{71}$: $$\bigl((3x^2+1)^{71}\bigr)' = 6x \cdot 71\,(3x^2+1)^{70} = 426x\,(3x^2+1)^{70}.$$ Likewise $\bigl(e^{\sin(x)}\bigr)' = \cos(x)\,e^{\sin(x)}$.

Applying the product rule to $x \cdot x^{-1} = 1$ and solving gives the derivative of $x^{-1}$: $$\bigl(x^{-1}\bigr)' = -x^{-2} = -\frac{1}{x^2},$$ confirming that the power rule holds for negative exponents as well.

### Quotient Rule

Combining the product and chain rules yields the rule for quotients, valid wherever the denominator does not vanish.

**[Quotient rule](https://mathworld.wolfram.com/QuotientRule.html).** For differentiable $f$ and $g$ with $g(x) \neq 0$: $$\left(\frac{f}{g}\right)'(x) = \frac{f'(x)\,g(x) - g'(x)\,f(x)}{\bigl(g(x)\bigr)^2}.$$

A classic application is the tangent function $\tan(x) = \dfrac{\sin(x)}{\cos(x)}$ for $x \in \left(-\tfrac{\pi}{2}, \tfrac{\pi}{2}\right)$: $$\tan'(x) = \frac{\cos^2(x) + \sin^2(x)}{\cos^2(x)} = 1 + \tan^2(x).$$

## Where This Leads

With these rules we can differentiate essentially every function built from powers, roots, exponentials, and trigonometric functions. The next page, [Applications of Derivatives and Extrema](02 Applications and Extrema.md), uses the first derivative to locate the largest and smallest values of a function and to determine where it rises and falls.
