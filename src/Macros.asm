; Useful method to vertically position the ball player
;
; Input:
;  PlayerY = Expected player scanline
;  Y = The current scanline (0 to 191)
;
; Output: None
; Modified: Acc
; Cycles: 16
;
; Note: Assumes that the carry is already set for proper subtraction
;
  MAC PositionPlayerVertically
    TYA               ; (2)
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