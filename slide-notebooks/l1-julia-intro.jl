#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
# # Lecture 1: Why solve PDEs on a GPU? & The tools to do it
#
# ## Why solve PDEs on a GPU?
# An intro by Ludovic about GPU computing:
# - why we do it
# - why it is cool
# - examples from his research


#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
# ## Tools for the job: introduction to Julia
#
# ### Aside 1: Jupyter Notebooks
#
# These slides are a [Jupyter notebook](https://jupyter.org/); a browser-based computational notebook.
#
# > You can follow the lecture along life at https://achtzack01.ethz.ch/, login with your nethz-name and an
# > arbitrary password (**but don't use your nethz password**).  You have to be within the ETHZ network or
# > use a VPN connection.
#
# Code cells are executed by putting the cursor into the cell and hitting `shift + enter`.  For more
# info see the [documentation](https://jupyter-notebook.readthedocs.io/en/stable/).

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
# ### What is your previous programming experience?
#
# 1. Julia
# 2. Matlab, Python, Octave, R, ...
# 3. C, Fortran, ...
# 4. Pascal, Java, C++, ...
# 5. Lisp, Haskell, ...
# 6. Assembler
# 7. Coq, Brainfuck, ...


#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
# ## The Julia programming language
#
# [Julia](https://julialang.org/) is a modern, interactive, and high performace programming language.  It's a general purpose
# language with a bend on technical computing.
#
# ![julia-logo](./figures/julia-logo-repl.png)
#
# - first released in 2012
# - reached version 1.0 in 2018
# - thriving community, for instance there are currently around 6300 packages registered

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
# ### What does Julia look like
#
# An example soling the Lorenz system of ODEs:

using OrdinaryDiffEq, Plots

function lorenz(x, p, t)
    σ = 10
    β = 8/3
    ρ = 28
    [σ*(x[2]-x[1]),
     x[1]*(ρ-x[3]),
     x[1]*x[2] - β*x[3]]
end

## integrate dx/dt = lorenz(t,x) numerically from t=0 to t=50 and starting point x₀
tspan = (0.0, 50.0)
x₀ = [2.0, 0.0, 0.0]
sol = solve(ODEProblem(lorenz, x₀, tspan), Tsit5())

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
# An its solution plotted
plot(sol, vars=(1,2,3)) # plot Lorenz attractor


#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
# ### Julia in brief
# Julia 1.0 released 2018
#
# Features:
# - general purpose language with a focus on technical computing
# - dynamic language
#   - interactive development
#   - garbage collection
# - good performance on par with C & Fortran
#   - just-ahead-of-time compiled via LLVM
#   - No need to vectorise: for loops are fast
# - multiple dispatch
# - user-defined types are as fast and compact as built-ins
# - Lisp-like macros and other metaprogramming facilities
# - designed for parallelism and distributed computation
# - good inter-op with other languages

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
# ### The two language problem*
#
# **One language to prototype   ---  one language for production**
# - example from Ludovic's past: prototype in Matlab, production in CUDA-C
#
# **One language for the users  ---  one language for under-the-hood**
# - Numpy (python --- C)
# - machine-learning: pytorch, tensorflow

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
# ![](./figures/ml.png)

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
# ### The two language problem
#
# Prototype/interface language:
# - easy to learn and use
# - interactive
# - productive
# - --> *but slow*
# - Examples: Python, Matlab, R, IDL...
#
# Production/fast language:
# - fast
# - --> *but* complicated/verbose/not-interactive/etc
# - Examples: C, C++, Fortran, Java...

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
# ###  Julia solves the two-language problem
#
# Julia is:
# - easy to learn and use
# - interactive
# - productive
#
# and also:
# - fast

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
# ![](./figures/flux-vs-tensorflow.png)


#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
# ###  Let's get our hands dirty!



#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
# ### Key feature: multiple dispatch
#
# - Julia is not an object oriented language
#
# OO:
# - methods belong to objects
# - method is selected based on first argument (e.g. `self` in Python)
#
# Multiple dispatch:
# - methods are separate from objects
# - are selected based on all arguments
# - similar to overloading but method selection occurs at runtime
# > very natural for mathematical programming
#
# Juliacon 2019 presentation on the subject by Stefan Karpinski
# (co-creator of Julia):
#
# ["The Unreasonable Effectiveness of Multiple Dispatch"](https://www.youtube.com/watch?v=kc9HwsxE1OY)

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
# ### Multiple dispatch demo

struct Rock end
struct Paper end
struct Scissors end
### of course structs could have fields as well
## struct Rock
##     color
##     name::String
##     density::Float64
## end

## define multi-method
play(::Rock, ::Paper) = "Paper wins"
play(::Rock, ::Scissors) = "Rock wins"
play(::Scissors, ::Paper) = "Scissors wins"
play(a, b) = play(b, a) # commutative

play(Scissors(), Rock())

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
# ### Multiple dispatch demo
# Can easily be extended later
#
# with new type:
struct Pond end
play(::Rock, ::Pond) = "Pond wins"
play(::Paper, ::Pond) = "Paper wins"
play(::Scissors, ::Pond) = "Pond wins"

play(Scissors(), Pond())
#-

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
# with new function:
combine(::Rock, ::Paper) = "Paperweight"
combine(::Paper, ::Scissors) = "Two pieces of papers"
## ...

combine(Rock(), Paper())

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
# *Multiple dispatch makes Julia package very composable*
