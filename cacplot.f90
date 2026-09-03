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
    END FUNCTION


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
      IMPORT :: C_PTR, C_LONG, C_INT;
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
      IMPORT :: C_PTR, C_LONG, C_INT;
      INTEGER(C_INT) :: XDrawLine
      TYPE(C_PTR), VALUE :: display, gc
      INTEGER(C_LONG), VALUE :: d
      INTEGER(C_INT), VALUE :: x1, y1, x2, y2
    END FUNCTION XDrawLine

    
    FUNCTION XDrawString(display, d, gc, x, y, string, length) BIND(C, NAME="XDrawString")
      IMPORT :: C_PTR, C_LONG, C_INT, C_CHAR;
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
  TYPE(C_PTR) :: DISP
  TYPE(C_PTR) :: GC
  INTEGER(C_LONG) :: WIN
  INTEGER(C_LONG) :: CMAP
  INTEGER(C_LONG) :: BLACK
  INTEGER(C_LONG) :: WHITE
  INTEGER :: WIN_W
  INTEGER :: WIN_H

  TYPE :: LINE_T
     INTEGER :: X1
     INTEGER :: Y1
     INTEGER :: X2
     INTEGER :: Y2
    INTEGER(C_LONG) :: PIXEL
    CHARACTER(LEN=20) :: CLR
  END TYPE LINE_T

  TYPE :: TEXT_T
     INTEGER :: X
     INTEGER :: Y
     INTEGER :: ANGLE
    INTEGER(C_LONG) :: PIXEL
    CHARACTER(LEN=50) :: TXT
    CHARACTER(LEN=20) :: CLR
  END TYPE TEXT_T

  TYPE(LINE_T), ALLOCATABLE :: LINES(:)
  TYPE(TEXT_T), ALLOCATABLE :: TEXTS(:)
  INTEGER :: NLINES = 0
  INTEGER :: NTEXTS = 0

  REAL(8) :: XMIN
  REAL(8) :: XMAX
  REAL(8) :: YMIN
  REAL(8) :: YMAX
  !PADR is the wide right margin reserved for the legend
  INTEGER :: PADX = 100
  INTEGER :: PADR = 250
  INTEGER :: PADY = 90
  LOGICAL :: IS_X_LOG = .FALSE.
  LOGICAL :: IS_Y_LOG = .FALSE.
  LOGICAL :: DRAW_GRID = .TRUE.
  CHARACTER(LEN=20) :: CUR_COLOR
  INTEGER(C_LONG) :: CUR_PIXEL
  INTEGER :: CUR_MARKER = 1
  INTEGER, PARAMETER :: C_LEFT = 1
  INTEGER, PARAMETER :: C_RIGHT = 2
  INTEGER, PARAMETER :: C_BOTTOM = 4
  INTEGER, PARAMETER :: C_TOP = 8

CONTAINS

  !this is used to ignore unused return statuses from X11 C functions
  SUBROUTINE CHECK(STATUS)
    INTEGER(C_INT), INTENT(IN) :: STATUS
    if (.false.) print *, STATUS  !since unused, it silence status
  END SUBROUTINE CHECK

  !doubles the line buffer size when full
  SUBROUTINE EXPAND_LINES()
    TYPE(LINE_T), ALLOCATABLE :: TEMP(:)
    ALLOCATE(TEMP(SIZE(LINES) * 2))
    TEMP(1:NLINES) = LINES(1:NLINES)
    CALL MOVE_ALLOC(TEMP, LINES)
  END SUBROUTINE EXPAND_LINES

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
    NTEXTS = 0
    !PRINT*, NLINES

    IF (.NOT. ALLOCATED(LINES)) ALLOCATE(LINES(1000000))
    IF (.NOT. ALLOCATED(TEXTS)) ALLOCATE(TEXTS(10000))

    !ALLOCATE(LINES(1000000))
    !ALLOCATE(TEXTS(10000))
    
    CUR_COLOR = 'black'
    CUR_PIXEL = 0
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
    
    CUR_COLOR = 'black'
    CUR_PIXEL = BLACK

    WIN = XCreateSimpleWindow(DISP, ROOT, 0_C_INT, 0_C_INT, INT(W, C_INT), INT(H, C_INT), &
                              1_C_INT, BLACK, WHITE)

    CALL CHECK( XSelectInput(DISP, WIN, 32769_C_LONG) ) 
    CALL CHECK( XMapWindow(DISP, WIN) )

    GC = XCreateGC(DISP, WIN, 0_C_LONG, C_NULL_PTR)
    CALL CHECK( XSetForeground(DISP, GC, BLACK) )
  END SUBROUTINE Init_Plot

  !********************************8

  !here we set the main title at the top of the plot
  SUBROUTINE Set_Title(TXT)
    CHARACTER(LEN=*), INTENT(IN) :: TXT
    CALL ADD_TEXT(WIN_W/2 - 100, 40, TXT)
  END SUBROUTINE Set_Title

  !log scaling on axes
  SUBROUTINE Set_Scale(X_LOG, Y_LOG)
    LOGICAL, INTENT(IN) :: X_LOG, Y_LOG
    IS_X_LOG = X_LOG
    IS_Y_LOG = Y_LOG
  END SUBROUTINE Set_Scale

  !*****************************************
  !color by X11 colormap
  SUBROUTINE Set_Color(CNAME)
    CHARACTER(LEN=*), INTENT(IN) :: CNAME
    TYPE(XColor), TARGET :: EXACT, SCREEN  
    CHARACTER(KIND=C_CHAR, LEN=30) :: C_STR
    
    CUR_COLOR = CNAME

    !THIS IS REAL(8)LY IMPORTANT WHEN ON SVG EXPORT MODE ON ONLY
    !SKIP X11 ALLOCATION
    IF (.NOT. C_ASSOCIATED(DISP)) THEN
       CUR_PIXEL = 0
       RETURN
    END IF
    
    C_STR = TRIM(CNAME) // C_NULL_CHAR
   
    IF (XAllocNamedColor(DISP, CMAP, C_STR, C_LOC(SCREEN), C_LOC(EXACT)) /= 0) THEN
       CUR_PIXEL = SCREEN%PIXEL
    ELSE

       CUR_PIXEL = BLACK
    END IF

  END SUBROUTINE Set_Color
  !*****************************************
  

  !here we set markers(1=Cross, 2=Ex, 3=Square, etc.)
  SUBROUTINE Set_Marker(M)
    INTEGER, INTENT(IN) :: M
    CUR_MARKER = M
  END SUBROUTINE Set_Marker

  !here we draw outer box, calculates tick positions, and prints labels
  SUBROUTINE Draw_Axes(XA, XE, YA, YE, XLABEL, YLABEL)
    REAL(8), INTENT(IN) :: XA
    REAL(8), INTENT(IN) :: XE
    REAL(8), INTENT(IN) :: YA
    REAL(8), INTENT(IN) :: YE
    CHARACTER(LEN=*), INTENT(IN) :: XLABEL
    CHARACTER(LEN=*), INTENT(IN) :: YLABEL
    REAL(8) :: V
    real(8) :: STEP
    REAL(8) :: POS
    INTEGER :: I
    integer :: P
    integer :: P_START
    INTEGER :: P_END
    CHARACTER(LEN=20) :: STR
    character(len=20) :: SAVE_CLR
    INTEGER(C_LONG) :: SAVE_PIX

    SAVE_CLR = CUR_COLOR
    SAVE_PIX = CUR_PIXEL
    
    CALL Set_Color('black')

    IF (IS_X_LOG) THEN
       XMIN = LOG10(XA)
       XMAX = LOG10(XE)
    ELSE
       XMIN = XA
       XMAX = XE
    END IF
    
    IF (IS_Y_LOG) THEN
       YMIN = LOG10(YA)
       YMAX = LOG10(YE)
    ELSE
       YMIN = YA
       YMAX = YE
    END IF

    !draw axis box
    CALL ADD_LINE(PADX, WIN_H - PADY, WIN_W - PADR, WIN_H - PADY)
    CALL ADD_LINE(PADX, PADY, WIN_W - PADR, PADY)
    CALL ADD_LINE(PADX, WIN_H - PADY, PADX, PADY)
    CALL ADD_LINE(WIN_W - PADR, WIN_H - PADY, WIN_W - PADR, PADY)
    
    !X axis ticks and labels
    IF (.NOT. IS_X_LOG) THEN
      STEP = (XE - XA) / 5.0
      DO I = 0, 5
        V = XA + I * STEP
        POS = PADX + (V - XMIN) / (XMAX - XMIN) * (WIN_W - PADX - PADR)
        
        CALL ADD_LINE(NINT(POS), WIN_H - PADY, NINT(POS), WIN_H - PADY + 8)

        IF (DRAW_GRID .AND. I>0 .AND. I<5) THEN
           CALL Set_Color('lightgray')
           CALL ADD_LINE(NINT(POS), WIN_H - PADY, NINT(POS), PADY)
           CALL Set_Color('black')
        END IF

        CALL NUM2STR(V, STR); CALL ADD_TEXT(NINT(POS) - 15, WIN_H - PADY + 25, STR)

     END DO
    ELSE

       P_START = FLOOR(XMIN)
       P_END = CEILING(XMAX)

       DO P = P_START, P_END
          
        POS = PADX + (real(P) - XMIN) / (XMAX - XMIN) * (WIN_W - PADX - PADR)

        IF (POS >= PADX .AND. POS <= WIN_W - PADR) THEN

           CALL ADD_LINE(NINT(POS), WIN_H - PADY, NINT(POS), WIN_H - PADY + 8)

           IF (DRAW_GRID) THEN

              CALL Set_Color('lightgray')
             CALL ADD_LINE(NINT(POS), WIN_H - PADY, NINT(POS), PADY)
             CALL Set_Color('black')

          END IF

          WRITE(STR, '("10^",I0)') P

          CALL ADD_TEXT(NINT(POS) - 15, WIN_H - PADY + 25, TRIM(STR))
          
        END IF

     END DO

  END IF

    !Y axis ticks and labels
    IF (.NOT. IS_Y_LOG) THEN
       STEP = (YE - YA) / 5.0
       
      DO I = 0, 5
        V = YA + I * STEP

        POS = WIN_H - PADY - (V - YMIN) / (YMAX - YMIN) * (WIN_H - 2*PADY)

        CALL ADD_LINE(PADX, NINT(POS), PADX - 8, NINT(POS))

        IF (DRAW_GRID .AND. I>0 .AND. I<5) THEN
           CALL Set_Color('lightgray')
           CALL ADD_LINE(PADX, NINT(POS), WIN_W - PADR, NINT(POS))
           CALL Set_Color('black')
        END IF

        CALL NUM2STR(V, STR); CALL ADD_TEXT(PADX - 70, NINT(POS) + 5, STR)

     END DO

  ELSE

     P_START = FLOOR(YMIN)

     P_END = CEILING(YMAX)

     DO P = P_START, P_END

        POS = WIN_H - PADY - (real(P) - YMIN) / (YMAX - YMIN) * (WIN_H - 2*PADY)

        IF (POS >= PADY .AND. POS <= WIN_H - PADY) THEN

           CALL ADD_LINE(PADX, NINT(POS), PADX - 8, NINT(POS))

           IF (DRAW_GRID) THEN
             CALL Set_Color('lightgray')
             CALL ADD_LINE(PADX, NINT(POS), WIN_W - PADR, NINT(POS))
             CALL Set_Color('black')

          END IF

          WRITE(STR, '("10^",I0)') P

          CALL ADD_TEXT(PADX - 50, NINT(POS) + 5, TRIM(STR))

       END IF
      END DO
    END IF

    CALL ADD_TEXT((WIN_W - PADR)/2, WIN_H - 25, XLABEL)
    CALL ADD_TEXT(30, WIN_H/2 + 50, YLABEL, -90)  !here we rotate y axis label 90 deg.

    CALL Set_Color(SAVE_CLR)
  END SUBROUTINE Draw_Axes


   !*******************************************************************

  !here looping through data arr to make line segments or points
  SUBROUTINE Draw_Curve(X, Y, N, STYLE)
    REAL(8), INTENT(IN) :: X(N)
    REAL(8), INTENT(IN) :: Y(N)
    INTEGER, INTENT(IN) :: N
    CHARACTER(LEN=1), INTENT(IN) :: STYLE 
    INTEGER :: I
    REAL(8) :: SX
    REAL(8) :: SY
    REAL(8) :: XT
    REAL(8) :: YT

    IF (STYLE == 'L' .OR. STYLE == 'B') THEN

       DO I = 1, N-1
        CALL DRAW_SEGMENT(X(I), Y(I), X(I+1), Y(I+1))
      END DO

   END IF

    IF (STYLE == 'S' .OR. STYLE == 'B') THEN
      DO I = 1, N
        XT = X(I); IF (IS_X_LOG) XT = LOG10(MAX(X(I), 1E-30))
        YT = Y(I); IF (IS_Y_LOG) YT = LOG10(MAX(Y(I), 1E-30))
        SX = PADX + (XT - XMIN) / (XMAX - XMIN) * (WIN_W - PADX - PADR)
        SY = WIN_H - PADY - (YT - YMIN) / (YMAX - YMIN) * (WIN_H - 2*PADY)
        
        IF (SX >= PADX .AND. SX <= WIN_W - PADR .AND. SY >= PADY .AND. SY <= WIN_H - PADY) THEN
          SELECT CASE(CUR_MARKER)
            CASE(1)
               CALL CLIP_AND_ADD(SX-4.0, SY, SX+4.0, SY)
               CALL CLIP_AND_ADD(SX, SY-4.0, SX, SY+4.0)
            CASE(2)
               CALL CLIP_AND_ADD(SX-3.0, SY-3.0, SX+3.0, SY+3.0)
               CALL CLIP_AND_ADD(SX-3.0, SY+3.0, SX+3.0, SY-3.0)
            CASE(3)
               CALL CLIP_AND_ADD(SX-3.0, SY-3.0, SX+3.0, SY-3.0)
               CALL CLIP_AND_ADD(SX+3.0, SY-3.0, SX+3.0, SY+3.0)
               CALL CLIP_AND_ADD(SX+3.0, SY+3.0, SX-3.0, SY+3.0)
               CALL CLIP_AND_ADD(SX-3.0, SY+3.0, SX-3.0, SY-3.0)
            CASE(4)
               CALL CLIP_AND_ADD(SX, SY-4.0, SX+4.0, SY+3.0)
               CALL CLIP_AND_ADD(SX+4.0, SY+3.0, SX-4.0, SY+3.0)
              CALL CLIP_AND_ADD(SX-4.0, SY+3.0, SX, SY-4.0)
           END SELECT
           
        END IF

     END DO

  END IF

END SUBROUTINE Draw_Curve

  !*******************************************************************
  !draw legend on right margin of the plot, no overlap with the plot
  SUBROUTINE Draw_Legend(LABELS, COLORS, STYLES, N)
    CHARACTER(LEN=*), INTENT(IN) :: LABELS(N), COLORS(N)
    CHARACTER(LEN=1), INTENT(IN) :: STYLES(N)
    INTEGER, INTENT(IN) :: N
    INTEGER :: I
    INTEGER :: LX
    INTEGER :: LY
    CHARACTER(LEN=20) :: SAVE_CLR
    
    SAVE_CLR = CUR_COLOR

    LX = WIN_W - PADR + 40

    LY = PADY + 20
    
    DO I = 1, N

       CALL Set_Color(COLORS(I))
       IF (STYLES(I) == 'L' .OR. STYLES(I) == 'B') CALL ADD_LINE(LX, LY + (I-1)*30, LX + 30, LY + (I-1)*30)

       IF (STYLES(I) == 'S' .OR. STYLES(I) == 'B') THEN
          CALL ADD_LINE(LX+12, LY+(I-1)*30-3, LX+18, LY+(I-1)*30+3)
          CALL ADD_LINE(LX+12, LY+(I-1)*30+3, LX+18, LY+(I-1)*30-3)

       END IF

       CALL Set_Color('black')

       CALL ADD_TEXT(LX + 45, LY + (I-1)*30 + 5, LABELS(I))

    END DO

    CALL Set_Color(SAVE_CLR)

  END SUBROUTINE Draw_Legend

  
  !*******************************************************************
  !SVG format writer/exporter here
  SUBROUTINE Export_SVG(FNAME)
    CHARACTER(LEN=*), INTENT(IN) :: FNAME
    INTEGER :: I
    !character(len=1024) :: output_filex
    !output_filex = trim(out_dir)//'/'//FNAME

    !print*, output_filex
    
    OPEN(UNIT=10, FILE=trim(out_dir)//'/'//FNAME, STATUS='UNKNOWN', ACTION='WRITE')
    WRITE(10,'(A)') '<?xml version="1.0" encoding="UTF-8"?>'
    WRITE(10,'(A,I0,A,I0,A)') '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ', WIN_W, ' ', WIN_H, '">'
    WRITE(10,'(A)') '<rect width="100%" height="100%" fill="white"/>'
    DO I = 1, NLINES
       !PRINT*, NLINES
      WRITE(10,'(A,I0,A,I0,A,I0,A,I0,A,A,A)') '<line x1="', LINES(I)%X1, '" y1="', LINES(I)%Y1, &
            '" x2="', LINES(I)%X2, '" y2="', LINES(I)%Y2, '" stroke="', TRIM(LINES(I)%CLR), '" stroke-width="1.5"/>'
    END DO
    DO I = 1, NTEXTS
      IF (TEXTS(I)%ANGLE /= 0) THEN
        WRITE(10,'(A,I0,A,I0,A,I0,A,I0,A,I0,A,A,A,A,A)') '<text x="', TEXTS(I)%X, '" y="', TEXTS(I)%Y, &
          '" transform="rotate(', TEXTS(I)%ANGLE, ' ', TEXTS(I)%X, ' ', TEXTS(I)%Y, &
          ')" fill="', TRIM(TEXTS(I)%CLR), '" font-family="monospace" font-size="14">', TRIM(TEXTS(I)%TXT), '</text>'
      ELSE
        WRITE(10,'(A,I0,A,I0,A,A,A,A,A)') '<text x="', TEXTS(I)%X, '" y="', TEXTS(I)%Y, &
          '" fill="', TRIM(TEXTS(I)%CLR), '" font-family="monospace" font-size="14">', TRIM(TEXTS(I)%TXT), '</text>'
      END IF
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
    INTEGER :: LEN
    LOGICAL :: RUNNING
    CHARACTER(KIND=C_CHAR, LEN=1), ALLOCATABLE :: CTXT(:)
    INTEGER(C_LONG) :: LAST_PIX

    CALL ADD_TEXT(WIN_W/2 - 100, 60, "(PRESS ANY KEY IN WINDOW TO CLOSE)")

    RUNNING = .TRUE.
    DO WHILE(RUNNING)

       CALL CHECK( XNextEvent(DISP, C_LOC(EV_BUFFER)) )

       EV_TYPE = EV_BUFFER(1) 
      
      IF (EV_TYPE == 12) THEN
        LAST_PIX = -1

        DO I = 1, NLINES

           IF (LINES(I)%PIXEL /= LAST_PIX) THEN

              CALL CHECK(XSetForeground(DISP, GC, LINES(I)%PIXEL))

              LAST_PIX = LINES(I)%PIXEL

           END IF

       CALL CHECK(XDrawLine(DISP, WIN, GC, LINES(I)%X1, LINES(I)%Y1, LINES(I)%X2, LINES(I)%Y2))

        END DO
        
        DO I = 1, NTEXTS

           IF (TEXTS(I)%PIXEL /= LAST_PIX) THEN

              CALL CHECK(XSetForeground(DISP, GC, TEXTS(I)%PIXEL))

              LAST_PIX = TEXTS(I)%PIXEL
          END IF

          LEN = LEN_TRIM(TEXTS(I)%TXT)

          ALLOCATE(CTXT(LEN))

          DO J = 1, LEN; CTXT(J) = TEXTS(I)%TXT(J:J); END DO

      CALL CHECK(XDrawString(DISP, WIN, GC, TEXTS(I)%X, TEXTS(I)%Y, CTXT, INT(LEN, C_INT)))

             DEALLOCATE(CTXT)

          END DO

       ELSE IF (EV_TYPE == 2) THEN

          RUNNING = .FALSE.

       END IF

    END DO

    CALL CHECK( XCloseDisplay(DISP) )

  END SUBROUTINE Render_Plot

  !******************************************
  !convert real(8) to string
  SUBROUTINE NUM2STR(VAL, STR)
    REAL(8), INTENT(IN) :: VAL
    CHARACTER(LEN=*), INTENT(OUT) :: STR
    CHARACTER(LEN=20) :: TMP
    INTEGER :: I
    INTEGER :: J

    WRITE(TMP, '(G11.4)') VAL

    STR = ' '; J = 1

    DO I = 1, 20
       IF (TMP(I:I) /= ' ' .AND. J <= LEN(STR)) THEN
          STR(J:J) = TMP(I:I); J = J + 1
       END IF
    END DO
    
  END SUBROUTINE NUM2STR
  !******************************************
  
  
  !Cohen-Sutherland clipping
  FUNCTION GET_OUTCODE(X, Y) RESULT(CODE)
    REAL(8), INTENT(IN) :: X
    REAL(8), INTENT(IN) :: Y
    INTEGER :: CODE

    CODE = 0

    IF (X < PADX) CODE = IOR(CODE, C_LEFT)
    IF (X > WIN_W - PADR) CODE = IOR(CODE, C_RIGHT)
    IF (Y < PADY) CODE = IOR(CODE, C_TOP)
    IF (Y > WIN_H - PADY) CODE = IOR(CODE, C_BOTTOM)

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
    INTEGER :: OUT0
    INTEGER :: OUT1
    INTEGER :: OUT_OUT
    LOGICAL :: ACCEPT

    X=0.0
    Y = 0.0

    X1 = X1_IN
    Y1 = Y1_IN
    X2 = X2_IN
    Y2 = Y2_IN
    ACCEPT = .FALSE.

    OUT0 = GET_OUTCODE(X1, Y1)
    OUT1 = GET_OUTCODE(X2, Y2)

    DO
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
         !  IF (Y2 /= Y1) X = X1 + (X2 - X1) * (real(PADY) - Y1) / (Y2 - Y1)
            IF (ABS(Y2-Y1) > 0.0) X = X1 + (X2 - X1) * (real(PADY) - Y1) / (Y2 - Y1)
          Y = real(PADY)
        ELSE IF (IAND(OUT_OUT, C_BOTTOM) /= 0) THEN
          ! IF (Y2 /= Y1) X = X1 + (X2 - X1) * (real(WIN_H - PADY) - Y1) / (Y2 - Y1)
           IF (ABS(Y2 - Y1) > 0.0) X = X1 + (X2 - X1) * (real(WIN_H - PADY) - Y1) / (Y2 - Y1)
          Y = real(WIN_H - PADY)
        ELSE IF (IAND(OUT_OUT, C_RIGHT) /= 0) THEN
          ! IF (X2 /= X1) Y = Y1 + (Y2 - Y1) * (real(WIN_W - PADR) - X1) / (X2 - X1)
           IF (ABS(X2 - X1) > 0.0) Y = Y1 + (Y2 - Y1) * (real(WIN_W - PADR) - X1) / (X2 - X1)
          X = real(WIN_W - PADR)
        ELSE IF (IAND(OUT_OUT, C_LEFT) /= 0) THEN
           !IF (X2 /= X1) Y = Y1 + (Y2 - Y1) * (real(PADX) - X1) / (X2 - X1)
           IF (ABS(X2-X1) > 0.0) Y = Y1 + (Y2 - Y1) * (real(PADX) - X1) / (X2 - X1)
          X = real(PADX)
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

    IF (ACCEPT) CALL ADD_LINE(NINT(X1), NINT(Y1), NINT(X2), NINT(Y2))

  END SUBROUTINE CLIP_AND_ADD

  !*************************************
  !push coordinate to line data
  SUBROUTINE ADD_LINE(X1, Y1, X2, Y2)
    INTEGER, INTENT(IN) :: X1
    INTEGER, INTENT(IN) :: Y1
    INTEGER, INTENT(IN) :: X2
    INTEGER, INTENT(IN) :: Y2
    
    IF (NLINES >= SIZE(LINES)) CALL EXPAND_LINES()

    NLINES = NLINES + 1

    LINES(NLINES)%X1 = X1
    LINES(NLINES)%Y1 = Y1
    LINES(NLINES)%X2 = X2
    LINES(NLINES)%Y2 = Y2
    LINES(NLINES)%CLR = CUR_COLOR
    LINES(NLINES)%PIXEL = CUR_PIXEL

  END SUBROUTINE ADD_LINE
  !**************************************

  !push string to texts data
  SUBROUTINE ADD_TEXT(X, Y, TXT, ANGLE)
    INTEGER, INTENT(IN) :: X
    INTEGER, INTENT(IN) :: Y
    CHARACTER(LEN=*), INTENT(IN) :: TXT
    INTEGER, INTENT(IN), OPTIONAL :: ANGLE

    IF (NTEXTS >= SIZE(TEXTS)) CALL EXPAND_TEXTS()

    NTEXTS = NTEXTS + 1

    TEXTS(NTEXTS)%X = X
    TEXTS(NTEXTS)%Y = Y
    TEXTS(NTEXTS)%TXT = TXT

    IF (PRESENT(ANGLE)) THEN
       TEXTS(NTEXTS)%ANGLE = ANGLE
    ELSE;
       TEXTS(NTEXTS)%ANGLE = 0
    END IF

      TEXTS(NTEXTS)%CLR = CUR_COLOR

      TEXTS(NTEXTS)%PIXEL = CUR_PIXEL

    END SUBROUTINE ADD_TEXT
    !************************************

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
    REAL(8) :: XT1
    REAL(8) :: YT1
    REAL(8) :: XT2
    REAL(8) :: YT2
    
    XT1 = X1
    IF (IS_X_LOG) XT1 = LOG10(MAX(X1, 1E-30))
    
    YT1 = Y1
    IF (IS_Y_LOG) YT1 = LOG10(MAX(Y1, 1E-30))

    XT2 = X2
    IF (IS_X_LOG) XT2 = LOG10(MAX(X2, 1E-30))

    YT2 = Y2
    IF (IS_Y_LOG) YT2 = LOG10(MAX(Y2, 1E-30))

    SX1 = PADX + (XT1 - XMIN) / (XMAX - XMIN) * (WIN_W - PADX - PADR)

    SY1 = WIN_H - PADY - (YT1 - YMIN) / (YMAX - YMIN) * (WIN_H - 2*PADY)

    SX2 = PADX + (XT2 - XMIN) / (XMAX - XMIN) * (WIN_W - PADX - PADR)

    SY2 = WIN_H - PADY - (YT2 - YMIN) / (YMAX - YMIN) * (WIN_H - 2*PADY)
    
    CALL CLIP_AND_ADD(SX1, SY1, SX2, SY2)

  END SUBROUTINE DRAW_SEGMENT


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
    REAL(8), ALLOCATABLE :: y_hits_nuc(:)
    REAL(8), ALLOCATABLE :: y_hits_cyto(:)
    CHARACTER(LEN=20) :: cell_string
    CHARACTER(LEN=*), PARAMETER :: ESC = ACHAR(27)
    CHARACTER(LEN=*), PARAMETER :: RST = ESC // "[0m"      !reset
    CHARACTER(LEN=*), PARAMETER :: BLUE = ESC // "[34m"     !blue
    REAL(8), PARAMETER :: PI = ACOS(-1.0)
    REAL(8) :: xmax
    REAL(8) :: ymax_val
    REAL(8) :: ymin_val
    CHARACTER(LEN=20), DIMENSION(2) :: legend_labels
    CHARACTER(LEN=20), DIMENSION(2) :: legend_colors
    CHARACTER(LEN=1), DIMENSION(2)  :: legend_styles
    REAL(8) :: MAX_HIT_NUC, MIN_HIT_NUC
    REAL(8) :: MAX_HIT_CYTO, MIN_HIT_CYTO

    IF (num_cells <= 0) THEN
       RETURN
    END IF
    
    ALLOCATE(x_arr(num_cells))
    ALLOCATE(y_dose_nuc(num_cells))
    ALLOCATE(y_dose_cyto(num_cells))
    ALLOCATE(y_hits_nuc(num_cells))
    ALLOCATE(y_hits_cyto(num_cells))

    WRITE(cell_string, '(I0)') num_cells

    PRINT*, ""
    PRINT '(3A)', BLUE // 'Plotting results for ', TRIM(cell_string), ' cells' // RST

    DO i = 1, num_cells
       !vol_nuc  = (4.0 / 3.0) * PI * (cells(i)%r_nuc**3)
        !vol_cyto = (4.0 / 3.0) * PI * (cells(i)%r_cyto**3) - vol_nuc

       vol_nuc  = (4.0 / 3.0) * PI * (cells_r_nuc(i)**3)
       vol_cyto = (4.0 / 3.0) * PI * (cells_r_cyto(i)**3) - vol_nuc
       
       mass_nuc  = vol_nuc * mat_rho / 1000.0   
       mass_cyto = vol_cyto * mat_rho / 1000.0

       d_nuc  = (dose_nuc(i) * 1.602e-13) / mass_nuc / real(nps_total)
       d_cyto = (dose_cyto(i) * 1.602e-13) / mass_cyto / real(nps_total)
       
       x_arr(i)       = real(i)
       y_dose_nuc(i)  = d_nuc
       y_dose_cyto(i) = d_cyto
       y_hits_nuc(i)  = real(hits_nuc(i))
       y_hits_cyto(i) = real(hits_cyto(i))
    END DO

    !overall max for y
    ymax_val = MAX(MAXVAL(y_dose_nuc), MAXVAL(y_dose_cyto))
    
    !ensure higher than 0.0
    ymin_val = HUGE(1.0)
    DO i = 1, num_cells
        IF (y_dose_nuc(i) > 0.0 .AND. y_dose_nuc(i) < ymin_val) ymin_val = y_dose_nuc(i)
        IF (y_dose_cyto(i) > 0.0 .AND. y_dose_cyto(i) < ymin_val) ymin_val = y_dose_cyto(i)
    END DO
    
    !safety if empty
    IF (ymax_val <= 0.0) ymax_val = 1.0
    IF (ymin_val == HUGE(1.0)) ymin_val = ymax_val * 1.0e-4 
    
    IF (ABS(ymax_val - ymin_val) < 1.0e-30) THEN
        ymin_val = ymin_val * 0.1 ! - 10.0
        ymax_val = (ymax_val * 10.0) !+10.0
    END IF
    
    xmax = real(num_cells)

    !init
    !CALL Init_Plot(1024, 768)

    !issue here was before the x11 window init was not separated
    !so if render_plot_check was off but svg export was on
    !one could see a flashing x11 empty window, that was so annoying and unprofessional
    !this way i have fixed it to avoid such flash
    If (RENDER_PLOT_CHECK == 1)then
       call Init_Plot(1024,768)
    else
       call Init_Canvas(1024,768)
       end if
    
    CALL Set_Title('CyricAlphaCell: Cell Dosimetry Results')  
    CALL Set_Scale(.FALSE., .TRUE.)  !lin X, log Y

    !axes draw (Xmin, Xmax, Ymin, Ymax, Xlabel, Ylabel)
    CALL Draw_Axes(0.0d0, xmax+xmax*0.01, ymin_val-ymin_val*0.1, ymax_val + ymax_val*0.1, 'Cell Index', 'Absorbed Dose (Gy)')


    !plot nuc. dose
    CALL Set_Color('red')
    CALL Set_Marker(1)
    CALL Draw_Curve(x_arr, y_dose_nuc, num_cells, 'S')

    

    !plot cyto dose
    CALL Set_Color('blue')
    CALL Set_Marker(3)
    CALL Draw_Curve(x_arr, y_dose_cyto, num_cells, 'S')  

    !legeds
    legend_labels(1) = 'Nucleus Dose'
    legend_colors(1) = 'red'
    legend_styles(1) = 'B'

    legend_labels(2) = 'Cytoplasm Dose'
    legend_colors(2) = 'blue'
    legend_styles(2) = 'B'

    !node draw legend takes arrays
    CALL Draw_Legend(legend_labels, legend_colors, legend_styles, 2)

    
    !export svg
    if(SVG_PLOT_CHECK == 1) CALL Export_SVG('cell_dosimetry_results.svg')

    if(RENDER_PLOT_CHECK == 1)  CALL Render_Plot



    !PRINT*, y_hits_nuc(3)

    DEALLOCATE(LINES)
    DEALLOCATE(TEXTS)

    DEALLOCATE(y_dose_nuc)
    DEALLOCATE(y_dose_cyto)


    !--------CELL HITS PLOTS BELOW---------

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

    !prevent division by zero in Draw_Axes
    IF (ABS(MAX_HIT_NUC - MIN_HIT_NUC) < 1.0D-6) THEN
        MIN_HIT_NUC = MAX(0.0D0, MIN_HIT_NUC - 1.0D0)
        MAX_HIT_NUC = MAX_HIT_NUC + 1.0D0
    END IF

    
    
     If (RENDER_PLOT_CHECK == 1)then
       call Init_Plot(1024,768)
    else
       call Init_Canvas(1024,768)
    end if
    
    CALL Set_Title('CyricAlphaCell: Cell Hit Results')  
    CALL Set_Scale(.FALSE., .TRUE.)  !lin X, LIN Y

        !axes draw (Xmin, Xmax, Ymin, Ymax, Xlabel, Ylabel)
    CALL Draw_Axes(0.0d0, xmax+xmax*0.01, MIN_HIT_NUC-MIN_HIT_NUC*0.1, MAX_HIT_NUC+MAX_HIT_NUC*0.1, 'Cell Index', 'Hits')


    !plot nuc. hits
   CALL Set_Color('red')
   CALL Set_Marker(2)
   CALL Draw_Curve(x_arr, y_hits_nuc, num_cells, 'S')


   !plot cyto. hits
   CALL Set_Color('blue')
   CALL Set_Marker(1)
   CALL Draw_Curve(x_arr, y_hits_cyto, num_cells, 'S')


       !legeds
    legend_labels(1) = 'Nucleus Hits'
    legend_colors(1) = 'red'
    legend_styles(1) = 'S'

    legend_labels(2) = 'Cytoplasm Hits'
    legend_colors(2) = 'blue'
    legend_styles(2) = 'S'

    !node draw legend takes arrays
    CALL Draw_Legend(legend_labels, legend_colors, legend_styles, 2)
    
     !export svg
    if(SVG_PLOT_CHECK == 1) CALL Export_SVG('cell_hit_results.svg')

    if(RENDER_PLOT_CHECK == 1)  CALL Render_Plot
    

    
    DEALLOCATE(y_hits_cyto)
    DEALLOCATE(y_hits_nuc)
        DEALLOCATE(x_arr)
    !**********************************************

        call PLOT_LET_SPECTRUM

        CALL RADIO_ZF

        call RADIO_ZD

        call RADIO_LETD

        call  RADIO_LAMBDA

        call  RADIO_P0

        call RADIO_SURV

        call RADIO_RBE

        call PLOT_MICRODOSIMETRY_Z_SPECTRA

END SUBROUTINE PLOT_RESULTS

!*******************************************************
SUBROUTINE PLOT_LET_SPECTRUM
    INTEGER :: j, i
    REAL(8), ALLOCATABLE :: x_let(:), y_let(:,:)
    REAL(8) :: xmin, xmax, ymin, ymax
    CHARACTER(LEN=20), ALLOCATABLE :: colors(:)
    CHARACTER(LEN=20), DIMENSION(6) :: color_list = &
    (/ CHARACTER(LEN=20) :: 'blue', 'red', 'forestgreen', 'darkorange', 'purple', 'teal' /)
    CHARACTER(LEN=1), DIMENSION(3) :: style_list = (/ 'L', 'S', 'B' /)
    INTEGER :: color_idx, style_idx, marker_type

    IF (LET_BINS <= 0 .OR. num_cells <= 0) RETURN

    ALLOCATE(x_let(LET_BINS))
    ALLOCATE(y_let(LET_BINS, num_cells))
    ALLOCATE(colors(num_cells))

    ! Compute X-axis values (Column 1)
    DO j = 1, LET_BINS
        x_let(j) = (real(j) - 0.5) * dLET_bin
    END DO

    ! Populate Y-values for all cells
    DO i = 1, num_cells
        DO j = 1, LET_BINS
            y_let(j, i) = let_hist_nuc(j, i) / (dLET_bin * real(nps_total))
        END DO
    END DO

    !global min/max for axes scaling
    xmin = x_let(1)
    xmax = x_let(LET_BINS)
    
    ymax = MAXVAL(y_let)
    ymin = HUGE(1.0)
    DO i = 1, num_cells
        DO j = 1, LET_BINS
            IF (y_let(j, i) > 0.0 .AND. y_let(j, i) < ymin) ymin = y_let(j, i)
        END DO
    END DO
    IF (ymin == HUGE(1.0)) ymin = ymax * 1.0e-4

    IF (RENDER_PLOT_CHECK == 1) THEN
        CALL Init_Plot(1024, 768)
    ELSE
        CALL Init_Canvas(1024, 768)
    END IF

    CALL Set_Title('CyricAlphaCell: Dose-Averaged LET Spectra')
    CALL Set_Scale(.FALSE., .TRUE.) ! .FALSE. for linear X, .TRUE. for log Y

    CALL Draw_Axes(xmin, xmax, ymin * 0.9, ymax * 1.1, 'LET (keV/um)', 'MeV / (keV/um) / source')

    !DO i = 1, num_cells
    !    IF (MOD(i, 2) == 0) THEN
    !        CALL Set_Color('blue')
    !    ELSE
    !        CALL Set_Color('red')
    !    END IF
    !    CALL Draw_Curve(x_let, y_let(:, i), LET_BINS, 'S')
    !END DO

    DO i = 1, num_cells
        color_idx = MOD(i - 1, SIZE(color_list)) + 1
        CALL Set_Color(color_list(color_idx))

        style_idx = MOD(i - 1, SIZE(style_list)) + 1
        
        marker_type = MOD(i - 1, 4) + 1
        CALL Set_Marker(marker_type)

        CALL Draw_Curve(x_let, y_let(:, i), LET_BINS, style_list(style_idx))
    END DO
 
    IF (SVG_PLOT_CHECK == 1) CALL Export_SVG('let_spectra_all.svg')
    IF (RENDER_PLOT_CHECK == 1) CALL Render_Plot

    DEALLOCATE(x_let, y_let, colors)
    IF (ALLOCATED(LINES)) DEALLOCATE(LINES)
    IF (ALLOCATED(TEXTS)) DEALLOCATE(TEXTS)
     
END SUBROUTINE PLOT_LET_SPECTRUM

!*******************************************************
SUBROUTINE RADIO_ZF
    INTEGER :: I
    REAL(8) :: YMIN, YMAX
    REAL(8), DIMENSION(num_cells) :: zF, X_ARR

    DO I = 1, num_cells
        IF (hit_events_nuc(I) > 0) THEN
            zF(I) = sum_z_nuc(I) / real(hit_events_nuc(I))
        ELSE
            zF(I) = 0.0
        END IF
        X_ARR(I) = real(I)
    END DO
   
    YMIN = MINVAL(zF)
    YMAX = MAXVAL(zF)
   
    IF (RENDER_PLOT_CHECK == 1) THEN
        CALL Init_Plot(1024, 768)
    ELSE
        CALL Init_Canvas(1024, 768)
    END IF

    CALL Set_Title('CyricAlphaCell: Radiobiology Results - z_F')
    CALL Set_Scale(.FALSE., .FALSE.)

    CALL Draw_Axes(0.0d0, real(num_cells, kind=8)*1.01, YMIN * 0.9, YMAX * 1.1, 'Cell Index', 'z_F (Gy)')

    CALL Set_Color('blue')
    CALL Set_Marker(1)

    CALL Draw_Curve(X_ARR, zF, num_cells, 'S')
    
    IF (SVG_PLOT_CHECK == 1) CALL Export_SVG('zF.svg')
    IF (RENDER_PLOT_CHECK == 1) CALL Render_Plot

    IF (ALLOCATED(LINES)) DEALLOCATE(LINES)
    IF (ALLOCATED(TEXTS)) DEALLOCATE(TEXTS)

END SUBROUTINE RADIO_ZF

!*******************************************************
SUBROUTINE RADIO_ZD
    INTEGER :: I, j
    REAL(8) :: YMIN, YMAX
    REAL(8), DIMENSION(num_cells) :: zD, X_ARR, let_D, sum_let_dose

    DO I = 1, num_cells
        X_ARR(I) = real(I)
        let_D(I) = 0.0
        sum_let_dose(I) = 0.0
        
        DO j = 1, LET_BINS
            IF (let_hist_nuc(j, I) > 0.0) THEN
                let_D(I) = let_D(I) + ((real(j)-0.5)*dLET_bin) * let_hist_nuc(j, I)
                sum_let_dose(I) = sum_let_dose(I) + let_hist_nuc(j, I)
            END IF
        END DO

        IF (sum_let_dose(I) > 0.0) THEN
            let_D(I) = let_D(I) / sum_let_dose(I)
        ELSE
            let_D(I) = 0.0
        END IF

        ! formula: z_domain = (0.204 * LET_D) / (d^2)
        IF (let_D(I) > 0.0) THEN
            zD(I) = (0.204 * let_D(I)) / (bio_domain_d**2) 
        ELSE
            zD(I) = sum_z2_nuc(I) / MAX(sum_z_nuc(I), 1.0E-6)
        END IF
    END DO
   
    YMIN = MINVAL(zD)
    YMAX = MAXVAL(zD)
   
    IF (RENDER_PLOT_CHECK == 1) THEN
        CALL Init_Plot(1024, 768)
    ELSE
        CALL Init_Canvas(1024, 768)
    END IF

    CALL Set_Title('CyricAlphaCell: Radiobiology Results - z_D')
    CALL Set_Scale(.FALSE., .FALSE.)

    CALL Draw_Axes(0.0d0, real(num_cells, kind=8)*1.01, YMIN * 0.9, YMAX * 1.1, 'Cell Index', 'z_D (Gy)')

    CALL Set_Color('purple')
    CALL Set_Marker(3)

    CALL Draw_Curve(X_ARR, zD, num_cells, 'S')
    
    IF (SVG_PLOT_CHECK == 1) CALL Export_SVG('zD.svg')
    IF (RENDER_PLOT_CHECK == 1) CALL Render_Plot

    IF (ALLOCATED(LINES)) DEALLOCATE(LINES)
    IF (ALLOCATED(TEXTS)) DEALLOCATE(TEXTS)

END SUBROUTINE RADIO_ZD

!*******************************************************
SUBROUTINE RADIO_LETD
    INTEGER :: I, j
    REAL(8) :: YMIN, YMAX
    REAL(8), DIMENSION(num_cells) :: let_D, X_ARR, sum_let_dose

    DO I = 1, num_cells
        X_ARR(I) = real(I)
        let_D(I) = 0.0
        sum_let_dose(I) = 0.0

        DO j = 1, LET_BINS
            IF (let_hist_nuc(j, I) > 0.0) THEN
                let_D(I) = let_D(I) + ((real(j)-0.5)*dLET_bin) * let_hist_nuc(j, I)
                sum_let_dose(I) = sum_let_dose(I) + let_hist_nuc(j, I)
            END IF
        END DO

        IF (sum_let_dose(I) > 0.0) THEN
           let_D(I) = let_D(I) / sum_let_dose(I)
        ELSE
           let_D(I) = 0.0
        END IF
    END DO
   
    YMIN = MINVAL(let_D)
    YMAX = MAXVAL(let_D)
   
    IF (RENDER_PLOT_CHECK == 1) THEN
        CALL Init_Plot(1024, 768)
    ELSE
        CALL Init_Canvas(1024, 768)
    END IF

    CALL Set_Title('CyricAlphaCell: Radiobiology Results - LET_D')
    CALL Set_Scale(.FALSE., .FALSE.)

    CALL Draw_Axes(0.0d0, real(num_cells, kind=8)*1.01, YMIN * 0.9, YMAX * 1.1, 'Cell Index', 'LET_D (keV/um)')

    CALL Set_Color('teal')
    CALL Set_Marker(2)

    CALL Draw_Curve(X_ARR, let_D, num_cells, 'S')
    
    IF (SVG_PLOT_CHECK == 1) CALL Export_SVG('LET_D.svg')
    IF (RENDER_PLOT_CHECK == 1) CALL Render_Plot

    IF (ALLOCATED(LINES)) DEALLOCATE(LINES)
    IF (ALLOCATED(TEXTS)) DEALLOCATE(TEXTS)

  END SUBROUTINE RADIO_LETD
!*******************************************************
SUBROUTINE RADIO_LAMBDA
    INTEGER :: I
    REAL(8) :: YMIN, YMAX
    REAL(8), DIMENSION(num_cells) :: lambda_arr, X_ARR, zF

    DO I = 1, num_cells
        X_ARR(I) = real(I)
        IF (hit_events_nuc(I) > 0) THEN
            zF(I) = sum_z_nuc(I) / real(hit_events_nuc(I))
            IF (zF(I) > 0.0) THEN
                lambda_arr(I) = bio_target_dose / zF(I)
            ELSE
                lambda_arr(I) = 0.0
            END IF
        ELSE
            lambda_arr(I) = 0.0
        END IF
    END DO
   
    YMIN = MINVAL(lambda_arr)
    YMAX = MAXVAL(lambda_arr)
   
    IF (RENDER_PLOT_CHECK == 1) THEN
        CALL Init_Plot(1024, 768)
    ELSE
        CALL Init_Canvas(1024, 768)
    END IF

    CALL Set_Title('CyricAlphaCell: Radiobiology Results - Mean Hits (at 2Gy)')
    CALL Set_Scale(.FALSE., .FALSE.)

    CALL Draw_Axes(0.0d0, real(num_cells, kind=8)*1.01, YMIN * 0.9, YMAX * 1.1, 'Cell Index', 'Mean Hits (lambda)')

    CALL Set_Color('red')
    CALL Set_Marker(4)

    CALL Draw_Curve(X_ARR, lambda_arr, num_cells, 'S')
    
    IF (SVG_PLOT_CHECK == 1) CALL Export_SVG('mean_hits.svg')
    IF (RENDER_PLOT_CHECK == 1) CALL Render_Plot

    IF (ALLOCATED(LINES)) DEALLOCATE(LINES)
    IF (ALLOCATED(TEXTS)) DEALLOCATE(TEXTS)

END SUBROUTINE RADIO_LAMBDA

!*******************************************************
SUBROUTINE RADIO_P0
    INTEGER :: I
    REAL(8) :: YMIN, YMAX
    REAL(8), DIMENSION(num_cells) :: p0_arr, X_ARR, zF, lambda_val

    DO I = 1, num_cells
        X_ARR(I) = real(I)
        IF (hit_events_nuc(I) > 0) THEN
            zF(I) = sum_z_nuc(I) / real(hit_events_nuc(I))
            IF (zF(I) > 0.0) THEN
                lambda_val(I) = bio_target_dose / zF(I)
                p0_arr(I) = EXP(-lambda_val(I))
            ELSE
                p0_arr(I) = 1.0
            END IF
        ELSE
            p0_arr(I) = 1.0
        END IF
    END DO
   
    YMIN = MINVAL(p0_arr)
    YMAX = MAXVAL(p0_arr)
   
    IF (RENDER_PLOT_CHECK == 1) THEN
        CALL Init_Plot(1024, 768)
    ELSE
        CALL Init_Canvas(1024, 768)
    END IF

    CALL Set_Title('CyricAlphaCell: Radiobiology Results - Prob 0 Hits')
    CALL Set_Scale(.FALSE., .FALSE.)

    CALL Draw_Axes(0.0d0, real(num_cells, kind=8)*1.01, YMIN * 0.9, YMAX * 1.1, 'Cell Index', 'Prob_0_Hits')

    CALL Set_Color('forestgreen')
    CALL Set_Marker(1)
    CALL Draw_Curve(X_ARR, p0_arr, num_cells, 'S')
    
    IF (SVG_PLOT_CHECK == 1) CALL Export_SVG('prob_0_hits.svg')
    IF (RENDER_PLOT_CHECK == 1) CALL Render_Plot

    IF (ALLOCATED(LINES)) DEALLOCATE(LINES)
    IF (ALLOCATED(TEXTS)) DEALLOCATE(TEXTS)

END SUBROUTINE RADIO_P0

!*******************************************************
SUBROUTINE RADIO_SURV
    INTEGER :: I, j
    REAL(8) :: YMIN, YMAX
    REAL(8), DIMENSION(num_cells) :: surv_arr, X_ARR, let_D, sum_let_dose, zD, alpha_alpha

    DO I = 1, num_cells
        X_ARR(I) = real(I)
        let_D(I) = 0.0
        sum_let_dose(I) = 0.0

        DO j = 1, LET_BINS
            IF (let_hist_nuc(j, I) > 0.0) THEN
                let_D(I) = let_D(I) + ((real(j)-0.5)*dLET_bin) * let_hist_nuc(j, I)
                sum_let_dose(I) = sum_let_dose(I) + let_hist_nuc(j, I)
            END IF
        END DO

        IF (sum_let_dose(I) > 0.0) THEN
           let_D(I) = let_D(I) / sum_let_dose(I)
        ELSE
           let_D(I) = 0.0
        END IF

        IF (let_D(I) > 0.0) THEN
            zD(I) = (0.204 * let_D(I)) / (bio_domain_d**2) 
        ELSE
            zD(I) = sum_z2_nuc(I) / MAX(sum_z_nuc(I), 1.0E-6)
        END IF

        alpha_alpha(I) = bio_alpha_x + bio_beta_x * zD(I)
        surv_arr(I) = EXP(-alpha_alpha(I) * bio_target_dose - bio_beta_x * bio_target_dose**2)
    END DO
   
    YMIN = MINVAL(surv_arr)
    YMAX = MAXVAL(surv_arr)
   
    IF (RENDER_PLOT_CHECK == 1) THEN
        CALL Init_Plot(1024, 768)
    ELSE
        CALL Init_Canvas(1024, 768)
    END IF

    CALL Set_Title('CyricAlphaCell: Radiobiology Results - Survival Fraction')
    CALL Set_Scale(.FALSE., .FALSE.)

    CALL Draw_Axes(0.0d0, real(num_cells, kind=8)*1.01, YMIN * 0.9, YMAX * 1.1, 'Cell Index', 'Surv_Frac')

    CALL Set_Color('blue')
    CALL Set_Marker(2)

    CALL Draw_Curve(X_ARR, surv_arr, num_cells, 'S')
    
    IF (SVG_PLOT_CHECK == 1) CALL Export_SVG('surv_frac.svg')
    IF (RENDER_PLOT_CHECK == 1) CALL Render_Plot

    IF (ALLOCATED(LINES)) DEALLOCATE(LINES)
    IF (ALLOCATED(TEXTS)) DEALLOCATE(TEXTS)

END SUBROUTINE RADIO_SURV

!*******************************************************
SUBROUTINE RADIO_RBE
    INTEGER :: I, j
    REAL(8) :: YMIN, YMAX
    REAL(8), DIMENSION(num_cells) :: rbe_arr, X_ARR, let_D, sum_let_dose, zD, alpha_alpha, surv_arr
    REAL(8) :: det, D_xray

    DO I = 1, num_cells
        X_ARR(I) = real(I)
        let_D(I) = 0.0
        sum_let_dose(I) = 0.0

        DO j = 1, LET_BINS
            IF (let_hist_nuc(j, I) > 0.0) THEN
                let_D(I) = let_D(I) + ((real(j)-0.5)*dLET_bin) * let_hist_nuc(j, I)
                sum_let_dose(I) = sum_let_dose(I) + let_hist_nuc(j, I)
            END IF
        END DO

        IF (sum_let_dose(I) > 0.0) THEN
           let_D(I) = let_D(I) / sum_let_dose(I)
        ELSE
           let_D(I) = 0.0
        END IF

        IF (let_D(I) > 0.0) THEN
            zD(I) = (0.204 * let_D(I)) / (bio_domain_d**2) 
        ELSE
            zD(I) = sum_z2_nuc(I) / MAX(sum_z_nuc(I), 1.0E-6)
        END IF

        alpha_alpha(I) = bio_alpha_x + bio_beta_x * zD(I)
        surv_arr(I) = EXP(-alpha_alpha(I) * bio_target_dose - bio_beta_x * bio_target_dose**2) 

        det = bio_alpha_x**2 - 4.0 * bio_beta_x * LOG(MAX(surv_arr(I), 1.0E-20))
        IF (det >= 0.0) THEN
            D_xray = (-bio_alpha_x + SQRT(det)) / (2.0 * bio_beta_x)
            rbe_arr(I) = D_xray / bio_target_dose
        ELSE
            rbe_arr(I) = 1.0
        END IF
    END DO
   
    YMIN = MINVAL(rbe_arr)
    YMAX = MAXVAL(rbe_arr)
   
    IF (RENDER_PLOT_CHECK == 1) THEN
        CALL Init_Plot(1024, 768)
    ELSE
        CALL Init_Canvas(1024, 768)
    END IF

    CALL Set_Title('CyricAlphaCell: Radiobiology Results - RBE')
    CALL Set_Scale(.FALSE., .FALSE.)

    CALL Draw_Axes(0.0d0, real(num_cells, kind=8)*1.01, YMIN * 0.9, YMAX * 1.1, 'Cell Index', 'RBE')

    CALL Set_Color('purple')
    CALL Set_Marker(3)

    CALL Draw_Curve(X_ARR, rbe_arr, num_cells, 'S')
    
    IF (SVG_PLOT_CHECK == 1) CALL Export_SVG('rbe.svg')
    IF (RENDER_PLOT_CHECK == 1) CALL Render_Plot

    IF (ALLOCATED(LINES)) DEALLOCATE(LINES)
    IF (ALLOCATED(TEXTS)) DEALLOCATE(TEXTS)

END SUBROUTINE RADIO_RBE

!*******************************************************
SUBROUTINE PLOT_MICRODOSIMETRY_Z_SPECTRA
    INTEGER :: j, i
    REAL(8), ALLOCATABLE :: x_z(:), y_z(:,:)
    REAL(8) :: xmin, xmax, ymin, ymax
    CHARACTER(LEN=20), DIMENSION(6) :: color_list = &
    (/ CHARACTER(LEN=20) :: 'blue', 'red', 'forestgreen', 'darkorange', 'purple', 'teal' /)
    CHARACTER(LEN=1), DIMENSION(3) :: style_list = (/ 'L', 'S', 'B' /)
    INTEGER :: color_idx, style_idx, marker_type

    IF (Z_BINS <= 0 .OR. num_cells <= 0) RETURN

    ALLOCATE(x_z(Z_BINS))
    ALLOCATE(y_z(Z_BINS, num_cells))

    DO j = 1, Z_BINS
        x_z(j) = (real(j, 8) - 0.5d0) * dZ_bin
    END DO

    DO i = 1, num_cells
        DO j = 1, Z_BINS
            !using micro domain array
            IF (mkm_hit_events(i) > 0.0d0) THEN
                y_z(j, i) = mkm_z_hist(j, i) / mkm_hit_events(i)
            ELSE
                y_z(j, i) = 0.0d0
            END IF
        END DO
    END DO

    !min/max
    xmin = minval(x_z) 
    xmax = maxval(x_z)  
    
    ymax = MAXVAL(y_z)
    ymin = HUGE(1.0d0)
    
    DO i = 1, num_cells
        DO j = 1, Z_BINS
            IF (y_z(j, i) > 0.0d0 .AND. y_z(j, i) < ymin) ymin = y_z(j, i)
        END DO
    END DO
    IF (ymin == HUGE(1.0d0)) ymin = ymax * 1.0d-4

    IF (RENDER_PLOT_CHECK == 1) THEN
        CALL Init_Plot(1024, 768)
    ELSE
        CALL Init_Canvas(1024, 768)
    END IF

    CALL Set_Title('CyricAlphaCell: Specific Energy Distribution f1(z)')
    !log-log here
    CALL Set_Scale(.TRUE., .TRUE.)

    CALL Draw_Axes(xmin, xmax, ymin * 0.9d0, ymax * 1.1d0, 'z (Gy)', 'f1(z)')

    DO i = 1, num_cells
        color_idx = MOD(i - 1, SIZE(color_list)) + 1
        CALL Set_Color(color_list(color_idx))

        style_idx = MOD(i - 1, SIZE(style_list)) + 1
        
        marker_type = MOD(i - 1, 4) + 1
        CALL Set_Marker(marker_type)

        CALL Draw_Curve(x_z, y_z(:, i), Z_BINS, style_list(style_idx))
    END DO
 
    IF (SVG_PLOT_CHECK == 1) CALL Export_SVG('microdosimetry_z_spectra_all.svg')
    IF (RENDER_PLOT_CHECK == 1) CALL Render_Plot

    DEALLOCATE(x_z, y_z)
    IF (ALLOCATED(LINES)) DEALLOCATE(LINES)
    IF (ALLOCATED(TEXTS)) DEALLOCATE(TEXTS)
     
END SUBROUTINE PLOT_MICRODOSIMETRY_Z_SPECTRA

END MODULE CACPLOTTER


