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
module source_mod
  use types_mod
  use physics_mod
  implicit none
  
contains

  !highly optmized version of source sampling
  subroutine sample_source(p, start_id, rng_state)
    type(Particle_vars), intent(out) :: p
    integer, intent(in) :: start_id
    integer(8), intent(inout) :: rng_state
    integer :: i
    integer :: c_idx
    real(8) :: r1
    real(8) ::  r2
    real(8) ::  r3
    real(8) ::  r_rad
    real(8) ::  costh
    real(8) ::  phi
    real(8), parameter :: TWO_PI = 2.0 * acos(-1.0)

    p%id = start_id
    p%parent_id = start_id
    p%ptype = P_ALPHA
    p%gen = 0
    p%record = (start_id <= max_tracks)
    p%E = max(0.001d0, src_E0)

    if (src_mode == 1) then
       p%x = src_x
       p%y = src_y
       p%z = src_z
    else if (src_mode == 2) then

       r1 = rand_dbl(rng_state)
       c_idx = 1

       do i = 1, num_cells
          if (r1 <= cells_src_cdf(i) .or. i == num_cells) then
             c_idx = i
             exit
          end if
        end do

        !call random_number(r1)
        !print*, "r1 second call: ", r1
        !pause
        !call random_number(r2)
        !call random_number(r3)

        !using bitwise random number in physics module
        !faster than fortran call random_number
        r1 = rand_dbl(rng_state)
        r2 = rand_dbl(rng_state)
        r3 = rand_dbl(rng_state)

        !sampling radius in a sphere of r_nuc
        r_rad = cells_r_nuc(c_idx) * (r1 ** 0.3333333d0)  !since sphere volume changes r^3 aka cube root

        !polar angle sampling -- inverse transform sampling of polar angle
        costh = 2.0d0 * r2 - 1.0d0

         !azimuthal angle sampling, it is easy since it is azimuthal goes 0 to 2pi
        phi   = TWO_PI * r3    ! 6.2831853 * r3  !2.Pi.r

        !translate to cartesian space
         !x_new = x + r.sin(theta).cos(phi) --> sin(theta) = sqrt(1-cos2(theta))
        p%x = cells_x(c_idx) + r_rad * sqrt(max(0.0d0, 1.0d0 - costh**2)) * cos(phi)
        ! same as above but for y since we have y_new = y+ r.sin(theta).sin(phi)
        p%y = cells_y(c_idx) + r_rad * sqrt(max(0.0d0, 1.0d0 - costh**2)) * sin(phi)
         !r.cos(theta) 
        p%z = cells_z(c_idx) + r_rad * costh
     end if

     !print*, p%x, p%y, p%z
     !pause

    !call random_number(r1)
    !call random_number(r2)

    r1 = rand_dbl(rng_state)
    r2 = rand_dbl(rng_state)

    costh = 2.0d0 * r1 - 1.0d0 !same sampling here for unit vectors
    
    phi   = TWO_PI * r2

    !here we sample direction unit vectors, do not multiply by radius just sampling (fixed the issue, done!)
    p%u = sqrt(max(0.0d0, 1.0d0 - costh**2)) * cos(phi)
    p%v = sqrt(max(0.0d0, 1.0d0 - costh**2)) * sin(phi)
    p%w = costh

  end subroutine sample_source
     
end module source_mod
