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
  lda #PLAYER_VERT_DELAY          ; (3) Vertical delay both players
  sta VDELP0                      ; (3)
  sta VDELP1                      ; (3)
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
  sta VBLANK                  ; 3  [ 3] Accumulator D1=0, turns off Vertical Blank signal (image output on)

  ; --- Start of screen ---

  ; 8 scanlines for the top doors and walls
  ;  The timing of these 8 lines are VERY IMPORTANT to have a stable image
  ldx topWallBuffer+3         ; 3  [ 6] Fourth playfield graphic (Use X to get timing right)
.topDoors
  tya                         ; 2  [ 8]
  sta WSYNC                   ; 3  [11]
  PositionPlayerVertically    ; 16 [16]
  lda topWallBuffer           ; 3  [19] First playfield graphic
  sta PF1                     ; 3  [22]
  dey                         ; 2  [24] Decrement Y to get timing right
  lda topDoorColors           ; 3  [27] Door 1 color
  sta COLUBK                  ; 3  [30]
  lda topWallBuffer+1         ; 3  [33] Second playfield graphic
  sta PF2                     ; 3  [36]
  lda topDoorColors+1         ; 3  [39] Door 2 color
  sta COLUBK                  ; 3  [42]
  lda topWallBuffer+2         ; 3  [45] Third playfield graphic
  sta PF2                     ; 3  [48]
  lda topDoorColors+2         ; 3  [51] Door 3 color
  sta COLUBK                  ; 3  [54]
  stx PF1                     ; 3  [57]
  ldx topWallBuffer+3         ; 3  [60] Fourth playfield graphic (Use X to get timing right)
  cpy #192-8                  ; 2  [62]
  bne .topDoors               ; 2/3[64]
  lda backgroundColor         ; 3  [67] Background color for next scanline
  sta COLUBK                  ; 3  [70]

  ; 8 scanlines for the top walls (where doors aren't shown)
.topWalls
  tya                         ; 2  [72]
  sta WSYNC                   ; 3  [75]
  PositionPlayerVertically    ; 16 [16]
  lda topWallBuffer           ; 3  [19] First playfield graphic
  sta PF1                     ; 3  [22]
  lda topWallBuffer+1         ; 3  [25] Second playfield graphic
  sta PF2                     ; 3  [28]
  lda leftItem1Color          ; 3  [31] Delay by setting up the item colors
  sta COLUP0                  ; 3  [34] Left item color
  lda rightItem1Color         ; 3  [37] Right item color
  sta COLUP1                  ; 3  [40]
  lda topWallBuffer+2         ; 3  [43] Third playfield graphics
  sta PF2                     ; 3  [46]
  lda topWallBuffer+3         ; 3  [49] Fourth playfield graphic
  sta PF1                     ; 3  [52]
  dey                         ; 3  [55]
  cpy #192-16                 ; 2  [59]
  bne .topWalls               ; 2/3[61]
  SLEEP 6                     ; 6 [65] Delay to get liquid timing right
  lda topLiquid               ; 3 [68] Get the liquid for the top half
  sta COLUBK                  ; 3 [71]

  ; 8 scanlines of horizontal walls with no item
.wall1
  sta WSYNC                   ; 3 [74]
  tya                         ; 2 [ 2]
  PositionPlayerVertically    ; 14[16]
  lda #$00                    ; 2 [18] Always clear middle area between walls
  sta PF1                     ; 3 [21]
  lda wall1Buffer             ; 3 [24] Left of middle walls
  sta PF2                     ; 3 [27]
  lda wall1Buffer+1           ; 3 [30] Right of middle walls
  ldx #1                      ; 2 [32] Load X to waste a cycle. X is used for default item offset of 1
  SLEEP 2                     ; 2 [34]
  dey                         ; 2 [36]
  cpy #192-24                 ; 2 [38]
  sta PF2                     ; 3 [41]
  bne .wall1                  ; 2 [43]

  ; Prepare the first item for the next round
  stx itemSpriteOffset        ; 3 [46] Set the item offset to 1
  ldy #0                      ; 2 [48] Compute graphics index
  lda (leftItem1Sprite),y     ; 6 [54] Load and store the left sprite
  sta GRP0                    ; 3 [57]
  lda (rightItem1Sprite),y    ; 6 [63] Load and store the right sprite
  sta GRP1                    ; 3 [66]
  ldy #192-24                 ; 2 [68] We know what the Y will be
  sec                         ; 2 [70] Carry must be set to position player

  ; 8 scanlines of a horizontal wall with an item
  ;  Updates the item index every 4 scanlines
.wall1Item
  sta WSYNC                   ; 3 [73]
  tya                         ; 2 [ 2]
  PositionPlayerVertically    ; 14[16]
  lda wall1Buffer             ; 3 [19] Left of middle walls
  sta PF2                     ; 3 [22]
  sty tempYBuffer             ; 3 [25] Load sprites every scanline to waste some cycles
  ldy itemSpriteOffset        ; 3 [28]
  lda (leftItem1Sprite),y     ; 6 [34] Load and store the left sprite
  sta GRP0                    ; 3 [37]
  lda (rightItem1Sprite),y    ; 6 [43] Load and store the right sprite
  ldy wall1Buffer+1           ; 3 [46] Right of middle walls
  sty PF2                     ; 3 [49]
  sta GRP1                    ; 3 [52]
  ldy tempYBuffer             ; 3 [55]
  dey                         ; 2 [57]
  cpy #192-28                 ; 2 [59]
  bne .wall1Item_NoInc        ; 2 [61]
  inc itemSpriteOffset        ; 5 [66]
.wall1Item_NoInc
  cpy #192-32                 ; 2 [63|68]
  bne .wall1Item              ; 2 [65|70]
  inc itemSpriteOffset        ; 5 [70] Add 1 to the offset

  ; 32 scanlines for the first door
  ;  Door is rendered in 3 chunks, 8-16-8
  ;  Updates the item on every other scanline

  ; 8 scanlines for first chunk of door
  lda door1Buffer             ; 3 [63] Load registers to quickly update frame data
  ldx leftDoorColors          ; 3 [66]
.door1Chunk1
  sta WSYNC                   ; 3 [72]
  sta PF0                     ; 3 [ 3] Left door visible or not
  stx COLUP0                  ; 3 [ 6] Left door color
  ; Update right item
  tya                         ; 2 [ 2]
  PositionPlayerVertically    ; 14[16]
  dey
  cpy #192-56
  bne .door1Chunk1

  ;24 scanlines of wall
.wall2
  sta WSYNC
  tya                         ; 2 [ 2]
  PositionPlayerVertically    ; 14[16]
  lda #$FF
  sta PF0
  dey
  cpy #192-80
  bne .wall2

  ; 32 scanlines of door
.door2
  sta WSYNC
  tya                         ; 2 [ 2]
  PositionPlayerVertically    ; 14[16]
  lda #0
  sta PF0
  dey
  cpy #192-112
  bne .door2

  ; 24 scanlines of wall
.wall3
  sta WSYNC
  tya                         ; 2 [ 2]
  PositionPlayerVertically    ; 14[16]
  lda #$FF
  sta PF0
  dey
  cpy #192-136
  bne .wall3

  ; 24 scanlines of door
.door3
  sta WSYNC
  tya                         ; 2 [ 2]
  PositionPlayerVertically    ; 14[16]
  lda #0
  sta PF0
  dey
  cpy #192-160
  bne .door3

  ; 16 scanlines of wall
.wall4
  sta WSYNC
  tya                         ; 2 [ 2]
  PositionPlayerVertically    ; 14[16]

  ; Just for now to avoid page overflow with branch
  SLEEP 40
  lda #$FF
  sta PF0
  dey
  cpy #192-176
  bne .wall4

  ; 8 Scanlines for the bottom walls
.bottomWalls
  tya                         ; 2  [ 2]
  sta WSYNC                   ; 3  [ 5]
  PositionPlayerVertically    ; 16 [16]
  lda bottomWallBuffer        ; 3  [19] First playfield graphic
  sta PF1                     ; 3  [22]
  lda bottomWallBuffer+1      ; 3  [25] Second playfield graphic
  sta PF2                     ; 3  [28]
  SLEEP 12                    ; 12 [40] Delay for a bit
  lda bottomWallBuffer+2      ; 3  [43] Third playfield graphic
  sta PF2                     ; 3  [46]
  lda bottomWallBuffer+3      ; 3  [49] Fourth playfield graphic
  sta PF1                     ; 3  [52]
  dey                         ; 2  [54]
  cpy #192-184                ; 2  [56]
  bne .bottomWalls            ; 2/3[58]

  ; 8 scanlines for the bottom doors and walls
  ;  The timing of these 8 lines are VERY IMPORTANT to have a stable image
  ldx bottomWallBuffer+3      ; 3  [61] Fourth playfield graphic (Use X to get timing right)
  tya                         ; 2  [63]
.bottomDoors
  tya                         ; 2  [65]
  sta WSYNC                   ; 3  [68]
  PositionPlayerVertically    ; 16 [16]
  lda bottomWallBuffer        ; 3  [19] First playfield graphic
  sta PF1                     ; 3  [22] Decrement Y to get timing right
  dey                         ; 2  [24]
  lda bottomDoorColors        ; 3  [27] Door 1 color
  sta COLUBK                  ; 3  [30]
  lda bottomWallBuffer+1      ; 3  [33] Second playfield graphic
  sta PF2                     ; 3  [36]
  lda bottomDoorColors+1      ; 3  [39] Door 2 color
  sta COLUBK                  ; 3  [42]
  lda bottomWallBuffer+2      ; 3  [45] Third playfield graphic
  sta PF2                     ; 3  [48]
  lda bottomDoorColors+2      ; 3  [51] Door 3 color
  sta COLUBK                  ; 3  [54]
  stx PF1                     ; 3  [57]
  ldx bottomWallBuffer+3      ; 3  [60] Fourth playfield graphic (Use X to get timing right)
  cpy #192-192                ; 2  [62]
  bne .bottomDoors            ; 2/3[64]

  ; End of screen - enter blanking
  sta WSYNC
  lda #%01000010
  sta VBLANK        

  ; 30 scanlines of overscan...
  REPEAT 30
    sta WSYNC
  REPEND
