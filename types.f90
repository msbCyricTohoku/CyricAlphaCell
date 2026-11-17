! ==============================================================================
! CyricAlphaCell: Cellular Alpha Microdosimetry Monte Carlo (optimized)
! Version 1.0.1
! ==============================================================================
! Description: A high-performance, OpenMP-accelerated track-structure 
!              Monte Carlo framework for precision internal alpha dosimetry 
!              in cell colonies.
!
! Authors:     Mehrdad S. Beni and Hiroshi Watabe
! Institution: RARiS (formerly CYRIC) Nuclear Lab
!              Tohoku University, Sendai, Japan
!
! License:     Distributed under the GNU General Public License (GPL)
! ==============================================================================
module TYPES_MOD
  use omp_lib
  implicit none
  
  integer, parameter :: P_ALPHA = 4
  integer, parameter :: E_GRID_MAX = 250000 !kev
  integer, parameter :: NUM_EBINS = 200
  integer, parameter :: Z_BINS = 2000
  integer, parameter :: LET_BINS = 300
  real(8), parameter    :: Z_MAX_GY = 1000.0 !change since now we score microdomain
  real(8), parameter    :: LET_MAX_KEV = 300.0 
!--------------------------------------
  INTEGER :: SVG_PLOT_CHECK   !for my custom cacplotter
  INTEGER :: RENDER_PLOT_CHECK !for my custom cacplotter

  !the type for cell and other stuff changed
  !this was to further optimize the model
  !so these can be within cpu registers 
  type :: Particle_vars
      integer :: id
      integer :: parent_id
      integer :: ptype
      integer :: gen
      real(8) :: E
      real(8) :: x
      real(8) :: y
      real(8) :: z
      real(8) :: u
      real(8) :: v
      real(8) :: w
      logical :: record
   end type Particle_vars
!--------------------------------------
  character(len=256) :: out_dir
  character(len=256) :: dedx_file
  integer :: nps_total
  integer ::  completed_nps
  integer :: use_straggling
  integer :: max_tracks
  real(8) :: global_ds
  real(8) :: e_cut
  integer :: src_mode 
  real(8) :: src_x
  real(8) :: src_y
  real(8) :: src_z
  real(8) :: src_E0
!--------------------------------------
  real(8)    :: bio_domain_d
  real(8)    :: bio_target_dose
  real(8)    :: bio_alpha_x
  real(8)    :: bio_beta_x
!--------------------------------------  
  integer :: num_cells
  integer, allocatable :: cells_id(:)
  real(8), allocatable :: cells_x(:)
  real(8), allocatable :: cells_y(:)
  real(8), allocatable :: cells_z(:)
  real(8), allocatable :: cells_r_nuc(:)
  real(8), allocatable :: cells_r_cyto(:)
  real(8), allocatable :: cells_src_prob(:)
  real(8), allocatable :: cells_src_cdf(:)
  real(8), allocatable :: cells_r_nuc_sq(:)
  real(8), allocatable ::  cells_r_cyto_sq(:)
  real(8), allocatable :: stp_a(:)
  !--------------------------------------
  real(8) :: mat_rho 
  real(8) :: mat_Z_eff 
  real(8) :: mat_A_eff 

end module types_mod
