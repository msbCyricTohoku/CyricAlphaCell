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
  type(Particle_vars) :: p_src
  real(8), allocatable :: h_dose_nuc(:)
  real(8), allocatable :: h_dose_cyto(:)
  real(8) :: mass_nuc
  real(8) :: z_val
  integer :: clock
  integer :: t_id
  integer :: n_threads
  !integer :: hit_cells(500)
  integer, allocatable :: hit_cells(:)
  integer :: num_hits
  integer :: h_idx
  integer(8) :: rng_state
  real(8)    :: cached_g
  logical    :: has_g

  call print_cyricalphacell_logo
  print *, "==============================================="
  print *, "      Cyric Alpha Cell (C.A.C) V1.0.0          "
  print *, "==============================================="
  print *, ">> OpenMP max CPU threads: ", omp_get_max_threads()

  call load_config()
  call init_tallies()

  call system_clock(count=clock)
  n_threads = omp_get_max_threads() 
  
  if (max_tracks > 0) open(800, file=trim(out_dir)//'/tracks.dat', status='replace')

  print *, ">> RUNNING (", nps_total, " Alpha Histories) <<"

  !$omp parallel private(p_src, i, c, h_dose_nuc, h_dose_cyto, mass_nuc, &
  !$omp z_val, t_id, hit_cells, num_hits, h_idx, rng_state, cached_g, &
  !$omp has_g) &
  !$omp reduction(+:dose_nuc, dose_cyto, dose_nuc_sq, dose_cyto_sq, &
  !$omp hits_nuc, hits_cyto, sum_z_nuc, sum_z2_nuc, hit_events_nuc)
  
    t_id = omp_get_thread_num()

  !init the register vars locally
  rng_state = 13371337_8 + int(clock, 8) * int(t_id + 1, 8) * 99991_8
  !print*, rng_state
  !pause
  has_g = .false.
  cached_g = 0.0d0

  allocate(h_dose_nuc(num_cells))
  allocate(h_dose_cyto(num_cells))
  allocate(hit_cells(num_cells))
  h_dose_nuc = 0.0d0
  h_dose_cyto = 0.0d0

  !$omp do schedule(dynamic, 1000)
  do i = 1, nps_total
      
      num_hits = 0 
      
 call sample_source(p_src, i, rng_state) 
 call transport_particle(p_src, h_dose_nuc, h_dose_cyto, t_id, hit_cells, num_hits, rng_state, cached_g, has_g) 
      
     do h_idx = 1, num_hits
          c = hit_cells(h_idx)
          
          if (h_dose_nuc(c) > 0.0d0) then
             dose_nuc(c) = dose_nuc(c) + h_dose_nuc(c)
             dose_nuc_sq(c) = dose_nuc_sq(c) + h_dose_nuc(c)**2
             hits_nuc(c) = hits_nuc(c) + 1
              
             mass_nuc = (4.1887902d0 * cells_r_nuc(c)**3) * mat_rho / 1000.0d0
             z_val = (h_dose_nuc(c) * 1.602d-13) / mass_nuc 
              
             sum_z_nuc(c) = sum_z_nuc(c) + z_val
             sum_z2_nuc(c) = sum_z2_nuc(c) + z_val**2
             hit_events_nuc(c) = hit_events_nuc(c) + 1
              
             h_dose_nuc(c) = 0.0d0
          end if
          
          if (h_dose_cyto(c) > 0.0d0) then
             dose_cyto(c) = dose_cyto(c) + h_dose_cyto(c)
             dose_cyto_sq(c) = dose_cyto_sq(c) + h_dose_cyto(c)**2
             hits_cyto(c) = hits_cyto(c) + 1
             h_dose_cyto(c) = 0.0d0
           end if
      end do

      if (mod(i, max(1, nps_total/10)) == 0) then
          !$omp critical(print_status)
          print *, int(100.0d0 * real(i, 8) / real(nps_total, 8)), "%"
          !$omp end critical(print_status)
      end if
  end do
  !$omp end do

  !deallocate(h_dose_nuc, h_dose_cyto)
  deallocate(h_dose_nuc, h_dose_cyto, hit_cells)

  !$omp end parallel

  call gather_thread_tallies()

  if (max_tracks > 0) close(800)

  call write_tallies(nps_total)
  print *, "***** RUN DONE *****"

  if(SVG_PLOT_CHECK /= 0 .OR. RENDER_PLOT_CHECK /=0) call plot_results

end program ben

subroutine print_cyricalphacell_logo()
  implicit none
  character, parameter :: ESC = char(27)
  character(len=*), parameter :: RST = ESC // "[0m"        !reset
  character(len=*), parameter :: BOLD_CYAN = ESC // "[1;36m" !cyan bold
  
  print *, BOLD_CYAN // "  ___        _       _    _      _          ___     _ _  " // RST
  print *, BOLD_CYAN // " / __|_  _ _(_)__   /_\  | |_ __| |_  __ _ / __|___| | | " // RST
  print *, BOLD_CYAN // "| (__| || | '_/ _| / _ \ | | '_ \ ' \/ _` | (__/ -_) | | " // RST
  print *, BOLD_CYAN // " \___|\_, |_| \__|/_/ \_\|_| .__/_||_\__,_|\___\___|_|_| " // RST
  print *, BOLD_CYAN // "      |__/                 |_|                           " // RST

end subroutine print_cyricalphacell_logo
