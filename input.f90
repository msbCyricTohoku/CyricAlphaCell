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
module input_mod
  use types_mod
  implicit none

contains

  subroutine load_config()
    character(len=256) :: line
    integer :: i
    real(8) :: cum_prob
    character(len=256) :: arg1
    integer :: num_args

    character(len=*), parameter :: ESC = achar(27)
    character(len=*), parameter :: RST = ESC // "[0m"      !reset
    
    character(len=*), parameter :: RED = ESC // "[31m"      !red
    character(len=*), parameter :: GREEN = ESC // "[32m"    !greeb
    character(len=*), parameter :: BLUE = ESC // "[34m"     !blue
    character(len=*), parameter :: BOLD_CYAN = ESC // "[1;36m" !cyan bold

    print *, "--- Reading Input Script ---"

    
    num_args = command_argument_count()

    if (num_args >= 1) then
    
        call get_command_argument(1, arg1)
        print '(2A)', BOLD_CYAN // "Running: ", trim(arg1) // RST
     else
        print*,  " "
        print*,  " "
        
        print '(A)', RED // "No input script provided." // RST

        print*,  " "
        print*,  " "
     end if

     open(105, file=arg1, status='old', action='read')

    
    !print*, line
    call read_next_valid_line(105, line)
    !PRINT*, line
    read(line, *) nps_total 
    !print*, nps_total
    !pause
    
    call read_next_valid_line(105, line)
    read(line, *) global_ds
    !call print_user_inps(line)

    call read_next_valid_line(105, line)
    read(line, *) e_cut
    !call print_user_inps(line)

    call read_next_valid_line(105, line)
    read(line, *) use_straggling
    !call print_user_inps(line)
    

    call read_next_valid_line(105, line)
    read(line, *) max_tracks
    !call print_user_inps(line)

    call read_next_valid_line(105, line)
    out_dir = trim(adjustl(line))
    !call print_user_inps(line)

    call execute_command_line("mkdir -p " // trim(out_dir)) !for windows release change

    !call read_next_valid_line(105, line)
    !read(line, *) src_mode
    !call read_next_valid_line(105, line)
    !read(line, *) src_E0
    !call read_next_valid_line(105, line)
    !read(line, *) src_x, src_y, src_z
    !call read_next_valid_line(105, line)
    !dedx_file = trim(adjustl(line))


    call read_next_valid_line(105, line)
    read(line, *) src_mode

    call read_next_valid_line(105, line)
    read(line, *) src_E0

    call read_next_valid_line(105, line)
    read(line, *) src_x, src_y, src_z

    call read_next_valid_line(105, line)
    dedx_file = trim(adjustl(line))

    call read_next_valid_line(105, line)
    read(line, *) mat_rho

    !print*, mat_rho
    
    call read_next_valid_line(105, line)
    read(line, *) mat_Z_eff

    !print*, mat_Z_eff

    call read_next_valid_line(105, line)
    read(line, *) mat_A_eff

    !print*, mat_A_eff

    call read_next_valid_line(105, line)
    read(line, *) bio_domain_d

    call read_next_valid_line(105, line)
    read(line, *) bio_target_dose

    call read_next_valid_line(105, line)
    read(line, *) bio_alpha_x

    call read_next_valid_line(105, line)
    read(line, *) bio_beta_x

    call read_next_valid_line(105, line)
    read(line, *) SVG_PLOT_CHECK

    call read_next_valid_line(105, line)
    read(line, *) RENDER_PLOT_CHECK

    
    
    call read_next_valid_line(105, line)
    read(line, *) num_cells

    !allocate(cells(num_cells))
    allocate(cells_id(num_cells))
    allocate(cells_x(num_cells), cells_y(num_cells), cells_z(num_cells))
    allocate(cells_r_nuc(num_cells), cells_r_cyto(num_cells))
    allocate(cells_src_prob(num_cells), cells_src_cdf(num_cells))

    !print*, num_cells
    !print*, size(cells)
   allocate(cells_r_nuc_sq(num_cells), cells_r_cyto_sq(num_cells))
    
    cum_prob = 0.0
    do i = 1, num_cells

       call read_next_valid_line(105, line)

       !read(line, *)  cells(i)%id, cells(i)%x, cells(i)%y, cells(i)%z, &
       !     cells(i)%r_nuc, cells(i)%r_cyto, cells(i)%src_prob
       read(line, *)  cells_id(i), cells_x(i), cells_y(i), cells_z(i), &
            cells_r_nuc(i), cells_r_cyto(i), cells_src_prob(i)




       !OPTIMIZATION: square at start when read
       cells_r_nuc_sq(i) = cells_r_nuc(i)**2
       cells_r_cyto_sq(i) = cells_r_cyto(i)**2

       !print*, cells(i)%src_prob
       !cum_prob = cum_prob + cells(i)%src_prob
       cum_prob = cum_prob + cells_src_prob(i)

       !cells(i)%src_cdf = cum_prob
       cells_src_cdf(i) = cum_prob

       !print*, cum_prob
    end do

    close(105)

    if (cum_prob > 0.0) then
       do i = 1, num_cells
          !cells(i)%src_cdf = cells(i)%src_cdf / cum_prob
          cells_src_cdf(i) = cells_src_cdf(i) / cum_prob
          !print*, cells(i)%src_cdf
       end do
    end if

    allocate(stp_a(E_GRID_MAX))

    call load_stopping_power(trim(dedx_file), mat_rho, stp_a)

    completed_nps = 0

  end subroutine load_config



subroutine print_user_inps(line)
 CHARACTER(LEN=256), INTENT(IN) :: line
    
  print*, trim(ADJUSTL(line))

end subroutine print_user_inps

  
!since users must have comments in their scripts this functions get rid of comments # chars
subroutine read_next_valid_line(u, clean_line)
    integer, intent(in) :: u
    character(len=256), intent(out) :: clean_line
    integer :: ios, k

    do
      read(u, '(A)', iostat=ios) clean_line

      if (ios /= 0) stop '[!] EOF or Error reading inputs.i'

      clean_line = adjustl(clean_line)

      if (len_trim(clean_line) == 0 .or. clean_line(1:1) == '#') then
         cycle
         end if

         k = index(clean_line, '#')

         !print*, k

         !print*, clean_line
         if (k > 0) then
            clean_line(k:) = ' '
         end if

         !print*, clean_line
         !pause

      exit

   end do

 end subroutine read_next_valid_line



!note the stopping power dedx files are taken from NIST astar database
  subroutine load_stopping_power(filename, rho, stp_out)
    character(len=*), intent(in) :: filename
    real(8), intent(in) :: rho
    real(8), intent(out) :: stp_out(E_GRID_MAX)
    integer :: i
    integer :: ios
    integer :: j
    integer :: npts
    integer :: u
    real(8), allocatable :: e_in(:)
    real(8), allocatable :: stp_in(:)
    real(8) :: e_keV
    real(8) :: f
    character(len=256) :: line

    stp_out = 0.0
    open(newunit=u, file=trim(filename), status='old', iostat=ios)
    if (ios /= 0) then
        print *, "[!] Warning: Missing dedx file -> ", trim(filename)
        return
    end if
    
    npts = 0
    do
       read(u, '(A)', iostat=ios) line
       if (ios /= 0) exit
       line = adjustl(line)
       if (len_trim(line) == 0 .or. line(1:1) == '#' .or. scan(line(1:1), 'a-zA-Z') > 0) cycle
       npts = npts + 1
    end do
    
    rewind(u)

    allocate(e_in(npts), stp_in(npts))

    j = 1
    do
       read(u, '(A)', iostat=ios) line

       if (ios /= 0) exit

       line = adjustl(line)

       if (len_trim(line) == 0 .or. line(1:1) == '#' .or. scan(line(1:1), 'a-zA-Z') > 0) cycle

       read(line, *, iostat=ios) e_in(j), stp_in(j)

       !print*, e_in(j), stp_in(j)
       
       e_in(j) = e_in(j) * 1000.0  !convert to keV

       stp_in(j) = stp_in(j) * rho !* 1000.0  !keV/cm  !check this -- checked no need 1000, using MeV/cm now

       j = j + 1

    end do

    close(u)

    !************************************************************
    j = 1
    do i = 1, E_GRID_MAX
       e_keV = real(i)

       if (e_keV <= e_in(1)) then
          stp_out(i) = stp_in(1)

       else if (e_keV >= e_in(npts)) then

          stp_out(i) = stp_in(npts)
       else
          do while (j < npts - 1 .and. e_in(j+1) < e_keV)
             j = j + 1
          end do

          f = (e_keV - e_in(j)) / max(1.0e-12, e_in(j+1) - e_in(j)) !for safe division
          stp_out(i) = stp_in(j) + f * (stp_in(j+1) - stp_in(j))  !linear interpolation
       end if

       !print*, e_keV, stp_out(i)
    end do
    !************************************************************
    
    deallocate(e_in, stp_in)

  end subroutine load_stopping_power

end module input_mod
