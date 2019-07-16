; Main kernel for the game

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
  lda #BALL_8X|PF_REFLECT         ; (2) 8 pixels ball, reflect player
  sta CTRLPF                      ; (3)
  lda #MISSILE_8X|PLAYER_DOUBLE   ; (2) 8 pixels missile, double size player
  sta NUSIZ0                      ; (3)
  sta NUSIZ1                      ; (3)
                                  ; Total: 48 Cycles

  ; Set player horizontal position (Player uses the ball)
  lda playerX                     ; (3)
  ldx #POSITION_BL                ; (2)
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

  ; 31 leftover scanlines of vertical blank...
  REPEAT 31
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
