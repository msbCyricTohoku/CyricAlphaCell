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
module source_mod
  use types_mod
  implicit none
  
contains

  subroutine sample_source(p, start_id)
    type(Particle_vars), intent(out) :: p
    integer, intent(in) :: start_id
    integer :: i
    integer :: c_idx
    real(8) :: r1
    real(8) :: r2
    real(8) :: r3
    real(8) :: r_rad
    real(8) :: costh
    real(8) :: phi
    real(8), parameter :: TWO_PI = 2.0 * acos(-1.0)

    p%id = start_id
    p%parent_id = start_id
    p%ptype = P_ALPHA
    p%gen = 0
    p%record = (start_id <= max_tracks)
    p%E = max(0.001, src_E0)

    if (src_mode == 1) then
       p%x = src_x
       p%y = src_y
       p%z = src_z
    else if (src_mode == 2) then

       call random_number(r1)
       !print*, "r1 first call: ", r1
       !pause

       c_idx = 1

       do i = 1, num_cells
          if (r1 <= cells(i)%src_cdf .or. i == num_cells) then
             c_idx = i
             exit
          end if
        end do
        
        call random_number(r1)
        !print*, "r1 second call: ", r1
        !pause
        call random_number(r2)
        call random_number(r3)

        !sampling radius in a sphere of r_nuc
        r_rad = cells(c_idx)%r_nuc * (r1 ** 0.3333333)  !since sphere volume changes r^3 aka cube root

        !polar angle sampling -- inverse transform sampling of polar angle
        costh = 2.0 * r2 - 1.0

        !azimuthal angle sampling, it is easy since it is azimuthal goes 0 to 2pi
        phi   = TWO_PI* r3  ! 6.2831853 * r3  !2.Pi.r

        !translate to cartesian space
        p%x = cells(c_idx)%x + r_rad * sqrt(max(0.0, 1.0 - costh**2)) * cos(phi)  !x_new = x + r.sin(theta).cos(phi) --> sin(theta) = sqrt(1-cos2(theta))
        p%y = cells(c_idx)%y + r_rad * sqrt(max(0.0, 1.0 - costh**2)) * sin(phi) ! same as above but for y since we have y_new = y+ r.sin(theta).sin(phi)
        p%z = cells(c_idx)%z + r_rad * costh   !r.cos(theta) 
     end if

     !print*, p%x, p%y, p%z
     !pause

    call random_number(r1)
    call random_number(r2)

    costh = 2.0* r1 - 1.0 !same sampling here for unit vectors 

    phi   = TWO_PI * r2

    !here we sample direction unit vectors, do not multiply by radius just sampling (fixed the issue, done!)
    p%u = sqrt(max(0.0, 1.0 - costh**2)) * cos(phi)
    p%v = sqrt(max(0.0, 1.0 - costh**2)) * sin(phi)
    p%w = costh

  end subroutine sample_source
     
end module source_mod
