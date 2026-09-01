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
module transport_mod
    use types_mod
    use geometry_mod
    use physics_mod
    use tally_mod
    implicit none
    
contains

  subroutine transport_particle(p, h_dose_nuc, h_dose_cyto)
    type(Particle_vars), intent(inout) :: p
    real(8), intent(inout) :: h_dose_nuc(:)
    real(8), intent(inout) :: h_dose_cyto(:)
    integer :: c_id
    integer :: region
    integer :: idx1
    real(8) :: ds
    real(8) :: dbnd
    real(8) :: stp_mean
    real(8) :: dE_mean
    real(8) :: dE
    real(8) :: E_keV
    real(8) f_interp
    real(8) :: E_mid
    real(8) :: ds_max
    real(8) :: stp_1
    real(8) :: stp_limit

    if (p%record) then
        !$omp critical(trackio)
        write(800, *) ""
        !$omp end critical(trackio)
    end if
    
    do while (p%E > e_cut)
       if (p%record) then
           !$omp critical(trackio)
           write(800, '(I8, I4, I4, 4E15.6)') p%parent_id, p%gen, p%ptype, p%x, p%y, p%z, p%E
           !$omp end critical(trackio)
        end if

        !print*, p%u,p%v,p%w
        !pause
       
       call get_cell_location(p%x, p%y, p%z, c_id, region) !get the cell location in geom.f90
       
       dbnd = dist_to_boundary(p%x, p%y, p%z, p%u, p%v, p%w)
       
       E_keV = p%E * 1000.0 !convert E to keV

       !print*, p%E
       !pause

       !linear interpolattion grid
       idx1 = min(max(int(E_keV), 1), E_GRID_MAX - 1)
       f_interp = E_keV - real(idx1)
       
       !print*, f_interp
       !pause

       !stopping power linear interpolatoion
       stp_1 = (1.0 - f_interp) * stp_a(idx1) + f_interp * stp_a(idx1+1)  !stp interpolated

       !max travel distance
       ds_max = min(global_ds, dbnd + 1.0e-5)

       stp_limit = max(0.0001, 0.05 * p%E / max(stp_1, 1.0e-6))

       if (ds_max > stp_limit) then
          ds_max = stp_limit
          end if

       ds = ds_max

       !midpoint energy, getting a more precise value
       E_mid = max(e_cut, p%E - (stp_1 * ds * 0.5))

       E_keV = E_mid * 1000.0

       !print*, E_kev
       !pause

       !linear interpolation here
       idx1 = min(max(int(E_keV), 1), E_GRID_MAX - 1)
       f_interp = E_keV - real(idx1, kind=8)

       f_interp = MAX(E_keV, 1.0) - real(idx1, kind=8) !this is to avoid alpha E fall below 1 keV

       stp_mean = (1.0 - f_interp) * stp_a(idx1) + f_interp * stp_a(idx1+1)

       !energy loss within modelling domain
       dE_mean = stp_mean * ds

       if (use_straggling == 1) then
           call sample_straggling(dE_mean, ds, mat_Z_eff, mat_A_eff, mat_rho, dE)
        else
           dE = dE_mean
        end if
       
          if (dE >= p%E) then
             if (dE > 1.0e-12) then
                ds = ds * (p%E / dE)
                dE = p%E
             end if
          end if
       
       !score arrays and LET spectra
       if (c_id > 0 .and. c_id <= num_cells) then

          if (region == 1) then
             h_dose_nuc(c_id) = h_dose_nuc(c_id) + dE

             if (ds > 0.0d0 .and. stp_mean > 0.0d0) then
                 call score_micro_domain(c_id, stp_mean, ds)
             end if
          end if
          

             if (region == 2) then
                h_dose_cyto(c_id) = h_dose_cyto(c_id) + dE
             end if
             
           call score_tally(c_id, region, dE, ds, p%E - dE/2.0, stp_mean)

        end if

        !updating E and location of particle type
       p%E = p%E - dE
       p%x = p%x + p%u * ds
       p%y = p%y + p%v * ds
       p%z = p%z + p%w * ds
    end do
    
    if (p%E > 0.0 .and. c_id > 0 .and. c_id <= num_cells) then
       if (region == 1) then
          h_dose_nuc(c_id) = h_dose_nuc(c_id) + p%E
    end if
    if (region == 2) then
       h_dose_cyto(c_id) = h_dose_cyto(c_id) + p%E
 end if

 call score_tally(c_id, region, p%E, 0.0d0, p%E, stp_mean)
 
    end if

  end subroutine transport_particle

end module transport_mod
