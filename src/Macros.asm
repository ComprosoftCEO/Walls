; Useful method to vertically position the ball player
;
; Input:
;  PlayerY = Expected player scanline
;  Acc = The current scanline (0 to 191)
;
; Output: None
; Modified: Acc
; Cycles: 14
;
; Note: Assumes that the carry is already set for proper subtraction
;
  MAC PositionPlayerVertically
    SBC playerY       ; (3) Assumes that carry is already set
    CMP #8            ; (2) Player is 8 pixels high
    BCC .draw         ; (2)
    LDA #0            ; (2)
    BCS .end          ; (2)
.draw
    LDA #BALL_ENABLE  ; (2)
    SEC               ; (2)
.end
    STA ENABL         ; (3)
  ENDM



; Useful method to vertically position the room items
;
; Input:
;  {1} = Item Y position
;  {2} = Item graphics buffer
;  {3} = Item graphics output
;  Y = The current scanline (0 to 191)
;
; Output: None
; Modified: Acc, X
; Cycles: 22
;
  MAC PositionItemVertically
    TYA               ; (2)
    SEC               ; (2)
    SBC {1}           ; (3)
    CMP #16           ; (2) Item graphics are 16 pixels high
    BCC .draw         ; (2)
    LDA #0            ; (2)
    SLEEP 4           ; (4)
    BCS .end          ; (2)
.draw
    LSR               ; (2) Duplicate each sprite for two scanlines
    TAX               ; (2)
    LDA {2},X         ; (4)
.end
    STA {3}           ; (3)
  ENDM


  MAC PositionItem1Vertically
    PositionItemVertically item1Y, item1Buffer, GRP0
  ENDM


  MAC PositionItem2Vertically
    PositionItemVertically item2Y, item2Buffer, GRP1
  ENDM


; Single method for calculating vertical walls. Used exclusively
;  by CalculateVertWalls subroutine
;
; Inputs:
;  Acc = Horizontal door settings
;  {1} = Output buffer
;
; Outputs:
;  Stores in {1} buffer

  MAC CalculateVertWall
    bmi .twoWalls

  ; Three walls along the top
.firstWall3
    asl
    bmi .firstWall3Closed
.firstWall3Open
    ldx #%11000000  ; PF1 is normal direction
    jmp .secondWall3
.firstWall3Closed
    ldx #%11111111  ; Solid wall
.secondWall3
    stx {1}         ; Store PF1 on left
    asl
    bmi .secondWall3Closed
.secondWall3Open
    ldx #%00011111  ; PF2 is reversed direction
    jmp .thirdWall3
.secondWall3Closed
    ldx #%11111111  ; Solid wall
.thirdWall3
    stx {1}+1       ; Store PF2 mirrored 
    stx {1}+2
    asl
    bmi .thirdWall3Closed
.thirdWall3Open
    ldx #%11000000  ; PF1 is normal direction
    stx {1}+3       ; Store PF1 on right side
    jmp .end
.thirdWall3Closed
    ldx #%11111111  ; Solid wall
    stx {1}+3       ; Store PF1 on right side
    jmp .end

  ;Two walls along the top
.twoWalls
  asl
  bmi .firstWall2Closed
.firstWall2Open
  ldx #%11110000  ; PF1 is normal direction
  ldy #%11111100  ; PF2 is reversed
  jmp .secondWall2
.firstWall2Closed
  ldx #%11111111  ; Solid wall
  ldy #%11111111  ; Solid wall
.secondWall2
  stx {1}         ; Store PF1 on left
  sty {1}+1       ; Store PF2 on left
  asl             ; Ignore the middle bit for two walls
  asl
  bmi .secondWall2Closed
.secondWall2Open
  ldx #%11110000  ; PF1 is normal direction
  ldy #%11111100  ; PF2 is reversed
  jmp .finishSecondWall
.secondWall2Closed
  ldx #%11111111  ; Solid wall
  ldy #%11111111  ; Solid wall
.finishSecondWall
  stx {1}+2       ; Store PF2 on right
  sty {1}+3       ; Store PF1 on right
.end
  asl
  ENDM