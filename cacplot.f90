! ==============================================================================
! CyricAlphaCell: Cellular Alpha Microdosimetry Monte Carlo (optimized)
! Version 1.2.1
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
MODULE CACPLOTTER
  USE ISO_C_BINDING
  use input_mod
  use tally_mod
  use TYPES_MOD
  IMPLICIT NONE
  !ISO C Binding for X11 C lib
  !***************************************************************************
  INTERFACE

     FUNCTION XOpenDisplay(display_name) BIND(C, NAME="XOpenDisplay")
      IMPORT :: C_PTR
      TYPE(C_PTR) :: XOpenDisplay
      TYPE(C_PTR), VALUE :: display_name
    END FUNCTION XOpenDisplay
    
    FUNCTION XDefaultRootWindow(display) BIND(C, NAME="XDefaultRootWindow")
      IMPORT :: C_PTR, C_LONG
      INTEGER(C_LONG) :: XDefaultRootWindow
      TYPE(C_PTR), VALUE :: display
    END FUNCTION XDefaultRootWindow


    FUNCTION XBlackPixel(display, screen_number) BIND(C, NAME="XBlackPixel")
      IMPORT :: C_PTR, C_LONG, C_INT
      INTEGER(C_LONG) :: XBlackPixel
      TYPE(C_PTR), VALUE :: display
      INTEGER(C_INT), VALUE :: screen_number
    END FUNCTION XBlackPixel

    
    FUNCTION XWhitePixel(display, screen_number) BIND(C, NAME="XWhitePixel")
      IMPORT :: C_PTR, C_LONG, C_INT
      INTEGER(C_LONG) :: XWhitePixel
      TYPE(C_PTR), VALUE :: display
      INTEGER(C_INT), VALUE :: screen_number
    END FUNCTION XWhitePixel
    
    FUNCTION XCreateSimpleWindow(display, parent, x, y, width, height, &
         border_width, border, background) BIND(C, NAME="XCreateSimpleWindow")
      IMPORT :: C_PTR, C_LONG, C_INT
      INTEGER(C_LONG) :: XCreateSimpleWindow
      TYPE(C_PTR), VALUE :: display
      INTEGER(C_LONG), VALUE :: parent
      INTEGER(C_INT), VALUE :: x, y, width, height, border_width
      INTEGER(C_LONG), VALUE :: border, background
    END FUNCTION XCreateSimpleWindow

    
    FUNCTION XSelectInput(display, w, event_mask) BIND(C, NAME="XSelectInput")
      IMPORT :: C_PTR, C_LONG, C_INT
      INTEGER(C_INT) :: XSelectInput
      TYPE(C_PTR), VALUE :: display
      INTEGER(C_LONG), VALUE :: w, event_mask
    END FUNCTION XSelectInput

    
    FUNCTION XMapWindow(display, w) BIND(C, NAME="XMapWindow")
      IMPORT :: C_PTR, C_LONG, C_INT
      INTEGER(C_INT) :: XMapWindow
      TYPE(C_PTR), VALUE :: display
      INTEGER(C_LONG), VALUE :: w
    END FUNCTION XMapWindow

    
    FUNCTION XCreateGC(display, d, valuemask, values) BIND(C, NAME="XCreateGC")
      IMPORT :: C_PTR, C_LONG
      TYPE(C_PTR) :: XCreateGC
      TYPE(C_PTR), VALUE :: display
      INTEGER(C_LONG), VALUE :: d, valuemask
      TYPE(C_PTR), VALUE :: values
    END FUNCTION XCreateGC
    
    
    FUNCTION XSetForeground(display, gc, foreground) BIND(C, NAME="XSetForeground")
      IMPORT :: C_PTR, C_LONG, C_INT
      INTEGER(C_INT) :: XSetForeground
      TYPE(C_PTR), VALUE :: display, gc
      INTEGER(C_LONG), VALUE :: foreground
    END FUNCTION XSetForeground

    
    FUNCTION XDrawLine(display, d, gc, x1, y1, x2, y2) BIND(C, NAME="XDrawLine")
      IMPORT :: C_PTR, C_LONG, C_INT
      INTEGER(C_INT) :: XDrawLine
      TYPE(C_PTR), VALUE :: display, gc
      INTEGER(C_LONG), VALUE :: d
      INTEGER(C_INT), VALUE :: x1, y1, x2, y2
    END FUNCTION XDrawLine


    FUNCTION XDrawRectangle(display, d, gc, x, y, width, height) &
         BIND(C, NAME="XDrawRectangle")
      IMPORT :: C_PTR, C_LONG, C_INT
      INTEGER(C_INT) :: XDrawRectangle
      TYPE(C_PTR), VALUE :: display, gc
      INTEGER(C_LONG), VALUE :: d
      INTEGER(C_INT), VALUE :: x, y, width, height
    END FUNCTION XDrawRectangle


    FUNCTION XFillRectangle(display, d, gc, x, y, width, height) &
         BIND(C, NAME="XFillRectangle")
      IMPORT :: C_PTR, C_LONG, C_INT
      INTEGER(C_INT) :: XFillRectangle
      TYPE(C_PTR), VALUE :: display, gc
      INTEGER(C_LONG), VALUE :: d
      INTEGER(C_INT), VALUE :: x, y, width, height
    END FUNCTION XFillRectangle

    
    FUNCTION XDrawString(display, d, gc, x, y, string, length) BIND(C, NAME="XDrawString")
      IMPORT :: C_PTR, C_LONG, C_INT, C_CHAR
      INTEGER(C_INT) :: XDrawString
      TYPE(C_PTR), VALUE :: display, gc
      INTEGER(C_LONG), VALUE :: d
      INTEGER(C_INT), VALUE :: x, y, length
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: string
    END FUNCTION XDrawString


    
    FUNCTION XNextEvent(display, event) BIND(C, NAME="XNextEvent")
      IMPORT :: C_PTR, C_INT
      INTEGER(C_INT) :: XNextEvent
      TYPE(C_PTR), VALUE :: display, event
    END FUNCTION XNextEvent

    
    FUNCTION XCloseDisplay(display) BIND(C, NAME="XCloseDisplay")
      IMPORT :: C_PTR, C_INT
      INTEGER(C_INT) :: XCloseDisplay
      TYPE(C_PTR), VALUE :: display
    END FUNCTION XCloseDisplay

    
    FUNCTION XDefaultColormap(display, screen_number) BIND(C, NAME="XDefaultColormap")
      IMPORT :: C_PTR, C_LONG, C_INT
      INTEGER(C_LONG) :: XDefaultColormap
      TYPE(C_PTR), VALUE :: display
      INTEGER(C_INT), VALUE :: screen_number
    END FUNCTION XDefaultColormap


    
    FUNCTION XAllocNamedColor(display, colormap, color_name, screen_def_return, &
         exact_def_return) BIND(C, NAME="XAllocNamedColor")
      IMPORT :: C_PTR, C_LONG, C_INT, C_CHAR
      INTEGER(C_INT) :: XAllocNamedColor
      TYPE(C_PTR), VALUE :: display
      INTEGER(C_LONG), VALUE :: colormap
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: color_name
      TYPE(C_PTR), VALUE :: screen_def_return, exact_def_return
    END FUNCTION XAllocNamedColor


    FUNCTION XParseColor(display, colormap, spec, exact_def_return) &
         BIND(C, NAME="XParseColor")
      IMPORT :: C_PTR, C_LONG, C_INT, C_CHAR
      INTEGER(C_INT) :: XParseColor
      TYPE(C_PTR), VALUE :: display
      INTEGER(C_LONG), VALUE :: colormap
      CHARACTER(KIND=C_CHAR), DIMENSION(*), INTENT(IN) :: spec
      TYPE(C_PTR), VALUE :: exact_def_return
    END FUNCTION XParseColor


    FUNCTION XAllocColor(display, colormap, screen_in_out) BIND(C, NAME="XAllocColor")
      IMPORT :: C_PTR, C_LONG, C_INT
      INTEGER(C_INT) :: XAllocColor
      TYPE(C_PTR), VALUE :: display
      INTEGER(C_LONG), VALUE :: colormap
      TYPE(C_PTR), VALUE :: screen_in_out
    END FUNCTION XAllocColor

    
  END INTERFACE
  !******************************************************************************

  
  !colors defined here
  TYPE, BIND(C) :: XColor
     INTEGER(C_LONG) :: PIXEL
     INTEGER(C_SHORT) :: RED
     INTEGER(C_SHORT) :: GREEN
     INTEGER(C_SHORT) :: BLUE
     CHARACTER(C_CHAR) :: FLAGS
     CHARACTER(C_CHAR) :: PAD
  END TYPE XColor

  !state
  TYPE(C_PTR) :: DISP = C_NULL_PTR
  TYPE(C_PTR) :: GC = C_NULL_PTR
  INTEGER(C_LONG) :: WIN = 0
  INTEGER(C_LONG) :: CMAP = 0
  INTEGER(C_LONG) :: BLACK = 0
  INTEGER(C_LONG) :: WHITE = 0
  INTEGER :: WIN_W = 1100
  INTEGER :: WIN_H = 750

  !sub-pixel vector primitives with z-layer ordering
  TYPE :: LINE_T
     REAL(8) :: X1
     REAL(8) :: Y1
     REAL(8) :: X2
     REAL(8) :: Y2
     REAL(8) :: LW
     REAL(8) :: OPACITY
     INTEGER :: DASH
     INTEGER :: LAYER
     INTEGER(C_LONG) :: PIXEL
     CHARACTER(LEN=24) :: CLR
  END TYPE LINE_T

  TYPE :: RECT_T
     REAL(8) :: X
     REAL(8) :: Y
     REAL(8) :: W
     REAL(8) :: H
     REAL(8) :: LW
     REAL(8) :: OPACITY
     LOGICAL :: HAS_FILL
     LOGICAL :: HAS_STROKE
     INTEGER :: LAYER
     INTEGER(C_LONG) :: FILL_PIX
     INTEGER(C_LONG) :: STROKE_PIX
     CHARACTER(LEN=24) :: FILL_CLR
     CHARACTER(LEN=24) :: STROKE_CLR
  END TYPE RECT_T

  TYPE :: CIRCLE_T
     REAL(8) :: CX
     REAL(8) :: CY
     REAL(8) :: R
     REAL(8) :: LW
     REAL(8) :: OPACITY
     INTEGER :: DASH
     LOGICAL :: HAS_FILL
     LOGICAL :: HAS_STROKE
     INTEGER :: LAYER
     INTEGER(C_LONG) :: FILL_PIX
     INTEGER(C_LONG) :: STROKE_PIX
     CHARACTER(LEN=24) :: FILL_CLR
     CHARACTER(LEN=24) :: STROKE_CLR
  END TYPE CIRCLE_T

  TYPE :: TEXT_T
     REAL(8) :: X
     REAL(8) :: Y
     INTEGER :: ANGLE
     INTEGER :: FSIZE
     LOGICAL :: BOLD
     INTEGER :: LAYER
     CHARACTER(LEN=1) :: ANCHOR
     INTEGER(C_LONG) :: PIXEL
     CHARACTER(LEN=120) :: TXT
     CHARACTER(LEN=240) :: SVG_TXT
     CHARACTER(LEN=24) :: CLR
  END TYPE TEXT_T

  TYPE(LINE_T), ALLOCATABLE :: LINES(:)
  TYPE(RECT_T), ALLOCATABLE :: RECTS(:)
  TYPE(CIRCLE_T), ALLOCATABLE :: CIRCLES(:)
  TYPE(TEXT_T), ALLOCATABLE :: TEXTS(:)
  INTEGER :: NLINES = 0
  INTEGER :: NRECTS = 0
  INTEGER :: NCIRCLES = 0
  INTEGER :: NTEXTS = 0

  REAL(8) :: AX_XMIN = 0.0d0
  REAL(8) :: AX_XMAX = 1.0d0
  REAL(8) :: AX_YMIN = 0.0d0
  REAL(8) :: AX_YMAX = 1.0d0
  !PADR is the wide right margin reserved for the legend
  INTEGER :: PADX = 115
  INTEGER :: PADR = 270
  INTEGER :: PADY = 90
  INTEGER :: PADY_TOP = 82
  INTEGER :: PADY_BOT = 90
  LOGICAL :: IS_X_LOG = .FALSE.
  LOGICAL :: IS_Y_LOG = .FALSE.
  LOGICAL :: DRAW_GRID = .TRUE.
  CHARACTER(LEN=24) :: CUR_COLOR = '#111111'
  INTEGER(C_LONG) :: CUR_PIXEL = 0
  REAL(8) :: CUR_LW = 2.0d0
  REAL(8) :: CUR_OPACITY = 1.0d0
  INTEGER :: CUR_DASH = 0
  INTEGER :: CUR_LAYER = 1
  INTEGER :: CUR_MARKER = 1
  INTEGER, PARAMETER :: C_LEFT = 1
  INTEGER, PARAMETER :: C_RIGHT = 2
  INTEGER, PARAMETER :: C_BOTTOM = 4
  INTEGER, PARAMETER :: C_TOP = 8

  !colorblind-safe journal palette
  CHARACTER(LEN=24), DIMENSION(6), PARAMETER :: PUB_PALETTE = (/ &
       CHARACTER(LEN=24) :: '#D62728', '#1F77B4', '#008080', &
                            '#E66100', '#7B3294', '#2CA02C' /)

CONTAINS

  !this is used to ignore unused return statuses from X11 C functions
  SUBROUTINE CHECK(STATUS)
    INTEGER(C_INT), INTENT(IN) :: STATUS
    if (.false.) print *, STATUS  !since unused, it silence status
  END SUBROUTINE CHECK

  !format real(8) for sub-pixel svg attributes
  PURE FUNCTION FSTR(VAL) RESULT(S)
    REAL(8), INTENT(IN) :: VAL
    CHARACTER(LEN=24) :: TMP
    CHARACTER(LEN=:), ALLOCATABLE :: S
    WRITE(TMP, '(F16.2)') VAL
    S = TRIM(ADJUSTL(TMP))
  END FUNCTION FSTR

  !format integer to trimmed string
  PURE FUNCTION ISTR(VAL) RESULT(S)
    INTEGER, INTENT(IN) :: VAL
    CHARACTER(LEN=20) :: TMP
    CHARACTER(LEN=:), ALLOCATABLE :: S
    WRITE(TMP, '(I0)') VAL
    S = TRIM(ADJUSTL(TMP))
  END FUNCTION ISTR

  !doubles the line buffer size when full
  SUBROUTINE EXPAND_LINES()
    TYPE(LINE_T), ALLOCATABLE :: TEMP(:)
    ALLOCATE(TEMP(SIZE(LINES) * 2))
    TEMP(1:NLINES) = LINES(1:NLINES)
    CALL MOVE_ALLOC(TEMP, LINES)
  END SUBROUTINE EXPAND_LINES

  !doubles the rect buffer size when full
  SUBROUTINE EXPAND_RECTS()
    TYPE(RECT_T), ALLOCATABLE :: TEMP(:)
    ALLOCATE(TEMP(SIZE(RECTS) * 2))
    TEMP(1:NRECTS) = RECTS(1:NRECTS)
    CALL MOVE_ALLOC(TEMP, RECTS)
  END SUBROUTINE EXPAND_RECTS

  !doubles the circle buffer size when full
  SUBROUTINE EXPAND_CIRCLES()
    TYPE(CIRCLE_T), ALLOCATABLE :: TEMP(:)
    ALLOCATE(TEMP(SIZE(CIRCLES) * 2))
    TEMP(1:NCIRCLES) = CIRCLES(1:NCIRCLES)
    CALL MOVE_ALLOC(TEMP, CIRCLES)
  END SUBROUTINE EXPAND_CIRCLES

  !doubles the text buffer size when full
  SUBROUTINE EXPAND_TEXTS()
    TYPE(TEXT_T), ALLOCATABLE :: TEMP(:)
    ALLOCATE(TEMP(SIZE(TEXTS) * 2))
    TEMP(1:NTEXTS) = TEXTS(1:NTEXTS)
    CALL MOVE_ALLOC(TEMP, TEXTS)
  END SUBROUTINE EXPAND_TEXTS

  !**********************************
  SUBROUTINE Init_Canvas(W, H)
    INTEGER, INTENT(IN) :: W, H
    WIN_W = W
    WIN_H = H
    !print*, W, H
    NLINES = 0
    NRECTS = 0
    NCIRCLES = 0
    NTEXTS = 0
    !PRINT*, NLINES

    IF (.NOT. ALLOCATED(LINES)) ALLOCATE(LINES(100000))
    IF (.NOT. ALLOCATED(RECTS)) ALLOCATE(RECTS(8192))
    IF (.NOT. ALLOCATED(CIRCLES)) ALLOCATE(CIRCLES(8192))
    IF (.NOT. ALLOCATED(TEXTS)) ALLOCATE(TEXTS(10000))

    !ALLOCATE(LINES(1000000))
    !ALLOCATE(TEXTS(10000))
    
    CUR_COLOR = '#111111'
    CUR_PIXEL = 0
    CUR_LW = 2.0d0
    CUR_OPACITY = 1.0d0
    CUR_DASH = 0
    CUR_LAYER = 1
  END SUBROUTINE Init_Canvas
  !**********************************

  !init X11 display, creates window, and pre alloc dynamic memory
  SUBROUTINE Init_Plot(W, H)
    INTEGER, INTENT(IN) :: W, H
    INTEGER(C_LONG) :: ROOT
    
    !WIN_W = W
    !WIN_H = H
    !NLINES = 0; NTEXTS = 0
    !ALLOCATE(LINES(1000000))
    !ALLOCATE(TEXTS(10000))

    CALL Init_Canvas(W, H)

    DISP = XOpenDisplay(C_NULL_PTR)
    IF (.NOT. C_ASSOCIATED(DISP)) STOP "ERROR: CANNOT OPEN X11 DISPLAY."

    ROOT = XDefaultRootWindow(DISP)
    CMAP = XDefaultColormap(DISP, 0_C_INT)
    BLACK = XBlackPixel(DISP, 0_C_INT)
    WHITE = XWhitePixel(DISP, 0_C_INT)
    
    CUR_COLOR = '#111111'
    CUR_PIXEL = BLACK

    WIN = XCreateSimpleWindow(DISP, ROOT, 0_C_INT, 0_C_INT, INT(W, C_INT), INT(H, C_INT), &
                              1_C_INT, BLACK, WHITE)

    CALL CHECK( XSelectInput(DISP, WIN, 32769_C_LONG) ) 
    CALL CHECK( XMapWindow(DISP, WIN) )

    GC = XCreateGC(DISP, WIN, 0_C_LONG, C_NULL_PTR)
    CALL CHECK( XSetForeground(DISP, GC, BLACK) )
  END SUBROUTINE Init_Plot

  !********************************8
  !helper to setup figure margins and canvas/x11 mode
  SUBROUTINE Begin_Figure(W, H, MARGIN_R)
    INTEGER, INTENT(IN) :: W, H
    INTEGER, INTENT(IN), OPTIONAL :: MARGIN_R
    PADX = 115
    PADY_TOP = 82
    PADY_BOT = 90
    PADY = 90
    IF (PRESENT(MARGIN_R)) THEN
       PADR = MARGIN_R
    ELSE
       PADR = 275
    END IF
    IF (RENDER_PLOT_CHECK == 1) THEN
       CALL Init_Plot(W, H)
    ELSE
       CALL Init_Canvas(W, H)
    END IF
  END SUBROUTINE Begin_Figure

  !helper to export, render, and free figure buffers
  SUBROUTINE Finish_Figure(SVG_NAME)
    CHARACTER(LEN=*), INTENT(IN) :: SVG_NAME
    IF (SVG_PLOT_CHECK == 1) CALL Export_SVG(SVG_NAME)
    IF (RENDER_PLOT_CHECK == 1) CALL Render_Plot
    IF (ALLOCATED(LINES)) DEALLOCATE(LINES)
    IF (ALLOCATED(RECTS)) DEALLOCATE(RECTS)
    IF (ALLOCATED(CIRCLES)) DEALLOCATE(CIRCLES)
    IF (ALLOCATED(TEXTS)) DEALLOCATE(TEXTS)
  END SUBROUTINE Finish_Figure

  !here we set the main title at the top of the plot
  SUBROUTINE Set_Title(TXT, SUBTXT)
    CHARACTER(LEN=*), INTENT(IN) :: TXT
    CHARACTER(LEN=*), INTENT(IN), OPTIONAL :: SUBTXT
    REAL(8) :: CX
    CX = 0.5d0 * real(PADX + WIN_W - PADR, 8)
    CALL ADD_TEXT_EX(CX, 36.0d0, TXT, TXT, 0, 18, .TRUE., 'C', '#111111', 3)
    IF (PRESENT(SUBTXT)) THEN
       IF (LEN_TRIM(SUBTXT) > 0) THEN
          CALL ADD_TEXT_EX(CX, 58.0d0, SUBTXT, SUBTXT, 0, 13, .FALSE., 'C', '#4B5563', 3)
       END IF
    END IF
  END SUBROUTINE Set_Title

  !log scaling on axes
  SUBROUTINE Set_Scale(X_LOG, Y_LOG)
    LOGICAL, INTENT(IN) :: X_LOG, Y_LOG
    IS_X_LOG = X_LOG
    IS_Y_LOG = Y_LOG
  END SUBROUTINE Set_Scale

  !*****************************************
  !resolve hex or named color in X11 colormap
  FUNCTION GET_X11_PIXEL(CNAME) RESULT(PIX)
    CHARACTER(LEN=*), INTENT(IN) :: CNAME
    INTEGER(C_LONG) :: PIX
    TYPE(XColor), TARGET :: EXACT, SCREEN
    CHARACTER(KIND=C_CHAR, LEN=32) :: C_STR

    !THIS IS REAL(8)LY IMPORTANT WHEN ON SVG EXPORT MODE ON ONLY
    !SKIP X11 ALLOCATION
    IF (.NOT. C_ASSOCIATED(DISP)) THEN
       PIX = 0
       RETURN
    END IF

    C_STR = TRIM(CNAME) // C_NULL_CHAR
    IF (XParseColor(DISP, CMAP, C_STR, C_LOC(SCREEN)) /= 0) THEN
       IF (XAllocColor(DISP, CMAP, C_LOC(SCREEN)) /= 0) THEN
          PIX = SCREEN%PIXEL
          RETURN
       END IF
    END IF
    IF (XAllocNamedColor(DISP, CMAP, C_STR, C_LOC(SCREEN), C_LOC(EXACT)) /= 0) THEN
       PIX = SCREEN%PIXEL
    ELSE
       PIX = BLACK
    END IF
  END FUNCTION GET_X11_PIXEL

  !color by X11 colormap
  SUBROUTINE Set_Color(CNAME)
    CHARACTER(LEN=*), INTENT(IN) :: CNAME
    CUR_COLOR = TRIM(CNAME)
    CUR_PIXEL = GET_X11_PIXEL(CNAME)
  END SUBROUTINE Set_Color
  !*****************************************

  !set stroke width, dash pattern, opacity, and z-layer
  SUBROUTINE Set_Style(LW, DASH, OPACITY, LAYER)
    REAL(8), INTENT(IN), OPTIONAL :: LW
    INTEGER, INTENT(IN), OPTIONAL :: DASH
    REAL(8), INTENT(IN), OPTIONAL :: OPACITY
    INTEGER, INTENT(IN), OPTIONAL :: LAYER
    IF (PRESENT(LW)) CUR_LW = LW
    IF (PRESENT(DASH)) CUR_DASH = DASH
    IF (PRESENT(OPACITY)) CUR_OPACITY = OPACITY
    IF (PRESENT(LAYER)) CUR_LAYER = LAYER
  END SUBROUTINE Set_Style

  !here we set markers(1=Circle, 2=Square, 3=Triangle, 4=Diamond, 5=Cross, 6=Ex)
  SUBROUTINE Set_Marker(M)
    INTEGER, INTENT(IN) :: M
    CUR_MARKER = M
  END SUBROUTINE Set_Marker

  !compute nice rounded tick step and axis bounds
  SUBROUTINE CALC_NICE_AXIS(VMIN_IN, VMAX_IN, AX_MIN, AX_MAX, STEP_OUT, LOCK_ZERO)
    REAL(8), INTENT(IN) :: VMIN_IN, VMAX_IN
    REAL(8), INTENT(OUT) :: AX_MIN, AX_MAX, STEP_OUT
    LOGICAL, INTENT(IN), OPTIONAL :: LOCK_ZERO
    REAL(8) :: LO, HI, SPAN, RAW_STEP, POW10, FRAC, NICE_F
    INTEGER :: EXPON
    LOGICAL :: LZERO

    LZERO = .FALSE.
    IF (PRESENT(LOCK_ZERO)) LZERO = LOCK_ZERO

    LO = VMIN_IN
    HI = VMAX_IN
    IF (HI < LO) THEN
       LO = VMAX_IN
       HI = VMIN_IN
    END IF

    SPAN = HI - LO
    IF (SPAN <= 1.0d-30) THEN
       IF (ABS(HI) <= 1.0d-30) THEN
          LO = 0.0d0
          HI = 1.0d0
       ELSE
          LO = LO * 0.85d0
          HI = HI * 1.15d0
          IF (LZERO .AND. VMIN_IN >= 0.0d0) LO = 0.0d0
       END IF
       SPAN = HI - LO
    ELSE
       IF (.NOT. (LZERO .AND. ABS(LO) < 1.0d-30)) THEN
          LO = LO - 0.04d0 * SPAN
          IF (VMIN_IN >= 0.0d0 .AND. LO < 0.0d0) LO = 0.0d0
       END IF
       HI = HI + 0.05d0 * SPAN
       SPAN = HI - LO
    END IF

    RAW_STEP = SPAN / 5.5d0
    EXPON = FLOOR(LOG10(RAW_STEP))
    POW10 = 10.0d0 ** EXPON
    FRAC = RAW_STEP / POW10

    IF (FRAC <= 1.0d0) THEN
       NICE_F = 1.0d0
    ELSE IF (FRAC <= 2.0d0) THEN
       NICE_F = 2.0d0
    ELSE IF (FRAC <= 2.5d0) THEN
       NICE_F = 2.5d0
    ELSE IF (FRAC <= 5.0d0) THEN
       NICE_F = 5.0d0
    ELSE
       NICE_F = 10.0d0
    END IF

    STEP_OUT = NICE_F * POW10
    AX_MIN = FLOOR((LO + 1.0d-10 * STEP_OUT) / STEP_OUT) * STEP_OUT
    AX_MAX = CEILING((HI - 1.0d-10 * STEP_OUT) / STEP_OUT) * STEP_OUT
    IF (AX_MAX <= AX_MIN) AX_MAX = AX_MIN + STEP_OUT
  END SUBROUTINE CALC_NICE_AXIS

  !here we draw outer box, calculates tick positions, and prints labels
  SUBROUTINE Draw_Axes(XA, XE, YA, YE, XLABEL, YLABEL, XSVG_OPT, YSVG_OPT, &
                       XSTEP_OPT, YSTEP_OPT)
    REAL(8), INTENT(IN) :: XA
    REAL(8), INTENT(IN) :: XE
    REAL(8), INTENT(IN) :: YA
    REAL(8), INTENT(IN) :: YE
    CHARACTER(LEN=*), INTENT(IN) :: XLABEL
    CHARACTER(LEN=*), INTENT(IN) :: YLABEL
    CHARACTER(LEN=*), INTENT(IN), OPTIONAL :: XSVG_OPT, YSVG_OPT
    REAL(8), INTENT(IN), OPTIONAL :: XSTEP_OPT, YSTEP_OPT

    REAL(8) :: X0, X1, Y0, Y1, PW, PH, V, STEP_X, STEP_Y, SUB_STEP, POS, MVAL
    INTEGER :: I, M, NTICKS, P, P_START, P_END, P_STRIDE
    CHARACTER(LEN=32) :: STR
    CHARACTER(LEN=80) :: S_SVG
    CHARACTER(LEN=240) :: XL_SVG, YL_SVG
    CHARACTER(LEN=24) :: SAVE_CLR
    REAL(8) :: SAVE_LW
    INTEGER :: SAVE_DASH, SAVE_LYR

    SAVE_CLR = CUR_COLOR
    SAVE_LW = CUR_LW
    SAVE_DASH = CUR_DASH
    SAVE_LYR = CUR_LAYER

    XL_SVG = XLABEL
    YL_SVG = YLABEL
    IF (PRESENT(XSVG_OPT)) XL_SVG = XSVG_OPT
    IF (PRESENT(YSVG_OPT)) YL_SVG = YSVG_OPT

    X0 = real(PADX, 8)
    X1 = real(WIN_W - PADR, 8)
    Y0 = real(PADY_TOP, 8)
    Y1 = real(WIN_H - PADY_BOT, 8)
    PW = X1 - X0
    PH = Y1 - Y0

    IF (IS_X_LOG) THEN
       P_START = FLOOR(LOG10(MAX(XA, 1.0d-30)) + 1.0d-9)
       P_END = CEILING(LOG10(MAX(XE, 1.0d-29)) - 1.0d-9)
       IF (P_END <= P_START) P_END = P_START + 1
       AX_XMIN = real(P_START, 8)
       AX_XMAX = real(P_END, 8)
       STEP_X = 1.0d0
    ELSE
       AX_XMIN = XA
       AX_XMAX = XE
       IF (PRESENT(XSTEP_OPT)) THEN
          STEP_X = XSTEP_OPT
       ELSE
          STEP_X = (XE - XA) / 5.0d0
       END IF
       STEP_X = MAX(1.0d-12, STEP_X)
    END IF
    
    IF (IS_Y_LOG) THEN
       P_START = FLOOR(LOG10(MAX(YA, 1.0d-30)) + 1.0d-9)
       P_END = CEILING(LOG10(MAX(YE, 1.0d-29)) - 1.0d-9)
       IF (P_END <= P_START) P_END = P_START + 1
       AX_YMIN = real(P_START, 8)
       AX_YMAX = real(P_END, 8)
       STEP_Y = 1.0d0
    ELSE
       AX_YMIN = YA
       AX_YMAX = YE
       IF (PRESENT(YSTEP_OPT)) THEN
          STEP_Y = YSTEP_OPT
       ELSE
          STEP_Y = (YE - YA) / 5.0d0
       END IF
       STEP_Y = MAX(1.0d-12, STEP_Y)
    END IF

    !plot background fill
    CALL ADD_RECT(X0, Y0, PW, PH, '#FFFFFF', 'none', 0.0d0, 1.0d0, 0)
    
    !X axis ticks and labels
    IF (.NOT. IS_X_LOG) THEN
      NTICKS = MAX(1, NINT((AX_XMAX - AX_XMIN) / STEP_X))
      SUB_STEP = STEP_X / 5.0d0
      IF (ABS(STEP_X - 1.0d0) < 1.0d-6) SUB_STEP = 1.0d0

      DO I = 0, NTICKS
        V = AX_XMIN + real(I, 8) * STEP_X
        POS = X0 + (V - AX_XMIN) / MAX(1.0d-12, AX_XMAX - AX_XMIN) * PW
        IF (POS >= X0 - 0.5d0 .AND. POS <= X1 + 0.5d0) THEN
           IF (DRAW_GRID .AND. POS > X0 + 1.0d0 .AND. POS < X1 - 1.0d0) THEN
              CALL Set_Color('#E2E8F0')
              CALL Set_Style(LW=0.9d0, DASH=1, OPACITY=1.0d0, LAYER=0)
              CALL ADD_LINE_F(POS, Y1, POS, Y0)
           END IF
           CALL Set_Color('#111111')
           CALL Set_Style(LW=1.6d0, DASH=0, OPACITY=1.0d0, LAYER=2)
           CALL ADD_LINE_F(POS, Y1, POS, Y1 - 9.0d0)
           CALL ADD_LINE_F(POS, Y0, POS, Y0 + 9.0d0)

           CALL NUM2STR(V, STR)
           CALL ADD_TEXT_EX(POS, Y1 + 23.0d0, STR, STR, 0, 13, .FALSE., 'C', '#111111', 3)
        END IF

        IF (SUB_STEP < STEP_X * 0.9d0 .AND. I < NTICKS) THEN
           CALL Set_Color('#111111')
           CALL Set_Style(LW=1.1d0, DASH=0, OPACITY=1.0d0, LAYER=2)
           DO M = 1, 4
              MVAL = V + real(M, 8) * SUB_STEP
              POS = X0 + (MVAL - AX_XMIN) / MAX(1.0d-12, AX_XMAX - AX_XMIN) * PW
              IF (POS > X0 .AND. POS < X1) THEN
                 CALL ADD_LINE_F(POS, Y1, POS, Y1 - 4.5d0)
                 CALL ADD_LINE_F(POS, Y0, POS, Y0 + 4.5d0)
              END IF
           END DO
        END IF
      END DO
    ELSE
       P_START = NINT(AX_XMIN)
       P_END = NINT(AX_XMAX)
       P_STRIDE = 1
       IF (P_END - P_START > 8) P_STRIDE = 2

       DO P = P_START, P_END
        POS = X0 + (real(P, 8) - AX_XMIN) / MAX(1.0d-12, AX_XMAX - AX_XMIN) * PW
        IF (POS >= X0 - 0.5d0 .AND. POS <= X1 + 0.5d0) THEN
           IF (DRAW_GRID .AND. P > P_START .AND. P < P_END) THEN
              CALL Set_Color('#E2E8F0')
              CALL Set_Style(LW=0.9d0, DASH=1, OPACITY=1.0d0, LAYER=0)
              CALL ADD_LINE_F(POS, Y1, POS, Y0)
           END IF
           CALL Set_Color('#111111')
           CALL Set_Style(LW=1.6d0, DASH=0, OPACITY=1.0d0, LAYER=2)
           CALL ADD_LINE_F(POS, Y1, POS, Y1 - 9.0d0)
           CALL ADD_LINE_F(POS, Y0, POS, Y0 + 9.0d0)

           IF (MOD(P - P_START, P_STRIDE) == 0) THEN
              WRITE(STR, '("10^",I0)') P
              S_SVG = '10<tspan dy="-5" font-size="10">' // ISTR(P) // '</tspan>'
              CALL ADD_TEXT_EX(POS, Y1 + 24.0d0, TRIM(STR), TRIM(S_SVG), &
                   0, 13, .FALSE., 'C', '#111111', 3)
           END IF
        END IF

        IF (P < P_END .AND. (P_END - P_START) <= 8) THEN
           CALL Set_Color('#111111')
           CALL Set_Style(LW=1.0d0, DASH=0, OPACITY=1.0d0, LAYER=2)
           DO M = 2, 9
              MVAL = real(P, 8) + LOG10(real(M, 8))
              POS = X0 + (MVAL - AX_XMIN) / MAX(1.0d-12, AX_XMAX - AX_XMIN) * PW
              IF (POS > X0 .AND. POS < X1) THEN
                 CALL ADD_LINE_F(POS, Y1, POS, Y1 - 4.5d0)
                 CALL ADD_LINE_F(POS, Y0, POS, Y0 + 4.5d0)
              END IF
           END DO
        END IF
      END DO
    END IF

    !Y axis ticks and labels
    IF (.NOT. IS_Y_LOG) THEN
      NTICKS = MAX(1, NINT((AX_YMAX - AX_YMIN) / STEP_Y))
      SUB_STEP = STEP_Y / 5.0d0

      DO I = 0, NTICKS
        V = AX_YMIN + real(I, 8) * STEP_Y
        POS = Y1 - (V - AX_YMIN) / MAX(1.0d-12, AX_YMAX - AX_YMIN) * PH
        IF (POS >= Y0 - 0.5d0 .AND. POS <= Y1 + 0.5d0) THEN
           IF (DRAW_GRID .AND. POS > Y0 + 1.0d0 .AND. POS < Y1 - 1.0d0) THEN
              CALL Set_Color('#E2E8F0')
              CALL Set_Style(LW=0.9d0, DASH=1, OPACITY=1.0d0, LAYER=0)
              CALL ADD_LINE_F(X0, POS, X1, POS)
           END IF
           CALL Set_Color('#111111')
           CALL Set_Style(LW=1.6d0, DASH=0, OPACITY=1.0d0, LAYER=2)
           CALL ADD_LINE_F(X0, POS, X0 + 9.0d0, POS)
           CALL ADD_LINE_F(X1, POS, X1 - 9.0d0, POS)

           CALL NUM2STR(V, STR)
           CALL ADD_TEXT_EX(X0 - 10.0d0, POS + 4.5d0, STR, STR, &
                0, 13, .FALSE., 'R', '#111111', 3)
        END IF

        IF (I < NTICKS) THEN
           CALL Set_Color('#111111')
           CALL Set_Style(LW=1.1d0, DASH=0, OPACITY=1.0d0, LAYER=2)
           DO M = 1, 4
              MVAL = V + real(M, 8) * SUB_STEP
              POS = Y1 - (MVAL - AX_YMIN) / MAX(1.0d-12, AX_YMAX - AX_YMIN) * PH
              IF (POS > Y0 .AND. POS < Y1) THEN
                 CALL ADD_LINE_F(X0, POS, X0 + 4.5d0, POS)
                 CALL ADD_LINE_F(X1, POS, X1 - 4.5d0, POS)
              END IF
           END DO
        END IF
      END DO
    ELSE
      P_START = NINT(AX_YMIN)
      P_END = NINT(AX_YMAX)
      P_STRIDE = 1
      IF (P_END - P_START > 8) P_STRIDE = 2

      DO P = P_START, P_END
        POS = Y1 - (real(P, 8) - AX_YMIN) / MAX(1.0d-12, AX_YMAX - AX_YMIN) * PH
        IF (POS >= Y0 - 0.5d0 .AND. POS <= Y1 + 0.5d0) THEN
           IF (DRAW_GRID .AND. P > P_START .AND. P < P_END) THEN
              CALL Set_Color('#E2E8F0')
              CALL Set_Style(LW=0.9d0, DASH=1, OPACITY=1.0d0, LAYER=0)
              CALL ADD_LINE_F(X0, POS, X1, POS)
           END IF
           CALL Set_Color('#111111')
           CALL Set_Style(LW=1.6d0, DASH=0, OPACITY=1.0d0, LAYER=2)
           CALL ADD_LINE_F(X0, POS, X0 + 9.0d0, POS)
           CALL ADD_LINE_F(X1, POS, X1 - 9.0d0, POS)

           IF (MOD(P - P_START, P_STRIDE) == 0) THEN
              WRITE(STR, '("10^",I0)') P
              S_SVG = '10<tspan dy="-5" font-size="10">' // ISTR(P) // '</tspan>'
              CALL ADD_TEXT_EX(X0 - 10.0d0, POS + 5.0d0, TRIM(STR), TRIM(S_SVG), &
                   0, 13, .FALSE., 'R', '#111111', 3)
           END IF
        END IF

        IF (P < P_END .AND. (P_END - P_START) <= 8) THEN
           CALL Set_Color('#111111')
           CALL Set_Style(LW=1.0d0, DASH=0, OPACITY=1.0d0, LAYER=2)
           DO M = 2, 9
              MVAL = real(P, 8) + LOG10(real(M, 8))
              POS = Y1 - (MVAL - AX_YMIN) / MAX(1.0d-12, AX_YMAX - AX_YMIN) * PH
              IF (POS > Y0 .AND. POS < Y1) THEN
                 CALL ADD_LINE_F(X0, POS, X0 + 4.5d0, POS)
                 CALL ADD_LINE_F(X1, POS, X1 - 4.5d0, POS)
              END IF
           END DO
        END IF
      END DO
    END IF

    !draw axis box
    CALL ADD_RECT(X0, Y0, PW, PH, 'none', '#111111', 2.0d0, 1.0d0, 2)

    CALL ADD_TEXT_EX(X0 + 0.5d0 * PW, real(WIN_H - 24, 8), XLABEL, XL_SVG, &
         0, 15, .TRUE., 'C', '#111111', 3)
    CALL ADD_TEXT_EX(34.0d0, Y0 + 0.5d0 * PH, YLABEL, YL_SVG, &
         -90, 15, .TRUE., 'C', '#111111', 3)  !here we rotate y axis label 90 deg.

    CALL Set_Color(SAVE_CLR)
    CALL Set_Style(LW=SAVE_LW, DASH=SAVE_DASH, LAYER=SAVE_LYR)
  END SUBROUTINE Draw_Axes


  !*******************************************************************
  SUBROUTINE DRAW_MARKER_AT(SX, SY, MTYPE, SZ, CLR, LYR)
    REAL(8), INTENT(IN) :: SX, SY, SZ
    INTEGER, INTENT(IN) :: MTYPE, LYR
    CHARACTER(LEN=*), INTENT(IN) :: CLR
    CHARACTER(LEN=24) :: SAVE_CLR
    REAL(8) :: SAVE_LW
    INTEGER :: SAVE_DASH, SAVE_LYR

    SAVE_CLR = CUR_COLOR
    SAVE_LW = CUR_LW
    SAVE_DASH = CUR_DASH
    SAVE_LYR = CUR_LAYER

    CALL Set_Color(CLR)
    CALL Set_Style(LW=1.6d0, DASH=0, OPACITY=1.0d0, LAYER=LYR)

    SELECT CASE(MTYPE)
    CASE(1)
       CALL ADD_CIRCLE(SX, SY, SZ, CLR, '#111111', 1.1d0, 1.0d0, 0, LYR)
    CASE(2)
       CALL ADD_RECT(SX - SZ, SY - SZ, 2.0d0*SZ, 2.0d0*SZ, '#FFFFFF', CLR, &
            1.8d0, 1.0d0, LYR)
    CASE(3)
       CALL ADD_LINE_F(SX, SY - SZ*1.15d0, SX + SZ*1.1d0, SY + SZ*0.9d0)
       CALL ADD_LINE_F(SX + SZ*1.1d0, SY + SZ*0.9d0, SX - SZ*1.1d0, SY + SZ*0.9d0)
       CALL ADD_LINE_F(SX - SZ*1.1d0, SY + SZ*0.9d0, SX, SY - SZ*1.15d0)
    CASE(4)
       CALL ADD_LINE_F(SX, SY - SZ*1.2d0, SX + SZ*1.1d0, SY)
       CALL ADD_LINE_F(SX + SZ*1.1d0, SY, SX, SY + SZ*1.2d0)
       CALL ADD_LINE_F(SX, SY + SZ*1.2d0, SX - SZ*1.1d0, SY)
       CALL ADD_LINE_F(SX - SZ*1.1d0, SY, SX, SY - SZ*1.2d0)
    CASE(5)
       CALL ADD_LINE_F(SX - SZ, SY, SX + SZ, SY)
       CALL ADD_LINE_F(SX, SY - SZ, SX, SY + SZ)
    CASE DEFAULT
       CALL ADD_LINE_F(SX - SZ*0.85d0, SY - SZ*0.85d0, SX + SZ*0.85d0, SY + SZ*0.85d0)
       CALL ADD_LINE_F(SX - SZ*0.85d0, SY + SZ*0.85d0, SX + SZ*0.85d0, SY - SZ*0.85d0)
    END SELECT

    CALL Set_Color(SAVE_CLR)
    CALL Set_Style(LW=SAVE_LW, DASH=SAVE_DASH, LAYER=SAVE_LYR)
  END SUBROUTINE DRAW_MARKER_AT

  !here looping through data arr to make line segments or points
  SUBROUTINE Draw_Curve(X, Y, N, STYLE)
    INTEGER, INTENT(IN) :: N
    REAL(8), INTENT(IN) :: X(N)
    REAL(8), INTENT(IN) :: Y(N)
    CHARACTER(LEN=1), INTENT(IN) :: STYLE 
    INTEGER :: I
    REAL(8) :: SX
    REAL(8) :: SY

    IF (STYLE == 'L' .OR. STYLE == 'B') THEN
       DO I = 1, N-1
          IF (IS_X_LOG .AND. (X(I) <= 0.0d0 .OR. X(I+1) <= 0.0d0)) CYCLE
          IF (IS_Y_LOG .AND. (Y(I) <= 0.0d0 .OR. Y(I+1) <= 0.0d0)) CYCLE
          CALL DRAW_SEGMENT(X(I), Y(I), X(I+1), Y(I+1))
       END DO
    END IF

    IF (STYLE == 'S' .OR. STYLE == 'B') THEN
      DO I = 1, N
        IF (IS_X_LOG .AND. X(I) <= 0.0d0) CYCLE
        IF (IS_Y_LOG .AND. Y(I) <= 0.0d0) CYCLE
        CALL DATA_TO_SCREEN(X(I), Y(I), SX, SY)
        IF (SX >= real(PADX, 8) .AND. SX <= real(WIN_W - PADR, 8) .AND. &
            SY >= real(PADY_TOP, 8) .AND. SY <= real(WIN_H - PADY_BOT, 8)) THEN
           CALL DRAW_MARKER_AT(SX, SY, CUR_MARKER, 4.2d0, CUR_COLOR, CUR_LAYER)
        END IF
      END DO
    END IF
  END SUBROUTINE Draw_Curve

  !draw spectrum curve cleanly without log(0) diagonal artifacts
  SUBROUTINE Draw_Spectrum_Curve(X, Y, N)
    INTEGER, INTENT(IN) :: N
    REAL(8), INTENT(IN) :: X(N), Y(N)
    INTEGER :: I
    REAL(8) :: Y_FLOOR, X_EDGE

    IF (IS_Y_LOG) THEN
       Y_FLOOR = 10.0d0 ** AX_YMIN
    ELSE
       Y_FLOOR = AX_YMIN
    END IF

    DO I = 1, N - 1
       IF (IS_X_LOG .AND. (X(I) <= 0.0d0 .OR. X(I+1) <= 0.0d0)) CYCLE
       IF (Y(I) > 0.0d0 .AND. Y(I+1) > 0.0d0) THEN
          CALL DRAW_SEGMENT(X(I), Y(I), X(I+1), Y(I+1))
       ELSE IF (Y(I) <= 0.0d0 .AND. Y(I+1) > 0.0d0) THEN
          X_EDGE = 0.5d0 * (X(I) + X(I+1))
          CALL DRAW_SEGMENT(X_EDGE, Y_FLOOR, X(I+1), Y(I+1))
       ELSE IF (Y(I) > 0.0d0 .AND. Y(I+1) <= 0.0d0) THEN
          X_EDGE = 0.5d0 * (X(I) + X(I+1))
          CALL DRAW_SEGMENT(X(I), Y(I), X_EDGE, Y_FLOOR)
       END IF
    END DO
  END SUBROUTINE Draw_Spectrum_Curve

  !*******************************************************************
  !draw legend on right margin of the plot, no overlap with the plot
  SUBROUTINE Draw_Legend(LABELS, COLORS, STYLES, N, DASHES, MARKERS)
    INTEGER, INTENT(IN) :: N
    CHARACTER(LEN=*), INTENT(IN) :: LABELS(N), COLORS(N)
    CHARACTER(LEN=1), INTENT(IN) :: STYLES(N)
    INTEGER, INTENT(IN), OPTIONAL :: DASHES(N), MARKERS(N)
    INTEGER :: I, D_I, M_I
    REAL(8) :: BOX_X, BOX_Y, BOX_W, BOX_H, ROW_Y, LX1, LX2
    CHARACTER(LEN=24) :: SAVE_CLR
    REAL(8) :: SAVE_LW
    INTEGER :: SAVE_DASH, SAVE_LYR
    
    IF (N <= 0) RETURN
    SAVE_CLR = CUR_COLOR
    SAVE_LW = CUR_LW
    SAVE_DASH = CUR_DASH
    SAVE_LYR = CUR_LAYER

    BOX_X = real(WIN_W - PADR + 18, 8)
    BOX_Y = real(PADY_TOP, 8)
    BOX_W = real(PADR - 32, 8)
    BOX_H = real(N * 28 + 16, 8)

    CALL ADD_RECT(BOX_X, BOX_Y, BOX_W, BOX_H, '#FFFFFF', '#111111', 1.4d0, 1.0d0, 2)

    LX1 = BOX_X + 12.0d0
    LX2 = BOX_X + 44.0d0
    
    DO I = 1, N
       ROW_Y = BOX_Y + 20.0d0 + real(I - 1, 8) * 28.0d0
       D_I = 0
       M_I = 1
       IF (PRESENT(DASHES)) D_I = DASHES(I)
       IF (PRESENT(MARKERS)) M_I = MARKERS(I)

       IF (STYLES(I) == 'F') THEN
          CALL ADD_RECT(LX1, ROW_Y - 6.0d0, 28.0d0, 12.0d0, COLORS(I), &
               '#111111', 1.1d0, 0.90d0, 3)
       ELSE
          IF (STYLES(I) == 'L' .OR. STYLES(I) == 'B') THEN
             CALL Set_Color(COLORS(I))
             CALL Set_Style(LW=2.2d0, DASH=D_I, OPACITY=1.0d0, LAYER=3)
             CALL ADD_LINE_F(LX1, ROW_Y, LX2, ROW_Y)
          END IF
          IF (STYLES(I) == 'S' .OR. STYLES(I) == 'B') THEN
             CALL DRAW_MARKER_AT(0.5d0*(LX1 + LX2), ROW_Y, M_I, 4.2d0, COLORS(I), 3)
          END IF
       END IF

       CALL ADD_TEXT_EX(LX2 + 10.0d0, ROW_Y + 4.5d0, TRIM(LABELS(I)), &
            TRIM(LABELS(I)), 0, 12, .FALSE., 'L', '#111111', 3)
    END DO

    CALL Set_Color(SAVE_CLR)
    CALL Set_Style(LW=SAVE_LW, DASH=SAVE_DASH, LAYER=SAVE_LYR)
  END SUBROUTINE Draw_Legend

  
  !*******************************************************************
  !SVG format writer/exporter here
  SUBROUTINE Export_SVG(FNAME)
    CHARACTER(LEN=*), INTENT(IN) :: FNAME
    INTEGER :: I, LYR
    CHARACTER(LEN=32) :: DASH_ATTR, ANCHOR_STR, WEIGHT_STR
    !character(len=1024) :: output_filex
    !output_filex = trim(out_dir)//'/'//FNAME

    !print*, output_filex
    
    OPEN(UNIT=10, FILE=trim(out_dir)//'/'//TRIM(FNAME), STATUS='REPLACE', ACTION='WRITE')
    WRITE(10,'(A)') '<?xml version="1.0" encoding="UTF-8"?>'
    WRITE(10,'(A,A,A,A,A,A,A,A,A)') &
         '<svg xmlns="http://www.w3.org/2000/svg" width="', ISTR(WIN_W), &
         '" height="', ISTR(WIN_H), '" viewBox="0 0 ', ISTR(WIN_W), ' ', &
         ISTR(WIN_H), '">'
    WRITE(10,'(A)') '<rect width="100%" height="100%" fill="#FFFFFF"/>'

    DO LYR = 0, 3
       !write rectangles in layer
       DO I = 1, NRECTS
          IF (RECTS(I)%LAYER /= LYR) CYCLE
          WRITE(10, '(A)', ADVANCE='NO') '<rect x="' // FSTR(RECTS(I)%X) // &
               '" y="' // FSTR(RECTS(I)%Y) // '" width="' // FSTR(RECTS(I)%W) // &
               '" height="' // FSTR(RECTS(I)%H) // '"'
          IF (RECTS(I)%HAS_FILL) THEN
             WRITE(10, '(A)', ADVANCE='NO') ' fill="' // TRIM(RECTS(I)%FILL_CLR) // &
                  '" fill-opacity="' // FSTR(RECTS(I)%OPACITY) // '"'
          ELSE
             WRITE(10, '(A)', ADVANCE='NO') ' fill="none"'
          END IF
          IF (RECTS(I)%HAS_STROKE) THEN
             WRITE(10, '(A)', ADVANCE='NO') ' stroke="' // TRIM(RECTS(I)%STROKE_CLR) // &
                  '" stroke-width="' // FSTR(RECTS(I)%LW) // '"'
          END IF
          WRITE(10, '(A)') '/>'
       END DO

       !write lines in layer
       DO I = 1, NLINES
          !PRINT*, NLINES
          IF (LINES(I)%LAYER /= LYR) CYCLE
          SELECT CASE(LINES(I)%DASH)
          CASE(1)
             DASH_ATTR = ' stroke-dasharray="8,5"'
          CASE(2)
             DASH_ATTR = ' stroke-dasharray="9,4,2,4"'
          CASE(3)
             DASH_ATTR = ' stroke-dasharray="2.5,3.5"'
          CASE DEFAULT
             DASH_ATTR = ''
          END SELECT
          WRITE(10,'(A)') '<line x1="' // FSTR(LINES(I)%X1) // &
               '" y1="' // FSTR(LINES(I)%Y1) // '" x2="' // FSTR(LINES(I)%X2) // &
               '" y2="' // FSTR(LINES(I)%Y2) // '" stroke="' // TRIM(LINES(I)%CLR) // &
               '" stroke-width="' // FSTR(LINES(I)%LW) // &
               '" stroke-opacity="' // FSTR(LINES(I)%OPACITY) // &
               '" stroke-linecap="round"' // TRIM(DASH_ATTR) // '/>'
       END DO

       !write circles in layer
       DO I = 1, NCIRCLES
          IF (CIRCLES(I)%LAYER /= LYR) CYCLE
          IF (CIRCLES(I)%DASH == 1) THEN
             DASH_ATTR = ' stroke-dasharray="5,4"'
          ELSE
             DASH_ATTR = ''
          END IF
          WRITE(10, '(A)', ADVANCE='NO') '<circle cx="' // FSTR(CIRCLES(I)%CX) // &
               '" cy="' // FSTR(CIRCLES(I)%CY) // '" r="' // FSTR(CIRCLES(I)%R) // '"'
          IF (CIRCLES(I)%HAS_FILL) THEN
             WRITE(10, '(A)', ADVANCE='NO') ' fill="' // TRIM(CIRCLES(I)%FILL_CLR) // &
                  '" fill-opacity="' // FSTR(CIRCLES(I)%OPACITY) // '"'
          ELSE
             WRITE(10, '(A)', ADVANCE='NO') ' fill="none"'
          END IF
          IF (CIRCLES(I)%HAS_STROKE) THEN
             WRITE(10, '(A)', ADVANCE='NO') ' stroke="' // TRIM(CIRCLES(I)%STROKE_CLR) // &
                  '" stroke-width="' // FSTR(CIRCLES(I)%LW) // '"' // TRIM(DASH_ATTR)
          END IF
          WRITE(10, '(A)') '/>'
       END DO

       !write text labels in layer
       DO I = 1, NTEXTS
          IF (TEXTS(I)%LAYER /= LYR) CYCLE
          SELECT CASE(TEXTS(I)%ANCHOR)
          CASE('C')
             ANCHOR_STR = 'middle'
          CASE('R')
             ANCHOR_STR = 'end'
          CASE DEFAULT
             ANCHOR_STR = 'start'
          END SELECT

          IF (TEXTS(I)%BOLD) THEN
             WEIGHT_STR = 'bold'
          ELSE
             WEIGHT_STR = 'normal'
          END IF

          WRITE(10, '(A)', ADVANCE='NO') '<text x="' // FSTR(TEXTS(I)%X) // &
               '" y="' // FSTR(TEXTS(I)%Y) // '"'
          IF (TEXTS(I)%ANGLE /= 0) THEN
             WRITE(10, '(A)', ADVANCE='NO') ' transform="rotate(' // &
                  ISTR(TEXTS(I)%ANGLE) // ' ' // FSTR(TEXTS(I)%X) // ' ' // &
                  FSTR(TEXTS(I)%Y) // ')"'
          END IF
          WRITE(10, '(A)') ' fill="' // TRIM(TEXTS(I)%CLR) // &
               '" font-family="Helvetica, Arial, sans-serif" font-size="' // &
               ISTR(TEXTS(I)%FSIZE) // '" font-weight="' // TRIM(WEIGHT_STR) // &
               '" text-anchor="' // TRIM(ANCHOR_STR) // '">' // &
               TRIM(TEXTS(I)%SVG_TXT) // '</text>'
       END DO
    END DO

    WRITE(10,'(A)') '</svg>'
    CLOSE(10)
    PRINT *, "--> PLOT SAVED TO SVG: ", TRIM(FNAME)
  END SUBROUTINE Export_SVG
  !*******************************************************************

  

  !render plot listener for X11 trigger
  SUBROUTINE Render_Plot()
    INTEGER(C_INT), TARGET :: EV_BUFFER(48) 
    INTEGER(C_INT) :: EV_TYPE
    INTEGER :: I
    INTEGER :: J
    INTEGER :: K
    INTEGER :: LYR
    INTEGER :: SLEN
    INTEGER :: XDRAW
    LOGICAL :: RUNNING
    CHARACTER(KIND=C_CHAR, LEN=1), ALLOCATABLE :: CTXT(:)
    INTEGER(C_LONG) :: LAST_PIX
    REAL(8) :: ANG1, ANG2, TWO_PI
    INTEGER(C_INT) :: CX1, CY1, CX2, CY2

    IF (.NOT. C_ASSOCIATED(DISP)) RETURN
    TWO_PI = 2.0d0 * ACOS(-1.0d0)

    CALL ADD_TEXT(WIN_W/2 - 100, 68, "(PRESS ANY KEY IN WINDOW TO CLOSE)")

    RUNNING = .TRUE.
    DO WHILE(RUNNING)

       CALL CHECK( XNextEvent(DISP, C_LOC(EV_BUFFER)) )

       EV_TYPE = EV_BUFFER(1) 
      
       IF (EV_TYPE == 12) THEN
          LAST_PIX = -1_C_LONG
          DO LYR = 0, 3
             DO I = 1, NRECTS
                IF (RECTS(I)%LAYER /= LYR) CYCLE
                IF (RECTS(I)%HAS_FILL) THEN
                   IF (RECTS(I)%FILL_PIX /= LAST_PIX) THEN
                      CALL CHECK(XSetForeground(DISP, GC, RECTS(I)%FILL_PIX))
                      LAST_PIX = RECTS(I)%FILL_PIX
                   END IF
                   CALL CHECK(XFillRectangle(DISP, WIN, GC, &
                        INT(NINT(RECTS(I)%X), C_INT), INT(NINT(RECTS(I)%Y), C_INT), &
                        INT(MAX(1, NINT(RECTS(I)%W)), C_INT), &
                        INT(MAX(1, NINT(RECTS(I)%H)), C_INT)))
                END IF
                IF (RECTS(I)%HAS_STROKE) THEN
                   IF (RECTS(I)%STROKE_PIX /= LAST_PIX) THEN
                      CALL CHECK(XSetForeground(DISP, GC, RECTS(I)%STROKE_PIX))
                      LAST_PIX = RECTS(I)%STROKE_PIX
                   END IF
                   CALL CHECK(XDrawRectangle(DISP, WIN, GC, &
                        INT(NINT(RECTS(I)%X), C_INT), INT(NINT(RECTS(I)%Y), C_INT), &
                        INT(MAX(1, NINT(RECTS(I)%W)), C_INT), &
                        INT(MAX(1, NINT(RECTS(I)%H)), C_INT)))
                END IF
             END DO

             DO I = 1, NLINES
                IF (LINES(I)%LAYER /= LYR) CYCLE
                IF (LINES(I)%PIXEL /= LAST_PIX) THEN
                   CALL CHECK(XSetForeground(DISP, GC, LINES(I)%PIXEL))
                   LAST_PIX = LINES(I)%PIXEL
                END IF
                CALL CHECK(XDrawLine(DISP, WIN, GC, &
                     INT(NINT(LINES(I)%X1), C_INT), INT(NINT(LINES(I)%Y1), C_INT), &
                     INT(NINT(LINES(I)%X2), C_INT), INT(NINT(LINES(I)%Y2), C_INT)))
             END DO

             DO I = 1, NCIRCLES
                IF (CIRCLES(I)%LAYER /= LYR) CYCLE
                IF (CIRCLES(I)%HAS_STROKE) THEN
                   CALL CHECK(XSetForeground(DISP, GC, CIRCLES(I)%STROKE_PIX))
                   LAST_PIX = CIRCLES(I)%STROKE_PIX
                ELSE IF (CIRCLES(I)%HAS_FILL) THEN
                   CALL CHECK(XSetForeground(DISP, GC, CIRCLES(I)%FILL_PIX))
                   LAST_PIX = CIRCLES(I)%FILL_PIX
                END IF
                DO K = 1, 24
                   ANG1 = TWO_PI * real(K - 1, 8) / 24.0d0
                   ANG2 = TWO_PI * real(K, 8) / 24.0d0
                   CX1 = INT(NINT(CIRCLES(I)%CX + CIRCLES(I)%R * COS(ANG1)), C_INT)
                   CY1 = INT(NINT(CIRCLES(I)%CY + CIRCLES(I)%R * SIN(ANG1)), C_INT)
                   CX2 = INT(NINT(CIRCLES(I)%CX + CIRCLES(I)%R * COS(ANG2)), C_INT)
                   CY2 = INT(NINT(CIRCLES(I)%CY + CIRCLES(I)%R * SIN(ANG2)), C_INT)
                   CALL CHECK(XDrawLine(DISP, WIN, GC, CX1, CY1, CX2, CY2))
                END DO
             END DO

             DO I = 1, NTEXTS
                IF (TEXTS(I)%LAYER /= LYR) CYCLE
                IF (TEXTS(I)%PIXEL /= LAST_PIX) THEN
                   CALL CHECK(XSetForeground(DISP, GC, TEXTS(I)%PIXEL))
                   LAST_PIX = TEXTS(I)%PIXEL
                END IF
                SLEN = LEN_TRIM(TEXTS(I)%TXT)
                IF (SLEN <= 0) CYCLE
                XDRAW = NINT(TEXTS(I)%X)
                IF (TEXTS(I)%ANCHOR == 'C') XDRAW = XDRAW - SLEN * 3
                IF (TEXTS(I)%ANCHOR == 'R') XDRAW = XDRAW - SLEN * 6
                ALLOCATE(CTXT(SLEN))
                DO J = 1, SLEN; CTXT(J) = TEXTS(I)%TXT(J:J); END DO
                CALL CHECK(XDrawString(DISP, WIN, GC, INT(XDRAW, C_INT), &
                     INT(NINT(TEXTS(I)%Y), C_INT), CTXT, INT(SLEN, C_INT)))
                DEALLOCATE(CTXT)
             END DO
          END DO
       ELSE IF (EV_TYPE == 2) THEN
          RUNNING = .FALSE.
       END IF
    END DO

    CALL CHECK( XCloseDisplay(DISP) )
    DISP = C_NULL_PTR

  END SUBROUTINE Render_Plot

  !******************************************
  !convert real(8) to string
  SUBROUTINE NUM2STR(VAL, STR)
    REAL(8), INTENT(IN) :: VAL
    CHARACTER(LEN=*), INTENT(OUT) :: STR
    CHARACTER(LEN=32) :: TMP
    REAL(8) :: AVAL
    INTEGER :: L

    AVAL = ABS(VAL)
    IF (AVAL < 1.0d-13) THEN
       STR = '0'
       RETURN
    END IF

    IF (AVAL >= 1.0d-2 .AND. AVAL < 1.0d5) THEN
       IF (ABS(VAL - ANINT(VAL)) <= 1.0d-6 * MAX(1.0d0, AVAL)) THEN
          WRITE(TMP, '(I0)') NINT(VAL, 8)
          STR = TRIM(ADJUSTL(TMP))
          RETURN
       ELSE IF (ABS(VAL*10.0d0 - ANINT(VAL*10.0d0)) <= 1.0d-5 * MAX(1.0d0, AVAL)) THEN
          WRITE(TMP, '(F16.1)') VAL
       ELSE IF (ABS(VAL*100.0d0 - ANINT(VAL*100.0d0)) <= 1.0d-4 * MAX(1.0d0, AVAL)) THEN
          WRITE(TMP, '(F16.2)') VAL
       ELSE
          WRITE(TMP, '(F16.3)') VAL
       END IF
       TMP = ADJUSTL(TMP)
       L = LEN_TRIM(TMP)
       DO WHILE (L > 2 .AND. TMP(L:L) == '0' .AND. TMP(L-1:L-1) /= '.')
          TMP(L:L) = ' '
          L = L - 1
       END DO
       STR = TRIM(TMP)
    ELSE
       WRITE(TMP, '(ES10.2)') VAL
       STR = TRIM(ADJUSTL(TMP))
    END IF
  END SUBROUTINE NUM2STR
  !******************************************
  
  
  !Cohen-Sutherland clipping
  FUNCTION GET_OUTCODE(X, Y) RESULT(CODE)
    REAL(8), INTENT(IN) :: X
    REAL(8), INTENT(IN) :: Y
    INTEGER :: CODE

    CODE = 0

    IF (X < real(PADX, 8) - 1.0d-5) CODE = IOR(CODE, C_LEFT)
    IF (X > real(WIN_W - PADR, 8) + 1.0d-5) CODE = IOR(CODE, C_RIGHT)
    IF (Y < real(PADY_TOP, 8) - 1.0d-5) CODE = IOR(CODE, C_TOP)
    IF (Y > real(WIN_H - PADY_BOT, 8) + 1.0d-5) CODE = IOR(CODE, C_BOTTOM)

  END FUNCTION GET_OUTCODE
  !******************************************
  
  !clips lines that exceed the axes boundary using Cohen-Sutherland algorithm
  SUBROUTINE CLIP_AND_ADD(X1_IN, Y1_IN, X2_IN, Y2_IN)
    REAL(8), INTENT(IN) :: X1_IN
    REAL(8), INTENT(IN) :: Y1_IN
    REAL(8), INTENT(IN) :: X2_IN
    REAL(8), INTENT(IN) :: Y2_IN
    REAL(8) :: X1
    REAL(8) :: Y1
    REAL(8) :: X2
    REAL(8) :: Y2
    REAL(8) :: X
    REAL(8) :: Y
    REAL(8) :: XL, XR, YT, YB
    INTEGER :: OUT0
    INTEGER :: OUT1
    INTEGER :: OUT_OUT
    INTEGER :: ITER
    LOGICAL :: ACCEPT

    XL = real(PADX, 8)
    XR = real(WIN_W - PADR, 8)
    YT = real(PADY_TOP, 8)
    YB = real(WIN_H - PADY_BOT, 8)

    X = 0.0d0
    Y = 0.0d0

    X1 = X1_IN
    Y1 = Y1_IN
    X2 = X2_IN
    Y2 = Y2_IN
    ACCEPT = .FALSE.

    OUT0 = GET_OUTCODE(X1, Y1)
    OUT1 = GET_OUTCODE(X2, Y2)

    DO ITER = 1, 20
      IF (IOR(OUT0, OUT1) == 0) THEN        
        ACCEPT = .TRUE.; EXIT
      ELSE IF (IAND(OUT0, OUT1) /= 0) THEN 
        EXIT
      ELSE
        
         IF (OUT0 /= 0) THEN
            OUT_OUT = OUT0
         ELSE
            OUT_OUT = OUT1
         END IF

         IF (IAND(OUT_OUT, C_TOP) /= 0) THEN
           !IF (Y2 /= Y1) X = X1 + (X2 - X1) * (real(PADY) - Y1) / (Y2 - Y1)
            IF (ABS(Y2 - Y1) > 1.0d-12) X = X1 + (X2 - X1) * (YT - Y1) / (Y2 - Y1)
            Y = YT
         ELSE IF (IAND(OUT_OUT, C_BOTTOM) /= 0) THEN
           !IF (Y2 /= Y1) X = X1 + (X2 - X1) * (real(WIN_H - PADY) - Y1) / (Y2 - Y1)
            IF (ABS(Y2 - Y1) > 1.0d-12) X = X1 + (X2 - X1) * (YB - Y1) / (Y2 - Y1)
            Y = YB
         ELSE IF (IAND(OUT_OUT, C_RIGHT) /= 0) THEN
           !IF (X2 /= X1) Y = Y1 + (Y2 - Y1) * (real(WIN_W - PADR) - X1) / (X2 - X1)
            IF (ABS(X2 - X1) > 1.0d-12) Y = Y1 + (Y2 - Y1) * (XR - X1) / (X2 - X1)
            X = XR
         ELSE IF (IAND(OUT_OUT, C_LEFT) /= 0) THEN
            !IF (X2 /= X1) Y = Y1 + (Y2 - Y1) * (real(PADX) - X1) / (X2 - X1)
            IF (ABS(X2 - X1) > 1.0d-12) Y = Y1 + (Y2 - Y1) * (XL - X1) / (X2 - X1)
            X = XL
         END IF
        
         IF (OUT_OUT == OUT0) THEN
            X1 = X
            Y1 = Y
            OUT0 = GET_OUTCODE(X1, Y1)
         ELSE
           X2 = X
           Y2 = Y
           OUT1 = GET_OUTCODE(X2, Y2)
         END IF
      END IF
    END DO

    IF (ACCEPT) CALL ADD_LINE_F(X1, Y1, X2, Y2)

  END SUBROUTINE CLIP_AND_ADD

  !*************************************
  !push sub-pixel coordinate to line data
  SUBROUTINE ADD_LINE_F(X1, Y1, X2, Y2)
    REAL(8), INTENT(IN) :: X1, Y1, X2, Y2

    IF (NLINES >= SIZE(LINES)) CALL EXPAND_LINES()

    NLINES = NLINES + 1

    LINES(NLINES)%X1 = X1
    LINES(NLINES)%Y1 = Y1
    LINES(NLINES)%X2 = X2
    LINES(NLINES)%Y2 = Y2
    LINES(NLINES)%LW = CUR_LW
    LINES(NLINES)%OPACITY = CUR_OPACITY
    LINES(NLINES)%DASH = CUR_DASH
    LINES(NLINES)%LAYER = CUR_LAYER
    LINES(NLINES)%CLR = CUR_COLOR
    LINES(NLINES)%PIXEL = CUR_PIXEL
  END SUBROUTINE ADD_LINE_F

  !push coordinate to line data
  SUBROUTINE ADD_LINE(X1, Y1, X2, Y2)
    INTEGER, INTENT(IN) :: X1
    INTEGER, INTENT(IN) :: Y1
    INTEGER, INTENT(IN) :: X2
    INTEGER, INTENT(IN) :: Y2
    CALL ADD_LINE_F(real(X1, 8), real(Y1, 8), real(X2, 8), real(Y2, 8))
  END SUBROUTINE ADD_LINE
  !**************************************

  !push rectangle primitive to rect data
  SUBROUTINE ADD_RECT(X, Y, W, H, FILL_C, STROKE_C, LW, OPAC, LYR)
    REAL(8), INTENT(IN) :: X, Y, W, H, LW, OPAC
    CHARACTER(LEN=*), INTENT(IN) :: FILL_C, STROKE_C
    INTEGER, INTENT(IN) :: LYR
    IF (W <= 0.0d0 .OR. H <= 0.0d0) RETURN
    IF (NRECTS >= SIZE(RECTS)) CALL EXPAND_RECTS()
    NRECTS = NRECTS + 1
    RECTS(NRECTS)%X = X
    RECTS(NRECTS)%Y = Y
    RECTS(NRECTS)%W = W
    RECTS(NRECTS)%H = H
    RECTS(NRECTS)%LW = LW
    RECTS(NRECTS)%OPACITY = OPAC
    RECTS(NRECTS)%LAYER = LYR
    RECTS(NRECTS)%HAS_FILL = (LEN_TRIM(FILL_C) > 0 .AND. TRIM(FILL_C) /= 'none')
    RECTS(NRECTS)%HAS_STROKE = (LEN_TRIM(STROKE_C) > 0 .AND. TRIM(STROKE_C) /= 'none')
    RECTS(NRECTS)%FILL_CLR = TRIM(FILL_C)
    RECTS(NRECTS)%STROKE_CLR = TRIM(STROKE_C)
    RECTS(NRECTS)%FILL_PIX = 0
    RECTS(NRECTS)%STROKE_PIX = 0
    IF (RECTS(NRECTS)%HAS_FILL) RECTS(NRECTS)%FILL_PIX = GET_X11_PIXEL(FILL_C)
    IF (RECTS(NRECTS)%HAS_STROKE) RECTS(NRECTS)%STROKE_PIX = GET_X11_PIXEL(STROKE_C)
  END SUBROUTINE ADD_RECT

  !push circle primitive to circle data
  SUBROUTINE ADD_CIRCLE(CX, CY, R, FILL_C, STROKE_C, LW, OPAC, DASH, LYR)
    REAL(8), INTENT(IN) :: CX, CY, R, LW, OPAC
    CHARACTER(LEN=*), INTENT(IN) :: FILL_C, STROKE_C
    INTEGER, INTENT(IN) :: DASH, LYR
    IF (R <= 0.0d0) RETURN
    IF (NCIRCLES >= SIZE(CIRCLES)) CALL EXPAND_CIRCLES()
    NCIRCLES = NCIRCLES + 1
    CIRCLES(NCIRCLES)%CX = CX
    CIRCLES(NCIRCLES)%CY = CY
    CIRCLES(NCIRCLES)%R = R
    CIRCLES(NCIRCLES)%LW = LW
    CIRCLES(NCIRCLES)%OPACITY = OPAC
    CIRCLES(NCIRCLES)%DASH = DASH
    CIRCLES(NCIRCLES)%LAYER = LYR
    CIRCLES(NCIRCLES)%HAS_FILL = (LEN_TRIM(FILL_C) > 0 .AND. TRIM(FILL_C) /= 'none')
    CIRCLES(NCIRCLES)%HAS_STROKE = (LEN_TRIM(STROKE_C) > 0 .AND. TRIM(STROKE_C) /= 'none')
    CIRCLES(NCIRCLES)%FILL_CLR = TRIM(FILL_C)
    CIRCLES(NCIRCLES)%STROKE_CLR = TRIM(STROKE_C)
    CIRCLES(NCIRCLES)%FILL_PIX = 0
    CIRCLES(NCIRCLES)%STROKE_PIX = 0
    IF (CIRCLES(NCIRCLES)%HAS_FILL) CIRCLES(NCIRCLES)%FILL_PIX = GET_X11_PIXEL(FILL_C)
    IF (CIRCLES(NCIRCLES)%HAS_STROKE) CIRCLES(NCIRCLES)%STROKE_PIX = GET_X11_PIXEL(STROKE_C)
  END SUBROUTINE ADD_CIRCLE

  PURE SUBROUTINE ESCAPE_SVG_PLAIN(IN_STR, OUT_STR)
    CHARACTER(LEN=*), INTENT(IN) :: IN_STR
    CHARACTER(LEN=240), INTENT(OUT) :: OUT_STR
    INTEGER :: I, P, L
    CHARACTER(LEN=1) :: CH

    OUT_STR = ' '
    P = 1
    L = LEN_TRIM(IN_STR)
    DO I = 1, L
       CH = IN_STR(I:I)
       IF (CH == '&') THEN
          IF (P + 4 <= 240) THEN
             OUT_STR(P:P+4) = '&amp;'
             P = P + 5
          END IF
       ELSE IF (CH == '<') THEN
          IF (P + 3 <= 240) THEN
             OUT_STR(P:P+3) = '&lt;'
             P = P + 4
          END IF
       ELSE IF (CH == '>') THEN
          IF (P + 3 <= 240) THEN
             OUT_STR(P:P+3) = '&gt;'
             P = P + 4
          END IF
       ELSE
          IF (P <= 240) THEN
             OUT_STR(P:P) = CH
             P = P + 1
          END IF
       END IF
    END DO
  END SUBROUTINE ESCAPE_SVG_PLAIN

  !push styled text with anchor and svg tspan support
  SUBROUTINE ADD_TEXT_EX(X, Y, TXT, SVG_TXT, ANGLE, FSIZE, BOLD, ANCHOR, CLR, LYR)
    REAL(8), INTENT(IN) :: X, Y
    CHARACTER(LEN=*), INTENT(IN) :: TXT, SVG_TXT, CLR
    INTEGER, INTENT(IN) :: ANGLE, FSIZE, LYR
    LOGICAL, INTENT(IN) :: BOLD
    CHARACTER(LEN=1), INTENT(IN) :: ANCHOR
    IF (NTEXTS >= SIZE(TEXTS)) CALL EXPAND_TEXTS()
    NTEXTS = NTEXTS + 1
    TEXTS(NTEXTS)%X = X
    TEXTS(NTEXTS)%Y = Y
    TEXTS(NTEXTS)%TXT = TXT
    !auto-escape &, <, > when plain text is passed without explicit SVG markup
    IF (TRIM(TXT) == TRIM(SVG_TXT)) THEN
       CALL ESCAPE_SVG_PLAIN(SVG_TXT, TEXTS(NTEXTS)%SVG_TXT)
    ELSE
       TEXTS(NTEXTS)%SVG_TXT = SVG_TXT
    END IF
    TEXTS(NTEXTS)%ANGLE = ANGLE
    TEXTS(NTEXTS)%FSIZE = FSIZE
    TEXTS(NTEXTS)%BOLD = BOLD
    TEXTS(NTEXTS)%ANCHOR = ANCHOR
    TEXTS(NTEXTS)%CLR = TRIM(CLR)
    TEXTS(NTEXTS)%PIXEL = GET_X11_PIXEL(CLR)
    TEXTS(NTEXTS)%LAYER = LYR
  END SUBROUTINE ADD_TEXT_EX

  
  !push string to texts data
  SUBROUTINE ADD_TEXT(X, Y, TXT, ANGLE)
    INTEGER, INTENT(IN) :: X
    INTEGER, INTENT(IN) :: Y
    CHARACTER(LEN=*), INTENT(IN) :: TXT
    INTEGER, INTENT(IN), OPTIONAL :: ANGLE
    INTEGER :: ANG
    ANG = 0
    IF (PRESENT(ANGLE)) ANG = ANGLE
    CALL ADD_TEXT_EX(real(X, 8), real(Y, 8), TXT, TXT, ANG, 13, .FALSE., &
         'L', CUR_COLOR, 3)
  END SUBROUTINE ADD_TEXT
  !************************************

  !map data coordinates to sub-pixel screen coordinates
  SUBROUTINE DATA_TO_SCREEN(XD, YD, SX, SY)
    REAL(8), INTENT(IN) :: XD, YD
    REAL(8), INTENT(OUT) :: SX, SY
    REAL(8) :: XT, YT
    XT = XD
    IF (IS_X_LOG) XT = LOG10(MAX(XD, 1.0d-30))
    YT = YD
    IF (IS_Y_LOG) YT = LOG10(MAX(YD, 1.0d-30))
    SX = real(PADX, 8) + (XT - AX_XMIN) / MAX(1.0d-12, AX_XMAX - AX_XMIN) * &
         real(WIN_W - PADX - PADR, 8)
    SY = real(WIN_H - PADY_BOT, 8) - (YT - AX_YMIN) / MAX(1.0d-12, AX_YMAX - AX_YMIN) * &
         real(WIN_H - PADY_TOP - PADY_BOT, 8)
  END SUBROUTINE DATA_TO_SCREEN

  !here we convert vals to pixels for drawing seg.
  SUBROUTINE DRAW_SEGMENT(X1, Y1, X2, Y2)
    REAL(8), INTENT(IN) :: X1
    REAL(8), INTENT(IN) :: Y1
    REAL(8), INTENT(IN) :: X2
    REAL(8), INTENT(IN) :: Y2
    REAL(8) :: SX1
    REAL(8) :: SY1
    REAL(8) :: SX2
    REAL(8) :: SY2
    
    CALL DATA_TO_SCREEN(X1, Y1, SX1, SY1)
    CALL DATA_TO_SCREEN(X2, Y2, SX2, SY2)
    CALL CLIP_AND_ADD(SX1, SY1, SX2, SY2)

  END SUBROUTINE DRAW_SEGMENT

  !*******************************************************
  !exact MKM radiobiology calculation matching tally_mod::write_tallies
  SUBROUTINE COMPUTE_CELL_RADIOBIO(zF, zD, let_D, lambda, p0, alpha_a, surv, rbe)
    REAL(8), INTENT(OUT) :: zF(num_cells), zD(num_cells), let_D(num_cells)
    REAL(8), INTENT(OUT) :: lambda(num_cells), p0(num_cells), alpha_a(num_cells)
    REAL(8), INTENT(OUT) :: surv(num_cells), rbe(num_cells)
    INTEGER :: I, J
    REAL(8) :: sum_let, z0, zD_star, det, D_xray

    z0 = (0.204d0 * 150.0d0) / (mat_rho * (bio_domain_d**2))

    DO I = 1, num_cells
       zF(I) = 0.0d0
       zD(I) = 0.0d0
       let_D(I) = 0.0d0
       lambda(I) = 0.0d0
       p0(I) = 1.0d0
       alpha_a(I) = bio_alpha_x
       surv(I) = 1.0d0
       rbe(I) = 1.0d0

       IF (hit_events_nuc(I) > 0) THEN
          zF(I) = sum_z_nuc(I) / real(hit_events_nuc(I), 8)
          sum_let = 0.0d0
          DO J = 1, LET_BINS
             IF (let_hist_nuc(J, I) > 0.0d0) THEN
                let_D(I) = let_D(I) + ((real(J, 8) - 0.5d0) * dLET_bin) * let_hist_nuc(J, I)
                sum_let = sum_let + let_hist_nuc(J, I)
             END IF
          END DO
          IF (sum_let > 0.0d0) let_D(I) = let_D(I) / sum_let

          IF (zF(I) > 0.0d0) THEN
             lambda(I) = bio_target_dose / zF(I)
             p0(I) = EXP(-lambda(I))
          END IF

          IF (let_D(I) > 0.0d0) THEN
             zD(I) = (0.204d0 * let_D(I)) / (mat_rho * (bio_domain_d**2))
          END IF

          IF (zD(I) > 0.0d0) THEN
             zD_star = (z0**2 / zD(I)) * (1.0d0 - EXP(-(zD(I)**2) / (z0**2)))
          ELSE
             zD_star = 0.0d0
          END IF

          alpha_a(I) = bio_alpha_x + bio_beta_x * zD_star
          surv(I) = EXP(-alpha_a(I)*bio_target_dose - bio_beta_x*(bio_target_dose**2))

          IF (bio_target_dose > 0.0d0 .AND. bio_beta_x > 0.0d0) THEN
             det = bio_alpha_x**2 - 4.0d0 * bio_beta_x * LOG(MAX(surv(I), 1.0d-30))
             IF (det >= 0.0d0) THEN
                D_xray = (-bio_alpha_x + SQRT(det)) / (2.0d0 * bio_beta_x)
                rbe(I) = D_xray / bio_target_dose
             END IF
          END IF
       END IF
    END DO
  END SUBROUTINE COMPUTE_CELL_RADIOBIO

  !selects up to 6 representative cells spanning unique radial shells in um
  SUBROUTINE SELECT_REP_CELLS(REP_IDS, REP_R_UM, N_REP)
    INTEGER, INTENT(OUT) :: REP_IDS(6)
    REAL(8), INTENT(OUT) :: REP_R_UM(6)
    INTEGER, INTENT(OUT) :: N_REP

    REAL(8), ALLOCATABLE :: R_ALL(:)
    INTEGER, ALLOCATABLE :: SHELL_IDS(:)
    REAL(8), ALLOCATABLE :: SHELL_R(:)
    REAL(8) :: X0, Y0, Z0, TOL_UM, BEST_R
    INTEGER :: I, K, BEST_ID, NSHELLS, IDX
    LOGICAL, ALLOCATABLE :: USED(:)

    REP_IDS = 1
    REP_R_UM = 0.0d0
    N_REP = 0
    IF (num_cells <= 0) RETURN

    ALLOCATE(R_ALL(num_cells), USED(num_cells))
    ALLOCATE(SHELL_IDS(num_cells), SHELL_R(num_cells))

    IF (src_mode == 1) THEN
       X0 = src_x
       Y0 = src_y
       Z0 = src_z
    ELSE
       BEST_ID = MAXLOC(cells_src_prob, DIM=1)
       IF (BEST_ID < 1 .OR. BEST_ID > num_cells) BEST_ID = 1
       X0 = cells_x(BEST_ID)
       Y0 = cells_y(BEST_ID)
       Z0 = cells_z(BEST_ID)
    END IF

    DO I = 1, num_cells
       R_ALL(I) = 1.0d4 * SQRT((cells_x(I) - X0)**2 + &
                               (cells_y(I) - Y0)**2 + (cells_z(I) - Z0)**2)
       USED(I) = (hit_events_nuc(I) <= 0)
    END DO

    IF (ALL(USED)) USED = .FALSE.

    TOL_UM = MAX(1.5d0, 0.25d0 * 1.0d4 * cells_r_cyto(1))
    NSHELLS = 0

    DO
       BEST_ID = 0
       BEST_R = HUGE(1.0d0)
       DO I = 1, num_cells
          IF (.NOT. USED(I) .AND. R_ALL(I) < BEST_R) THEN
             BEST_R = R_ALL(I)
             BEST_ID = I
          END IF
       END DO
       IF (BEST_ID == 0) EXIT

       NSHELLS = NSHELLS + 1
       SHELL_IDS(NSHELLS) = BEST_ID
       SHELL_R(NSHELLS) = BEST_R

       DO I = 1, num_cells
          IF (ABS(R_ALL(I) - BEST_R) <= TOL_UM) USED(I) = .TRUE.
       END DO
    END DO

    IF (NSHELLS <= 6) THEN
       N_REP = NSHELLS
       DO K = 1, N_REP
          REP_IDS(K) = SHELL_IDS(K)
          REP_R_UM(K) = SHELL_R(K)
       END DO
    ELSE
       N_REP = 6
       DO K = 1, 6
          IDX = 1 + NINT(real(K - 1, 8) * real(NSHELLS - 1, 8) / 5.0d0)
          REP_IDS(K) = SHELL_IDS(IDX)
          REP_R_UM(K) = SHELL_R(IDX)
       END DO
    END IF

    DEALLOCATE(R_ALL, USED, SHELL_IDS, SHELL_R)
  END SUBROUTINE SELECT_REP_CELLS

  !smooth 5-stop plasma colormap mapping [0,1] to #RRGGBB
  SUBROUTINE COLORMAP_PLASMA(T_IN, HEX_OUT)
    REAL(8), INTENT(IN) :: T_IN
    CHARACTER(LEN=24), INTENT(OUT) :: HEX_OUT
    REAL(8) :: T, S
    INTEGER :: SEG, R_I, G_I, B_I
    INTEGER, PARAMETER :: CR(5) = (/ 13, 126, 204, 248, 240 /)
    INTEGER, PARAMETER :: CG(5) = (/ 8, 3, 71, 149, 249 /)
    INTEGER, PARAMETER :: CB(5) = (/ 135, 168, 120, 64, 33 /)

    T = MIN(1.0d0, MAX(0.0d0, T_IN)) * 4.0d0
    SEG = MIN(4, MAX(1, INT(T) + 1))
    S = T - real(SEG - 1, 8)

    R_I = NINT((1.0d0 - S) * real(CR(SEG), 8) + S * real(CR(MIN(5, SEG+1)), 8))
    G_I = NINT((1.0d0 - S) * real(CG(SEG), 8) + S * real(CG(MIN(5, SEG+1)), 8))
    B_I = NINT((1.0d0 - S) * real(CB(SEG), 8) + S * real(CB(MIN(5, SEG+1)), 8))

    WRITE(HEX_OUT, '("#",3Z2.2)') R_I, G_I, B_I
  END SUBROUTINE COLORMAP_PLASMA


SUBROUTINE PLOT_RESULTS
    INTEGER :: i
    REAL(8) :: vol_nuc
    REAL(8) :: vol_cyto
    REAL(8) :: mass_nuc
    REAL(8) :: mass_cyto
    REAL(8) :: d_nuc
    REAL(8) :: d_cyto
    REAL(8), ALLOCATABLE :: x_arr(:)
    REAL(8), ALLOCATABLE :: y_dose_nuc(:)
    REAL(8), ALLOCATABLE :: y_dose_cyto(:)
    REAL(8), ALLOCATABLE :: e_dose_nuc(:)
    REAL(8), ALLOCATABLE :: e_dose_cyto(:)
    REAL(8), ALLOCATABLE :: y_hits_nuc(:)
    REAL(8), ALLOCATABLE :: y_hits_cyto(:)
    CHARACTER(LEN=20) :: cell_string
    CHARACTER(LEN=*), PARAMETER :: ESC = ACHAR(27)
    CHARACTER(LEN=*), PARAMETER :: RST = ESC // "[0m"      !reset
    CHARACTER(LEN=*), PARAMETER :: BLUE = ESC // "[34m"     !blue
    REAL(8), PARAMETER :: PI = ACOS(-1.0d0)
    REAL(8) :: xmax
    REAL(8) :: ymax_val
    REAL(8) :: ymin_val
    CHARACTER(LEN=28), DIMENSION(2) :: legend_labels
    CHARACTER(LEN=28), DIMENSION(2) :: legend_colors
    CHARACTER(LEN=1), DIMENSION(2)  :: legend_styles
    INTEGER, DIMENSION(2) :: legend_markers
    REAL(8) :: MAX_HIT_NUC, MIN_HIT_NUC
    REAL(8) :: MAX_HIT_CYTO, MIN_HIT_CYTO
    REAL(8) :: x_step, y_step, ax_lo, ax_hi, y_base, sx, sy, sy_base, sy_lo, sy_hi, bw, ymin_pos
    LOGICAL :: use_log_y

    IF (num_cells <= 0) THEN
       RETURN
    END IF
    
    ALLOCATE(x_arr(num_cells))
    ALLOCATE(y_dose_nuc(num_cells))
    ALLOCATE(y_dose_cyto(num_cells))
    ALLOCATE(e_dose_nuc(num_cells))
    ALLOCATE(e_dose_cyto(num_cells))
    ALLOCATE(y_hits_nuc(num_cells))
    ALLOCATE(y_hits_cyto(num_cells))

    WRITE(cell_string, '(I0)') num_cells

    PRINT*, ""
    PRINT '(3A)', BLUE // 'Plotting results for ', TRIM(cell_string), ' cells' // RST

    DO i = 1, num_cells
       !vol_nuc  = (4.0 / 3.0) * PI * (cells(i)%r_nuc**3)
       !vol_cyto = (4.0 / 3.0) * PI * (cells(i)%r_cyto**3) - vol_nuc

       vol_nuc  = (4.0d0 / 3.0d0) * PI * (cells_r_nuc(i)**3)
       vol_cyto = (4.0d0 / 3.0d0) * PI * (cells_r_cyto(i)**3) - vol_nuc
       
       mass_nuc  = vol_nuc * mat_rho / 1000.0d0   
       mass_cyto = vol_cyto * mat_rho / 1000.0d0

       d_nuc  = (dose_nuc(i) * 1.602d-13) / mass_nuc / real(nps_total, 8)
       d_cyto = (dose_cyto(i) * 1.602d-13) / mass_cyto / real(nps_total, 8)
       
       x_arr(i)       = real(i, 8)
       y_dose_nuc(i)  = d_nuc
       y_dose_cyto(i) = d_cyto
       e_dose_nuc(i)  = calc_rel_error(dose_nuc(i), dose_nuc_sq(i), nps_total)
       e_dose_cyto(i) = calc_rel_error(dose_cyto(i), dose_cyto_sq(i), nps_total)
       y_hits_nuc(i)  = real(hits_nuc(i), 8)
       y_hits_cyto(i) = real(hits_cyto(i), 8)
    END DO

    !overall max for y
    ymax_val = MAX(MAXVAL(y_dose_nuc * (1.0d0 + e_dose_nuc)), &
                   MAXVAL(y_dose_cyto * (1.0d0 + e_dose_cyto)))
    
    !ensure higher than 0.0
    ymin_val = HUGE(1.0d0)
    DO i = 1, num_cells
        IF (y_dose_nuc(i) > 0.0d0 .AND. y_dose_nuc(i) < ymin_val) ymin_val = y_dose_nuc(i)
        IF (y_dose_cyto(i) > 0.0d0 .AND. y_dose_cyto(i) < ymin_val) ymin_val = y_dose_cyto(i)
    END DO
    
    !safety if empty
    IF (ymax_val <= 0.0d0) ymax_val = 1.0d0
    IF (ymin_val == HUGE(1.0d0)) ymin_val = ymax_val * 1.0d-4 
    
    IF (ABS(ymax_val - ymin_val) < 1.0d-30) THEN
        ymin_val = ymin_val * 0.1d0 !- 10.0
        ymax_val = ymax_val * 10.0d0 !+10.0
    END IF
    
    xmax = real(num_cells, 8)

    !init
    !CALL Init_Plot(1024, 768)

    !issue here was before the x11 window init was not separated
    !so if render_plot_check was off but svg export was on
    !one could see a flashing x11 empty window, that was so annoying and unprofessional
    !this way i have fixed it to avoid such flash
    PADX = 115; PADR = 260; PADY_TOP = 82; PADY_BOT = 90
    If (RENDER_PLOT_CHECK == 1)then
       call Init_Plot(1100,720)
    else
       call Init_Canvas(1100,720)
    end if
    
    CALL Set_Title('CELLULAR ABSORBED DOSE PER SOURCE ALPHA', &
         'Histories = ' // ISTR(nps_total) // '  |  Error bars: +/- 1 sigma')
    CALL Set_Scale(.FALSE., .TRUE.)  !lin X, log Y

    x_step = MAX(1.0d0, ANINT(xmax / 10.0d0))
    IF (num_cells <= 20) x_step = 1.0d0

    !axes draw (Xmin, Xmax, Ymin, Ymax, Xlabel, Ylabel)
    CALL Draw_Axes(0.3d0, xmax + 0.7d0, ymin_val * 0.7d0, ymax_val * 1.5d0, &
         'Cell ID', 'Absorbed Dose [Gy / history]', XSTEP_OPT=x_step)

    IF (num_cells <= 35) THEN
       y_base = 10.0d0 ** AX_YMIN
       CALL DATA_TO_SCREEN(1.0d0, y_base, sx, sy_base)
       bw = MAX(3.0d0, 0.34d0 * real(WIN_W - PADX - PADR, 8) / real(num_cells + 1, 8))

       DO i = 1, num_cells
          !plot nuc. dose bar + error whisker
          IF (y_dose_nuc(i) > y_base) THEN
             CALL DATA_TO_SCREEN(x_arr(i), y_dose_nuc(i), sx, sy)
             CALL ADD_RECT(sx - bw - 1.0d0, sy, bw, sy_base - sy, &
                  '#D62728', '#111111', 1.1d0, 0.88d0, 1)
             IF (e_dose_nuc(i) > 0.0d0) THEN
                CALL DATA_TO_SCREEN(x_arr(i), MAX(y_base, y_dose_nuc(i)*(1.0d0-e_dose_nuc(i))), sx, sy_lo)
                CALL DATA_TO_SCREEN(x_arr(i), y_dose_nuc(i)*(1.0d0+e_dose_nuc(i)), sx, sy_hi)
                CALL Set_Color('#111111')
                CALL Set_Style(LW=1.3d0, DASH=0, LAYER=2)
                CALL ADD_LINE_F(sx - 0.5d0*bw - 1.0d0, sy_lo, sx - 0.5d0*bw - 1.0d0, sy_hi)
                CALL ADD_LINE_F(sx - 0.8d0*bw - 1.0d0, sy_hi, sx - 0.2d0*bw - 1.0d0, sy_hi)
             END IF
          END IF

          !plot cyto dose bar + error whisker
          IF (y_dose_cyto(i) > y_base) THEN
             CALL DATA_TO_SCREEN(x_arr(i), y_dose_cyto(i), sx, sy)
             CALL ADD_RECT(sx + 1.0d0, sy, bw, sy_base - sy, &
                  '#1F77B4', '#111111', 1.1d0, 0.88d0, 1)
             IF (e_dose_cyto(i) > 0.0d0) THEN
                CALL DATA_TO_SCREEN(x_arr(i), MAX(y_base, y_dose_cyto(i)*(1.0d0-e_dose_cyto(i))), sx, sy_lo)
                CALL DATA_TO_SCREEN(x_arr(i), y_dose_cyto(i)*(1.0d0+e_dose_cyto(i)), sx, sy_hi)
                CALL Set_Color('#111111')
                CALL Set_Style(LW=1.3d0, DASH=0, LAYER=2)
                CALL ADD_LINE_F(sx + 0.5d0*bw + 1.0d0, sy_lo, sx + 0.5d0*bw + 1.0d0, sy_hi)
                CALL ADD_LINE_F(sx + 0.2d0*bw + 1.0d0, sy_hi, sx + 0.8d0*bw + 1.0d0, sy_hi)
             END IF
          END IF
       END DO
       legend_styles(1) = 'F'
       legend_styles(2) = 'F'
    ELSE
       !plot nuc. dose
       CALL Set_Color('#D62728')
       CALL Set_Marker(1)
       CALL Draw_Curve(x_arr, y_dose_nuc, num_cells, 'S')

       !plot cyto dose
       CALL Set_Color('#1F77B4')
       CALL Set_Marker(2)
       CALL Draw_Curve(x_arr, y_dose_cyto, num_cells, 'S')
       legend_styles(1) = 'S'
       legend_styles(2) = 'S'
    END IF

    !legeds
    legend_labels(1) = 'Nucleus Dose'
    legend_colors(1) = '#D62728'
    legend_markers(1) = 1

    legend_labels(2) = 'Cytoplasm Dose'
    legend_colors(2) = '#1F77B4'
    legend_markers(2) = 2

    !node draw legend takes arrays
    CALL Draw_Legend(legend_labels, legend_colors, legend_styles, 2, MARKERS=legend_markers)

    !export svg
    if(SVG_PLOT_CHECK == 1) CALL Export_SVG('cell_dosimetry_results.svg')
    if(RENDER_PLOT_CHECK == 1) CALL Render_Plot

    !PRINT*, y_hits_nuc(3)
    IF (ALLOCATED(LINES)) DEALLOCATE(LINES)
    IF (ALLOCATED(RECTS)) DEALLOCATE(RECTS)
    IF (ALLOCATED(CIRCLES)) DEALLOCATE(CIRCLES)
    IF (ALLOCATED(TEXTS)) DEALLOCATE(TEXTS)

    DEALLOCATE(y_dose_nuc, y_dose_cyto, e_dose_nuc, e_dose_cyto)

    MAX_HIT_NUC = MAXVAL(y_hits_nuc)
    MIN_HIT_NUC = MINVAL(y_hits_nuc)

    MAX_HIT_CYTO = MAXVAL(y_hits_cyto)
    MIN_HIT_CYTO = MINVAL(y_hits_cyto)

    IF(MIN_HIT_CYTO < MIN_HIT_NUC)THEN
       MIN_HIT_NUC = MIN_HIT_CYTO
    END IF

    IF(MAX_HIT_CYTO > MAX_HIT_NUC) THEN
       MAX_HIT_NUC = MAX_HIT_CYTO
    END IF

    ymin_pos = HUGE(1.0d0)
    DO i = 1, num_cells
       IF (y_hits_nuc(i) > 0.0d0) ymin_pos = MIN(ymin_pos, y_hits_nuc(i))
       IF (y_hits_cyto(i) > 0.0d0) ymin_pos = MIN(ymin_pos, y_hits_cyto(i))
    END DO

    !prevent division by zero in Draw_Axes
    IF (MAX_HIT_NUC <= 0.0d0) MAX_HIT_NUC = 10.0d0
    IF (ymin_pos == HUGE(1.0d0)) ymin_pos = 1.0d0
    use_log_y = (MAX_HIT_NUC / MAX(1.0d0, ymin_pos) >= 25.0d0)

    If (RENDER_PLOT_CHECK == 1)then
       call Init_Plot(1100,720)
    else
       call Init_Canvas(1100,720)
    end if
    
    CALL Set_Title('CELLULAR PARTICLE TRAVERSAL COUNTS', &
         'Histories = ' // ISTR(nps_total))
    CALL Set_Scale(.FALSE., use_log_y)

    !axes draw (Xmin, Xmax, Ymin, Ymax, Xlabel, Ylabel)
    IF (use_log_y) THEN
       CALL Draw_Axes(0.3d0, xmax + 0.7d0, MAX(0.8d0, ymin_pos * 0.7d0), &
            MAX_HIT_NUC * 1.5d0, 'Cell ID', 'Track Traversals [counts]', XSTEP_OPT=x_step)
       y_base = 10.0d0 ** AX_YMIN
    ELSE
       CALL CALC_NICE_AXIS(0.0d0, MAX_HIT_NUC, ax_lo, ax_hi, y_step, LOCK_ZERO=.TRUE.)
       CALL Draw_Axes(0.3d0, xmax + 0.7d0, ax_lo, ax_hi, &
            'Cell ID', 'Track Traversals [counts]', XSTEP_OPT=x_step, YSTEP_OPT=y_step)
       y_base = 0.0d0
    END IF

    IF (num_cells <= 35) THEN
       CALL DATA_TO_SCREEN(1.0d0, y_base, sx, sy_base)
       bw = MAX(3.0d0, 0.34d0 * real(WIN_W - PADX - PADR, 8) / real(num_cells + 1, 8))
       DO i = 1, num_cells
          IF (y_hits_nuc(i) > y_base) THEN
             CALL DATA_TO_SCREEN(x_arr(i), y_hits_nuc(i), sx, sy)
             CALL ADD_RECT(sx - bw - 1.0d0, sy, bw, sy_base - sy, &
                  '#D62728', '#111111', 1.1d0, 0.88d0, 1)
          END IF
          IF (y_hits_cyto(i) > y_base) THEN
             CALL DATA_TO_SCREEN(x_arr(i), y_hits_cyto(i), sx, sy)
             CALL ADD_RECT(sx + 1.0d0, sy, bw, sy_base - sy, &
                  '#1F77B4', '#111111', 1.1d0, 0.88d0, 1)
          END IF
       END DO
       legend_styles(1) = 'F'
       legend_styles(2) = 'F'
    ELSE
       !plot nuc. hits
       CALL Set_Color('#D62728')
       CALL Set_Marker(1)
       CALL Draw_Curve(x_arr, y_hits_nuc, num_cells, 'S')

       !plot cyto. hits
       CALL Set_Color('#1F77B4')
       CALL Set_Marker(2)
       CALL Draw_Curve(x_arr, y_hits_cyto, num_cells, 'S')
       legend_styles(1) = 'S'
       legend_styles(2) = 'S'
    END IF

    !legeds
    legend_labels(1) = 'Nucleus Hits'
    legend_colors(1) = '#D62728'
    legend_markers(1) = 1

    legend_labels(2) = 'Cytoplasm Hits'
    legend_colors(2) = '#1F77B4'
    legend_markers(2) = 2

    !node draw legend takes arrays
    CALL Draw_Legend(legend_labels, legend_colors, legend_styles, 2, MARKERS=legend_markers)
    
    !export svg
    if(SVG_PLOT_CHECK == 1) CALL Export_SVG('cell_hit_results.svg')
    if(RENDER_PLOT_CHECK == 1) CALL Render_Plot
    
    IF (ALLOCATED(LINES)) DEALLOCATE(LINES)
    IF (ALLOCATED(RECTS)) DEALLOCATE(RECTS)
    IF (ALLOCATED(CIRCLES)) DEALLOCATE(CIRCLES)
    IF (ALLOCATED(TEXTS)) DEALLOCATE(TEXTS)

    DEALLOCATE(y_hits_cyto)
    DEALLOCATE(y_hits_nuc)
    DEALLOCATE(x_arr)
    !**********************************************

    call PLOT_LET_SPECTRUM

    CALL RADIO_ZF

    call RADIO_ZD

    call RADIO_LETD

    call RADIO_LAMBDA

    call RADIO_P0

    call RADIO_SURV

    call RADIO_RBE

    call PLOT_MICRODOSIMETRY_Z_SPECTRA

    call PLOT_MICRODOSIMETRY_ZF1Z

    call PLOT_SURVIVAL_CURVES

    call PLOT_CROSSFIRE_SURVIVAL

    call PLOT_RBE_OVERKILL_CURVE

    call PLOT_COLONY_2D_MAP

    call  PLOT_COLONY_3D_STRUCTURE

END SUBROUTINE PLOT_RESULTS

!*******************************************************
SUBROUTINE PLOT_LET_SPECTRUM
    INTEGER :: j, k, cid, n_rep
    INTEGER :: rep_ids(6), leg_dsh(6)
    REAL(8) :: rep_r(6), ymin, ymax, xmax_hit, ax_xlo, ax_xhi, x_step
    REAL(8), ALLOCATABLE :: x_let(:), y_let(:,:)
    CHARACTER(LEN=32) :: leg_lbl(6), leg_clr(6), r_str
    CHARACTER(LEN=1) :: leg_sty(6)

    IF (LET_BINS <= 0 .OR. num_cells <= 0) RETURN
    CALL SELECT_REP_CELLS(rep_ids, rep_r, n_rep)
    IF (n_rep <= 0) RETURN

    ALLOCATE(x_let(LET_BINS))
    ALLOCATE(y_let(LET_BINS, n_rep))

    !Compute X-axis values (Column 1)
    DO j = 1, LET_BINS
        x_let(j) = (real(j, 8) - 0.5d0) * dLET_bin
    END DO

    !Populate Y-values for representative radial shell cells
    ymax = 0.0d0
    ymin = HUGE(1.0d0)
    xmax_hit = 0.0d0
    DO k = 1, n_rep
        cid = rep_ids(k)
        DO j = 1, LET_BINS
            y_let(j, k) = let_hist_nuc(j, cid) / (dLET_bin * real(nps_total, 8))
            IF (y_let(j, k) > 0.0d0) THEN
               IF (y_let(j, k) < ymin) ymin = y_let(j, k)
               IF (y_let(j, k) > ymax) ymax = y_let(j, k)
               xmax_hit = MAX(xmax_hit, x_let(j))
            END IF
        END DO
    END DO

    !global min/max for axes scaling
    IF (ymax <= 0.0d0) ymax = 1.0d0
    IF (ymin == HUGE(1.0d0)) ymin = ymax * 1.0d-6
    ymin = MAX(ymin, ymax * 1.0d-8)

    CALL CALC_NICE_AXIS(0.0d0, MIN(real(LET_MAX_KEV, 8), MAX(50.0d0, xmax_hit * 1.08d0)), &
         ax_xlo, ax_xhi, x_step, LOCK_ZERO=.TRUE.)

    CALL Begin_Figure(1120, 720, 285)
    CALL Set_Title('NUCLEUS DOSE-AVERAGED LET SPECTRA', &
         'Representative radial colony shells')
    CALL Set_Scale(.FALSE., .TRUE.) !.FALSE. for linear X, .TRUE. for log Y

    CALL Draw_Axes(ax_xlo, ax_xhi, ymin * 0.6d0, ymax * 1.6d0, &
         'LET [keV/um]', 'Energy Density [MeV / (keV/um) / source]', &
         XSVG_OPT='LET [keV/&#956;m]', &
         YSVG_OPT='Energy Density [MeV / (keV/&#956;m) / source]', &
         XSTEP_OPT=x_step)

    !DO i = 1, num_cells
    !    IF (MOD(i, 2) == 0) THEN
    !        CALL Set_Color('blue')
    !    ELSE
    !        CALL Set_Color('red')
    !    END IF
    !    CALL Draw_Curve(x_let, y_let(:, i), LET_BINS, 'S')
    !END DO

    DO k = 1, n_rep
        leg_clr(k) = PUB_PALETTE(k)
        leg_dsh(k) = MOD(k - 1, 4)
        leg_sty(k) = 'L'
        CALL NUM2STR(rep_r(k), r_str)
        leg_lbl(k) = 'Cell ' // ISTR(rep_ids(k)) // ' (r=' // TRIM(r_str) // ' um)'

        CALL Set_Color(leg_clr(k))
        CALL Set_Style(LW=2.2d0, DASH=leg_dsh(k), OPACITY=1.0d0, LAYER=1)
        CALL Draw_Spectrum_Curve(x_let, y_let(:, k), LET_BINS)
    END DO
 
    CALL Draw_Legend(leg_lbl(1:n_rep), leg_clr(1:n_rep), leg_sty(1:n_rep), &
         n_rep, DASHES=leg_dsh(1:n_rep))
    CALL Finish_Figure('let_spectra_all.svg')
    DEALLOCATE(x_let, y_let)
     
END SUBROUTINE PLOT_LET_SPECTRUM

!*******************************************************
SUBROUTINE PLOT_SINGLE_CELL_METRIC(VALS, TITLE_TXT, SUB_TXT, YLBL, YSVG, &
                                   BAR_CLR, FNAME, LOCK_ZERO)
    REAL(8), INTENT(IN) :: VALS(num_cells)
    CHARACTER(LEN=*), INTENT(IN) :: TITLE_TXT, SUB_TXT, YLBL, YSVG, BAR_CLR, FNAME
    LOGICAL, INTENT(IN) :: LOCK_ZERO
    INTEGER :: I
    REAL(8) :: vmin, vmax, ax_lo, ax_hi, y_step, x_step, sx, sy, sy_b, bw
    REAL(8), ALLOCATABLE :: x_arr(:)

    ALLOCATE(x_arr(num_cells))
    vmin = HUGE(1.0d0)
    vmax = -HUGE(1.0d0)
    DO I = 1, num_cells
       x_arr(I) = real(I, 8)
       IF (hit_events_nuc(I) > 0 .OR. LOCK_ZERO) THEN
          vmin = MIN(vmin, VALS(I))
          vmax = MAX(vmax, VALS(I))
       END IF
    END DO
    IF (vmin == HUGE(1.0d0)) THEN
       vmin = 0.0d0
       vmax = 1.0d0
    END IF

    IF (LOCK_ZERO) vmin = 0.0d0
    CALL CALC_NICE_AXIS(vmin, vmax, ax_lo, ax_hi, y_step, LOCK_ZERO=LOCK_ZERO)

    CALL Begin_Figure(1050, 700, 90)
    CALL Set_Title(TITLE_TXT, SUB_TXT)
    CALL Set_Scale(.FALSE., .FALSE.)

    x_step = MAX(1.0d0, ANINT(real(num_cells, 8) / 10.0d0))
    IF (num_cells <= 20) x_step = 1.0d0

    CALL Draw_Axes(0.3d0, real(num_cells, 8) + 0.7d0, ax_lo, ax_hi, &
         'Cell ID', YLBL, YSVG_OPT=YSVG, XSTEP_OPT=x_step, YSTEP_OPT=y_step)

    IF (num_cells <= 35) THEN
       CALL DATA_TO_SCREEN(1.0d0, ax_lo, sx, sy_b)
       bw = MAX(4.0d0, 0.56d0 * real(WIN_W - PADX - PADR, 8) / real(num_cells + 1, 8))
       DO I = 1, num_cells
          IF (hit_events_nuc(I) > 0 .AND. VALS(I) > ax_lo) THEN
             CALL DATA_TO_SCREEN(x_arr(I), VALS(I), sx, sy)
             CALL ADD_RECT(sx - 0.5d0*bw, sy, bw, sy_b - sy, &
                  BAR_CLR, '#111111', 1.2d0, 0.88d0, 1)
          END IF
       END DO
    ELSE
       CALL Set_Color(BAR_CLR)
       CALL Set_Marker(1)
       CALL Draw_Curve(x_arr, VALS, num_cells, 'S')
    END IF

    CALL Finish_Figure(FNAME)
    DEALLOCATE(x_arr)
END SUBROUTINE PLOT_SINGLE_CELL_METRIC

!*******************************************************
SUBROUTINE RADIO_ZF
    REAL(8), DIMENSION(num_cells) :: zF, zD, letD, lam, p0, aa, sv, rb
    CALL COMPUTE_CELL_RADIOBIO(zF, zD, letD, lam, p0, aa, sv, rb)
    CALL PLOT_SINGLE_CELL_METRIC(zF, 'FREQUENCY-MEAN SPECIFIC ENERGY (z_F)', &
         'Nuclear single-event mean per hit cell', 'z_F [Gy]', &
         'z<tspan dy="4" font-size="11">F</tspan><tspan dy="-4"> [Gy]</tspan>', &
         '#1F77B4', 'zF.svg', .TRUE.)
END SUBROUTINE RADIO_ZF

!*******************************************************
SUBROUTINE RADIO_ZD
    REAL(8), DIMENSION(num_cells) :: zF, zD, letD, lam, p0, aa, sv, rb
    CHARACTER(LEN=32) :: d_str
    !formula: z_domain = (0.204 * LET_D) / (rho * d^2)
    CALL COMPUTE_CELL_RADIOBIO(zF, zD, letD, lam, p0, aa, sv, rb)
    CALL NUM2STR(bio_domain_d, d_str)
    CALL PLOT_SINGLE_CELL_METRIC(zD, 'DOSE-MEAN SPECIFIC ENERGY (z_D)', &
         'MKM domain diameter d = ' // TRIM(d_str) // ' um', 'z_D [Gy]', &
         'z<tspan dy="4" font-size="11">D</tspan><tspan dy="-4"> [Gy]</tspan>', &
         '#7B3294', 'zD.svg', .TRUE.)
END SUBROUTINE RADIO_ZD

!*******************************************************
SUBROUTINE RADIO_LETD
    REAL(8), DIMENSION(num_cells) :: zF, zD, letD, lam, p0, aa, sv, rb
    CALL COMPUTE_CELL_RADIOBIO(zF, zD, letD, lam, p0, aa, sv, rb)
    CALL PLOT_SINGLE_CELL_METRIC(letD, 'DOSE-AVERAGED LINEAR ENERGY TRANSFER (LET_D)', &
         'Nucleus dose-weighted mean LET', 'LET_D [keV/um]', &
         'LET<tspan dy="4" font-size="11">D</tspan>' // &
         '<tspan dy="-4"> [keV/&#956;m]</tspan>', &
         '#008080', 'LET_D.svg', .TRUE.)
END SUBROUTINE RADIO_LETD

!*******************************************************
SUBROUTINE RADIO_LAMBDA
    REAL(8), DIMENSION(num_cells) :: zF, zD, letD, lam, p0, aa, sv, rb
    CHARACTER(LEN=32) :: dt_str
    CALL COMPUTE_CELL_RADIOBIO(zF, zD, letD, lam, p0, aa, sv, rb)
    CALL NUM2STR(bio_target_dose, dt_str)
    CALL PLOT_SINGLE_CELL_METRIC(lam, 'MEAN NUCLEAR TRAVERSALS AT TARGET DOSE', &
         'Target Dose = ' // TRIM(dt_str) // ' Gy', 'Mean Hits (lambda)', &
         'Mean Hits (D / z<tspan dy="4" font-size="11">F</tspan>' // &
         '<tspan dy="-4">)</tspan>', '#D62728', 'mean_hits.svg', .TRUE.)
END SUBROUTINE RADIO_LAMBDA

!*******************************************************
SUBROUTINE RADIO_P0
    REAL(8), DIMENSION(num_cells) :: zF, zD, letD, lam, p0, aa, sv, rb
    CHARACTER(LEN=32) :: dt_str
    CALL COMPUTE_CELL_RADIOBIO(zF, zD, letD, lam, p0, aa, sv, rb)
    CALL NUM2STR(bio_target_dose, dt_str)
    CALL PLOT_SINGLE_CELL_METRIC(p0, 'POISSON ZERO-HIT PROBABILITY P(0)', &
         'Target Dose = ' // TRIM(dt_str) // ' Gy  |  P(0) = exp(-D / z_F)', &
         'Prob_0_Hits', 'Zero-Hit Probability P(0)', &
         '#2CA02C', 'prob_0_hits.svg', .TRUE.)
END SUBROUTINE RADIO_P0

!*******************************************************
SUBROUTINE RADIO_SURV
    REAL(8), DIMENSION(num_cells) :: zF, zD, letD, lam, p0, aa, sv, rb
    CHARACTER(LEN=32) :: dt_str
    CALL COMPUTE_CELL_RADIOBIO(zF, zD, letD, lam, p0, aa, sv, rb)
    CALL NUM2STR(bio_target_dose, dt_str)
    CALL PLOT_SINGLE_CELL_METRIC(sv, 'MKM SURVIVING FRACTION AT TARGET DOSE', &
         'Target Dose = ' // TRIM(dt_str) // ' Gy (Saturation-corrected MKM)', &
         'Surv_Frac', 'Surviving Fraction S', &
         '#1F77B4', 'surv_frac.svg', .TRUE.)
END SUBROUTINE RADIO_SURV

!*******************************************************
SUBROUTINE RADIO_RBE
    REAL(8), DIMENSION(num_cells) :: zF, zD, letD, lam, p0, aa, sv, rb
    CHARACTER(LEN=32) :: dt_str
    CALL COMPUTE_CELL_RADIOBIO(zF, zD, letD, lam, p0, aa, sv, rb)
    CALL NUM2STR(bio_target_dose, dt_str)
    CALL PLOT_SINGLE_CELL_METRIC(rb, 'RELATIVE BIOLOGICAL EFFECTIVENESS (RBE)', &
         'Iso-survival RBE at D = ' // TRIM(dt_str) // ' Gy (Saturation MKM)', &
         'RBE', 'RBE', '#E66100', 'rbe.svg', .FALSE.)
END SUBROUTINE RADIO_RBE

!*******************************************************
SUBROUTINE PLOT_MICRODOSIMETRY_Z_SPECTRA
    INTEGER :: j, k, cid, n_rep
    INTEGER :: rep_ids(6), leg_dsh(6)
    REAL(8) :: rep_r(6), xmin, xmax, ymin, ymax
    REAL(8), ALLOCATABLE :: x_z(:), y_z(:,:)
    CHARACTER(LEN=32) :: leg_lbl(6), leg_clr(6), r_str, d_str
    CHARACTER(LEN=1) :: leg_sty(6)

    IF (Z_BINS <= 0 .OR. num_cells <= 0) RETURN
    CALL SELECT_REP_CELLS(rep_ids, rep_r, n_rep)
    IF (n_rep <= 0) RETURN

    ALLOCATE(x_z(Z_BINS))
    ALLOCATE(y_z(Z_BINS, n_rep))

    DO j = 1, Z_BINS
        x_z(j) = (real(j, 8) - 0.5d0) * dZ_bin
    END DO

    !min/max
    xmin = x_z(1)
    xmax = x_z(1)
    ymax = 0.0d0
    ymin = HUGE(1.0d0)

    DO k = 1, n_rep
        cid = rep_ids(k)
        DO j = 1, Z_BINS
            !using micro domain array normalized by dZ_bin [Gy^-1]
            IF (mkm_hit_events(cid) > 0.0d0) THEN
                y_z(j, k) = mkm_z_hist(j, cid) / (mkm_hit_events(cid) * dZ_bin)
            ELSE
                y_z(j, k) = 0.0d0
            END IF
            IF (y_z(j, k) > 0.0d0) THEN
                IF (y_z(j, k) < ymin) ymin = y_z(j, k)
                IF (y_z(j, k) > ymax) ymax = y_z(j, k)
                xmax = MAX(xmax, x_z(j))
            END IF
        END DO
    END DO

    IF (ymax <= 0.0d0) ymax = 1.0d0
    IF (ymin == HUGE(1.0d0)) ymin = ymax * 1.0d-6
    ymin = MAX(ymin, ymax * 1.0d-7)

    CALL NUM2STR(bio_domain_d, d_str)
    CALL Begin_Figure(1120, 720, 285)
    CALL Set_Title('SINGLE-EVENT SPECIFIC ENERGY SPECTRUM f_1(z)', &
         'MKM micro-domain diameter d = ' // TRIM(d_str) // ' um')
    !log-log here
    CALL Set_Scale(.TRUE., .TRUE.)

    CALL Draw_Axes(xmin, MAX(xmax * 1.3d0, 10.0d0), ymin * 0.6d0, ymax * 1.6d0, &
         'Specific Energy, z [Gy]', 'f_1(z) [Gy^-1]', &
         YSVG_OPT='f<tspan dy="4" font-size="11">1</tspan>' // &
         '<tspan dy="-4">(z) [Gy</tspan>' // &
         '<tspan dy="-5" font-size="10">-1</tspan><tspan dy="5">]</tspan>')

    DO k = 1, n_rep
        leg_clr(k) = PUB_PALETTE(k)
        leg_dsh(k) = MOD(k - 1, 4)
        leg_sty(k) = 'L'
        CALL NUM2STR(rep_r(k), r_str)
        leg_lbl(k) = 'Cell ' // ISTR(rep_ids(k)) // ' (r=' // TRIM(r_str) // ' um)'

        CALL Set_Color(leg_clr(k))
        CALL Set_Style(LW=2.2d0, DASH=leg_dsh(k), OPACITY=1.0d0, LAYER=1)
        CALL Draw_Spectrum_Curve(x_z, y_z(:, k), Z_BINS)
    END DO
 
    CALL Draw_Legend(leg_lbl(1:n_rep), leg_clr(1:n_rep), leg_sty(1:n_rep), &
         n_rep, DASHES=leg_dsh(1:n_rep))
    CALL Finish_Figure('microdosimetry_z_spectra_all.svg')
    DEALLOCATE(x_z, y_z)
     
END SUBROUTINE PLOT_MICRODOSIMETRY_Z_SPECTRA

!*******************************************************
!ICRU-36 weighted microdosimetric spectrum z * f1(z) vs log10(z)
SUBROUTINE PLOT_MICRODOSIMETRY_ZF1Z
    INTEGER :: j, k, cid, n_rep
    INTEGER :: rep_ids(6), leg_dsh(6)
    REAL(8) :: rep_r(6), ymax_v, xmax_v, ax_ylo, ax_yhi, y_step
    REAL(8), ALLOCATABLE :: x_z(:), y_zf1(:,:)
    CHARACTER(LEN=32) :: leg_lbl(6), leg_clr(6), r_str, d_str
    CHARACTER(LEN=1) :: leg_sty(6)

    IF (Z_BINS <= 0 .OR. num_cells <= 0) RETURN
    CALL SELECT_REP_CELLS(rep_ids, rep_r, n_rep)
    IF (n_rep <= 0) RETURN

    ALLOCATE(x_z(Z_BINS), y_zf1(Z_BINS, n_rep))
    ymax_v = 0.0d0
    xmax_v = dZ_bin

    DO j = 1, Z_BINS
       x_z(j) = (real(j, 8) - 0.5d0) * dZ_bin
    END DO

    DO k = 1, n_rep
       cid = rep_ids(k)
       DO j = 1, Z_BINS
          IF (mkm_hit_events(cid) > 0.0d0) THEN
             y_zf1(j, k) = x_z(j) * mkm_z_hist(j, cid) / (mkm_hit_events(cid) * dZ_bin)
          ELSE
             y_zf1(j, k) = 0.0d0
          END IF
          IF (y_zf1(j, k) > 0.0d0) THEN
             ymax_v = MAX(ymax_v, y_zf1(j, k))
             xmax_v = MAX(xmax_v, x_z(j))
          END IF
       END DO
    END DO

    IF (ymax_v <= 0.0d0) ymax_v = 1.0d0
    CALL CALC_NICE_AXIS(0.0d0, ymax_v, ax_ylo, ax_yhi, y_step, LOCK_ZERO=.TRUE.)
    CALL NUM2STR(bio_domain_d, d_str)

    CALL Begin_Figure(1120, 720, 285)
    CALL Set_Title('ICRU MICRODOSIMETRIC SPECTRUM z * f_1(z)', &
         'Equal area under curve = equal event probability (d = ' // TRIM(d_str) // ' um)')
    CALL Set_Scale(.TRUE., .FALSE.)

    CALL Draw_Axes(x_z(1), MAX(xmax_v * 1.3d0, 10.0d0), ax_ylo, ax_yhi, &
         'Specific Energy, z [Gy]', 'z * f_1(z) [dimensionless]', &
         YSVG_OPT='z &#183; f<tspan dy="4" font-size="11">1</tspan>' // &
         '<tspan dy="-4">(z)</tspan>', YSTEP_OPT=y_step)

    DO k = 1, n_rep
       leg_clr(k) = PUB_PALETTE(k)
       leg_dsh(k) = MOD(k - 1, 4)
       leg_sty(k) = 'L'
       CALL NUM2STR(rep_r(k), r_str)
       leg_lbl(k) = 'Cell ' // ISTR(rep_ids(k)) // ' (r=' // TRIM(r_str) // ' um)'

       CALL Set_Color(leg_clr(k))
       CALL Set_Style(LW=2.2d0, DASH=leg_dsh(k), OPACITY=1.0d0, LAYER=1)
       CALL Draw_Spectrum_Curve(x_z, y_zf1(:, k), Z_BINS)
    END DO

    CALL Draw_Legend(leg_lbl(1:n_rep), leg_clr(1:n_rep), leg_sty(1:n_rep), &
         n_rep, DASHES=leg_dsh(1:n_rep))
    CALL Finish_Figure('microdosimetry_zf1z.svg')
    DEALLOCATE(x_z, y_zf1)
END SUBROUTINE PLOT_MICRODOSIMETRY_ZF1Z

!*******************************************************
!clonogenic survival curves S(D) vs local absorbed dose D
SUBROUTINE PLOT_SURVIVAL_CURVES
    INTEGER, PARAMETER :: ND = 200
    INTEGER :: I, K, cid, n_rep, n_leg
    INTEGER :: rep_ids(6), leg_dsh(7)
    REAL(8) :: rep_r(6), D_max, d_step, ymin_s
    REAL(8), DIMENSION(num_cells) :: zF, zD, letD, lam, p0, alpha_a, sv, rb
    REAL(8) :: D_grid(ND), S_curve(ND)
    CHARACTER(LEN=34) :: leg_lbl(7), leg_clr(7), r_str, ax_str, bx_str
    CHARACTER(LEN=1) :: leg_sty(7)

    CALL COMPUTE_CELL_RADIOBIO(zF, zD, letD, lam, p0, alpha_a, sv, rb)
    CALL SELECT_REP_CELLS(rep_ids, rep_r, n_rep)
    IF (n_rep <= 0) RETURN

    D_max = MAX(4.0d0, 2.0d0 * real(bio_target_dose, 8))
    DO I = 1, ND
       D_grid(I) = real(I - 1, 8) * D_max / real(ND - 1, 8)
    END DO

    ymin_s = 1.0d-3
    DO K = 1, n_rep
       cid = rep_ids(K)
       ymin_s = MIN(ymin_s, EXP(-alpha_a(cid)*D_max - bio_beta_x*(D_max**2)))
    END DO
    ymin_s = MAX(1.0d-4, ymin_s)

    CALL NUM2STR(bio_alpha_x, ax_str)
    CALL NUM2STR(bio_beta_x, bx_str)

    CALL Begin_Figure(1140, 730, 300)
    CALL Set_Title('CLONOGENIC CELL SURVIVAL CURVES S(D)', &
         'Reference X-ray: alpha = ' // TRIM(ax_str) // ' Gy^-1, beta = ' // &
         TRIM(bx_str) // ' Gy^-2')
    CALL Set_Scale(.FALSE., .TRUE.)

    d_step = MAX(0.5d0, ANINT(D_max / 4.0d0 * 2.0d0) / 2.0d0)
    CALL Draw_Axes(0.0d0, D_max, ymin_s, 1.0d0, &
         'Local Nucleus Absorbed Dose, D [Gy]', 'Surviving Fraction, S(D)', &
         XSTEP_OPT=d_step)

    !vertical dashed reference at target dose
    IF (bio_target_dose > 0.0d0 .AND. bio_target_dose < D_max) THEN
       CALL Set_Color('#9CA3AF')
       CALL Set_Style(LW=1.3d0, DASH=3, OPACITY=1.0d0, LAYER=0)
       CALL DRAW_SEGMENT(bio_target_dose, 10.0d0**AX_YMIN, bio_target_dose, 1.0d0)
    END IF

    !reference X-ray curve
    DO I = 1, ND
       S_curve(I) = EXP(-bio_alpha_x * D_grid(I) - bio_beta_x * (D_grid(I)**2))
    END DO
    CALL Set_Color('#111111')
    CALL Set_Style(LW=2.6d0, DASH=0, OPACITY=1.0d0, LAYER=1)
    CALL Draw_Curve(D_grid, S_curve, ND, 'L')

    leg_lbl(1) = 'Reference X-ray'
    leg_clr(1) = '#111111'
    leg_sty(1) = 'L'
    leg_dsh(1) = 0

    !alpha survival curves for radial shells
    DO K = 1, n_rep
       cid = rep_ids(K)
       DO I = 1, ND
          S_curve(I) = EXP(-alpha_a(cid) * D_grid(I) - bio_beta_x * (D_grid(I)**2))
       END DO
       leg_clr(K+1) = PUB_PALETTE(K)
       leg_dsh(K+1) = MOD(K - 1, 4)
       leg_sty(K+1) = 'L'
       CALL NUM2STR(letD(cid), r_str)
       leg_lbl(K+1) = 'Cell ' // ISTR(cid) // ' (LET=' // TRIM(r_str) // ')'

       CALL Set_Color(leg_clr(K+1))
       CALL Set_Style(LW=2.2d0, DASH=leg_dsh(K+1), OPACITY=1.0d0, LAYER=1)
       CALL Draw_Curve(D_grid, S_curve, ND, 'L')
    END DO

    n_leg = n_rep + 1
    CALL Draw_Legend(leg_lbl(1:n_leg), leg_clr(1:n_leg), leg_sty(1:n_leg), &
         n_leg, DASHES=leg_dsh(1:n_leg))
    CALL Finish_Figure('survival_curves.svg')
END SUBROUTINE PLOT_SURVIVAL_CURVES

!*******************************************************
!colony cross-fire survival vs cumulative alpha decays
SUBROUTINE PLOT_CROSSFIRE_SURVIVAL
    INTEGER, PARAMETER :: NPTS = 240
    INTEGER :: I, C, K, cid, n_rep, n_leg
    INTEGER :: rep_ids(6), leg_dsh(7)
    REAL(8), PARAMETER :: PI = ACOS(-1.0d0)
    REAL(8) :: rep_r(6), vol_nuc, mass_nuc, d_min_pos, n_max_exp, di
    REAL(8), DIMENSION(num_cells) :: zF, zD, letD, lam, p0, alpha_a, sv, rb, d_per_h
    REAL(8) :: N_grid(NPTS), S_cell(NPTS), S_mean(NPTS)
    CHARACTER(LEN=34) :: leg_lbl(7), leg_clr(7), r_str
    CHARACTER(LEN=1) :: leg_sty(7)

    CALL COMPUTE_CELL_RADIOBIO(zF, zD, letD, lam, p0, alpha_a, sv, rb)
    CALL SELECT_REP_CELLS(rep_ids, rep_r, n_rep)
    IF (n_rep <= 0) RETURN

    d_min_pos = HUGE(1.0d0)
    DO C = 1, num_cells
       vol_nuc = (4.0d0 / 3.0d0) * PI * (cells_r_nuc(C)**3)
       mass_nuc = vol_nuc * mat_rho / 1000.0d0
       d_per_h(C) = (dose_nuc(C) * 1.602d-13) / mass_nuc / real(nps_total, 8)
       IF (d_per_h(C) > 0.0d0) d_min_pos = MIN(d_min_pos, d_per_h(C))
    END DO
    IF (d_min_pos == HUGE(1.0d0)) RETURN

    !cast ceiling integer to real(8) for max intrinsic
    n_max_exp = MIN(6.0d0, MAX(3.0d0, real(CEILING(LOG10(4.0d0 / d_min_pos)), 8)))

    DO I = 1, NPTS
       N_grid(I) = 10.0d0 ** (real(I - 1, 8) * n_max_exp / real(NPTS - 1, 8))
       S_mean(I) = 0.0d0
       DO C = 1, num_cells
          di = N_grid(I) * d_per_h(C)
          S_mean(I) = S_mean(I) + EXP(-alpha_a(C) * di - bio_beta_x * (di**2))
       END DO
       S_mean(I) = S_mean(I) / real(num_cells, 8)
    END DO

    CALL Begin_Figure(1140, 730, 300)
    CALL Set_Title('COLONY CROSS-FIRE SURVIVAL vs. CUMULATIVE DECAYS', &
         'Progressive bystander eradication across radial cell shells')
    CALL Set_Scale(.TRUE., .FALSE.)

    CALL Draw_Axes(1.0d0, 10.0d0**n_max_exp, 0.0d0, 1.05d0, &
         'Cumulative Source Alpha Decays, N_alpha', 'Surviving Probability, S(N)', &
         XSVG_OPT='Cumulative Source Alpha Decays, N' // &
         '<tspan dy="4" font-size="11">&#945;</tspan>', YSTEP_OPT=0.2d0)

    DO K = 1, n_rep
       cid = rep_ids(K)
       DO I = 1, NPTS
          di = N_grid(I) * d_per_h(cid)
          S_cell(I) = EXP(-alpha_a(cid) * di - bio_beta_x * (di**2))
       END DO
       leg_clr(K) = PUB_PALETTE(K)
       leg_dsh(K) = MOD(K - 1, 4)
       leg_sty(K) = 'L'
       CALL NUM2STR(rep_r(K), r_str)
       leg_lbl(K) = 'Cell ' // ISTR(cid) // ' (r=' // TRIM(r_str) // ' um)'

       CALL Set_Color(leg_clr(K))
       CALL Set_Style(LW=2.1d0, DASH=leg_dsh(K), OPACITY=1.0d0, LAYER=1)
       CALL Draw_Curve(N_grid, S_cell, NPTS, 'L')
    END DO

    !whole colony mean survival curve
    n_leg = n_rep + 1
    leg_lbl(n_leg) = 'Colony Mean Survival'
    leg_clr(n_leg) = '#111111'
    leg_sty(n_leg) = 'L'
    leg_dsh(n_leg) = 0

    CALL Set_Color('#111111')
    CALL Set_Style(LW=2.8d0, DASH=0, OPACITY=1.0d0, LAYER=1)
    CALL Draw_Curve(N_grid, S_mean, NPTS, 'L')

    CALL Draw_Legend(leg_lbl(1:n_leg), leg_clr(1:n_leg), leg_sty(1:n_leg), &
         n_leg, DASHES=leg_dsh(1:n_leg))
    CALL Finish_Figure('crossfire_survival.svg')
END SUBROUTINE PLOT_CROSSFIRE_SURVIVAL

!*******************************************************
!MKM RBE vs LET_D overkill turnover curve with colony shell overlay
SUBROUTINE PLOT_RBE_OVERKILL_CURVE
    INTEGER, PARAMETER :: NL = 250
    INTEGER :: I, K, cid, n_rep, n_leg
    INTEGER :: rep_ids(6), leg_dsh(7), leg_mkr(7)
    REAL(8) :: rep_r(6), z0, zd_v, zds_v, aa_v, sv_v, det, dx_v
    REAL(8) :: ax_ylo, ax_yhi, y_step, sx, sy
    REAL(8) :: L_grid(NL), RBE_th(NL)
    REAL(8), DIMENSION(num_cells) :: zF, zD, letD, lam, p0, alpha_a, sv, rb
    CHARACTER(LEN=34) :: leg_lbl(7), leg_clr(7), r_str, dt_str
    CHARACTER(LEN=1) :: leg_sty(7)

    IF (bio_target_dose <= 0.0d0 .OR. bio_beta_x <= 0.0d0) RETURN
    CALL COMPUTE_CELL_RADIOBIO(zF, zD, letD, lam, p0, alpha_a, sv, rb)
    CALL SELECT_REP_CELLS(rep_ids, rep_r, n_rep)
    IF (n_rep <= 0) RETURN

    z0 = (0.204d0 * 150.0d0) / (mat_rho * (bio_domain_d**2))

    DO I = 1, NL
       L_grid(I) = real(I, 8)
       zd_v = (0.204d0 * L_grid(I)) / (mat_rho * (bio_domain_d**2))
       zds_v = (z0**2 / zd_v) * (1.0d0 - EXP(-(zd_v**2) / (z0**2)))
       aa_v = bio_alpha_x + bio_beta_x * zds_v
       sv_v = EXP(-aa_v * bio_target_dose - bio_beta_x * (bio_target_dose**2))
       det = bio_alpha_x**2 - 4.0d0 * bio_beta_x * LOG(MAX(sv_v, 1.0d-30))
       dx_v = (-bio_alpha_x + SQRT(MAX(0.0d0, det))) / (2.0d0 * bio_beta_x)
       RBE_th(I) = dx_v / bio_target_dose
    END DO

    CALL CALC_NICE_AXIS(1.0d0, MAXVAL(RBE_th) * 1.04d0, ax_ylo, ax_yhi, &
         y_step, LOCK_ZERO=.FALSE.)
    CALL NUM2STR(bio_target_dose, dt_str)

    CALL Begin_Figure(1140, 730, 300)
    CALL Set_Title('RBE vs. LET_D: MKM SATURATION & OVERKILL TURNOVER', &
         'Target Dose = ' // TRIM(dt_str) // ' Gy  |  y_0 = 150 keV/um')
    CALL Set_Scale(.FALSE., .FALSE.)

    CALL Draw_Axes(0.0d0, 250.0d0, ax_ylo, ax_yhi, &
         'Dose-Averaged LET, LET_D [keV/um]', 'RBE', &
         XSVG_OPT='Dose-Averaged LET, LET<tspan dy="4" font-size="11">D</tspan>' // &
         '<tspan dy="-4"> [keV/&#956;m]</tspan>', &
         XSTEP_OPT=50.0d0, YSTEP_OPT=y_step)

    !theoretical MKM curve
    CALL Set_Color('#374151')
    CALL Set_Style(LW=2.2d0, DASH=1, OPACITY=1.0d0, LAYER=1)
    CALL Draw_Curve(L_grid, RBE_th, NL, 'L')

    leg_lbl(1) = 'MKM Theory Curve'
    leg_clr(1) = '#374151'
    leg_sty(1) = 'L'
    leg_dsh(1) = 1
    leg_mkr(1) = 1

    !simulated colony shells
    DO K = 1, n_rep
       cid = rep_ids(K)
       CALL DATA_TO_SCREEN(letD(cid), rb(cid), sx, sy)
       CALL DRAW_MARKER_AT(sx, sy, K, 5.5d0, PUB_PALETTE(K), 2)

       leg_clr(K+1) = PUB_PALETTE(K)
       leg_sty(K+1) = 'S'
       leg_dsh(K+1) = 0
       leg_mkr(K+1) = K
       CALL NUM2STR(rep_r(K), r_str)
       leg_lbl(K+1) = 'Cell ' // ISTR(cid) // ' (r=' // TRIM(r_str) // ' um)'
    END DO

    n_leg = n_rep + 1
    CALL Draw_Legend(leg_lbl(1:n_leg), leg_clr(1:n_leg), leg_sty(1:n_leg), &
         n_leg, DASHES=leg_dsh(1:n_leg), MARKERS=leg_mkr(1:n_leg))
    CALL Finish_Figure('rbe_vs_letd_overkill.svg')
END SUBROUTINE PLOT_RBE_OVERKILL_CURVE

!*******************************************************
!2D spatial colony RBE heatmap with optional alpha particle tracks
!*******************************************************
!2D spatial colony RBE heatmap with optional alpha particle tracks
SUBROUTINE PLOT_COLONY_2D_MAP
    INTEGER :: I, K, ios, u_trk, pid, prev_pid, gen_i, ptype_i, n_seg, leg_rows
    REAL(8) :: xmin_bb, xmax_bb, ymin_bb, ymax_bb
    REAL(8) :: x_c, y_c, span, half_s, ax_lo, ax_hi, step_xy, px_per_um
    REAL(8) :: cx_um, cy_um, rc_um, rn_um, sx, sy, z_slice, z_tol
    REAL(8) :: tx, ty, tz, te, px, py, rbe_min, rbe_max, t_norm
    REAL(8) :: cb_x, cb_y, cb_w, cb_h, band_h, tick_y, tick_v
    LOGICAL :: has_tracks
    CHARACTER(LEN=256) :: trk_file, line
    CHARACTER(LEN=24) :: fill_hex, txt_clr, v_str
    REAL(8), DIMENSION(num_cells) :: zF, zD, letD, lam, p0, alpha_a, sv, rb

    CALL COMPUTE_CELL_RADIOBIO(zF, zD, letD, lam, p0, alpha_a, sv, rb)

    !always slice through the colony Z midplane
    z_slice = 0.5d0 * (MINVAL(cells_z) + MAXVAL(cells_z))
    z_tol = MAX(1.0d-4, 1.2d0 * MAXVAL(cells_r_cyto))

    xmin_bb = 1.0d4 * MINVAL(cells_x - cells_r_cyto)
    xmax_bb = 1.0d4 * MAXVAL(cells_x + cells_r_cyto)
    ymin_bb = 1.0d4 * MINVAL(cells_y - cells_r_cyto)
    ymax_bb = 1.0d4 * MAXVAL(cells_y + cells_r_cyto)

    !include point source position in frame when src_mode == 1
    IF (src_mode == 1) THEN
       xmin_bb = MIN(xmin_bb, 1.0d4 * src_x - 4.0d0)
       xmax_bb = MAX(xmax_bb, 1.0d4 * src_x + 4.0d0)
       ymin_bb = MIN(ymin_bb, 1.0d4 * src_y - 4.0d0)
       ymax_bb = MAX(ymax_bb, 1.0d4 * src_y + 4.0d0)
    END IF

    x_c = 0.5d0 * (xmin_bb + xmax_bb)
    y_c = 0.5d0 * (ymin_bb + ymax_bb)
    span = MAX(xmax_bb - xmin_bb, ymax_bb - ymin_bb)
    IF (span <= 0.0d0) span = 40.0d0
    half_s = 0.58d0 * span

    CALL CALC_NICE_AXIS(x_c - half_s, x_c + half_s, ax_lo, ax_hi, step_xy)
    half_s = MAX(ABS(ax_hi - x_c), ABS(x_c - ax_lo))

    rbe_min = HUGE(1.0d0)
    rbe_max = -HUGE(1.0d0)
    DO I = 1, num_cells
       IF (hit_events_nuc(I) > 0) THEN
          rbe_min = MIN(rbe_min, rb(I))
          rbe_max = MAX(rbe_max, rb(I))
       END IF
    END DO
    IF (rbe_min == HUGE(1.0d0)) THEN
       rbe_min = 1.0d0
       rbe_max = 2.0d0
    ELSE IF (ABS(rbe_max - rbe_min) < 1.0d-4) THEN
       rbe_min = MAX(1.0d0, rbe_min - 0.2d0)
       rbe_max = rbe_max + 0.2d0
    END IF

    !600x600 px isotropic square plot area
    CALL Begin_Figure(1000, 772, 285)
    CALL Set_Title('2D COLONY GEOMETRY, TRACKS & SPATIAL RBE MAP', &
         'Midplane XY projection  |  Nucleus color: MKM RBE')
    CALL Set_Scale(.FALSE., .FALSE.)

    CALL Draw_Axes(x_c - half_s, x_c + half_s, y_c - half_s, y_c + half_s, &
         'X Position [um]', 'Y Position [um]', &
         XSVG_OPT='X Position [&#956;m]', YSVG_OPT='Y Position [&#956;m]', &
         XSTEP_OPT=step_xy, YSTEP_OPT=step_xy)

    px_per_um = 600.0d0 / (2.0d0 * half_s)

    !overlay recorded alpha tracks if tracks.dat exists
    trk_file = TRIM(out_dir) // '/tracks.dat'
    INQUIRE(FILE=TRIM(trk_file), EXIST=has_tracks)
    n_seg = 0
    IF (has_tracks .AND. max_tracks > 0) THEN
       OPEN(NEWUNIT=u_trk, FILE=TRIM(trk_file), STATUS='OLD', ACTION='READ', IOSTAT=ios)
       IF (ios == 0) THEN
          CALL Set_Color('#F59E0B')
          CALL Set_Style(LW=0.85d0, DASH=0, OPACITY=0.32d0, LAYER=1)
          prev_pid = -1
          px = 0.0d0
          py = 0.0d0
          DO
             READ(u_trk, '(A)', IOSTAT=ios) line
             IF (ios /= 0) EXIT
             IF (LEN_TRIM(line) == 0) THEN
                prev_pid = -1
                CYCLE
             END IF
             READ(line, *, IOSTAT=ios) pid, gen_i, ptype_i, tx, ty, tz, te
             IF (ios /= 0) CYCLE
             IF (ABS(tz - z_slice) > z_tol * 2.5d0 .OR. te < 0.0d0 .OR. &
                 gen_i < 0 .OR. ptype_i < 0) THEN
                prev_pid = -1
                CYCLE
             END IF
             tx = tx * 1.0d4
             ty = ty * 1.0d4
             IF (pid == prev_pid) THEN
                CALL DRAW_SEGMENT(px, py, tx, ty)
                n_seg = n_seg + 1
                IF (n_seg >= 15000) EXIT
             END IF
             prev_pid = pid
             px = tx
             py = ty
          END DO
          CLOSE(u_trk)
       END IF
    END IF

    !draw cytoplasm dashed circles and RBE-colored nuclei
    DO I = 1, num_cells
       IF (ABS(cells_z(I) - z_slice) > z_tol) CYCLE
       cx_um = cells_x(I) * 1.0d4
       cy_um = cells_y(I) * 1.0d4
       rc_um = cells_r_cyto(I) * 1.0d4
       rn_um = cells_r_nuc(I) * 1.0d4

       CALL DATA_TO_SCREEN(cx_um, cy_um, sx, sy)
       IF (sx < real(PADX, 8) .OR. sx > real(WIN_W - PADR, 8) .OR. &
           sy < real(PADY_TOP, 8) .OR. sy > real(WIN_H - PADY_BOT, 8)) CYCLE

       CALL ADD_CIRCLE(sx, sy, rc_um * px_per_um, 'none', '#06B6D4', &
            1.5d0, 0.90d0, 1, 1)

       IF (hit_events_nuc(I) > 0) THEN
          t_norm = (rb(I) - rbe_min) / (rbe_max - rbe_min)
          CALL COLORMAP_PLASMA(t_norm, fill_hex)
          IF (t_norm < 0.62d0) THEN
             txt_clr = '#FFFFFF'
          ELSE
             txt_clr = '#111111'
          END IF
       ELSE
          fill_hex = '#E5E7EB'
          txt_clr = '#374151'
       END IF

       CALL ADD_CIRCLE(sx, sy, rn_um * px_per_um, fill_hex, '#111111', &
            1.4d0, 0.92d0, 0, 1)

       IF (num_cells <= 60 .AND. rn_um * px_per_um >= 8.0d0) THEN
          CALL ADD_TEXT_EX(sx, sy + 4.0d0, ISTR(cells_id(I)), ISTR(cells_id(I)), &
               0, 11, .TRUE., 'C', txt_clr, 3)
       END IF
    END DO

    !draw point source crosshair marker if src_mode == 1
    IF (src_mode == 1) THEN
       CALL DATA_TO_SCREEN(src_x * 1.0d4, src_y * 1.0d4, sx, sy)
       IF (sx >= real(PADX, 8) .AND. sx <= real(WIN_W - PADR, 8) .AND. &
           sy >= real(PADY_TOP, 8) .AND. sy <= real(WIN_H - PADY_BOT, 8)) THEN
          CALL ADD_CIRCLE(sx, sy, 6.0d0, '#DC2626', '#111111', 1.5d0, 1.0d0, 0, 3)
          CALL DRAW_MARKER_AT(sx, sy, 5, 9.0d0, '#DC2626', 3)
       END IF
    END IF

    !vertical RBE colorbar on right margin
    cb_x = real(WIN_W - PADR + 34, 8)
    cb_y = real(PADY_TOP + 24, 8)
    cb_w = 24.0d0
    cb_h = 320.0d0
    band_h = cb_h / 50.0d0

    CALL ADD_TEXT_EX(cb_x + 0.5d0*cb_w, cb_y - 12.0d0, 'MKM RBE', 'MKM RBE', &
         0, 13, .TRUE., 'C', '#111111', 3)

    DO K = 1, 50
       t_norm = real(K - 1, 8) / 49.0d0
       CALL COLORMAP_PLASMA(t_norm, fill_hex)
       CALL ADD_RECT(cb_x, cb_y + cb_h - real(K, 8)*band_h, cb_w, band_h + 0.6d0, &
            fill_hex, 'none', 0.0d0, 1.0d0, 2)
    END DO
    CALL ADD_RECT(cb_x, cb_y, cb_w, cb_h, 'none', '#111111', 1.5d0, 1.0d0, 3)

    DO K = 0, 4
       tick_y = cb_y + cb_h - (real(K, 8) / 4.0d0) * cb_h
       tick_v = rbe_min + (real(K, 8) / 4.0d0) * (rbe_max - rbe_min)
       CALL Set_Color('#111111')
       CALL Set_Style(LW=1.4d0, DASH=0, LAYER=3)
       CALL ADD_LINE_F(cb_x + cb_w, tick_y, cb_x + cb_w + 6.0d0, tick_y)
       CALL NUM2STR(tick_v, v_str)
       CALL ADD_TEXT_EX(cb_x + cb_w + 10.0d0, tick_y + 4.5d0, v_str, v_str, &
            0, 12, .FALSE., 'L', '#111111', 3)
    END DO

    !geometry legend key below colorbar
    leg_rows = 3
    IF (src_mode == 1) leg_rows = 4
    CALL ADD_RECT(cb_x, cb_y + cb_h + 28.0d0, 210.0d0, real(leg_rows*28 + 12, 8), &
         '#FFFFFF', '#111111', 1.3d0, 1.0d0, 2)
    CALL ADD_CIRCLE(cb_x + 22.0d0, cb_y + cb_h + 48.0d0, 7.0d0, &
         '#CC4778', '#111111', 1.2d0, 1.0d0, 0, 3)
    CALL ADD_TEXT_EX(cb_x + 40.0d0, cb_y + cb_h + 52.0d0, &
         'Nucleus (RBE)', 'Nucleus (RBE)', 0, 12, .FALSE., 'L', '#111111', 3)

    CALL ADD_CIRCLE(cb_x + 22.0d0, cb_y + cb_h + 76.0d0, 8.0d0, &
         'none', '#06B6D4', 1.5d0, 1.0d0, 1, 3)
    CALL ADD_TEXT_EX(cb_x + 40.0d0, cb_y + cb_h + 80.0d0, &
         'Cytoplasm', 'Cytoplasm', 0, 12, .FALSE., 'L', '#111111', 3)

    CALL Set_Color('#F59E0B')
    CALL Set_Style(LW=2.2d0, DASH=0, OPACITY=1.0d0, LAYER=3)
    CALL ADD_LINE_F(cb_x + 12.0d0, cb_y + cb_h + 102.0d0, &
                    cb_x + 32.0d0, cb_y + cb_h + 102.0d0)
    CALL ADD_TEXT_EX(cb_x + 40.0d0, cb_y + cb_h + 106.0d0, &
         'Alpha Tracks', 'Alpha Tracks', 0, 12, .FALSE., 'L', '#111111', 3)

    IF (src_mode == 1) THEN
       CALL ADD_CIRCLE(cb_x + 22.0d0, cb_y + cb_h + 130.0d0, 5.5d0, &
            '#DC2626', '#111111', 1.3d0, 1.0d0, 0, 3)
       CALL ADD_TEXT_EX(cb_x + 40.0d0, cb_y + cb_h + 134.0d0, &
            'Point Source', 'Point Source', 0, 12, .FALSE., 'L', '#111111', 3)
    END IF

    CALL Finish_Figure('colony_rbe_map_2d.svg')
  END SUBROUTINE PLOT_COLONY_2D_MAP

!*******************************************************
!orthonormal 3D world-to-screen projection with camera depth
PURE SUBROUTINE PROJ_3D(XW, YW, ZW, XC, YC, ZC, SCALE_PX, CX_S, CY_S, SX, SY, DEPTH)
    REAL(8), INTENT(IN) :: XW, YW, ZW, XC, YC, ZC, SCALE_PX, CX_S, CY_S
    REAL(8), INTENT(OUT) :: SX, SY, DEPTH
    REAL(8), PARAMETER :: DEG2RAD = ACOS(-1.0d0) / 180.0d0
    REAL(8), PARAMETER :: COS_PSI = COS(34.0d0 * DEG2RAD)
    REAL(8), PARAMETER :: SIN_PSI = SIN(34.0d0 * DEG2RAD)
    REAL(8), PARAMETER :: COS_ALP = COS(24.0d0 * DEG2RAD)
    REAL(8), PARAMETER :: SIN_ALP = SIN(24.0d0 * DEG2RAD)
    REAL(8) :: DX, DY, DZ, U_R, U_UP

    DX = XW - XC
    DY = YW - YC
    DZ = ZW - ZC

    U_R = COS_PSI * DX + SIN_PSI * DY
    U_UP = -SIN_ALP * SIN_PSI * DX + SIN_ALP * COS_PSI * DY + COS_ALP * DZ
    DEPTH = COS_ALP * SIN_PSI * DX - COS_ALP * COS_PSI * DY + SIN_ALP * DZ

    SX = CX_S + SCALE_PX * U_R
    SY = CY_S - SCALE_PX * U_UP
END SUBROUTINE PROJ_3D

!*******************************************************
SUBROUTINE PLOT_COLONY_3D_STRUCTURE
    INTEGER, PARAMETER :: NSEG_SPH = 20
    INTEGER :: I, J, M, IDX, TMP_ID, NT_X, NT_Y, NT_Z
    INTEGER :: ios, u_trk, pid, prev_pid, gen_i, ptype_i, n_seg, leg_n
    INTEGER, ALLOCATABLE :: ORDER(:)
    REAL(8), ALLOCATABLE :: C_DEPTH(:)
    REAL(8), PARAMETER :: TWO_PI = 2.0d0 * ACOS(-1.0d0)
    REAL(8) :: xmin_w, xmax_w, ymin_w, ymax_w, zmin_w, zmax_w, min_span
    REAL(8) :: x0, x1, y0, y1, z0, z1, step_x, step_y, step_z
    REAL(8) :: xc, yc, zc, scale_px, cx_scr, cy_scr
    REAL(8) :: u_min, u_max, v_min, v_max, sx, sy, sx2, sy2, dep, dep2
    REAL(8) :: vx, vy, vz, vval, t1, t2, px1, py1, pz1, px2, py2, pz2
    REAL(8) :: cx_i, cy_i, cz_i, rc_i, rn_i, tx, ty, tz, te, px, py, pz
    LOGICAL :: has_tracks, has_unhit
    CHARACTER(LEN=256) :: trk_file, line
    CHARACTER(LEN=32) :: t_str
    CHARACTER(LEN=24) :: nuc_fill, nuc_rim
    CHARACTER(LEN=34) :: leg_lbl(5), leg_clr(5)
    CHARACTER(LEN=1) :: leg_sty(5)
    INTEGER :: leg_dsh(5), leg_mkr(5)

    IF (num_cells <= 0) RETURN

    !world bounding box in um
    xmin_w = 1.0d4 * MINVAL(cells_x - cells_r_cyto)
    xmax_w = 1.0d4 * MAXVAL(cells_x + cells_r_cyto)
    ymin_w = 1.0d4 * MINVAL(cells_y - cells_r_cyto)
    ymax_w = 1.0d4 * MAXVAL(cells_y + cells_r_cyto)
    zmin_w = 1.0d4 * MINVAL(cells_z - cells_r_cyto)
    zmax_w = 1.0d4 * MAXVAL(cells_z + cells_r_cyto)

    IF (src_mode == 1) THEN
       xmin_w = MIN(xmin_w, 1.0d4 * src_x - 4.0d0)
       xmax_w = MAX(xmax_w, 1.0d4 * src_x + 4.0d0)
       ymin_w = MIN(ymin_w, 1.0d4 * src_y - 4.0d0)
       ymax_w = MAX(ymax_w, 1.0d4 * src_y + 4.0d0)
       zmin_w = MIN(zmin_w, 1.0d4 * src_z - 4.0d0)
       zmax_w = MAX(zmax_w, 1.0d4 * src_z + 4.0d0)
    END IF

    !ensure clean 3D room depth even for 2D monolayer inputs
    min_span = MAX(24.0d0, 0.35d0 * MAX(xmax_w - xmin_w, ymax_w - ymin_w))
    IF (zmax_w - zmin_w < min_span) THEN
       zc = 0.5d0 * (zmin_w + zmax_w)
       zmin_w = zc - 0.5d0 * min_span
       zmax_w = zc + 0.5d0 * min_span
    END IF

    CALL CALC_NICE_AXIS(xmin_w, xmax_w, x0, x1, step_x)
    CALL CALC_NICE_AXIS(ymin_w, ymax_w, y0, y1, step_y)
    CALL CALC_NICE_AXIS(zmin_w, zmax_w, z0, z1, step_z)

    xc = 0.5d0 * (x0 + x1)
    yc = 0.5d0 * (y0 + y1)
    zc = 0.5d0 * (z0 + z1)

    CALL Begin_Figure(1160, 820, 290)
    CALL Set_Title('3D CELLULAR COLONY ARCHITECTURE & ALPHA TRACKS', &
         'Depth-sorted 3D microdosimetric geometry [um]')

    !fit projected 8 cube corners inside canvas viewport
    u_min = HUGE(1.0d0); u_max = -HUGE(1.0d0)
    v_min = HUGE(1.0d0); v_max = -HUGE(1.0d0)
    DO I = 0, 1
       DO J = 0, 1
          DO M = 0, 1
             vx = x0 + real(I, 8) * (x1 - x0)
             vy = y0 + real(J, 8) * (y1 - y0)
             vz = z0 + real(M, 8) * (z1 - z0)
             CALL PROJ_3D(vx, vy, vz, xc, yc, zc, 1.0d0, 0.0d0, 0.0d0, sx, sy, dep)
             u_min = MIN(u_min, sx); u_max = MAX(u_max, sx)
             v_min = MIN(v_min, sy); v_max = MAX(v_max, sy)
          END DO
       END DO
    END DO

    scale_px = MIN(real(WIN_W - PADX - PADR - 60, 8) / MAX(1.0d-6, u_max - u_min), &
                   real(WIN_H - PADY_TOP - PADY_BOT - 50, 8) / MAX(1.0d-6, v_max - v_min))
    cx_scr = 0.5d0 * real(PADX + WIN_W - PADR, 8) - 0.5d0 * scale_px * (u_min + u_max)
    cy_scr = 0.5d0 * real(PADY_TOP + 15 + WIN_H - PADY_BOT, 8) - 0.5d0 * scale_px * (v_min + v_max)

    NT_X = MAX(1, NINT((x1 - x0) / step_x))
    NT_Y = MAX(1, NINT((y1 - y0) / step_y))
    NT_Z = MAX(1, NINT((z1 - z0) / step_z))

    CALL Set_Color('#E2E8F0')
    CALL Set_Style(LW=0.85d0, DASH=0, OPACITY=1.0d0, LAYER=0)

    !X gridlines on floor (z=z0) and back-right wall (y=y1)
    DO I = 0, NT_X
       vval = x0 + real(I, 8) * step_x
       CALL PROJ_3D(vval, y0, z0, xc, yc, zc, scale_px, cx_scr, cy_scr, sx, sy, dep)
       CALL PROJ_3D(vval, y1, z0, xc, yc, zc, scale_px, cx_scr, cy_scr, sx2, sy2, dep2)
       CALL ADD_LINE_F(sx, sy, sx2, sy2)
       CALL PROJ_3D(vval, y1, z1, xc, yc, zc, scale_px, cx_scr, cy_scr, sx, sy, dep)
       CALL ADD_LINE_F(sx2, sy2, sx, sy)
    END DO

    !Y gridlines on floor (z=z0) and back-left wall (x=x0)
    DO J = 0, NT_Y
       vval = y0 + real(J, 8) * step_y
       CALL PROJ_3D(x0, vval, z0, xc, yc, zc, scale_px, cx_scr, cy_scr, sx, sy, dep)
       CALL PROJ_3D(x1, vval, z0, xc, yc, zc, scale_px, cx_scr, cy_scr, sx2, sy2, dep2)
       CALL ADD_LINE_F(sx, sy, sx2, sy2)
       CALL PROJ_3D(x0, vval, z1, xc, yc, zc, scale_px, cx_scr, cy_scr, sx2, sy2, dep2)
       CALL ADD_LINE_F(sx, sy, sx2, sy2)
    END DO

    !Z gridlines on back-left (x=x0) and back-right (y=y1) walls
    DO M = 0, NT_Z
       vval = z0 + real(M, 8) * step_z
       CALL PROJ_3D(x0, y0, vval, xc, yc, zc, scale_px, cx_scr, cy_scr, sx, sy, dep)
       CALL PROJ_3D(x0, y1, vval, xc, yc, zc, scale_px, cx_scr, cy_scr, sx2, sy2, dep2)
       CALL ADD_LINE_F(sx, sy, sx2, sy2)
       CALL PROJ_3D(x1, y1, vval, xc, yc, zc, scale_px, cx_scr, cy_scr, sx, sy, dep)
       CALL ADD_LINE_F(sx2, sy2, sx, sy)
    END DO

    !crisp dark border edges of the 3 back walls
    CALL Set_Color('#1E293B')
    CALL Set_Style(LW=1.6d0, DASH=0, OPACITY=1.0d0, LAYER=0)
    !floor outer X and Y axes
    CALL PROJ_3D(x0, y0, z0, xc, yc, zc, scale_px, cx_scr, cy_scr, sx, sy, dep)
    CALL PROJ_3D(x1, y0, z0, xc, yc, zc, scale_px, cx_scr, cy_scr, sx2, sy2, dep2)
    CALL ADD_LINE_F(sx, sy, sx2, sy2)
    CALL PROJ_3D(x1, y1, z0, xc, yc, zc, scale_px, cx_scr, cy_scr, sx, sy, dep)
    CALL ADD_LINE_F(sx2, sy2, sx, sy)
    !vertical Z axis on right (x1, y1) and left (x0, y0) and back (x0, y1)
    CALL PROJ_3D(x1, y1, z1, xc, yc, zc, scale_px, cx_scr, cy_scr, sx2, sy2, dep2)
    CALL ADD_LINE_F(sx, sy, sx2, sy2)
    CALL PROJ_3D(x0, y1, z1, xc, yc, zc, scale_px, cx_scr, cy_scr, sx, sy, dep)
    CALL ADD_LINE_F(sx2, sy2, sx, sy)
    CALL PROJ_3D(x0, y0, z1, xc, yc, zc, scale_px, cx_scr, cy_scr, sx2, sy2, dep2)
    CALL ADD_LINE_F(sx, sy, sx2, sy2)
    CALL PROJ_3D(x0, y0, z0, xc, yc, zc, scale_px, cx_scr, cy_scr, sx, sy, dep)
    CALL ADD_LINE_F(sx2, sy2, sx, sy)

    CALL Set_Color('#CBD5E1')
    CALL Set_Style(LW=1.1d0, DASH=0, OPACITY=0.50d0, LAYER=0)
    DO I = 1, num_cells
       cx_i = cells_x(I) * 1.0d4
       cy_i = cells_y(I) * 1.0d4
       rc_i = cells_r_cyto(I) * 1.0d4
       DO M = 1, 16
          t1 = TWO_PI * real(M - 1, 8) / 16.0d0
          t2 = TWO_PI * real(M, 8) / 16.0d0
          CALL PROJ_3D(cx_i + rc_i*COS(t1), cy_i + rc_i*SIN(t1), z0, &
               xc, yc, zc, scale_px, cx_scr, cy_scr, sx, sy, dep)
          CALL PROJ_3D(cx_i + rc_i*COS(t2), cy_i + rc_i*SIN(t2), z0, &
               xc, yc, zc, scale_px, cx_scr, cy_scr, sx2, sy2, dep2)
          CALL ADD_LINE_F(sx, sy, sx2, sy2)
       END DO
    END DO

    trk_file = TRIM(out_dir) // '/tracks.dat'
    INQUIRE(FILE=TRIM(trk_file), EXIST=has_tracks)
    n_seg = 0
    IF (has_tracks .AND. max_tracks > 0) THEN
       OPEN(NEWUNIT=u_trk, FILE=TRIM(trk_file), STATUS='OLD', ACTION='READ', IOSTAT=ios)
       IF (ios == 0) THEN
          CALL Set_Color('#F59E0B')
          CALL Set_Style(LW=0.80d0, DASH=0, OPACITY=0.30d0, LAYER=1)
          prev_pid = -1
          px = 0.0d0; py = 0.0d0; pz = 0.0d0
          DO
             READ(u_trk, '(A)', IOSTAT=ios) line
             IF (ios /= 0) EXIT
             IF (LEN_TRIM(line) == 0) THEN
                prev_pid = -1
                CYCLE
             END IF
             READ(line, *, IOSTAT=ios) pid, gen_i, ptype_i, tx, ty, tz, te
             IF (ios /= 0) CYCLE
             IF (te < 0.0d0 .OR. gen_i < 0 .OR. ptype_i < 0) CYCLE
             tx = tx * 1.0d4; ty = ty * 1.0d4; tz = tz * 1.0d4
             IF (tx < x0 .OR. tx > x1 .OR. ty < y0 .OR. ty > y1 .OR. tz < z0 .OR. tz > z1) THEN
                prev_pid = -1
                CYCLE
             END IF
             IF (pid == prev_pid) THEN
                CALL PROJ_3D(px, py, pz, xc, yc, zc, scale_px, cx_scr, cy_scr, sx, sy, dep)
                CALL PROJ_3D(tx, ty, tz, xc, yc, zc, scale_px, cx_scr, cy_scr, sx2, sy2, dep2)
                CALL ADD_LINE_F(sx, sy, sx2, sy2)
                n_seg = n_seg + 1
                IF (n_seg >= 16000) EXIT
             END IF
             prev_pid = pid
             px = tx; py = ty; pz = tz
          END DO
          CLOSE(u_trk)
       END IF
    END IF

    ALLOCATE(ORDER(num_cells), C_DEPTH(num_cells))
    DO I = 1, num_cells
       ORDER(I) = I
       CALL PROJ_3D(cells_x(I)*1.0d4, cells_y(I)*1.0d4, cells_z(I)*1.0d4, &
            xc, yc, zc, scale_px, cx_scr, cy_scr, sx, sy, C_DEPTH(I))
    END DO

    !sort ascending by camera depth (farthest drawn first, nearest drawn last)
    DO I = 2, num_cells
       TMP_ID = ORDER(I)
       dep = C_DEPTH(TMP_ID)
       J = I - 1
       DO WHILE (J >= 1)
          IF (C_DEPTH(ORDER(J)) <= dep) EXIT
          ORDER(J + 1) = ORDER(J)
          J = J - 1
       END DO
       ORDER(J + 1) = TMP_ID
    END DO

    has_unhit = .FALSE.
    DO IDX = 1, num_cells
       I = ORDER(IDX)
       cx_i = cells_x(I) * 1.0d4
       cy_i = cells_y(I) * 1.0d4
       cz_i = cells_z(I) * 1.0d4
       rc_i = cells_r_cyto(I) * 1.0d4
       rn_i = cells_r_nuc(I) * 1.0d4

       CALL PROJ_3D(cx_i, cy_i, cz_i, xc, yc, zc, scale_px, cx_scr, cy_scr, sx, sy, dep)

       !cytoplasm translucent 3D shell
       CALL ADD_CIRCLE(sx, sy, rc_i * scale_px, '#CFFAFE', '#0891B2', &
            1.10d0, 0.14d0, 0, 1)

       !nucleus 3D sphere colored by source / hit target / unhit status
       IF (src_mode == 2 .AND. cells_src_prob(I) > 0.0d0) THEN
          nuc_fill = '#E11D48'
          nuc_rim = '#881337'
       ELSE IF (hit_events_nuc(I) > 0) THEN
          nuc_fill = '#9333EA'
          nuc_rim = '#3B0764'
       ELSE
          nuc_fill = '#94A3B8'
          nuc_rim = '#334155'
          has_unhit = .TRUE.
       END IF

       CALL ADD_CIRCLE(sx, sy, rn_i * scale_px, nuc_fill, nuc_rim, &
            1.15d0, 0.90d0, 0, 1)

       !3D specular highlight on nucleus
       IF (RENDER_PLOT_CHECK == 0 .AND. rn_i * scale_px >= 3.5d0) THEN
          CALL ADD_CIRCLE(sx - 0.30d0*rn_i*scale_px, sy - 0.30d0*rn_i*scale_px, &
               0.26d0*rn_i*scale_px, '#FFFFFF', 'none', 0.0d0, 0.42d0, 0, 1)
       END IF

       !3D latitude & meridian great-circle wireframe arcs on cytoplasm
       DO M = 1, NSEG_SPH
          t1 = TWO_PI * real(M - 1, 8) / real(NSEG_SPH, 8)
          t2 = TWO_PI * real(M, 8) / real(NSEG_SPH, 8)

          !XY equator ring
          px1 = cx_i + rc_i*COS(t1); py1 = cy_i + rc_i*SIN(t1); pz1 = cz_i
          px2 = cx_i + rc_i*COS(t2); py2 = cy_i + rc_i*SIN(t2); pz2 = cz_i
          CALL PROJ_3D(px1, py1, pz1, xc, yc, zc, scale_px, cx_scr, cy_scr, sx, sy, dep2)
          CALL PROJ_3D(px2, py2, pz2, xc, yc, zc, scale_px, cx_scr, cy_scr, sx2, sy2, dep)
          IF (0.5d0*(dep + dep2) >= C_DEPTH(I)) THEN
             CALL Set_Color('#06B6D4')
             CALL Set_Style(LW=0.85d0, DASH=0, OPACITY=0.42d0, LAYER=2)
          ELSE
             CALL Set_Color('#06B6D4')
             CALL Set_Style(LW=0.75d0, DASH=0, OPACITY=0.18d0, LAYER=1)
          END IF
          CALL ADD_LINE_F(sx, sy, sx2, sy2)

          !XZ meridian ring
          px1 = cx_i + rc_i*COS(t1); py1 = cy_i; pz1 = cz_i + rc_i*SIN(t1)
          px2 = cx_i + rc_i*COS(t2); py2 = cy_i; pz2 = cz_i + rc_i*SIN(t2)
          CALL PROJ_3D(px1, py1, pz1, xc, yc, zc, scale_px, cx_scr, cy_scr, sx, sy, dep2)
          CALL PROJ_3D(px2, py2, pz2, xc, yc, zc, scale_px, cx_scr, cy_scr, sx2, sy2, dep)
          IF (0.5d0*(dep + dep2) >= C_DEPTH(I)) THEN
             CALL Set_Color('#06B6D4')
             CALL Set_Style(LW=0.85d0, DASH=0, OPACITY=0.38d0, LAYER=2)
          ELSE
             CALL Set_Color('#06B6D4')
             CALL Set_Style(LW=0.75d0, DASH=0, OPACITY=0.16d0, LAYER=1)
          END IF
          CALL ADD_LINE_F(sx, sy, sx2, sy2)
       END DO
    END DO

    DEALLOCATE(ORDER, C_DEPTH)

    !external 3D point source beacon + vertical elevation stalk if src_mode == 1
    IF (src_mode == 1) THEN
       CALL PROJ_3D(src_x*1.0d4, src_y*1.0d4, z0, xc, yc, zc, &
            scale_px, cx_scr, cy_scr, sx, sy, dep)
       CALL PROJ_3D(src_x*1.0d4, src_y*1.0d4, src_z*1.0d4, xc, yc, zc, &
            scale_px, cx_scr, cy_scr, sx2, sy2, dep2)
       CALL Set_Color('#E11D48')
       CALL Set_Style(LW=1.4d0, DASH=1, OPACITY=0.75d0, LAYER=2)
       CALL ADD_LINE_F(sx, sy, sx2, sy2)
       CALL ADD_CIRCLE(sx2, sy2, 6.5d0, '#E11D48', '#111111', 1.4d0, 1.0d0, 0, 2)
       CALL DRAW_MARKER_AT(sx2, sy2, 5, 10.0d0, '#E11D48', 2)
    END IF

    CALL Set_Color('#94A3B8')
    CALL Set_Style(LW=1.0d0, DASH=1, OPACITY=0.45d0, LAYER=2)
    CALL PROJ_3D(x1, y0, z1, xc, yc, zc, scale_px, cx_scr, cy_scr, sx, sy, dep)
    CALL PROJ_3D(x0, y0, z1, xc, yc, zc, scale_px, cx_scr, cy_scr, sx2, sy2, dep2)
    CALL ADD_LINE_F(sx, sy, sx2, sy2)
    CALL PROJ_3D(x1, y1, z1, xc, yc, zc, scale_px, cx_scr, cy_scr, sx2, sy2, dep2)
    CALL ADD_LINE_F(sx, sy, sx2, sy2)
    CALL PROJ_3D(x1, y0, z0, xc, yc, zc, scale_px, cx_scr, cy_scr, sx2, sy2, dep2)
    CALL ADD_LINE_F(sx, sy, sx2, sy2)

    CALL Set_Color('#111111')
    CALL Set_Style(LW=1.5d0, DASH=0, OPACITY=1.0d0, LAYER=2)

    !X-axis ticks along (x, y0, z0)
    DO I = 0, NT_X
       vval = x0 + real(I, 8) * step_x
       CALL PROJ_3D(vval, y0, z0, xc, yc, zc, scale_px, cx_scr, cy_scr, sx, sy, dep)
       CALL ADD_LINE_F(sx, sy, sx - 4.0d0, sy + 6.0d0)
       CALL NUM2STR(vval, t_str)
       CALL ADD_TEXT_EX(sx - 6.0d0, sy + 20.0d0, t_str, t_str, 0, 12, .FALSE., 'C', '#111111', 3)
    END DO
    CALL PROJ_3D(0.5d0*(x0 + x1), y0, z0, xc, yc, zc, scale_px, cx_scr, cy_scr, sx, sy, dep)
    CALL ADD_TEXT_EX(sx - 24.0d0, sy + 42.0d0, 'X [um]', 'X [&#956;m]', 0, 14, .TRUE., 'C', '#111111', 3)

    !Y-axis ticks along (x1, y, z0)
    DO J = 0, NT_Y
       vval = y0 + real(J, 8) * step_y
       CALL PROJ_3D(x1, vval, z0, xc, yc, zc, scale_px, cx_scr, cy_scr, sx, sy, dep)
       CALL ADD_LINE_F(sx, sy, sx + 5.0d0, sy + 5.0d0)
       CALL NUM2STR(vval, t_str)
       CALL ADD_TEXT_EX(sx + 10.0d0, sy + 18.0d0, t_str, t_str, 0, 12, .FALSE., 'L', '#111111', 3)
    END DO
    CALL PROJ_3D(x1, 0.5d0*(y0 + y1), z0, xc, yc, zc, scale_px, cx_scr, cy_scr, sx, sy, dep)
    CALL ADD_TEXT_EX(sx + 38.0d0, sy + 36.0d0, 'Y [um]', 'Y [&#956;m]', 0, 14, .TRUE., 'C', '#111111', 3)

    !Z-axis ticks along (x1, y1, z)
    DO M = 0, NT_Z
       vval = z0 + real(M, 8) * step_z
       CALL PROJ_3D(x1, y1, vval, xc, yc, zc, scale_px, cx_scr, cy_scr, sx, sy, dep)
       CALL ADD_LINE_F(sx, sy, sx + 7.0d0, sy)
       CALL NUM2STR(vval, t_str)
       CALL ADD_TEXT_EX(sx + 12.0d0, sy + 4.5d0, t_str, t_str, 0, 12, .FALSE., 'L', '#111111', 3)
    END DO
    CALL PROJ_3D(x1, y1, 0.5d0*(z0 + z1), xc, yc, zc, scale_px, cx_scr, cy_scr, sx, sy, dep)
    CALL ADD_TEXT_EX(sx + 54.0d0, sy, 'Z [um]', 'Z [&#956;m]', -90, 14, .TRUE., 'C', '#111111', 3)

    leg_n = 0
    leg_n = leg_n + 1
    IF (src_mode == 1) THEN
       leg_lbl(leg_n) = 'Alpha Point Source'
    ELSE
       leg_lbl(leg_n) = 'Source Nucleus'
    END IF
    leg_clr(leg_n) = '#E11D48'; leg_sty(leg_n) = 'S'; leg_mkr(leg_n) = 1; leg_dsh(leg_n) = 0

    leg_n = leg_n + 1
    leg_lbl(leg_n) = 'Hit Target Nucleus'
    leg_clr(leg_n) = '#9333EA'; leg_sty(leg_n) = 'S'; leg_mkr(leg_n) = 1; leg_dsh(leg_n) = 0

    IF (has_unhit) THEN
       leg_n = leg_n + 1
       leg_lbl(leg_n) = 'Unhit Nucleus'
       leg_clr(leg_n) = '#94A3B8'; leg_sty(leg_n) = 'S'; leg_mkr(leg_n) = 1; leg_dsh(leg_n) = 0
    END IF

    leg_n = leg_n + 1
    leg_lbl(leg_n) = 'Cytoplasm 3D Shell'
    leg_clr(leg_n) = '#06B6D4'; leg_sty(leg_n) = 'L'; leg_mkr(leg_n) = 1; leg_dsh(leg_n) = 0

    leg_n = leg_n + 1
    leg_lbl(leg_n) = '3D Alpha Tracks'
    leg_clr(leg_n) = '#F59E0B'; leg_sty(leg_n) = 'L'; leg_mkr(leg_n) = 1; leg_dsh(leg_n) = 0

    CALL Draw_Legend(leg_lbl(1:leg_n), leg_clr(1:leg_n), leg_sty(1:leg_n), &
         leg_n, DASHES=leg_dsh(1:leg_n), MARKERS=leg_mkr(1:leg_n))

    CALL Finish_Figure('colony_structure_3d.svg')
END SUBROUTINE PLOT_COLONY_3D_STRUCTURE
  

END MODULE CACPLOTTER
