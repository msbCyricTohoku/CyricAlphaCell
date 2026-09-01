! ==============================================================================
! CyricAlphaCell: Cellular Alpha Microdosimetry Monte Carlo
! Version 1.0.0
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
  
  !here I define microdosimetry params
  integer, parameter :: NUM_EBINS = 200
  integer, parameter :: Z_BINS = 2000 !500
  integer, parameter :: LET_BINS = 300
  real, parameter    :: Z_MAX_GY = 1000.0 !2000.0 !10000.0  !5.0 !max specific energy (Gy) to bin
  real(8), parameter    :: LET_MAX_KEV = 300.0  !max LET (keV/um) to bin

  INTEGER :: SVG_PLOT_CHECK
  INTEGER :: RENDER_PLOT_CHECK

  
  !here are the particle types
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

  !here are cell param types
  type :: CellTarget
      integer :: id !here cell id are imp since i made a UI and can track the source
      real(8) :: x !the location of spherical cells
      real(8) :: y
      real(8) :: z
      real(8) :: r_nuc !nucleus radius
      real(8) :: r_cyto !cell/cytoplasm radius
      real(8) :: src_prob !source probabiliy, 1=ON 0=OFF
      real(8) :: src_cdf !source cum. distb. function, i sum the prob. 
  end type CellTarget

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
  
  !MKM params for microdose
  real(8)    :: bio_domain_d
  real(8)    :: bio_target_dose
  real(8)    :: bio_alpha_x
  real(8)    :: bio_beta_x
  
  integer :: num_cells
  type(CellTarget), allocatable :: cells(:)
  real(8), allocatable :: stp_a(:)
  
  real(8) :: mat_rho ! = 1.0    !these must change to user defined   
  real(8) :: mat_Z_eff ! = 7.42  !these must change to user defined
  real(8) :: mat_A_eff != 14.3  !these must change to user defined

end module types_mod
