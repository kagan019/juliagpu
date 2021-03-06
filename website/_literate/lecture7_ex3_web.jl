md"""
## Exercise 3 - **Cauchy-Navier elastic waves**
"""

#md # 👉 See [Logistics](/logistics/#submission) for submission details.

md"""
The goal of this exercise is to:
- Familiarise with Cauch-Navier elasticity
- Step from acoustic waves to elastic waves
- Get a glimpse into solid mechanics

"""

md"""
### Getting started

In this exercises your task will be to terminate the 2D implementation of an elastic wave solver based on the [Cauchy-Navier elasticity as presented in lecture 7](#towards_stokes_flow_i_acoustic_to_elastic).

In class, we stopped at [**Task 2**](#task_2_-_adding_normal_stresses), adding normal stress components.

The remaining 2 tasks to achieve a full implementation of the 2D elastic wave solver are:
- adding shear stresses
- re-arranging the order of computation

Create a folder titles `elastic2D` within this week's lecture 7 GitHub parent folder. Copy in there the following codes developed in class (refer to the [course section](#towards_stokes_flow_i_acoustic_to_elastic) for directions regarding details implementing these 3 code versions):
- `acoustic_2D_elast0.jl`
- `acoustic_2D_elast1.jl`
- `acoustic_2D_elast2.jl` 

### Task 3 - adding shear stresses

Start by making a new duplicate of the latest `acoustic_2D_elast2.jl` script, renaming it `acoustic_2D_elast3.jl`. In this new script, add the shear stress $xy$ component:
```julia
τxy  .= τxy .+ ??
```

Note that we assume the strain(-rate) tensor to be symmetric, thus the following is to be assumed $τ_{xy} = τ_{yx}$. 

Make sure to correctly interpret [Einstein's notation](https://en.wikipedia.org/wiki/Einstein_notation) - normal $(τ_{xx}, τ_{yy})$ and shear $(τ_{xy})$ stresses are not defined in the same way.
"""

#nb # > 💡 hint: Transforming [Einstein's notation](https://en.wikipedia.org/wiki/Einstein_notation) into code: rate of change of normal stress $∂τ_{xx}/∂t$ is defined as $2~μ~(∂v_x/∂x -1/3∇v)$, i.e. two $2μ$ times the normal strain-rate. For the rate of change of the shear stress $∂τ_{xy}/∂t$, the shear strain-rate defines as $1/2~(∂v_x/∂y + ∂v_y/∂x)$. Make sure to implement it consistently.
#md # \note{Transforming [Einstein's notation](https://en.wikipedia.org/wiki/Einstein_notation) into code: rate of change of normal stress $∂τ_{xx}/∂t$ is defined as $2~μ~(∂v_x/∂x -1/3∇v)$, i.e. two $2μ$ times the normal strain-rate. For the rate of change of the shear stress $∂τ_{xy}/∂t$, the shear strain-rate defines as $1/2~(∂v_x/∂y + ∂v_y/∂x)$. Make sure to implement it consistently.}

md"""
![2D staggered grid](../assets/literate_figures/stagg_elast_ex7.png)

The shear stress $τ_{xy}$ derivative needs then to be included into the momentum equations, used to compute the rate of change of velocity in both $x$ and $y$ direction (similarly to the normal stress).
"""

#nb # > 💡 hint: Make sure to take the "cross-derivative" of the shear stress when adding them to the momentum equation; use $∂τ_{xy}/∂y$ when computing `dVxdt` and $∂τ_{xy}/∂x$ for computing `dVydt`.
#md # \note{Make sure to take the "cross-derivative" of the shear stress when adding them to the momentum equation; use $∂τ_{xy}/∂y$ when computing `dVxdt` and $∂τ_{xy}/∂x$ for computing `dVydt`.}

md"""
### Task 4 - rearranging the code

For enhanced stability of the elastic solver, it is important to use the newly computed quantities as soon as possible. 

Create a last duplicate of the `acoustic_2D_elast3.jl` script, renaming it `elastic_2D.jl`.

In this final version of the script, move the pressure update at the beginning of the time loop. First update pressure in order to use the updated pressure later on when computing the pressure gradient in the velocity update.

You should now have a 2D elastic solver up and running 🚀

### Final Task

Compare the results between acoustic and elastic wave propagation for identical physical and numerical input parameters. Create one figure for each simulation that you add to the `README` in a new final section. Comment briefly about the results.
"""


