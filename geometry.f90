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
module geometry_mod
  use types_mod
  implicit none
  
contains
  
  subroutine get_cell_location(x, y, z, c_id, region)
    real(8), intent(in) :: x, y, z
    integer, intent(inout) :: c_id
    integer, intent(out) :: region ! 1 = Nuc, 2 = Cyto, 0 = Out
    integer :: i
    real(8) :: d2

    !temporal coherence
    if (c_id > 0 .and. c_id <= num_cells) then
       
       !euclidean dist from point x,y,z to cell center
        d2 = (x - cells_x(c_id))**2 + (y - cells_y(c_id))**2 + (z - cells_z(c_id))**2

        if (d2 <= cells_r_cyto_sq(c_id)) then

           if (d2 <= cells_r_nuc_sq(c_id)) then

              region = 1

           else

              region = 2

           end if

           return

        end if
    end if

    c_id = 0
    region = 0

    do i = 1, num_cells

       !the distance calc.
       d2 = (x - cells_x(i))**2 + (y - cells_y(i))**2 + (z - cells_z(i))**2

        if (d2 <= cells_r_cyto_sq(i)) then
          if (d2 <= cells_r_nuc_sq(i)) then
             region = 1
          else
             region = 2
          end if
          c_id = i
          return
       end if
            !else will be outside ID = 0 from init time
     end do
   end subroutine get_cell_location

   !calc distance from x,y,z along trajectory direction vector
   !this is the optimized version
   !from perf report i noticed the prev. version had large overhead
   !this version is highly optimized, i kept the old version commented below this function
   pure function dist_to_boundary(x, y, z, u, v, w) result(dbnd)
    real(8), intent(in) :: x
 real(8), intent(in) :: y
 real(8), intent(in) :: z
 real(8), intent(in) :: u
 real(8), intent(in) :: v
 real(8), intent(in) :: w
    real(8) :: dbnd
    integer :: i
    real(8) :: cx
 real(8) ::  cy
 real(8) ::  cz
 real(8) ::  dx
 real(8) ::  dy
 real(8) ::  dz
    real(8) :: H_A
 real(8) ::  C_quad_A
 real(8) ::  det_A
 real(8) ::  sqrt_det_A
    real(8) :: dist_sq
 real(8) ::  rad_cyto_sq
 real(8) ::  rad_sq
 real(8) ::  d1
 real(8) ::  d2
    
    !reg caching via associate
    !global arrays will NOT change during this loop
    !compiler now load the arrays into L1/regs once
    associate ( &
        nx => cells_x, &
        ny => cells_y, &
        nz => cells_z, &
        nrc => cells_r_cyto, &
        nrc_sq => cells_r_cyto_sq, &
        nrn_sq => cells_r_nuc_sq &
    )

    dbnd = 1.0e10
    
    do i = 1, num_cells
       cx = nx(i)
       cy = ny(i)
       cz = nz(i)

       dx = x-cx
       dy = y-cy
       dz = z-cz

       H_A = dx*u + dy*v + dz*w
       
       !skip if the bounding sphere is strictly further away
       if (-H_A - nrc(i) > dbnd) cycle

       dist_sq = dx*dx + dy*dy + dz*dz
       rad_cyto_sq = nrc_sq(i)
       
       !skip if cell is behind the ray origin
       if (H_A > 0.0d0 .and. dist_sq > rad_cyto_sq) cycle

       !process cytoplasm ---
       C_quad_A = dist_sq - rad_cyto_sq
       det_A = H_A*H_A - C_quad_A
         
       if (det_A >= 0.0d0) then
           sqrt_det_A = sqrt(det_A)
           d1 = -H_A - sqrt_det_A
           d2 = -H_A + sqrt_det_A

           if (d1 > 1.0e-6 .and. d1 < dbnd) then
              dbnd = d1
           else if (d2 > 1.0e-6 .and. d2 < dbnd) then
              dbnd = d2
           end if
             
           !process nuc ONLY if hit cyto
           rad_sq = nrn_sq(i)
             
           C_quad_A = dist_sq - rad_sq
           det_A = H_A*H_A - C_quad_A
             
           if (det_A >= 0.0d0) then
               sqrt_det_A = sqrt(det_A)
               d1 = -H_A - sqrt_det_A
               d2 = -H_A + sqrt_det_A

               if (d1 > 1.0e-6 .and. d1 < dbnd) then
                  dbnd = d1
               else if (d2 > 1.0e-6 .and. d2 < dbnd) then
                  dbnd = d2
               end if
           end if
       end if
    end do
    
    end associate
  end function dist_to_boundary


  !old function -- not optimized
!    pure function dist_to_boundary(x, y, z, u, v, w) result(dbnd)
!    real(8), intent(in) :: x
!    real(8), intent(in) :: y
!    real(8), intent(in) :: z
!    real(8), intent(in) :: u
!    real(8), intent(in) :: v
!    real(8), intent(in) :: w
!    real(8) :: dbnd
!    integer :: i
!    integer :: r_idx
!    real(8) :: A_quad
!    real(8) :: B_quad
!    real(8) :: C_quad
!    real(8) :: det
!    real(8) :: d1
!    real(8) :: d2
!    real(8) :: cx
!    real(8) :: cy
!    real(8) :: cz
    ! real(8) :: rad

    ! dbnd = 1.0e10
    ! !A coeff of quadratic ray eq. 
    ! A_quad = u*u + v*v + w*w  ! units vectors u,v,w
    ! if (abs(A_quad) < 1e-9) return
    ! do i = 1, num_cells
    !    !cell x,y,z
    !    cx = cells(i)%x
    !    cy = cells(i)%y
    !    cz = cells(i)%z
    !    do r_idx = 1, 2
    !       if (r_idx == 1) then
    !          rad = cells(i)%r_nuc
    !       else
    !          rad = cells(i)%r_cyto
    !       end if
    !       !B coeff of ray sphere interaction
    !         B_quad = 2.0 * ( (x-cx)*u + (y-cy)*v + (z-cz)*w )
    !         !the C coeff
    !         C_quad = (x-cx)**2 + (y-cy)**2 + (z-cz)**2 - rad**2
    !         !det => B^2-4AC
    !         det = B_quad*B_quad - 4.0*A_quad*C_quad
    !         if (det >= 0.0) then
    !            !calc. intersection distance from solving quadratic eq.
    !            d1 = (-B_quad - sqrt(det)) / (2.0*A_quad)
    !             d2 = (-B_quad + sqrt(det)) / (2.0*A_quad)

    !             if (d1 > 1e-6 .and. d1 < dbnd) then
    !                dbnd = d1
    !                end if
    !                if (d2 > 1e-6 .and. d2 < dbnd) then
    !                   dbnd = d2
    !                 end if
    !          end if
    !       end do
    !    end do
    !  end function dist_to_boundary

  

end module geometry_mod
