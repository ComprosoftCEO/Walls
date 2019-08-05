  SEG.U Variables
  ORG $0080

; Player position
playerX             ds 1    ; Horizontal position of the player
playerY             ds 1    ; Reverse scanline of the player (192 = top, 0 = bottom)

; Dungeon colors
backgroundColor     ds 1    ; Color of the background
wallColor           ds 1    ; Color of the wall

; Liquids
topLiquid           ds 1    ; Color of the top third liquid
middleTopLiquid     ds 1    ; Color of the first half of the middle liquid
middleBottomLiquid  ds 1    ; Color of the second half of the middle liquid
bottomLiquid        ds 1    ; Color of the bottom third liquid

; Doors
horDoors            ds 1    ; Configuration for horizontal doors
verDoors            ds 1    ; Configuration for vertical doors
topDoorColors       ds 3    ; Color of the doors along the top
bottomDoorColors    ds 3    ; Color of the doors along the bottom
leftDoorColors      ds 3    ; Color of the doors along the left
rightDoorColors     ds 3    ; Color of the doors along the right

; Item sprites and colors
leftItemX           ds 1    ; Left items share the same horizontal position
rightItemX          ds 1    ; Right items share the same horizontal position

leftItem1Sprite     ds 2    ; Pointer to the top left item sprite (8 byte image)
leftItem1Color      ds 1    ; Color of the top left item
leftItem2Sprite     ds 2    ; Pointer to the middle left item sprite (8 byte image
leftItem2Color      ds 1    ; Color of the middle left item
leftItem3Sprite     ds 2    ; Pointer to the bottom left item sprite (8 byte image)
leftItem3Color      ds 1    ; Color of the bottom left item

rightItem1Sprite    ds 2    ; Pointer to the top right item sprite (8 byte image)
rightItem1Color     ds 1    ; Color of the top right item
rightItem2Sprite    ds 2    ; Pointer to the middle right item sprite (8 byte image
rightItem2Color     ds 1    ; Color of the middle right item
rightItem3Sprite    ds 2    ; Pointer to the bottom right item sprite (8 byte image)
rightItem3Color     ds 1    ; Color of the bottom right item

; Wall Buffers (calculated by the Kernel)
topWallBuffer       ds 4    ; Temporary buffer for the top wall PF graphics
wall1Buffer         ds 2    ; First layer of walls buffer
bottomWallBuffer    ds 4    ; Temporary buffer for the bottom wall PF graphics

; Other temporary variables
tempYBuffer = topWallBuffer ; Only use this after finished with topWallBuffer