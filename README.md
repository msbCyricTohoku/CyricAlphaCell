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
```

**Developers:** Mehrdad S. Beni & Hiroshi Watabe  
**Institution:** RARiS (CYRIC) Nuclear Lab, Tohoku University, Japan  
**License:** GNU General Public License (GPL)  
**Interactive Input Designer (CAC Studio):** https://msbcyrictohoku.github.io/CyricAlphaCell/

---

## 1. Overview

CyricAlphaCell (C.A.C) is an OpenMP-accelerated Monte Carlo track-structure engine written in modern Fortran for cellular-level alpha-particle microdosimetry. Using the Continuous-Slowing-Down Approximation (CSDA) with Bohr energy-loss straggling, it computes:

- Macroscopic absorbed doses and hit counts per cell nucleus and cytoplasm
- Dose-averaged Linear Energy Transfer (LET) distributions
- Dynamic micro-domain specific energy distributions, f1(z)
- Cell survival fractions and Relative Biological Effectiveness (RBE) via the Microdosimetric Kinetic Model (MKM)

---

## 2. Interactive Input Designer (CAC Studio)

New users do not need to write geometry files by hand. Use **CAC Studio** directly in your browser to configure parameters, build 2D or 3D cell colonies, and export ready-to-run `.i` input files:

https://msbcyrictohoku.github.io/CyricAlphaCell/

CAC Studio provides:
- Interactive 2D (XY, XZ, YZ) and 3D Orbit geometry views
- Built-in colony generators (hexagonal, square, ring, line, 3D HCP spheroid, 3D cubic)
- Automatic 3D non-overlap protection so cytoplasmic spheres never intersect
- Built-in example benchmark cases, hover help tooltips, and `.i` file import/export

---

## 3. Step-by-Step Tutorial

### Step 1: Install Prerequisites

Make sure the following tools are installed on your system:
- A Fortran compiler with OpenMP support (e.g., `gfortran`)
- `cmake` and `make`
- X11 development headers (required for native plotting, e.g., `libx11-dev` on Debian/Ubuntu or `libx11` on Arch/Artix)

### Step 2: Clone and Build C.A.C

```bash
git clone https://github.com/msbcyrictohoku/CyricAlphaCell.git
cd CyricAlphaCell
mkdir build && cd build
cmake ..
make
cd ..
```

This creates the executable at `build/cac.bin`.

### Step 3: Prepare an Input File

**Option A (Recommended): Use CAC Studio**
1. Open https://msbcyrictohoku.github.io/CyricAlphaCell/
2. Select a starter case or configure your Physics, Source, Bio (MKM), and Colony tabs.
3. Click **Export .i File** to save `inputs.i` into your `CyricAlphaCell` directory.

**Option B: Create or Edit Manually**
Copy the template in Section 4 into a file named `inputs.i` in the root `CyricAlphaCell` directory and adjust the values as needed.

### Step 4: Run the Simulation

Run C.A.C from the repository root directory so that relative paths to `data/*.dedx` resolve automatically:

```bash
./build/cac.bin inputs.i
```

To control the number of OpenMP CPU threads:

```bash
OMP_NUM_THREADS=8 ./build/cac.bin inputs.i
```

### Step 5: Inspect the Results

All simulation results are written to the folder specified by `output directory` in your input file (for example, `output/`). Open the `.dat` files in your preferred plotting or analysis tool, or view the generated `.svg` plots directly in a web browser.

---

## 4. Input File Format

The input file follows a strict whitespace-separated layout. Everything after `#` on a line is ignored as a comment.

**Important formatting rules:**
- Always leave at least one space between a parameter value and `#`.
- All cell coordinates and radii are in **centimeters (cm)**.
- MKM domain diameter `d` is in **micrometers (um)**.
- Alpha energy and cutoff energy are in **MeV**.
- **No cell overlaps are allowed:** cytoplasmic spheres must not intersect in 3D space, and `R_nuc` must be strictly smaller than `R_cyto`.

### Standard Template (`inputs.i`)

```text
#--- CyricAlphaCell Parameters ---
100000          # nps_total (number of alpha histories)
1.0e-4          # global_ds (cm) -> 1 um maximum step length
0.01            # e_cut (MeV) -> stop tracking at 10 keV
1               # use_straggling (1=On, 0=Off)
500             # max_tracks to record in tracks.dat
output          # output directory (no spaces)

#--- Source Config ---
2               # src_mode: 1 = Point Source, 2 = Distributed inside Nuclei
5.3             # src_E0 (MeV) -> initial alpha energy
0.0 0.0 0.0     # src_x, src_y, src_z (cm, used only if src_mode = 1)
data/water_liquid.dedx  # Path to stopping power file
1.0             # rho_mat density (g/cm^3)
10.0            # Z_eff effective atomic number
18.015          # A_eff effective mass

#--- Radiobiology Parameters (MKM Model) ---
0.5             # Bio domain diameter d (um) -> 0.5 for alpha particles
2.0             # Reference Target Dose (Gy) -> used to evaluate RBE
0.18            # Reference X-ray alpha (Gy^-1)
0.02            # Reference X-ray beta (Gy^-2)

#--- Plotting Option ---
1               # save SVG (1=On, 0=Off)
0               # render window (1=On, 0=Off; keep 0 on headless servers)

#--- Cellular Colony Geometry ---
3               # num_cells
# ID    X(cm)          Y(cm)          Z(cm)          R_nuc(cm)     R_cyto(cm)    Source_Probability
1       0.00000e+0     0.00000e+0     0.00000e+0     5.00e-4       1.00e-3       1.0000
2      -1.00100e-3    -1.73378e-3     0.00000e+0     5.00e-4       1.00e-3       0.0000
3       1.00100e-3    -1.73378e-3     0.00000e+0     5.00e-4       1.00e-3       0.0000
```

### Available Stopping Power Tables (`data/`)

The repository includes NIST ASTAR stopping-power tables in the `data/` directory:

- `data/water_liquid.dedx`
- `data/muscle_skeletal.dedx`
- `data/adipose_tissue.dedx`
- `data/bone_cortical.dedx`
- `data/a150_tep.dedx`
- `data/air_dry.dedx`
- `data/polyethylene.dedx`
- `data/aluminum.dedx`
- `data/titanium.dedx`
- `data/lead.dedx`

---

## 5. Output Files

All outputs are saved inside the configured output directory:

| File | Description |
| :--- | :--- |
| `cellular_dosimetry.dat` | Macroscopic dose and hit counts per nucleus and cytoplasm |
| `radiobiology_rbe.dat` | `z_F`, `z_D`, `L_D`, Survival Fraction, and RBE per cell |
| `microdosimetry_z_spectra.dat` | Analytic `f1(z)` specific energy distribution for the MKM domain |
| `let_spectra.dat` | Dose-averaged LET distribution |
| `tracks.dat` | Recorded XYZ track coordinate projection data |
| `*.svg` | Native vector plots (generated when `save SVG = 1`) |

---

## 6. Core Physics and Equations

### Particle Transport
Alpha particles are transported using CSDA coupled with randomized energy-loss straggling. Stopping powers (`S = dE/dx`) are interpolated from NIST ASTAR data.

Bohr straggling variance:
```text
sigma_Bohr^2 = 4 * pi * z^2 * Z_eff * e^4 * N * ds
```

Energy loss is sampled from a Lognormal-Gaussian distribution bounded by the mean energy loss to prevent unphysical negative energy sampling.

### Microdosimetry
Specific energy (`z`), frequency-mean specific energy (`z_F`), and dose-averaged LET (`L_D`):
```text
z   = epsilon / m
z_F = (Sum of z_i) / N_hits
L_D = (Sum of L_i * epsilon_i) / (Sum of epsilon_i)
```
where `epsilon` is the deposited energy and `m` is the mass of the target domain.

### Radiobiology and MKM Overkill Effect
The domain-specific dose-mean specific energy (`z_D`) is calculated analytically from `L_D` for a domain of diameter `d`:
```text
z_D = (0.204 * L_D) / d^2
```

To account for the overkill effect at high LET, `z_D` is saturated using `z_0` (derived from `y_0 = 150 keV/um`):
```text
z_D* = (z_0^2 / z_D) * (1 - exp(-(z_D^2) / z_0^2))
```

Survival fraction (`S`) and effective linear parameter (`alpha`):
```text
alpha = alpha_X + beta_X * z_D*
S     = exp(-alpha * D - beta_X * D^2)
```

---

## 7. License

This project is distributed under the **GNU General Public License (GPL)**.
