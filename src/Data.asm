;-----------------------------
; This table converts the "remainder" of the division by 15 (-1 to -15) to the correct
; fine adjustment value. This table is on a page boundary to guarantee the processor
; will cross a page boundary and waste a cycle in order to be at the precise position
; for a RESP0,x write
fineAdjustBegin
  DC.B %01110000; Left 7
  DC.B %01100000; Left 6
  DC.B %01010000; Left 5
  DC.B %01000000; Left 4
  DC.B %00110000; Left 3
  DC.B %00100000; Left 2
  DC.B %00010000; Left 1
  DC.B %00000000; No movement.
  DC.B %11110000; Right 1
  DC.B %11100000; Right 2
  DC.B %11010000; Right 3
  DC.B %11000000; Right 4
  DC.B %10110000; Right 5
  DC.B %10100000; Right 6
  DC.B %10010000; Right 7

; NOTE: %11110001 = -15
fineAdjustTable EQU fineAdjustBegin - %11110001



;------------------------
; Various item graphics
;------------------------

; No item
grNull = 0

; Key in the dungeon
grKey
  DC.B %00000000
  DC.B %00000000
  DC.B %00000000
  DC.B %00000000
  DC.B %00000000
  DC.B %00000000
  DC.B %00000000
  DC.B %00000000

; Up staircase
grStairUp
  DC.B %00000000
  DC.B %00000000
  DC.B %00000000
  DC.B %00000000
  DC.B %00000000
  DC.B %00000000
  DC.B %00000000
  DC.B %00000000

; Down staircase
grStairDown
  DC.B %11100000
  DC.B %00100000
  DC.B %00111000
  DC.B %00001000
  DC.B %01001110
  DC.B %01000010
  DC.B %11100011
  DC.B %01000000
