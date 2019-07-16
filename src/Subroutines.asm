; Positions an object horizontally
;
; Inputs:
;   A = Desired position.
;   X = Desired object to be positioned (0-4) (P0, P1, M0, M1, BL)
;
; Scanlines: If control comes on or before cycle 73 then 1 scanline is consumed.
; If control comes after cycle 73 then 2 scanlines are consumed.
;
; Outputs:
;   X = unchanged
;   A = Fine Adjustment value.
;   Y = the "remainder" of the division by 15 minus an additional 15.
;
; control is returned on cycle 6 of the next scanline.
PosObject   SUBROUTINE
            sta WSYNC                ; 00     Sync to start of scanline.
            sec                      ; 02     Set the carry flag so no borrow will be applied during the division.
.divideby15 sbc #15                  ; 04     Waste the necessary amount of time dividing X-pos by 15!
            bcs .divideby15          ; 06/07  11/16/21/26/31/36/41/46/51/56/61/66
            tay
            lda fineAdjustTable,y    ; 13 -> Consume 5 cycles by guaranteeing we cross a page boundary
            sta HMP0,x
            sta RESP0,x              ; 21/ 26/31/36/41/46/51/56/61/66/71 - Set the rough position.
            rts

POSITION_P0     = $0
POSITION_P1     = $1
POSITION_M0     = $2
POSITION_M1     = $3
POSITION_BL     = $4