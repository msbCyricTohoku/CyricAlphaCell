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
module physics_mod
  use types_mod
  implicit none

contains

  !bitwise random number generator
  function rand_dbl(state) result(r)
      integer(8), intent(inout) :: state
      real(8) :: r
      state = ieor(state, ishft(state, 13))
      state = ieor(state, ishft(state, -7))
      state = ieor(state, ishft(state, 17))
      r = real(iand(state, 9007199254740991_8), 8) * 1.1102230246251565e-16_8
    end function rand_dbl


!    function rand_dbl(state) result(r)
!      integer(8), intent(inout) :: state
!      real(8) :: r
      
!      call random_number(r)
      
!      state = state + 1_8
!  end function rand_dbl

  !optimized version of straggling
  subroutine sample_straggling(dE_mean, ds, Z_eff, A_eff, rho, dE_actual, rng_state, cached_g, has_g)
    real(8), intent(in) :: dE_mean
    real(8), intent(in)  :: ds
    real(8), intent(in) :: Z_eff
    real(8), intent(in) :: A_eff
    real(8), intent(in) :: rho
    real(8), intent(out) :: dE_actual
    integer(8), intent(inout) :: rng_state
    real(8), intent(inout)    :: cached_g
    logical, intent(inout)    :: has_g 
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
   
    !bohr straggling variance
    !note i have pre-calc coeff
    !4.pi.Z1^2.Z_2.e^4.N.x   <--- Bohr straggling formula implemented here
    var_bohr = 0.1569d0 * (4.0d0) * (Z_eff / A_eff) * rho * ds

    !Z_eff and A_eff are being used for molecules and mixtures, user must supply
    
    
    std_bohr = sqrt(max(1.0e-12, var_bohr))

    std_bohr = min(std_bohr, dE_mean * 0.4d0) !clamped at 40%, can try other values but must not be too high or low
    !preventing the gaussian tail in sampling to increase particle energy instead of reducing or making it deterministic csda
    

    if (dE_mean <= 1.0e-12) then
       dE_actual = 0.0d0
       return
    end if

    if (has_g) then
        g = cached_g
        has_g = .false.
    else
        do
            u1 = rand_dbl(rng_state)
            u2 = rand_dbl(rng_state)

            !print*, u1, u2
            !pause
            
            v1 = 2.0d0 * u1 - 1.0d0
            v2 = 2.0d0 * u2 - 1.0d0

            w_sq = v1*v1 + v2*v2

            if (w_sq < 1.0d0 .and. w_sq > 1.0e-12) exit
        end do
        mult = sqrt(-2.0d0 * log(w_sq) / w_sq)
        g = v1 * mult
        
        cached_g = v2 * mult
        has_g = .true.
    end if

    s = sqrt(log(1.0d0 + (std_bohr / dE_mean)**2)) 
    m = log(dE_mean) - 0.5d0 * s**2
    
    !scaling the normal distb and then exponential avoid inf.
    dE_actual = exp(m + s * g)
    !m is mean, s is std., g rand var.
    

  end subroutine sample_straggling

end module physics_mod
