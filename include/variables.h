  SEG.U Variables
  ORG $0080

;All variables for the program
playerX             ds 1
playerY             ds 1

backgroundColor     ds 1    ; Color of the background
wallColor           ds 1    ; Color of the wall
threeWallsFlag      ds 1    ; xx...... - Horizontal, vertical, true if use 3 walls
