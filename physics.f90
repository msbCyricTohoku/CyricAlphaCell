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
module physics_mod
  use types_mod
  implicit none

contains

  subroutine sample_straggling(dE_mean, ds, Z_eff, A_eff, rho, dE_actual)
    real(8), intent(in)  :: dE_mean
    real(8), intent(in)  :: ds
    real(8), intent(in)  :: Z_eff
    real(8), intent(in)  :: A_eff
    real(8), intent(in)  :: rho
    real(8), intent(out) :: dE_actual
    real(8) :: u1
    real(8) :: u2
    real(8) :: g
    real(8) :: var_bohr
    real(8) :: std_bohr
    real(8) :: m
    real(8) :: s
    real(8), parameter :: TWO_PI = 2.0 * acos(-1.0)

    !bohr straggling variance
    !note i have pre-calc coeff
    !4.pi.Z1^2.Z_2.e^4.N.x   <--- Bohr straggling formula implemented here
    var_bohr = 0.1569 * (4.0) * (Z_eff / A_eff) * rho * ds

    !Z_eff and A_eff are being used for molecules and mixtures, user must supply

    std_bohr = sqrt(max(1.0e-12, var_bohr))

    std_bohr = min(std_bohr, dE_mean * 0.4)  !clamped at 40%, can try other values but must not be too high or low
    !preventing the gaussian tail in sampling to increase particle energy instead of reducing or making it deterministic csda

    if (dE_mean <= 1.0e-12) then
       dE_actual = 0.0
       return
    end if

    call random_number(u1)
    call random_number(u2)

    !print*, TWO_PI
    !pause

    g = sqrt(-2.0 * log(max(1.0e-10, u1))) * cos(TWO_PI * u2) !box-muller to get gussian

    s = sqrt(log(1.0 + (std_bohr / dE_mean)**2)) !lognormal to avoid any negative sampling

    m = log(dE_mean) - 0.5 * s**2

    !print*, dE_mean
    !pause

    
    dE_actual = exp(m + s * g) !scaling the normal distb and then exponential avoid inf.
    !m is mean, s is std., g rand var.

  end subroutine sample_straggling

end module physics_mod
