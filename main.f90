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
program ben
  use omp_lib
  use types_mod
  use input_mod
  use source_mod
  use tally_mod
  use transport_mod
  use cacplotter
  implicit none

  integer :: i
  integer :: c
  !integer :: ie_z
  type(Particle_vars) :: p_src
  real(8), allocatable :: h_dose_nuc(:)
  real(8), allocatable :: h_dose_cyto(:)
  real(8) :: mass_nuc
  real(8) z_val
  integer :: seed_size
  integer :: clock
  integer :: t_id
  integer, allocatable :: seed(:)





  call print_cyricalphacell_logo

  print *, "==============================================="
  print *, "      Cyric Alpha Cell (C.A.C) V1.0.0          "
  print *, "==============================================="
  print *, ">> OpenMP max CPU threads: ", omp_get_max_threads()

  call load_config()
  
  call init_tallies()


    !print*, num_cells
  
  if (max_tracks > 0) open(800, file=trim(out_dir)//'/tracks.dat', status='replace')

  print *, ">> RUNNING (", nps_total, " Alpha Histories) <<"

  !$omp parallel private(p_src, i, c, h_dose_nuc, h_dose_cyto, mass_nuc, z_val, t_id, clock, seed_size, seed) &
  !$omp reduction(+:dose_nuc, dose_cyto, dose_nuc_sq, dose_cyto_sq, hits_nuc, hits_cyto, spec_nuc, spec_cyto, &
  !$omp             let_hist_nuc, sum_z_nuc, sum_z2_nuc, hit_events_nuc)

  t_id = omp_get_thread_num()

  !$omp critical(rng_seed)

  call system_clock(count=clock)

  !$omp end critical(rng_seed)

  call random_seed(size=seed_size)

  allocate(seed(seed_size))

  seed = clock + 37 * (t_id + 1) * (/ (c, c = 1, seed_size) /)

  call random_seed(put=seed)

  deallocate(seed)

  allocate(h_dose_nuc(num_cells))
  allocate(h_dose_cyto(num_cells))

  !$omp do schedule(dynamic)
  do i = 1, nps_total
      h_dose_nuc = 0.0
      h_dose_cyto = 0.0
      
      call sample_source(p_src, i)  !sample source
      
      call transport_particle(p_src, h_dose_nuc, h_dose_cyto) !transport
      
      !end of history, microdose calc.
      do c = 1, num_cells
          if (h_dose_nuc(c) > 0.0) then

             dose_nuc(c) = dose_nuc(c) + h_dose_nuc(c)

             dose_nuc_sq(c) = dose_nuc_sq(c) + h_dose_nuc(c)**2

            hits_nuc(c) = hits_nuc(c) + 1
              
              !specific energy z calc.
              mass_nuc = (4.1887902 * cells(c)%r_nuc**3) * mat_rho / 1000.0 ! kg

              !print*, "mass: ", mass_nuc
              
              z_val = (h_dose_nuc(c) * 1.602e-13) / mass_nuc ! Gy
              
              sum_z_nuc(c) = sum_z_nuc(c) + z_val

              !sum_z2_nuc(c) = sum_z2_nuc(c) + z_val**2
              !hit_events_nuc(c) = hit_events_nuc(c) + 1
              !ie_z = int(z_val / dZ_bin) + 1
              !if (ie_z >= 1 .and. ie_z <= Z_BINS) then
               !  z_hist_nuc(ie_z, c) = z_hist_nuc(ie_z, c) + 1.0
              ! end if
              !end if

              sum_z2_nuc(c) = sum_z2_nuc(c) + z_val**2

              hit_events_nuc(c) = hit_events_nuc(c) + 1
              
          end if
          
          if (h_dose_cyto(c) > 0.0) then

             dose_cyto(c) = dose_cyto(c) + h_dose_cyto(c)

              dose_cyto_sq(c) = dose_cyto_sq(c) + h_dose_cyto(c)**2

              hits_cyto(c) = hits_cyto(c) + 1

           end if
      end do

      !$omp atomic
      completed_nps = completed_nps + 1
      if (mod(completed_nps, max(1, nps_total/10)) == 0) then
          !$omp critical(print_status)
          print *, int(100.0d0*real(completed_nps)/nps_total), "%"
          !$omp end critical(print_status)
      end if
  end do
  !$omp end do

  deallocate(h_dose_nuc, h_dose_cyto)
  !$omp end parallel
  
  if (max_tracks > 0) close(800)

  call write_tallies(nps_total)
  print *, "***** RUN DONE *****"


  if(SVG_PLOT_CHECK /= 0 .OR. RENDER_PLOT_CHECK /=0) call plot_results


  !pause
  
end program ben



subroutine print_cyricalphacell_logo()
  implicit none

  ! Define the escape character
  character, parameter :: ESC = char(27)
  
  ! Define color parameters
  character(len=*), parameter :: RST = ESC // "[0m"        ! reset
  character(len=*), parameter :: BOLD_CYAN = ESC // "[1;36m" ! cyan bold
  
  ! Print the colored ASCII art
  print *, BOLD_CYAN // "  ___        _       _    _      _          ___     _ _  " // RST
  print *, BOLD_CYAN // " / __|_  _ _(_)__   /_\  | |_ __| |_  __ _ / __|___| | | " // RST
  print *, BOLD_CYAN // "| (__| || | '_/ _| / _ \ | | '_ \ ' \/ _` | (__/ -_) | | " // RST
  print *, BOLD_CYAN // " \___|\_, |_| \__|/_/ \_\|_| .__/_||_\__,_|\___\___|_|_| " // RST
  print *, BOLD_CYAN // "      |__/                 |_|                           " // RST

end subroutine print_cyricalphacell_logo
