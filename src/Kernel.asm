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
  lda leftItemX       ; (3)
  ldx #POSITION_P0    ; (2)
  jsr PosObject       ; (1 Scanline)
  lda rightItemX      ; (3)
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
  lda #(28 * 76 - 3) / 64
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
  sta VDELP1                      ; (3) No delay for player 1 and ball
  sta VDELBL                      ; (3)
  lda #PLAYER_VERT_DELAY          ; (3) Vertical delay player 0
  sta VDELP0                      ; (3)
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
  lda #$FF
  sta PF0
  lda #$0
  SEC
  sta WSYNC
  sta VBLANK         ; Accumulator D1=0, turns off Vertical Blank signal (image output on)

  ; --- Start of screen ---

  ; 8 scanlines for the top doors and walls
  ; The timing of these 8 lines are VERY IMPORTANT to have a stable image
  ldx topWallBuffer+3         ; (3) Fourth playfield graphic (Use X to get timing right)
.topDoors
  sta WSYNC                   ; (3)
  PositionPlayerVertically    ; (16)
  lda topWallBuffer           ; (3) First playfield graphic
  sta PF1                     ; (3)
  lda topDoorColors           ; (3) Door 1 color
  sta COLUBK                  ; (3)
  lda.w topWallBuffer+1       ; (3) Second playfield graphic
  sta PF2                     ; (3)
  lda topDoorColors+1         ; (3) Door 2 color
  sta COLUBK                  ; (3)
  lda topWallBuffer+2         ; (3) Third playfield graphic
  sta PF2                     ; (3)
  lda topDoorColors+2         ; (4) Door 3 color
  sta COLUBK                  ; (3)
  stx PF1                     ; (3)
  lda backgroundColor         ; (3)
  dey                         ; (3)
  ldx topWallBuffer+3         ; (3) Fourth playfield graphic (Use X to get timing right)
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
  SLEEP 12                    ; (12)40
  lda topWallBuffer+2         ; (3)
  sta PF2                     ; (3) 46
  lda topWallBuffer+3         ; (3)
  sta PF1                     ; (3) 52
  dey                         ; (3)
  cpy #192-16                 ; (2)
  bne .topWalls               ; (2) 59
  SLEEP 6                     ; (10)
  lda topLiquid               ; (3) 68
  sta COLUBK                  ; (3) 71

  ; 8 scanlines of horizontal walls with no item
.wall1
  sta WSYNC                   ; 3 [74]
  PositionPlayerVertically    ; 16[16]
  lda #$FF                    ; 3 [19] Always set left and right wall
  sta PF0                     ; 3 [22]
  lda #$00                    ; 3 [25] Always clear middle area between walls
  sta PF1                     ; 3 [28]
  lda wall1Buffer             ; 3 [31] Left of middle walls
  sta PF2                     ; 3 [34]
  lda wall1Buffer+1           ; 3 [37] Right of middle walls
  dey                         ; 2 [39]
  sty tempYBuffer             ; 3 [42] Loading sprite requires Y to be stored in temp location
  cpy #192-24                 ; 2 [44]
  sta PF2                     ; 3 [47]
  bne .wall1                  ; 2 [49]

  ; Prepare the first item for the next round
  tya                         ; 2 [51] Compute graphics index
  lsr                         ; 2 [53] Shift right to have 4 scanline pixels
  lsr                         ; 2 [55]
  and #$0f                    ; 2 [57] Mask extra bits
  tay                         ; 2 [59]
  lda (leftItem1Sprite),y     ; 6 [65] Load and store the sprite
  sta GRP0                    ; 3 [68]
  ldy tempYBuffer             ; 3 [71] Get back Y from temporary location
  sec                         ; 2 [73] Carry must be set to position player

.wall1Item
  sta WSYNC                   ; 3 [76]
  PositionPlayerVertically    ; 16[16]
  lda wall1Buffer             ; 3 [19] Left of middle walls
  sta PF2                     ; 3 [22]
  sty tempYBuffer             ; 3 [25] Loading sprite requires Y to be stored in temp location
  tya                         ; 2 [27] Compute graphics index
  lsr                         ; 2 [29] Shift right to have 4 scanline pixels
  lsr                         ; 2 [31]
  and #$0f                    ; 2 [33] Mask extra bits
  tay                         ; 2 [35]
  lda (leftItem1Sprite),y     ; 6 [41] Load and store the sprite
  sta GRP0                    ; 3 [44]
  lda wall1Buffer+1           ; 3 [47] Right of middle walls
  sta PF2                     ; 3 [50]
  ldy tempYBuffer             ; 3 [53] Get back Y from temporary location
  dey                         ; 2 [55]
  cpy #192-32                 ; 2 [57]
  bne .wall1Item              ; 2 [59]

  ; 24 scanlines of door
.door1
  sta WSYNC                   ; 3 [62]
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

  ; Just for now to avoid page overflow with branch
  SLEEP 40
  lda #$FF
  sta PF0
  dey
  cpy #192-176
  bne .wall4

  ; 8 Scanlines for the bottom walls
.bottomWalls
  sta WSYNC                   ; (3)
  PositionPlayerVertically    ; (16)
  lda bottomWallBuffer        ; (3)
  sta PF1                     ; (3) 22
  lda bottomWallBuffer+1      ; (3)
  sta PF2                     ; (3) 28
  SLEEP 12                    ; (12)
  lda bottomWallBuffer+2      ; (3)
  sta PF2                     ; (3) 26
  lda bottomWallBuffer+3      ; (3)
  sta PF1                     ; (3)
  dey                         ; (3)
  cpy #192-184                ; (2)
  bne .bottomWalls            ; (2)

  ; 8 scanlines for the bottom doors and walls
  ; The timing of these 8 lines are VERY IMPORTANT to have a stable image
  ldx bottomWallBuffer+3      ; (3) Fourth playfield graphic (Use X to get timing right)
.bottomDoors
  sta WSYNC                   ; (3)
  PositionPlayerVertically    ; (16)
  lda bottomWallBuffer        ; (3) First playfield graphic
  sta PF1                     ; (3)
  lda bottomDoorColors        ; (3) Door 1 color
  sta COLUBK                  ; (3)
  lda.w bottomWallBuffer+1    ; (3) Second playfield graphic
  sta PF2                     ; (3)
  lda bottomDoorColors+1      ; (3) Door 2 color
  sta COLUBK                  ; (3)
  lda bottomWallBuffer+2      ; (3) Third playfield graphic
  sta PF2                     ; (3)
  lda bottomDoorColors+2      ; (4) Door 3 color
  sta COLUBK                  ; (3)
  stx PF1                     ; (3)
  lda backgroundColor         ; (3)
  dey                         ; (3)
  ldx bottomWallBuffer+3      ; (3) Fourth playfield graphic (Use X to get timing right)
  sta COLUBK                  ; (3)
  cpy #0                      ; (2)
  bne .bottomDoors            ; (2)

  ; End of screen - enter blanking
  sta WSYNC
  lda #%01000010
  sta VBLANK        

  ; 30 scanlines of overscan...
  REPEAT 30
    sta WSYNC
  REPEND
