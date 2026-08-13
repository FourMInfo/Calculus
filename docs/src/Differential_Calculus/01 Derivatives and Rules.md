# Derivatives and Derivative Rules

## Introduction

The [derivative](https://mathworld.wolfram.com/Derivative.html) is the central tool of differential calculus. Following Walz, _Foundations of Mathematics_, Section 6.1: this section builds the derivative from the intuitive notion of _slope_, gives its precise definition as a limit of difference quotients, and then develops the rules that let us differentiate large classes of functions without returning to that limit each time.

## The Slope of a Function

_Slope_ is a core concept in working with functions, so it pays to spend a bit of time trying to understand it. Slope is the graphical stand in for the even more fundamental concept of _rate of change_. What makes differential calculus and its tool, the derivative, so useful is precisely that it allows us to calculate the rate of change of functions (and even the rate of the rate of change and so on!). But let's start with the simpler idea of slope.

On a two dimensional graph there are essentially two directions: horizontal and vertical. If we were physically moving in space we could conceptualize the graph as a visual representation of moving forward (or backward) along the horizontal or $x$-axis, and up (or down) along the vertical $y$-axis. You notice I put _backward_ and _down_ in parentheses because which direction we choose to call the positive one does not matter yet — we will see what a _negative_ slope means shortly. Wherever I use up I can use down, and the same for forward and backwards. So let's stick to forward and up in our preliminary discussion.

If we imagine we are moving in space, the way we draw a graph of this motion is as follows: For every point $x$ we touch as we move forward (_run_), we draw or map a point at the corresponding height $y$ we are moving up to (_rise_). The graph is one way to represent that motion; a _function_ is another—algebraic and far more convenient. I plug in the current $x$ (horizontal location) into the function and it spits out the $y$—my current height. Neither one is more fundamental than the other, and that is precisely the great insight behind [analytic geometry](https://fourm.info/linear_algebra/dev/Basics/04%20Analytic%20Geometry/), which should already be familiar to us: Descartes—and, independently, Fermat—saw that geometric curves and algebraic equations are two languages for the same objects. The modern notion of a _function_ arrived later, with Leibniz and Euler, but it fits straight into their frame. Graph and function are siblings, each describing our motion in its own dialect.

But now I want the answer to a very fundamental question: how far do we move up for each single step we take forward? _That_ ratio—up (rise) per forward (run)—is called the _slope_. Note that it is a ratio and not a distance: if I take a step twice as long I rise twice as far, so it is the _comparison_ of the two, and not either one on its own, that tells us anything about the graph. Essentially then, the slope is a graphical representation of rate of change: how much the height $y$ of the graph changes per unit I move horizontally along $x$.

We can see this directly. Below is a single straight line along which we take three steps of quite different sizes. The rises differ, the runs differ — but every ratio comes out to the same number, and _that_ number is the slope of the line.

```@setup slope
using Calculus

f(x) = 2x + 1
xs = range(0, 8, length = 200)

plt = plot(xs, f.(xs);
    line = (:black, 2), legend = false,
    xlabel = "x", ylabel = "y",
    xlims = (0, 8.6), ylims = (0, 18),
    title = "Same line, three different steps, one slope")

num(v) = isinteger(v) ? string(Int(v)) : string(v)   # 2.0 -> "2", 1.5 -> "1.5"

for (x0, h) in ((1.0, 1.0), (3.0, 2.0), (6.0, 1.5))
    y0, y1 = f(x0), f(x0 + h)
    plot!(plt, [x0, x0 + h], [y0, y0]; line = (:gray40, 1.5, :dash))       # the run
    plot!(plt, [x0 + h, x0 + h], [y0, y1]; line = (:gray40, 1.5, :dash))   # the rise
    scatter!(plt, [x0, x0 + h], [y0, y1]; color = :black, markersize = 4)
    annotate!(plt, x0 + h / 2, y0 - 1.3,
        text("rise $(num(2h)) ÷ run $(num(h)) = 2", 8, :center))
end
```

```@example slope
plt # hide
```

The _first derivative_ is a function derived from the base function that allows us to compute the slope of the function, in this context the graph's rate of change, for any point $x$ on the graph. The _second derivative_ is the rate of the rate of change in the graph's height. And so we can continue on. Of course, as I mentioned earlier slope is the graphical representation of rate of change, so we can just as well talk about rates of change without using a graph. The rate of change of a car's _position_ is its _speed_; the rate of change of its _speed_ is its _acceleration_ — there is a first derivative and a second derivative, in units we all already know. Or think of the news reporting that prices are still rising, but more slowly: that one sentence makes a claim about a first derivative (prices rising) and a second derivative (the rising easing off) at the same time. We could equally talk about the growth of a plant, or the interest accumulating in my bank account, or any rate of change for that matter. The graph is just the representation of these! So if you consider the concept of rate of change more broadly, it should be clear why differential calculus is so useful!

While we can use functions and descriptive language to talk about rate of change and rate of the rate of change, graphs are also great at helping us visualize these and making this concept more intuitive. For example, the curve below keeps rising—its slope stays positive everywhere—yet the tangent lines drawn along it grow steadily shallower, so the curve rises by less and less. The curve always rising indicates the rate of change is always positive. The gradual decline indicates that the rate of this change is declining. This illustrates what we mean when we say "prices are rising, but easing off."

```@setup slope2
using Calculus

g(x) = 5 * (1 - exp(-x / 3))          # rises toward 5, but ever more slowly
gp(x) = (5 / 3) * exp(-x / 3)         # its slope: positive, but shrinking
xs = range(0, 9, length = 200)

plt = plot(xs, g.(xs);
    line = (:black, 2), legend = false,
    xlabel = "x", ylabel = "y",
    xlims = (0, 9.4), ylims = (0, 5.3),
    title = "Still rising, but ever more slowly")

for x0 in (1.5, 3.5, 6.5)
    y0, m = g(x0), gp(x0)
    hw = 1.2                          # half-width of the drawn tangent segment
    plot!(plt, [x0 - hw, x0 + hw], [y0 - hw * m, y0 + hw * m]; line = (:royalblue, 2))
    scatter!(plt, [x0], [y0]; color = :black, markersize = 4)
    annotate!(plt, x0, y0 + 0.45,
        text("slope ≈ $(round(m, digits = 2))", 8, :center, :royalblue))
end
```

```@example slope2
plt # hide
```

From now on, everything we talk about in differential calculus is exactly how we compute the derivatives for any given function. Working with graphs is just the way to concretize these calculations and concepts and make them easier to understand. So we will continue to talk about how to compute the slope.

## Computing Derivatives

Before giving the general definition, we compute the derivatives of a few simple functions directly.

### Constant Functions

A constant function $f(x) = c$ has a horizontal graph, so its slope is $0$ everywhere. To confirm this, note the rise is always 0, so the ratio is $$\frac{f(x+h) - f(x)}{(x+h) - x} = \frac{c - c}{h} = \frac{0}{h} = 0.$$

**First derivative of a constant function.** For $f(x) = c$ the first derivative vanishes for all $x$: $$f'(x) = 0.$$

### Linear Functions

For a linear function $f(x) = cx + d$ the graph is a straight line, whose slope is constant. Moving a small step $h \neq 0$ from $x$ to $x + h$ changes the value by $f(x+h) - f(x) = c\,h$, so the ratio of the change in value to the change in position is $$\frac{f(x+h) - f(x)}{(x+h) - x} = \frac{c\,h}{h} = c.$$

**First derivative of a linear function.** For $f(x) = cx + d$ the first derivative is the constant $c$: $$f'(x) = c.$$

In particular the _identity_ $f(x) = x$ (with $c = 1$, $d = 0$) has $f'(x) = 1$.

### The Quadratic Power Function

The previous two function types are exceptional since their slope is constant. Let's look at how most functions work, where the slope changes for each location of $x$.

We can see this with the quadratic function $f(x) = x^2$. Its graph is a parabola, and a single glance shows the slope is _not_ constant: near the bottom the curve is almost flat, while further out it climbs ever more steeply. Drawing the tangent line at a few points makes this concrete — shallow where the parabola is nearly flat, steep where it rises sharply. The slope plainly depends on _where_ we are, that is, on the value of $x$.

```@setup qslope
using Calculus

q(x) = x^2
xs = range(-1, 2.7, length = 220)

plt = plot(xs, q.(xs);
    line = (:black, 2), legend = false,
    xlabel = "x", ylabel = "y",
    xlims = (-1.1, 3.1), ylims = (-0.6, 8.6),
    title = "The slope of x² grows with x")

for x0 in (0.5, 1.5, 2.5)
    m = 2x0                                  # the slope of x^2 at x0 is 2x0
    hw = 0.4                                 # half-width of the drawn tangent
    plot!(plt, [x0 - hw, x0 + hw], [q(x0) - m*hw, q(x0) + m*hw]; line = (:royalblue, 2))
    scatter!(plt, [x0], [q(x0)]; color = :black, markersize = 4)
    annotate!(plt, x0 - 0.06, q(x0) + 0.25, text("slope = $(Int(m))", 8, :right, :royalblue))
end
```

```@example qslope
plt # hide
```

How do we calculate the slope of the parabola at point $x$? Let's take an approximation and imagine two points, $x$ and $x+h$, and using the function $f$ calculate the values on the parabola. If we draw a line between those two calculated points on the parabola, we can use the binomial formula to calculate the slope of the line: the ratio of the change in value to the change in position between $x$ and $x + h$ is $$\frac{f(x+h) - f(x)}{(x+h) - x} = \frac{(x+h)^2 - x^2}{h} = \frac{2hx + h^2}{h} = 2x + h.$$

Of course, the slope of this line is just an approximation. But we have learned the slope is not constant but completely dependent on $x$. So if $x = 1$ the slope will be $2x + h = 2 \times 1 + h = 2 + h$. If $x = 2$ the slope will be $2x + h = 2 \times 2 + h = 4 + h$. And so on. In other words the slope is different for every value of $x$.

The remaining question is how do we get rid of the pesky $h$ and get the _actual_ slope at $x$? Intuitively we can imagine that the smaller $h$ is, the closer the line we create is to the actual slope at point $x$. If we let $h$ get closer and closer to $0$ without ever becoming $0$ we say that $h$ _tends towards_ $0$ (written $h \to 0$). For example, if in the formula $2x + h$ we set $x = 1$ and we set $h$ to consecutively take the values $1/10, 1/100, 1/1000, \dots$ we in turn get the resulting approximations for the slope: $2.1, 2.01, 2.001, \dots$

Following this thought to the end, we say the term $2 + h$ _converges_ to the limit $2$ as $h \to 0$. The mathematical notation for this is:

$$\lim_{h \to 0} (2 + h) = 2,$$

which means the term $2 + h$ is arbitrarily close to the _limit_ (from the Latin _limes_) $2$ whenever $h$ is close enough to $0$. So the actual slope of $f(x) = x^2$ at $x = 1$ is exactly $2$.

The same reasoning works at _any_ point $x$, not just $x = 1$ — we only used $1$ to put numbers on the page. Taking the limit of the general approximation $2x + h$ gives

$$\lim_{h \to 0} (2x + h) = 2x,$$

so the slope of $f(x) = x^2$ at any point is $2x$ — a slope that, just as the graph showed, grows with $x$.

Geometrically, this limiting slope belongs to the straight line that just _touches_ the parabola at $x$ — its _tangent_ line (from the Latin _tangere_, "to touch"). As $h \to 0$, the line drawn through our two points swings around and settles onto that tangent:

```@setup qlimit
using Calculus

q(x) = x^2
num(v) = isinteger(v) ? string(Int(v)) : string(v)
xs = range(0.35, 2.35, length = 220)

plt = plot(xs, q.(xs);
    line = (:black, 2), legend = false,
    xlabel = "x", ylabel = "y",
    xlims = (0.25, 3.35), ylims = (-0.4, 5.9),
    title = "As h → 0 the line settles onto the tangent")

x0, y0 = 1.0, 1.0

# connecting lines through (x0,y0) and (x0+h, f(x0+h)); slopes 3, 2.5, 2.25 close in on 2
for h in (1.0, 0.5, 0.25)
    x1, y1 = x0 + h, q(x0 + h)
    plot!(plt, [x0, x1], [y0, y1]; line = (:gray45, 1.5, :dash))
    scatter!(plt, [x1], [y1]; color = :gray25, markersize = 3.5)
    annotate!(plt, x1 - 0.1, y1 + 0.05, text("slope = $(num(2 + h))", 7, :right, :gray25))
end

tangent(x) = y0 + 2 * (x - x0)                # the limiting line: slope 2 at x = 1
plot!(plt, [0.4, 2.2], [tangent(0.4), tangent(2.2)]; line = (:royalblue, 2.5))
annotate!(plt, 2.25, tangent(2.2) + 0.05, text("tangent, slope = 2", 8, :left, :royalblue))

scatter!(plt, [x0], [y0]; color = :black, markersize = 4.5)
annotate!(plt, x0, y0 - 0.33, text("x = 1", 8, :center, :black))
```

```@example qlimit
plt # hide
```

Using this idea we can define the first derivative for this specific function as follows:
**First derivative of the quadratic power function.** For $f(x) = x^2$: $$f'(x) = 2x.$$

### The General Power Function

Let's now define the derivative for any power function. The same pattern holds for every power $p_i(x) = x^i$ with $i \in \mathbb{N}$: bring the exponent down as a factor and reduce it by one.

**First derivative of the power function.** For $p_i(x) = x^i$: $$p_i'(x) = i\,x^{i-1}.$$

For example $(x^{3})' = 3\,x^{2}$ and $(x^7)' = 7 x^6$. As we will see below, this "rough rule" also extends to negative and fractional exponents.

## The Derivative as a Limit

The idea we used above of approximating the slope with a line through two nearby points, then letting those points merge at the limit, involved quite a bit of hand waving. Ee will now make this idea a bit more precise, although we still will not precisely define the idea of limit. As an aside, if you look at the history of the Calculus, this is exactly how it developed. Both Newton and Leibniz, the founders of modern Calculus, had the intuitive insights and developed the procedures for calculating the derivatives of different types of functions (as we will do below). Making their ideas more precise is what many great mathemeticians did in the eighteenth and Noneteenth centuries. But that is beyond the scope of this basic introduction.

So let's start by more precisely defining what we mean by a line between two nearby points and the slope of that line in relation to the function $f$. Start by choosing $x$ and a small $h \neq 0$ such that both $x$ and $x + h$ lie in the domain of $f$ (and so are points on the $x$-axis).

- The [secant line](https://mathworld.wolfram.com/SecantLine.html) of $f$ through $x$ and $x + h$ is defined as the straight line through the two points $(x, f(x))$ and $(x+h, f(x+h))$.
- Its slope is the _difference quotient_ which is the ratio of the difference between the two $y$-axis co-ordinates per the difference of the $x$-axis co-ordinates (which difference is, of course, just $h$). This gives us: $$\frac{f(x+h) - f(x)}{h}.$$

The difference quotient is only an _approximation_ to the actual slope at $x$. Passing to the limit $h \to 0$ gives the exact value:

**First derivative.** If this limit of the difference quotients $$f'(x) = \lim_{h \to 0} \frac{f(x+h) - f(x)}{h}$$ exists, then $f'(x)$ is the value of the slope of $f$ at $x$, called the _first derivative_ of $f$ at $x$. In that case $f$ is said to be _differentiable_ at $x$.

**Tangent of $f$ at $x$.** The linear function $t$ through $(x, f(x))$ with slope $f'(x)$ is the [tangent line](https://mathworld.wolfram.com/TangentLine.html) of $f$ at $x$.

We can derive the function $t$ as follows. The tangent is just a straight line, with two key facts that pin it down:

1. its slope is $f'(x)$, the derivative at the _point of tangency_, and
2. it passes through the point $(x, f(x))$, i.e. it touches the curve there.

Using the point-slope form of a line — closely related to the [slope-intercept form](https://fourm.info/math_foundations/dev/Algebra/03%20Solving%20Equations/#Standard-Forms) — $y = m \cdot (\bar{x} - x_0) + y_0$, we plug in $m = f'(x)$ and $(x_0, y_0) = (x, f(x))$ to derive $t$:

$$t(\bar{x}) = f'(x)\,(\bar{x} - x) + f(x) = f'(x)\,\bar{x} - f'(x)\,x + f(x).$$

Here $x$ is the _fixed_ point of tangency (a specific number), while $\bar{x}$ is the running input of the tangent line; the bar keeps these two roles of "$x$" apart.

**Example.** Take $f(x) = x^2$, so $f'(x) = 2x$. Substituting into the formula and simplifying:

$$t(\bar{x}) = 2x \cdot \bar{x} - 2x \cdot x + x^2 = 2x\,\bar{x} - 2x^2 + x^2 = 2x\,\bar{x} - x^2.$$

This is still general — $x$ is any point of tangency. To read off a concrete tangent, fix a point, say $x = 1$, where $f(1) = 1$ and $f'(1) = 2$:

$$t(\bar{x}) = 2 \cdot 1 \cdot \bar{x} - 1^2 = 2\bar{x} - 1,$$

the straight line of slope $2$ through $(1, 1)$.

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
