# Integration Techniques

The [main theorem](02 Antiderivatives and Main Theorem.md) reduces evaluating a definite integral to finding an antiderivative — but for many integrands no antiderivative is immediately visible. This page follows Walz, _Foundations of Mathematics_, the final part of Section 6.3: it develops [integration by parts](https://mathworld.wolfram.com/IntegrationbyParts.html) and the substitution rule, obtained by reading the product and chain rules backwards, and closes with an application to the area of an ellipse.

## When No Antiderivative Is Obvious

For integrands such as $$x e^x, \quad \ln(x), \quad \sin^2(x), \quad 6x(3x^2+1)^{71}, \quad \frac{\ln(x)}{x},$$ the antiderivative is not apparent. Two rules extend our reach considerably. (It should be noted that some continuous integrands, such as $e^{-x^2}$, have _no_ antiderivative expressible in closed form by elementary functions.)

## Integration by Parts

Integrating the [product rule](https://mathworld.wolfram.com/ProductRule.html) $(f \cdot g)' = f'g + g'f$ and rearranging gives:

**[Integration by parts](https://mathworld.wolfram.com/IntegrationbyParts.html).** For functions $f$ and $g$ differentiable on $\lbrack a, b \rbrack$: $$\int_a^b f'(x)\,g(x)\,dx = \bigl\lbrack f(x)\,g(x) \bigr\rbrack_a^b - \int_a^b f(x)\,g'(x)\,dx.$$

The idea is to choose $f'$ and $g$ so that the remaining integral on the right is easier than the original.

- **A product with $e^x$.** For $h(x) = x e^x$, set $f(x) = e^x$ and $g(x) = x$. Then $$\int x e^x\,dx = x e^x - \int e^x\,dx = (x - 1)e^x,$$ so $\displaystyle\int_1^2 x e^x\,dx = e^2$.
- **The logarithm.** Writing $\ln(x) = 1 \cdot \ln(x)$ and integrating by parts gives the antiderivative $F(x) = x\ln(x) - x$, hence $$\int_1^7 \ln(x)\,dx = \bigl\lbrack x\ln(x) - x \bigr\rbrack_1^7 = 7\ln(7) - 6.$$
- **A trigonometric square.** For $\sin^2(x) = \sin(x)\sin(x)$, one integration by parts together with $\cos^2(x) = 1 - \sin^2(x)$ yields $$\int \sin^2(x)\,dx = \tfrac{1}{2}\bigl(-\cos(x)\sin(x) + x\bigr).$$

## The Substitution Rule

Integrating the [chain rule](https://mathworld.wolfram.com/ChainRule.html) $(F \circ g)'(x) = g'(x)\,f(g(x))$, where $F' = f$, gives the [substitution rule](https://mathworld.wolfram.com/ChangeofVariablesTheorem.html) — the one-dimensional change of variables.

**Substitution rule.** If $f$ is continuous and $g$ is differentiable on $\lbrack a, b \rbrack$: $$\int_a^b g'(x)\,f\bigl(g(x)\bigr)\,dx = \int_{g(a)}^{g(b)} f(\bar{x})\,d\bar{x}.$$

A complicated integrand of the form $g' \cdot (f \circ g)$ is replaced by the simpler integrand $f$, with the bounds adjusted accordingly.

- **A high power.** For $6x(3x^2+1)^{71}$, take $g(x) = 3x^2 + 1$ (so $g'(x) = 6x$) and $f(\bar{x}) = \bar{x}^{71}$. Then $$\int 6x(3x^2+1)^{71}\,dx = \frac{1}{72}(3x^2+1)^{72}.$$
- **A logarithm in the integrand.** For $\dfrac{\ln(x)}{x}$, take $g(x) = \ln(x)$ (so $g'(x) = \tfrac{1}{x}$) and $f(\bar{x}) = \bar{x}$. Then the antiderivative is $\tfrac{1}{2}\ln^2(x)$, so $$\int_1^2 \frac{\ln(x)}{x}\,dx = \frac{\ln^2(2)}{2}.$$

## Reading the Rule Backwards: the Second Substitution

The substitution rule can also be applied from right to left: to simplify an integrand one _introduces_ a substitution $x = g(t)$, multiplies by the derivative $g'(t)$, and adjusts the bounds. This is sometimes called the _second substitution rule_.

**Application — area of an ellipse.** For an ellipse with semi-axes $r$ and $b$, the area is $$F = \int_{-r}^{r} b\sqrt{1 - \frac{x^2}{r^2}}\,dx.$$ Substituting $x = r\sin(t)$ (so $dx = r\cos(t)\,dt$) and using $\cos(t) = \sqrt{1 - \sin^2(t)}$ together with $\int_0^{\pi/2}\sin^2(t)\,dt = \tfrac{\pi}{4}$ gives $$F = \pi r b.$$ For the circle $r = b$ this reduces to the familiar $\pi r^2$.

## Summary of Integral Calculus

Across these three pages the tools of integration form a coherent whole:

- [The Definite Integral](01 Definite Integral.md) defines the integral as a limit of Riemann sums and gives its basic properties.
- [Antiderivatives and the Main Theorem](02 Antiderivatives and Main Theorem.md) connects integration to differentiation, so integrals are evaluated via antiderivatives.
- Integration by parts and substitution, developed here, produce antiderivatives for a wide range of functions.

Together with the [differential calculus](../Differential_Calculus/01 Derivatives and Rules.md) pages, they complete the core of single-variable calculus as presented in Walz, Chapter 6.
