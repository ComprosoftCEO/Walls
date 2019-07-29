; Main kernel for the game
  PROCESSOR 6502

Kernel  SUBROUTINE

  ; Start of vertical blank processing
  lda #2              ; (2) LoaD Accumulator with 2 so D1=1
  sta WSYNC           ; (3) Wait for SYNC (halts CPU until end of scanline)
  sta VSYNC           ; (3) Accumulator D1=1, turns on Vertical Sync signal
  sta WSYNC           ; (3) Wait for Sync - halts CPU until end of 1st scanline of VSYNC
  sta WSYNC           ; (3) wait until end of 2nd scanline of VSYNC
  lda #0              ; (2) LoaD Accumulator with 0 so D1=0
  sta WSYNC           ; (3) wait until end of 3rd scanline of VSYNC
  sta VSYNC           ; (3) Accumulator D1=0, turns off Vertical Sync signal

  ; Set player horizontal position (Player uses the ball)
  ;  2 total scanlines
  lda playerX         ; (3)
  ldx #POSITION_BL    ; (2)
  jsr PosObject       ; (1 Scanline)

  ; Set the item horizontal positions (Items use P0 and P1)
  ;  4 total scanlines
  lda item1X          ; (3)
  ldx #POSITION_P0    ; (2)
  jsr PosObject       ; (1 Scanline)
  lda item2X          ; (3)
  ldx #POSITION_P1    ; (2)
  jsr PosObject       ; (1 Scanline)

  ; Set missile 0 horizontal position along left wall for left door color
  ; Set missile 1 horizontal position along right wall for right door color
  ;  4 total scanlines
  lda #LEFT_DOOR_X                ; (2)
  ldx #POSITION_M0                ; (2)
  jsr PosObject                   ; (1 Scanline)
  lda #RIGHT_DOOR_X               ; (2)
  ldx #POSITION_M1                ; (2)
  jsr PosObject                   ; (1 Scanline)

  ; 29 leftover scanlines of vertical blank...
  ; Do other misc calculations to load the data
  lda #(28 * 72) / 64
  sta TIM64T

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

  ; Other calculations
  jsr CalculateVertWalls

.waitVBlank
  sta WSYNC
  lda INTIM
  bne .waitVBlank
  sta WSYNC

  ; 1 scanline to prepare for drawing
  ldy #192
  ldx wallsFlags
  lda #$FF
  sta PF0
  lda #$0
  SEC
  sta WSYNC
  sta VBLANK         ; Accumulator D1=0, turns off Vertical Blank signal (image output on)

  ; --- Start of screen ---

  ; 8 scanlines for the top doors and walls
  ; The timing of these 8 lines are VERY IMPORTANT to have a stable image
  ldx topWallBuffer+3         ; (3)
.topDoors
  sta WSYNC                   ; (3)
  PositionPlayerVertically    ; (16)
  lda topWallBuffer           ; (3)
  sta PF1                     ; (3)
  lda topDoorColors           ; (3)
  sta COLUBK                  ; (3)
  lda.w topWallBuffer+1       ; (3)
  sta PF2                     ; (3)
  lda topDoorColors+1         ; (3)
  sta COLUBK                  ; (3)
  lda topWallBuffer+2         ; (3)
  sta PF2                     ; (3)
  lda topDoorColors+2         ; (4)
  sta COLUBK                  ; (3)
  stx PF1                     ; (3)
  lda backgroundColor         ; (3)
  dey                         ; (3)
  ldx topWallBuffer+3         ; (3)
  sta COLUBK                  ; (3)
  cpy #192-8                  ; (2)
  bne .topDoors               ; (2)

  ; 8 scanlines for the top walls (where doors aren't shown)
.topWalls
  sta WSYNC                   ; (3)
  PositionPlayerVertically    ; (16)
  lda topWallBuffer           ; (3)
  sta PF1                     ; (3) 22
  lda topWallBuffer+1         ; (3)
  sta PF2                     ; (3) 28
  SLEEP 12                    ; (12)
  lda topWallBuffer+2         ; (3)
  sta PF2                     ; (3) 26
  lda topWallBuffer+3         ; (3)
  sta PF1                     ; (3)
  dey                         ; (3)
  cpy #192-16                 ; (2)
  bne .topWalls               ; (2)

  ; 16 scanlines of horizontal walls
.wall1
  sta WSYNC
  PositionPlayerVertically
  lda #$00
  sta PF1
  STA PF2
  dey
  cpy #192-32
  bne .wall1

  ; 24 scanlines of door
.door1
  sta WSYNC
  PositionPlayerVertically
  lda #0
  sta PF0
  dey
  cpy #192-56
  bne .door1

  ;24 scanlines of wall
.wall2
  sta WSYNC
  PositionPlayerVertically
  lda #$FF
  sta PF0
  dey
  cpy #192-80
  bne .wall2

  ; 32 scanlines of door
.door2
  sta WSYNC
  PositionPlayerVertically
  lda #0
  sta PF0
  dey
  cpy #192-112
  bne .door2

  ; 24 scanlines of wall
.wall3
  sta WSYNC
  PositionPlayerVertically
  lda #$FF
  sta PF0
  dey
  cpy #192-136
  bne .wall3

  ; 24 scanlines of door
.door3
  sta WSYNC
  PositionPlayerVertically
  lda #0
  sta PF0
  dey
  cpy #192-160
  bne .door3

  ; 16 scanlines of wall
.wall4
  sta WSYNC
  PositionPlayerVertically
  lda #$FF
  sta PF0
  dey
  cpy #192-176
  bne .wall4

  ; 16 Scanlines for the bottom
.bottom
  sta WSYNC
  PositionPlayerVertically
  dey
  bne .bottom
  sta WSYNC

  lda #%01000010
  sta VBLANK        ; end of screen - enter blanking

  ; 30 scanlines of overscan...
  REPEAT 30
    sta WSYNC
  REPEND
