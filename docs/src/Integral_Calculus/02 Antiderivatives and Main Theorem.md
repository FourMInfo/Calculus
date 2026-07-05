# Antiderivatives and the Main Theorem

The [fundamental theorem of calculus](https://mathworld.wolfram.com/FundamentalTheoremsofCalculus.html) reveals that integration and differentiation are inverse operations. This page follows Walz, _Foundations of Mathematics_, the middle of Section 6.3: it introduces the integral function, shows that differentiating it recovers the integrand, and uses this to turn the evaluation of definite integrals into the search for antiderivatives.

It continues directly from [The Definite Integral](01 Definite Integral.md), where integrability and the basic properties were established.

## The Integral Function

Fixing the lower bound $a$ and letting the upper bound vary defines the _integral function_ $$F_a(t) = \int_a^t f(x)\,dx.$$

For the power function $f(x) = x^i$ this is $F_a(t) = \dfrac{t^{i+1}}{i+1} - \dfrac{a^{i+1}}{i+1}$, and differentiating with respect to $t$ gives back the integrand: $$F_a'(t) = t^i = f(t).$$

This is not a coincidence. It holds for every continuous function.

## Differentiability of the Integral Function

For a general continuous $f$, the difference quotient of $F_a$ simplifies, using the interval properties of the integral, to $$\frac{F_a(t + h) - F_a(t)}{h} = \frac{1}{h}\int_t^{t+h} f(x)\,dx.$$

The _mean value theorem of integral calculus_ states that for continuous $f$ there is a point $\xi \in \lbrack t, t+h \rbrack$ with $\int_t^{t+h} f(x)\,dx = f(\xi)\,h$. Hence the difference quotient equals $f(\xi)$, and as $h \to 0$ the point $\xi$ is squeezed towards $t$, giving $f(\xi) \to f(t)$.

**Differentiability of the integral function.** For any continuous function $f$ on $\lbrack a, b \rbrack$, the integral function $F_a(t) = \int_a^t f(x)\,dx$ is differentiable and $$F_a'(t) = f(t).$$

So _differentiating cancels integrating_; conversely $\int_a^t F_a'(x)\,dx = F_a(t)$, so _integrating cancels differentiating_. This is the sense in which the two operations are inverse.

## Antiderivatives (Primitives)

The integral function $F_a$ is defined only implicitly, as an integral. To evaluate integrals we look instead for an _explicit_ function whose derivative is $f$.

**Antiderivative.** A differentiable function $F$ with $F' = f$ is called an _antiderivative_ (or _primitive_) of $f$.

Every derivative rule read backwards supplies antiderivatives. For example:

- $F(x) = \dfrac{x^{i+1}}{i+1}$ is an antiderivative of $x^i$.
- $F(x) = e^x$ is an antiderivative of $e^x$; the natural logarithm $\ln(x)$ is an antiderivative of $\tfrac{1}{x}$ for $x > 0$.
- $F(x) = -\cos(x)$ is an antiderivative of $\sin(x)$.

Antiderivatives are not unique, but they are unique up to a constant:

**Antiderivatives differ only by a constant.** If $F$ and $G$ are both antiderivatives of $f$, then $F(x) = G(x) + c$ for some constant $c$, because $(F - G)' = f - f = 0$.

## The Main Theorem

Since the integral function $F_a$ is itself an antiderivative of $f$, any antiderivative $F$ differs from it only by a constant. Evaluating that constant at $t = a$ yields $F_a(t) = F(t) - F(a)$, and setting $t = b$ gives the central result.

**Main theorem of differential and integral calculus.** If $f$ is continuous on $\lbrack a, b \rbrack$ and $F$ is _any_ antiderivative of $f$, then $$\int_a^b f(x)\,dx = F(b) - F(a).$$

The evaluation is written with the bracket notation $$\bigl\lbrack F(x) \bigr\rbrack_a^b = F(b) - F(a).$$

The machinery for evaluating a definite integral is therefore:

1. Find _any_ antiderivative $F$ of $f$.
2. Compute $F(b)$ and $F(a)$ by substituting the bounds.
3. The difference $F(b) - F(a)$ is the definite integral.

## Worked Examples

- With $F(x) = \tfrac{1}{3}x^3$ an antiderivative of $x^2$: $$\int_1^{10} x^2\,dx = \frac{10^3}{3} - \frac{1^3}{3} = \frac{999}{3} = 333.$$ Using $G(x) = \tfrac{1}{3}x^3 + 15$ instead gives the same result — the additive constant cancels.
- Since $(e^x)' = e^x$: $$\int_1^{3} e^x\,dx = \bigl\lbrack e^x \bigr\rbrack_1^3 = e^3 - e = e(e^2 - 1).$$
- Since $(-\cos(x))' = \sin(x)$: $$\int_0^{\pi} \sin(x)\,dx = \bigl\lbrack -\cos(x) \bigr\rbrack_0^\pi = -\cos(\pi) + \cos(0) = 2.$$

## Where This Leads

The main theorem reduces integration to finding antiderivatives — but for many integrands no antiderivative is obvious. The next page, [Integration Techniques](03 Integration Techniques.md), develops partial integration and the substitution rule, which produce antiderivatives for many further functions.
