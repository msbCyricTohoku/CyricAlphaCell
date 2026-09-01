#-- - CyricAlphaCell Parameters - --
100000       # nps_total
1.0e-4         # global_ds (cm) -> 1 um maximum step length
0.01           # e_cut (MeV) -> stop tracking at 10 keV
1              # use_straggling (1=On, 0=Off)
500            # max_tracks to record in tracks.dat
output         # output directory

#-- - Source Config - --
2              # src_mode: 1 = Point Source, 2 = Distributed inside Nuclei
5.3            # src_E0 (MeV) -> Alpha Energy
0.0 0.0 0.0    # src_x, src_y, src_z (used only if src_mode=1)
data/water_liquid.dedx # Path to stopping power file
1.0   # rho_mat density
10.0  # Z_eff effective atomic
18.015  # A_eff effective mass

#-- - Radiobiology Parameters(MKM Model) - --
0.5            # Bio domain diameter 'd' (um) -> 0.5 for alpha particles
2.0            # Reference Target Dose (Gy) -> Used to evaluate RBE
0.18           # Reference X-ray alpha (Gy^-1)
0.02           # Reference X-ray beta (Gy^-2)

#-- - Plotting Option - --
1    # save SVG (1=On, 0=Off)
0    # render window (1=On, 0=Off)

#-- - Cellular Colony Geometry - --
19             # num_cells
# ID    X(cm)         Y(cm)           Z(cm)       R_nuc(cm)   R_cyto(cm)  Source_Probability
1       0.0e+0        0.0e+0          0.0e+0      5.00e-4     1.0e-3      1.0
2       -1.001e-3     -1.73378e-3     0.0e+0      5.00e-4     1.0e-3      0.0
3       1.001e-3      -1.73378e-3     0.0e+0      5.00e-4     1.0e-3      0.0
4       -2.002e-3     0.0e+0          0.0e+0      5.00e-4     1.0e-3      0.0
5       2.002e-3      0.0e+0          0.0e+0      5.00e-4     1.0e-3      0.0
6       -1.001e-3     1.73378e-3      0.0e+0      5.00e-4     1.0e-3      0.0
7       1.001e-3      1.73378e-3      0.0e+0      5.00e-4     1.0e-3      0.0
8       0.0e+0        -3.46756e-3     0.0e+0      5.00e-4     1.0e-3      0.0
9       0.0e+0        3.46756e-3      0.0e+0      5.00e-4     1.0e-3      0.0
10      -3.003e-3     -1.73378e-3     0.0e+0      5.00e-4     1.0e-3      0.0
11      3.003e-3      -1.73378e-3     0.0e+0      5.00e-4     1.0e-3      0.0
12      -3.003e-3     1.73378e-3      0.0e+0      5.00e-4     1.0e-3      0.0
13      3.003e-3      1.73378e-3      0.0e+0      5.00e-4     1.0e-3      0.0
14      -2.002e-3     -3.46756e-3     0.0e+0      5.00e-4     1.0e-3      0.0
15      2.002e-3      -3.46756e-3     0.0e+0      5.00e-4     1.0e-3      0.0
16      -4.004e-3     0.0e+0          0.0e+0      5.00e-4     1.0e-3      0.0
17      4.004e-3      0.0e+0          0.0e+0      5.00e-4     1.0e-3      0.0
18      -2.002e-3     3.46756e-3      0.0e+0      5.00e-4     1.0e-3      0.0
19      2.002e-3      3.46756e-3      0.0e+0      5.00e-4     1.0e-3      0.0
