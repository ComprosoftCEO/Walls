  SEG.U Variables
  ORG $0080

;All variables for the program
playerX             ds 1    ; Room has 1 player (represented by ball)
playerY             ds 1

item1X              ds 1    ; Room has 2 items
item1Y              ds 1
item2X              ds 1
item2Y              ds 1

; Doors
horDoors            ds 1    ; Configuration for horizontal doors
verDoors            ds 1    ; Configuration for vertical doors

; Colors
backgroundColor     ds 1    ; Color of the background
wallColor           ds 1    ; Color of the wall
item1Color          ds 1    ; Color of item 1
item2Color          ds 1    ; Color of item 2
wallsFlags          ds 1    ; hvHHHVVV - Horizontal, vertical, true if use 3 walls
topDoorColors       ds 3    ; Color of the doors along the top
bottomDoorColors    ds 3    ; Color of the doors along the bottom
leftDoorColors      ds 3    ; Color of the doors along the left
rightDoorColors     ds 3    ; Color of the doors along the right

; Kernel Buffers
item1Buffer         ds 8    ; Temporary buffer for item 1 graphics
item2Buffer         ds 8    ; Temporary buffer for item 2 graphics
topWallBuffer       ds 4    ; Temporary buffer for the top wall PF graphics
bottomWallBuffer    ds 4    ; Temporary buffer for the bottom wall PF graphics