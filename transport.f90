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
module transport_mod
    use types_mod
    use geometry_mod
    use physics_mod
    use tally_mod
    implicit none
    
contains

  !heavily optimized version
  subroutine transport_particle(p, h_dose_nuc, h_dose_cyto, t_id, hit_cells, num_hits, rng_state, cached_g, has_g)
    type(Particle_vars), intent(inout) :: p
    real(8), intent(inout) :: h_dose_nuc(:)
    real(8), intent(inout) :: h_dose_cyto(:)
    integer, intent(in) :: t_id
    integer, intent(inout) :: hit_cells(:)
    integer, intent(inout) :: num_hits
    integer(8), intent(inout) :: rng_state
    real(8), intent(inout)    :: cached_g
    logical, intent(inout)    :: has_g
    integer :: c_id
    integer :: region
    integer :: idx1
    real(8) :: ds
    real(8) ::  dbnd
    real(8) ::  stp_mean
    real(8) ::  dE_mean
    real(8) ::  dE
    real(8) ::  E_keV
    real(8) :: f_interp
    real(8) ::  E_mid
    real(8) ::  ds_max
    real(8) ::  stp_1
    real(8) ::  stp_limit
   
    !vars for inline straggling
    real(8) :: u1
    real(8) ::  u2
    real(8) ::  g
    real(8) ::  var_bohr
    real(8) ::  std_bohr
    real(8) ::  m
    real(8) ::  s
    real(8) :: v1
    real(8) ::  v2
    real(8) ::  w_sq
    real(8) ::  mult

    if (p%record) then
        !$omp critical(trackio)
        write(800, *) ""
        !$omp end critical(trackio)
    end if
    
    c_id = 0

    stp_mean = 0.d0;
    
    do while (p%E > e_cut)
       if (p%record) then
           !$omp critical(trackio)
           write(800, '(I8, I4, I4, 4E15.6)') p%parent_id, p%gen, p%ptype, p%x, p%y, p%z, p%E
           !$omp end critical(trackio)
        end if
       
       call get_cell_location(p%x, p%y, p%z, c_id, region)
       dbnd = dist_to_boundary(p%x, p%y, p%z, p%u, p%v, p%w)
       E_keV = p%E * 1000.0d0 

       idx1 = min(max(int(E_keV), 1), E_GRID_MAX - 1)
       f_interp = E_keV - real(idx1, 8)
       
       stp_1 = (1.0d0 - f_interp) * stp_a(idx1) + f_interp * stp_a(idx1+1)  

       !ds_max = min(global_ds, dbnd + 1.0e-5_8)
       ds_max = min(global_ds, dbnd + 1.0d-8)
       
       stp_limit = max(1.0d-6, 0.05d0 * p%E / max(stp_1, 1.0e-6_8))

       if (ds_max > stp_limit) then
          ds_max = stp_limit
       end if
       ds = ds_max

       E_mid = max(e_cut, p%E - (stp_1 * ds * 0.5d0))
       E_keV = E_mid * 1000.0d0

       idx1 = min(max(int(E_keV), 1), E_GRID_MAX - 1)
       f_interp = MAX(E_keV, 1.0d0) - real(idx1, 8) 
       stp_mean = (1.0d0 - f_interp) * stp_a(idx1) + f_interp * stp_a(idx1+1)

       dE_mean = stp_mean * ds
!---------------------------------------
       !inline straggling -- it is much more optimized
       if (use_straggling == 1) then

          !4.pi.Z1^2.Z_2.e^4.N.x   <--- Bohr straggling formula implemented here
          var_bohr = 0.6276d0 * (mat_Z_eff / mat_A_eff) * mat_rho * ds

          std_bohr = sqrt(max(1.0e-12_8, var_bohr))

          std_bohr = min(std_bohr, dE_mean * 0.4d0)

           if (dE_mean <= 1.0e-12_8) then
              dE = 0.0d0
           else
               if (has_g) then
                   g = cached_g
                   has_g = .false.
               else
                   do
                       u1 = rand_dbl(rng_state)
                       u2 = rand_dbl(rng_state)
                       v1 = 2.0d0 * u1 - 1.0d0
                       v2 = 2.0d0 * u2 - 1.0d0
                       
                       w_sq = v1*v1 + v2*v2

                       if (w_sq < 1.0d0 .and. w_sq > 1.0e-12_8) exit


                    end do

                    mult = sqrt(-2.0d0 * log(w_sq) / w_sq)

                    g = v1 * mult

                    cached_g = v2 * mult
                   has_g = .true.

                end if

                !there was a bug here, the fix belw
                !s = sqrt(log(1.0d0 + (std_bohr / (dE_mean*dE_mean))))
                s = sqrt(log(1.0d0 + (std_bohr / dE_mean)**2))

               m = log(dE_mean) - 0.5d0 * s*s

               !m is mean, s is std., g rand var.
               dE = exp(m + s * g) 

            end if
        else
           dE = dE_mean
        end if
!--------------------------------------------
       
        if (dE >= p%E) then
           if (dE > 1.0e-12_8) then
              ds = ds * (p%E / dE)
              dE = p%E
           end if
        end if

        !score arrays and LET spectra
       if (c_id > 0 .and. c_id <= num_cells .and. dE > 0.0d0) then

          if (h_dose_nuc(c_id) == 0.0d0 .and. h_dose_cyto(c_id) == 0.0d0) then
              num_hits = num_hits + 1
              hit_cells(num_hits) = c_id
          end if

          if (region == 1) then
             h_dose_nuc(c_id) = h_dose_nuc(c_id) + dE
             
             if (ds > 0.0d0 .and. stp_mean > 0.0d0) then
                 call score_micro_domain(c_id, stp_mean, ds, t_id, rng_state, cached_g, has_g)
             end if

          end if
          
          if (region == 2) then
             h_dose_cyto(c_id) = h_dose_cyto(c_id) + dE
          end if
             
          call score_tally(c_id, region, dE, ds, p%E - dE/2.0d0, stp_mean, t_id)
       end if

       !updating E and location of particle type
       p%E = p%E - dE
       p%x = p%x + p%u * ds
       p%y = p%y + p%v * ds
       p%z = p%z + p%w * ds
    end do
    !---------------------------------------
    
    !if (p%E > 0.0d0 .and. c_id > 0 .and. c_id <= num_cells) then
    if (p%E > 0.0d0) then
       call get_cell_location(p%x, p%y, p%z, c_id, region)
       if (c_id > 0 .and. c_id <= num_cells) then
       if (h_dose_nuc(c_id) == 0.0d0 .and. h_dose_cyto(c_id) == 0.0d0) then
          
           num_hits = num_hits + 1
           hit_cells(num_hits) = c_id

        end if

       if (region == 1) then
          h_dose_nuc(c_id) = h_dose_nuc(c_id) + p%E
       end if

       if (region == 2) then
          h_dose_cyto(c_id) = h_dose_cyto(c_id) + p%E
       end if

       call score_tally(c_id, region, p%E, 0.0d0, p%E, stp_mean, t_id)
       
    end if
    end if
    
!---------------------------------------
    
  end subroutine transport_particle

end module transport_mod
