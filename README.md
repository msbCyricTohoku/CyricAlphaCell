```text
===============================================================================
  ___        _       _  _      _          ___     _ _  
 / __|_  _ _(_)__   /_\  | |_ __| |_  __ _ / __|___| | | 
| (__| || | '_/ _| / _ \ | | '_ \ ' \/ _` | (__/ -_) | | 
 \___|\_, |_| \__|/_/ \_\|_| .__/_||_\__,_|\___\___|_|_| 
      |__/                 |_|                           

 CyricAlphaCell (C.A.C) - Version 1.0.0
 Cellular Alpha Microdosimetry Monte Carlo Framework
===============================================================================

Authors:     Mehrdad S. Beni & Hiroshi Watabe
Institution: RARiS (CYRIC) Nuclear Lab, Tohoku University, Japan
License:     GNU General Public License (GPL)

-------------------------------------------------------------------------------
1. OVERVIEW
-------------------------------------------------------------------------------
CyricAlphaCell (C.A.C) is a high-performance, OpenMP-accelerated track-structure Monte 
Carlo engine built in modern Fortran. It calculates cellular-level macroscopic 
doses, dose-averaged LET, dynamic micro-domain specific energy distributions 
(f1(z)), and evaluates cell survival using the Microdosimetric Kinetic Model 
(MKM). It is designed to be mathematically rigorous, highly parallelized, and 
extremely fast via Continuous-Slowing-Down Approximation (CSDA).

-------------------------------------------------------------------------------
2. CORE PHYSICS & EQUATIONS
-------------------------------------------------------------------------------
[ PARTICLE TRANSPORT ]
Alpha particles are transported using CSDA coupled with randomized energy-loss 
straggling. Stopping powers (S = dE/dx) are interpolated from NIST ASTAR data.

Bohr Straggling Variance:
sigma_Bohr^2 = 4 * pi * z^2 * Z_eff * e^4 * N * ds

Energy loss is sampled from a Lognormal-Gaussian distribution bounded by the 
mean energy loss to prevent unphysical negative energy sampling.

[ MICRODOSIMETRY ]
Specific Energy (z):
z = epsilon / m
Where epsilon is the deposited energy and m is the mass of the target domain.

Frequency-Mean Specific Energy (z_F) & Dose-Averaged LET (L_D):
z_F = (Sum of z_i) / N_hits
L_D = (Sum of L_i * epsilon_i) / (Sum of epsilon_i)

[ RADIOBIOLOGY & MKM OVERKILL EFFECT ]
The domain-specific dose-mean specific energy (z_D) is calculated analytically 
from L_D for a domain of diameter d:
z_D = (0.204 * L_D) / d^2

To account for the overkill effect at high LET (where excess energy yields 
diminishing cell kill), z_D is clamped using the saturation parameter z_0 
(derived from y_0 = 150 keV/um):
z_D* = (z_0^2 / z_D) * (1 - exp(-(z_D^2) / z_0^2))

Survival Fraction (S) & Alpha parameter:
alpha = alpha_X + beta_X * z_D*
S = exp(-alpha * D - beta_X * D^2)

-------------------------------------------------------------------------------
3. BUILD INSTRUCTIONS (CMAKE)
-------------------------------------------------------------------------------
C.A.C is built using CMake. A Fortran compiler (e.g., gfortran) with OpenMP 
support is required. X11 development headers are required for native plotting.

$ git clone <repository_url>
$ cd CyricAlpha
$ mkdir build && cd build
$ cmake ..
$ make

This will produce the cac.bin executable in your build directory.

-------------------------------------------------------------------------------
4. USER MANUAL & INPUT PREPARATION
-------------------------------------------------------------------------------
Run the executable by passing your input file as the first argument:
$ ./cac.bin inputs.i

The input file MUST follow a strict, whitespace-separated format. Comments (#) 
are ignored. Below is a standard template (e.g., inputs.i):

#-- - CyricAlphaCell Parameters - --
100000       # nps_total
1.0e-4       # global_ds (cm) -> 1 um maximum step length
0.01         # e_cut (MeV) -> stop tracking at 10 keV
1            # use_straggling (1=On, 0=Off)
500          # max_tracks to record in tracks.dat
output       # output directory

#-- - Source Config - --
2            # src_mode: 1 = Point Source, 2 = Distributed inside Nuclei
5.3          # src_E0 (MeV) -> Alpha Energy
0.0 0.0 0.0  # src_x, src_y, src_z (used only if src_mode=1)
data/water_liquid.dedx # Path to stopping power file
1.0   # rho_mat density
10.0  # Z_eff effective atomic
18.015  # A_eff effective mass

#-- - Radiobiology Parameters(MKM Model) - --
0.5          # Bio domain diameter 'd' (um) -> 0.5 for alpha particles
2.0          # Reference Target Dose (Gy) -> Used to evaluate RBE
0.18         # Reference X-ray alpha (Gy^-1)
0.02         # Reference X-ray beta (Gy^-2)

#-- - Plotting Option - --
1    # save SVG (1=On, 0=Off)
0    # render window (1=On, 0=Off)

#-- - Cellular Colony Geometry - --
19             # num_cells
# ID    X(cm)         Y(cm)           Z(cm)       R_nuc(cm)   R_cyto(cm)  Source_Probability
1       0.0e+0        0.0e+0          0.0e+0      5.00e-4     1.0e-3      1.0
2       -1.001e-3     -1.73378e-3     0.0e+0      5.00e-4     1.0e-3      0.0
3       1.001e-3      -1.73378e-3     0.0e+0      5.00e-4     1.0e-3      0.0

*Note: Use the included HTML UI configurator to easily generate massive, 
non-overlapping cellular geometry arrays for your inputs.i file.*

-------------------------------------------------------------------------------
5. OUTPUT FILES
-------------------------------------------------------------------------------
All outputs are generated in the specified output directory:
- cellular_dosimetry.dat       (Macro dose & hits per nucleus/cytoplasm)
- radiobiology_rbe.dat         (z_F, z_D, L_D, Survival, and RBE per cell)
- microdosimetry_z_spectra.dat (Analytic f1(z) for the MKM micro-domain)
- let_spectra.dat              (Dose-averaged LET distribution)
- tracks.dat                   (XYZ track coordinate projection data)
- *.svg                        (Native vector plots, if enabled)

===============================================================================
