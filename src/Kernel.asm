; Main kernel for the game

  ; Start of vertical blank processing
  lda #0
  sta VBLANK
  VERTICAL_SYNC

  ; Configure various global drawing settings
  lda backgroundColor       ; Background/foreground color
  sta COLUBK
  lda wallColor
  sta COLUPF

  ; Set player horizontal position (Player uses the ball)
  lda playerX
  ldx #POSITION_BL
  jsr PosObject      ; 1 Scanline

  ; Set missile 0 horizontal position along left wall
  ;  to use for the left door color
  lda #LEFT_DOOR_X
  ldx #POSITION_M0
  jsr PosObject       ; 1 Scanline

  ; Set missile 1 horizontal position along right wall
  ;  to use for the right door color
  lda #RIGHT_DOOR_X
  ldx #POSITION_M1
  jsr PosObject       ; 1 Scanline

  ; Configure screen to reflect
  lda #PF_REFLECT
  sta CTRLPF

  lda #0
  sta COLUPF
  sta COLUBK

  ; 36 scanlines of vertical blank...
  REPEAT 36
    sta WSYNC
  REPEND

  ; 192 scanlines of picture...
  ldx #0
  lda $2A
  sta COLUPF
  REPEAT 8
    inx               ; 2
    stx COLUBK        ; 3
    lda #%11110000    ; 2
    sta PF0           ; 3
    lda #%00000000    ; 2
    sta PF1           ; 3
    lda #%00000000    ; 2
    sta PF2           ; 3
    SLEEP 30
    lda #%11111111
    sta PF1
    sta WSYNC
  REPEND

  REPEAT 192 - 8
    inx               ; 2
    stx COLUBK        ; 3
    sta WSYNC
  REPEND

  lda #%01000010
  sta VBLANK        ; end of screen - enter blanking

  ; 30 scanlines of overscan...
  REPEAT 30
    sta WSYNC
  REPEND
