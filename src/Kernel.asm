; Main kernel for the game
  PROCESSOR 6502

  ; Start of vertical blank processing
  lda #0
  sta VBLANK
  VERTICAL_SYNC

  ; Configure various global drawing settings
  lda #0                          ; (2)
  sta GRP0                        ; (3) Clear any misc. graphics registers
  sta GRP1                        ; (3)
  sta ENAM0                       ; (3)
  sta ENAM1                       ; (3)
  sta ENABL                       ; (3)
  sta REFP0                       ; (3) No reflection for any objects
  sta REFP1                       ; (3)
  lda backgroundColor             ; (3) Configure foreground & background
  sta COLUBK                      ; (3)
  lda wallColor                   ; (3)
  sta COLUPF                      ; (3)
  lda #BALL_4X|PF_REFLECT         ; (2) 4 pixels ball, reflect player
  sta CTRLPF                      ; (3)
  lda #MISSILE_8X|PLAYER_DOUBLE   ; (2) 8 pixels missile, double size player
  sta NUSIZ0                      ; (3)
  sta NUSIZ1                      ; (3)
                                  ; Total: 48 Cycles

  ; Set player horizontal position (Player uses the ball)
  lda playerX                     ; (3)
  ldx #POSITION_BL                ; (2)
  jsr PosObject                   ; (1 Scanline)

  ; Set the item horizontal positions (Items use P0 and P1)
  lda item1X                      ; (3)
  ldx #POSITION_P0                ; (2)
  jsr PosObject                   ; (1 Scanline)
  lda item2X                      ; (3)
  ldx #POSITION_P1                ; (2)
  jsr PosObject                   ; (1 Scanline)

  ; Set missile 0 horizontal position along left wall
  ;  to use for the left door color
  lda #LEFT_DOOR_X                ; (2)
  ldx #POSITION_M0                ; (2)
  jsr PosObject                   ; (1 Scanline)

  ; Set missile 1 horizontal position along right wall
  ;  to use for the right door color
  lda #RIGHT_DOOR_X               ; (2)
  ldx #POSITION_M1                ; (2)
  jsr PosObject                   ; (1 Scanline)

  ; 28 leftover scanlines of vertical blank...
  ldy #28
.loop
  dey
  sty WSYNC
  bne .loop

  ; 1 scanline to prepare for drawing
  ldy #0
  ldx wallsFlags
  lda #$FF
  sta PF0
  SEC

  ; --- Start of screen ---
Kernel  SUBROUTINE

  ; 16 scanlines for the top walls
.topWalls
  sec
  sta WSYNC
  PositionPlayerVertically  
  iny
  cpy #16
  bne .topWalls

  ; 16 scanlines of horizontal walls
.wall1
  sec
  sta WSYNC
  PositionPlayerVertically
  iny
  cpy #32
  bne .wall1

  ; 24 scanlines of door
.door1
  sec
  sta WSYNC
  PositionPlayerVertically
  lda #0
  sta PF0
  iny
  cpy #56
  bne .door1

  ;24 scanlines of wall
.wall2
  sec
  sta WSYNC
  PositionPlayerVertically
  lda #$FF
  sta PF0
  iny
  cpy #80
  bne .wall2

  ; 32 scanlines of door
.door2
  sec
  sta WSYNC
  PositionPlayerVertically
  lda #0
  sta PF0
  iny
  cpy #112
  bne .door2

  ; 24 scanlines of wall
.wall3
  sec
  sta WSYNC
  PositionPlayerVertically
  lda #$FF
  sta PF0
  iny
  cpy #136
  bne .wall3

  ; 24 scanlines of door
.door3
  sec
  sta WSYNC
  PositionPlayerVertically
  lda #0
  sta PF0
  iny
  cpy #160
  bne .door3

  ; 16 scanlines of wall
.wall4
  sec
  sta WSYNC
  PositionPlayerVertically
  lda #$FF
  sta PF0
  iny
  cpy #176
  bne .wall4

  ; 16 Scanlines for the bottom
.bottom
  sec
  sta WSYNC
  PositionPlayerVertically
  iny
  cpy #192
  bne .bottom
  sta WSYNC

  lda #%01000010
  sta VBLANK        ; end of screen - enter blanking

  ; 30 scanlines of overscan...
  REPEAT 30
    sta WSYNC
  REPEND
