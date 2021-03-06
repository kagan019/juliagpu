+++
title = "Lecture 10"
hascode = true
literate_mds = true
showall = false
noeval = true
+++

# Final projects

> **Agenda**\
> :books: Final projects\
> :computer: MPI & Advanced optimisations Q&A\
> :construction: Exercises: Q&A

---

**Content**

\toc

---

## Information about final projects

Final projects will provide 60% of the course grade. We recommend you work in teams of two, but being your own teammate is fine too.

_Note that a single GitHub repository is sufficient per project._

**Project's due date is December 23, 2021 -- 23h59 CET (enforced by a "release tag v1.0.0").**

[**Project template** available here](https://github.com/eth-vaw-glaciology/FinalProjectRepo.jl) - copy or clone to get started.

\warn{The final project GitHub repository shoud **remain private** until submission on December 23, 2021.}

---

Final projects compose of 2 distinct parts (50% of the project mark each) to be handed-in on a single GitHub repository, including scripts, documentation (and code documentation), unit and reference testing, Continuous Integration (CI - using e.g. GitHub Actions), instructions to run the software and reproduce the results, references.

### Part 1: 3D multi-XPUs diffusion solver
Steady state solution of a diffusive process for given physical time steps using the pseudo-transient acceleration (using the so-called "[dual-time](/lecture4/#implicit_solutions)" method).

Your task in **_part 1_** is to solve the linear diffusion equation in 3D

$$ \frac{∂H}{∂t} = ∇ ⋅ D\;∇H ~ ,$$

where $D=1$, using an implicit iterative approach leveraging [pseudo-transient **acceleration** (or damping)](lecture4/#one_needs_a_second_order_implementation) (see [Lecture 4](/lecture4/#steady-state_and_implicit_iterative_solutions)). Use the following physical parameters
```julia
lx, ly, lz = 10.0, 10.0, 10.0 # domain size
D          = 1.0              # diffusion coefficient
ttot       = 1.0              # total simulation time
dt         = 0.2              # physical time step
```
and converge your reference solution to $\mathrm{tol_{nl}} = 10^{-8}$ using the "normalised" L2-norm of the equation's residual $R_H$ (`norm(R_H)/sqrt(length(R_H))`). _The residual $R_H$ is defined as imbalance of Eq. (1), one can obtain by, e.g, moving all terms on the right-hand-side._

Consider implementing the following definition of a "global" norm function (relying on `MPI.Allreduce()`):
```julia
norm_g(A) = (sum2_l = sum(A.^2); sqrt(MPI.Allreduce(sum2_l, MPI.SUM, MPI.COMM_WORLD)))
```

As **initial condition**, define a Gaussian distribution of $H$ centred in the domain's centre with **amplitude of 2** and standard deviation of 1. Enforce Dirichlet boundary condition $H=0$ an all 6 faces.

\note{Use [ParallelStencil.jl](https://github.com/omlins/ParallelStencil.jl) and [ImplicitGlobalGrid.jl](https://github.com/eth-cscs/ImplicitGlobalGrid.jl) for the (multi-)XPU implementation. You are free to use either `@parallel` or `@parallel_indices` type of kernel definition.}

Implement the 3D diffusion equation (1) using a [dual-time](/lecture4/#implicit_solutions) method, including the physical time-derivative as physical term in the residual definition and using pseudo-time to iterate the solution as suggested [here (Eqs 11 & 12)](/lecture4/#implicit_solutions). Make use of acceleration (or damping) to enforce scaling of the pseudo-transient iterations, finding the optimal damping term.

For the multi-XPU implementation, you can build on the [2D multi-XPU diffusion](/lecture8/#using_implicitglobalgridjl) provided in Lecture 8, extending it to 3D. For 3D visualisation, feel free to check out [Makie.jl](https://makie.juliaplots.org/stable/) which offers interesting graphical rendering capabilities. 

👉 Refer to the [`part1.md`](https://github.com/eth-vaw-glaciology/FinalProjectRepo.jl/blob/main/docs/part1.md) in [FinalProjectRepo.jl/docs/](https://github.com/eth-vaw-glaciology/FinalProjectRepo.jl/blob/main/docs/) regarding the **specific steps we expect you to work and report on**.

👉 Make sure to **include unit and reference tests**. We provide you with a [reference test](https://github.com/eth-vaw-glaciology/FinalProjectRepo.jl/blob/main//test/part1.jl) (using [ReferenceTests.jl](https://github.com/JuliaTesting/ReferenceTests.jl)) you can benchmark your implementation against. Adapt it to your needs and ensure your 3D diffusion solver to return `H` and `xc`, the global solution array and the corresponding global x-coordinate vector, respectively (`C` and `xc` in the [`diffusion_2D_perf_multixpu.jl`](https://github.com/eth-vaw-glaciology/course-101-0250-00/tree/main/scripts/diffusion_2D_perf_multixpu.jl) script).

The 3D diffusion script for reference testing should be:
- executed as a **single** (non-MPI) program,
- run on the **CPU** (not GPU),
- use `nx = ny = nz = 32` as **local** grid resolution,
- return the `H` array and the `xc` (x-coordinate) vector.

\note{GitHub Actions only provides CPU-based runners. For unit and reference testing purpose, select small problem sizes (here `nx = ny = nz = 32`), run on a single process (launching the code without `mpirun` or `mpiexecjl`) and use ParallelStencil's CPU backend (setting `USE_GPU = false`).}

For multi-XPU visualisation purpose, the global result array `H_g` can be assembled using ImplicitGlobalGrid's [`gather!()`](https://github.com/eth-cscs/ImplicitGlobalGrid.jl/blob/master/src/gather.jl) function. Refer to e.g. [2D multi-XPU diffusion](/lecture8/#using_implicitglobalgridjl) for further details on how to construct the global solution and coordinate vectors.

> If you struggle implementing the [dual-time](/lecture4/#implicit_solutions) solution strategy, you can look-up this [1D diffusion code](https://github.com/eth-vaw-glaciology/course-101-0250-00/tree/main/scripts/diff_1D_dualtime.jl) for inspiration. Set the `steady` flag to `false` for dual-time, time dependent implicit solution; set it to `true` for a steady-state implicit solution.

### Part 2: [your personal project]
Selecting a project of your choice among 3 possible directions:
1. Solving PDEs you have some interest in (e.g. related to another project or future study/research direction of yours)
2. Applying [advanced optimisations](/lecture9/) and benchmarking to existing PDEs; the ones seen in class or, e.g., to examples from [ParallelStencil's miniapps](https://github.com/omlins/ParallelStencil.jl#concise-singlemulti-xpu-miniapps).
3. Solving one of the proposed PDE's
    - [2D Shallow water equations](https://en.wikipedia.org/wiki/Shallow_water_equations)
    - [3D Thermo-mechanically coupled viscous flow](https://doi.org/10.1093/gji/ggy434)
    - [3D elastic wave propagation](https://en.wikipedia.org/wiki/Linear_elasticity#Elastodynamics_in_terms_of_displacements)
    - 3D viscous Stokes flow
    - viscous or elastic poromechanics
    - more ...

## Getting started with the final projects

The following steps will get you started with the final projects:
1. Find a classmate to work with (being your own mate is fine too)
2. Select a topic of your choice for **_part 2_** (see [here](#part_2_your_personal_project))
3. Copy or clone the [**template**](https://github.com/eth-vaw-glaciology/FinalProjectRepo.jl) for the final project.
4. Invite the teaching staff to the repo
5. Send and email to Ludovic (luraess@ethz.ch) and Mauro (werder@vaw.baug.ethz.ch) by **Tuesday November 30, 2021**, with subject _**Final projects**_ including
    - your project mate
    - a brief description of your choice for **_part 2_**
    - a link to your final project GitHub repository
    - _anything else missing in this list_
6. Work on you final project, asking for help
    - in the Element _Helpdesk_ channel for general question
    - as **GitHub "issue"** for project specific questions

## Project submission

Submission deadline for the project is **December 23, 2021 -- 23h59 CET**.

Final submission timestamp is enforced upon tagging the v1.0.0 version release of your repository. See [GitHub docs](https://docs.github.com/en/repositories/releasing-projects-on-github/about-releases) for infos.

Also, add the last commit HSA to [Moodle](https://moodle-app2.let.ethz.ch/course/view.php?id=15755#section-10) as for the exercises.

## Project grading

Grading of the project will be 50% for **_part 1_** and 50% for **_part 2_**.

For a successful outcome, both parts are expected to be handed-in as single GitHub repository featuring the following items:
- documented and polished scripts (using e.g. docstrings, in-line comments)
- documentation including:
  - a succinct `README.md` directing to both project parts enhanced documentation  
  - an enhanced `README.md` for each parts following to proposed structure with equations, cross-references, figures, figure captions
  - instructions to run the software and reproduce the results
  - references
- unit and reference testing
- Continuous Integration (CI - using e.g. GitHub Actions)
- additional features if needed

---

_Note that in case of un-expected results, the grading will reward the development, implementation and extensive documentation, even if, e.g, stiff PDEs would not deliver expected results._
