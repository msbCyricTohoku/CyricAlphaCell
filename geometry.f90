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
module geometry_mod
  use types_mod
  implicit none
  
contains
  
  subroutine get_cell_location(x, y, z, c_id, region)
    real(8), intent(in) :: x
    real(8), intent(in) :: y
    real(8), intent(in) :: z
    integer, intent(out) :: c_id
    integer, intent(out) :: region ! 1 = Nuc, 2 = Cyto, 0 = Out
    integer :: i
    real(8) :: d2

    c_id = 0
    region = 0

    do i = 1, num_cells
        d2 = (x - cells(i)%x)**2 + (y - cells(i)%y)**2 + (z - cells(i)%z)**2  !euclidean dist from point x,y,z to cell center

        !check if the point is inside or on nucleus then ID = 1
        if (d2 <= cells(i)%r_nuc**2) then
           c_id = i
           region = 1

           return

           !check if the point is inside or on cytoplasm then ID = 2
        else if (d2 <= cells(i)%r_cyto**2) then
           c_id = i
           region = 2
           return
        end if
     end do
     !else will be outside ID = 0 from init time
   end subroutine get_cell_location

   
   !calc distance from x,y,z along trajectory direction vector         
  pure function dist_to_boundary(x, y, z, u, v, w) result(dbnd)
    real(8), intent(in) :: x
    real(8), intent(in) :: y
    real(8), intent(in) :: z
    real(8), intent(in) :: u
    real(8), intent(in) :: v
    real(8), intent(in) :: w
    real(8) :: dbnd
    integer :: i
    integer :: r_idx
    real(8) :: A_quad
    real(8) :: B_quad
    real(8) :: C_quad
    real(8) :: det
    real(8) :: d1
    real(8) :: d2
    real(8) :: cx
    real(8) :: cy
    real(8) :: cz
    real(8) :: rad

    dbnd = 1.0e10

    !A coeff of quadratic ray eq. 
    A_quad = u*u + v*v + w*w  ! units vectors u,v,w

    if (abs(A_quad) < 1e-9) return

    do i = 1, num_cells
       !cell x,y,z
       cx = cells(i)%x
       cy = cells(i)%y
       cz = cells(i)%z

       do r_idx = 1, 2
          if (r_idx == 1) then
             rad = cells(i)%r_nuc
          else
             rad = cells(i)%r_cyto
          end if

          !B coeff of ray sphere interaction
            B_quad = 2.0 * ( (x-cx)*u + (y-cy)*v + (z-cz)*w )

            !the C coeff
            C_quad = (x-cx)**2 + (y-cy)**2 + (z-cz)**2 - rad**2

            !det => B^2-4AC
            det = B_quad*B_quad - 4.0*A_quad*C_quad
            
            if (det >= 0.0) then

               !calc. intersection distance from solving quadratic eq.
               d1 = (-B_quad - sqrt(det)) / (2.0*A_quad)
                d2 = (-B_quad + sqrt(det)) / (2.0*A_quad)

                if (d1 > 1e-6 .and. d1 < dbnd) then
                   dbnd = d1
                   end if
                   if (d2 > 1e-6 .and. d2 < dbnd) then
                      dbnd = d2
                    end if
             end if

          end do

       end do

     end function dist_to_boundary

end module geometry_mod
