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
module tally_mod
  use types_mod
  use physics_mod   !micro-domain straggling
  implicit none

  real(8) :: dE_bin
  real(8) :: dZ_bin
  real(8) :: dLET_bin
  real(8), allocatable :: dose_nuc(:)
  real(8), allocatable :: dose_cyto(:)
  real(8), allocatable :: dose_nuc_sq(:)
  real(8), allocatable :: dose_cyto_sq(:)
  integer, allocatable :: hits_nuc(:)
  integer, allocatable :: hits_cyto(:)
  real(8), allocatable :: spec_nuc(:,:)
  real(8), allocatable :: spec_cyto(:,:)
  !macro microdosimetry tallies
  real(8), allocatable :: let_hist_nuc(:,:)
  real(8), allocatable :: sum_z_nuc(:)
  real(8), allocatable :: sum_z2_nuc(:)
  integer, allocatable :: hit_events_nuc(:)
  !micro-domain MKM tallies for f1(z)
  real(8), allocatable :: mkm_z_hist(:,:)
  real(8), allocatable :: mkm_hit_events(:)
  !OPTIMIZATION: local thread arrays
  integer :: max_threads
  real(8), allocatable :: t_spec_nuc(:,:,:)
  real(8), allocatable :: t_spec_cyto(:,:,:)
  real(8), allocatable :: t_let_hist_nuc(:,:,:)
  real(8), allocatable :: t_mkm_z_hist(:,:,:)
  real(8), allocatable :: t_mkm_hit_events(:,:)

contains

  subroutine init_tallies()
    allocate(dose_nuc(num_cells))
    dose_nuc = 0.0d0
    allocate(dose_cyto(num_cells))
    dose_cyto = 0.0d0
    allocate(dose_nuc_sq(num_cells))
    dose_nuc_sq = 0.0d0
    allocate(dose_cyto_sq(num_cells))
    dose_cyto_sq = 0.0d0
    allocate(hits_nuc(num_cells))
    hits_nuc = 0
    allocate(hits_cyto(num_cells))
    hits_cyto = 0
    allocate(spec_nuc(NUM_EBINS, num_cells))
    spec_nuc = 0.0d0
    allocate(spec_cyto(NUM_EBINS, num_cells))
    spec_cyto = 0.0d0
    allocate(let_hist_nuc(LET_BINS, num_cells))
    let_hist_nuc = 0.0d0
    allocate(sum_z_nuc(num_cells))
    sum_z_nuc = 0.0d0
    allocate(sum_z2_nuc(num_cells))
    sum_z2_nuc = 0.0d0
    allocate(hit_events_nuc(num_cells))
    hit_events_nuc = 0
    !init
    allocate(mkm_z_hist(Z_BINS, num_cells))
    mkm_z_hist = 0.0d0
    allocate(mkm_hit_events(num_cells))
    mkm_hit_events = 0.0d0
    
    dE_bin = (src_E0 * 1.1d0) / real(NUM_EBINS, 8)
    dZ_bin = Z_MAX_GY / real(Z_BINS, 8)
    dLET_bin = LET_MAX_KEV / real(LET_BINS, 8)

    !allocate thread local arrays
    max_threads = omp_get_max_threads()
    allocate(t_spec_nuc(NUM_EBINS, num_cells, 0:max_threads-1))
    t_spec_nuc = 0.0d0
    allocate(t_spec_cyto(NUM_EBINS, num_cells, 0:max_threads-1))
    t_spec_cyto = 0.0d0
    allocate(t_let_hist_nuc(LET_BINS, num_cells, 0:max_threads-1))
    t_let_hist_nuc = 0.0d0
    allocate(t_mkm_z_hist(Z_BINS, num_cells, 0:max_threads-1))
    t_mkm_z_hist = 0.0d0
    allocate(t_mkm_hit_events(num_cells, 0:max_threads-1))
    t_mkm_hit_events = 0.0d0

  end subroutine init_tallies
  !********************************************************
  
  !this is for optimization
  subroutine gather_thread_tallies()
    integer :: t
    do t = 0, max_threads - 1
       spec_nuc = spec_nuc + t_spec_nuc(:,:,t)
       spec_cyto = spec_cyto + t_spec_cyto(:,:,t)
       let_hist_nuc = let_hist_nuc + t_let_hist_nuc(:,:,t)
       mkm_z_hist = mkm_z_hist + t_mkm_z_hist(:,:,t)
       mkm_hit_events = mkm_hit_events + t_mkm_hit_events(:,t)
    end do
  end subroutine gather_thread_tallies
  !****************************************************

  !function to claculate relative error and return as real8
  !initially i used real4
  real(8) function calc_rel_error(s1, s2, n)
    real(8), intent(in) :: s1 
    real(8), intent(in) :: s2
    integer, intent(in) :: n
    real(8) :: var
    if (n <= 1 .or. s1 <= 0.0d0) then
       calc_rel_error = 0.0d0
       return
    end if
    var = (s2 - (s1**2)/real(n, 8)) / real(n-1, 8)
    if (var < 0.0d0) var = 0.0d0
    calc_rel_error = sqrt(var / real(n, 8)) / (s1 / real(n, 8))
  end function calc_rel_error
  !************************************************

  subroutine score_tally(c_id, region, dE, ds, E_kin, let_val, t_id)
    integer, intent(in) :: c_id
    integer, intent(in) :: region
    real(8), intent(in) :: dE 
    real(8), intent(in) :: ds
    real(8), intent(in) :: E_kin
    real(8), intent(in) :: let_val
    integer, intent(in) :: t_id
    integer :: ie, ie_let
    real(8) :: let_kev_um

    if (c_id < 1 .or. c_id > num_cells) return

    if (region == 1 .and. dE > 0.0d0 .and. let_val > 0.0d0) then
        let_kev_um = let_val * 0.1d0 
        ie_let = int(let_kev_um / dLET_bin) + 1
        if (ie_let >= 1 .and. ie_let <= LET_BINS) then
            t_let_hist_nuc(ie_let, c_id, t_id) = t_let_hist_nuc(ie_let, c_id, t_id) + dE
        end if
    end if

    ie = int(E_kin / dE_bin) + 1
    if (ds > 0.0d0 .and. ie >= 1 .and. ie <= NUM_EBINS) then
        if (region == 1) t_spec_nuc(ie, c_id, t_id) = t_spec_nuc(ie, c_id, t_id) + ds
        if (region == 2) t_spec_cyto(ie, c_id, t_id) = t_spec_cyto(ie, c_id, t_id) + ds
    end if
  end subroutine score_tally
  !*******************************************************

  !micro-domain sampling
  !added rng_state, cached_g, has_g
  subroutine score_micro_domain(c_id, let_val, ds, t_id, rng_state, cached_g, has_g)
    integer, intent(in) :: c_id
    real(8), intent(in) :: let_val, ds
    integer, intent(in) :: t_id
    integer(8), intent(inout) :: rng_state
    real(8), intent(inout)    :: cached_g
    logical, intent(inout)    :: has_g
    real(8) :: d_cm
    real(8) :: r_d
    real(8) :: m_d
    real(8) :: l_chord
    real(8) :: eps_mean
    real(8) :: eps_actual
    real(8) :: z_val
    real(8) :: u
    integer :: ie_z
    real(8), parameter :: PI = 3.14159265358979323846d0

    if (c_id < 1 .or. c_id > num_cells) return

    d_cm = bio_domain_d * 1.0d-4
    r_d = d_cm / 2.0d0
    m_d = (4.0d0 / 3.0d0) * PI * (r_d**3) * mat_rho / 1000.0d0 

    u = rand_dbl(rng_state)

    l_chord = d_cm * sqrt(max(u, 1.0d-12))
    eps_mean = let_val * l_chord 

    if (use_straggling == 1) then
        call sample_straggling(eps_mean, l_chord, mat_Z_eff, mat_A_eff, mat_rho, eps_actual, rng_state, cached_g, has_g)
    else
        eps_actual = eps_mean
    end if

    if (eps_actual > 0.0d0) then
        z_val = (eps_actual * 1.602d-13) / m_d
        ie_z = int(z_val / dZ_bin) + 1
        
        if (ie_z >= 1 .and. ie_z <= Z_BINS) then
            t_mkm_z_hist(ie_z, c_id, t_id) = t_mkm_z_hist(ie_z, c_id, t_id) + ds
        end if
        t_mkm_hit_events(c_id, t_id) = t_mkm_hit_events(c_id, t_id) + ds
    end if
  end subroutine score_micro_domain
!*******************************************************
  
  
  subroutine write_tallies(nps)
    integer, intent(in) :: nps
    integer :: i
    integer :: j
    real(8) :: vol_nuc
    real(8) ::vol_cyto
    real(8) ::mass_nuc
    real(8) ::mass_cyto
    real(8) :: zF
    real(8) ::zD
    real(8) ::let_D
    real(8) ::sum_let_dose
    real(8) :: lambda
    real(8) :: p0
    real(8) :: surv
    real(8) :: rbe
    real(8) :: D_target
    real(8) :: D_xray
    real(8) :: det
    real(8) :: alpha_x
    real(8) :: beta_x
    real(8) :: alpha_alpha
    real(8) :: z0
    real(8) :: zD_star
    
    alpha_x = bio_alpha_x       
    beta_x  = bio_beta_x        
    D_target = bio_target_dose  

    open(90, file=trim(out_dir)//'/cellular_dosimetry.dat', status='replace')
    write(90, '(A)') "# Cell_ID  Nuc_Dose(Gy)  Nuc_Err(Frac) Cyto_Dose(Gy) Cyto_Err(Frac) Nuc_Trks Cyto_Trks"
    do i = 1, num_cells
        vol_nuc  = 4.1887902d0 * (cells_r_nuc(i)**3)
        vol_cyto = 4.1887902d0 * (cells_r_cyto(i)**3) - vol_nuc

        mass_nuc  = vol_nuc * mat_rho / 1000.0d0   
        mass_cyto = vol_cyto * mat_rho / 1000.0d0  
        
        write(90, '(I8, 4ES14.5, 2I10)') i, &
            (dose_nuc(i) * 1.602d-13) / mass_nuc / real(nps, 8), &
            calc_rel_error(dose_nuc(i), dose_nuc_sq(i), nps), &
            (dose_cyto(i) * 1.602d-13) / mass_cyto / real(nps, 8), &
            calc_rel_error(dose_cyto(i), dose_cyto_sq(i), nps), &
            hits_nuc(i), hits_cyto(i)
    end do
    close(90)

    !########################### cellular dose file ends here ######################
    open(91, file=trim(out_dir)//'/radiobiology_rbe.dat', status='replace')
    write(91, '("# Target Dose = ", F5.2, " Gy | Baseline X-ray: a=", F6.3, ", b=", F6.3)') bio_target_dose, bio_alpha_x, bio_beta_x
    write(91, '(A)') "# Cell_ID  z_F(Gy)      z_D(Gy)      LET_D(keV/um) Mean_Hits(at_2Gy) Prob_0_Hits  Surv_Frac  RBE"
    do i = 1, num_cells
        if (hit_events_nuc(i) > 0) then
            zF = sum_z_nuc(i) / real(hit_events_nuc(i), 8)
            let_D = 0.0d0; sum_let_dose = 0.0d0
            do j = 1, LET_BINS
                if (let_hist_nuc(j, i) > 0.0d0) then
                    let_D = let_D + ((real(j,8)-0.5d0)*dLET_bin) * let_hist_nuc(j, i)
                    sum_let_dose = sum_let_dose + let_hist_nuc(j, i)
                end if
            end do

            if (sum_let_dose > 0.0d0) then
               let_D = let_D / sum_let_dose
            else
               let_D = 0.0d0
            end if
            
            if (zF > 0.0d0) then
                lambda = D_target / zF
                p0 = exp(-lambda)
            else
                lambda = 0.0d0; p0 = 1.0d0
            end if
            
            if (let_D > 0.0d0) then
                 zD = (0.204d0 * let_D) / (bio_domain_d**2) 
             end if
             
             z0 = (0.204d0 * 150.0d0) / (bio_domain_d**2)
             if (zD > 0.0d0) then
                 zD_star = (z0**2 / zD) * (1.0d0 - exp(-(zD**2) / z0**2))
             else
                 zD_star = 0.0d0
             end if
             
             alpha_alpha = alpha_x + beta_x * zD_star
             surv = exp(-alpha_alpha * D_target - beta_x * D_target**2)

            det = alpha_x**2 - 4.0d0 * beta_x * log(max(surv, 1.0d-30))
            if (det >= 0.0d0) then
                D_xray = (-alpha_x + sqrt(det)) / (2.0d0 * beta_x)
                rbe = D_xray / D_target
            else
                rbe = 1.0d0
            end if
            write(91, '(I8, 7ES13.4)') i, zF, zD, let_D, lambda, p0, surv, rbe
        end if
    end do
    close(91)
    !########################### radiobio rbe file ends here ######################
    
    !analytical micro domain spectra directly
    open(92, file=trim(out_dir)//'/microdosimetry_z_spectra.dat', status='replace')
    write(92, '(A)') "# Specific Energy Distribution f1(z) for MKM Micro-Domain"
    write(92, '(A, F6.3, A)') "# Dynamic Target Diameter: ", bio_domain_d, " um"
    write(92, '(A)') "# z(Gy)    Cell_1_Prob  Cell_2_Prob  Cell_3_Prob ..."
    do j = 1, Z_BINS
        write(92, '(ES12.4)', advance='no') (real(j,8)-0.5d0)*dZ_bin
        do i = 1, num_cells
            if (mkm_hit_events(i) > 0.0d0) then
                write(92, '(ES14.5)', advance='no') mkm_z_hist(j, i) / mkm_hit_events(i)
            else
                write(92, '(ES14.5)', advance='no') 0.0d0
            end if
        end do
        write(92, *) ""
    end do
    close(92)
    !########################### microdose z spectra file ends here ######################
    
    
    open(93, file=trim(out_dir)//'/let_spectra.dat', status='replace')
    write(93, '(A)') "# Dose-Averaged LET Spectrum (L_D)"
    write(93, '(A)') "# LET(keV/um)  Cell_1_Dose  Cell_2_Dose  Cell_3_Dose ..."
    do j = 1, LET_BINS
        write(93, '(ES12.4)', advance='no') (real(j,8)-0.5d0)*dLET_bin
        do i = 1, num_cells
            write(93, '(ES14.5)', advance='no') let_hist_nuc(j, i) / (dLET_bin * real(nps, 8))
        end do
        write(93, *) ""
    end do
    close(93)
    !########################### let spectra file ends here ######################
      
    print*, ">> microdosimetry results generated in: ", trim(out_dir)
  end subroutine write_tallies
  
end module tally_mod
