  processor 6502
  include "include/vcs.h"
  include "include/macro.h"

  include "include/variables.h"
  include "include/constants.h"
  include "src/Macros.asm"

  SEG
  ORG $F000

Reset

  CLEAN_START


  lda #42
  sta playerX
  lda #0
  sta playerY

  lda #$1E
  sta wallColor
  lda #$FC
  sta backgroundColor
  lda #$2C
  sta topDoorColors
  sta bottomDoorColors
  lda #$3C
  sta topDoorColors+1
  sta bottomDoorColors+1
  lda #$4C
  sta topDoorColors+2
  sta bottomDoorColors+2

StartOfFrame

  include "src/Kernel.asm"
  inc playerY
  inc horDoors

  jmp StartOfFrame

  ; Helpful subroutines
  include "src/Subroutines.asm"

  ; Any additional binary data to include
  include "src/Data.asm"

  ORG $FFFA
  .word Reset          ; NMI
  .word Reset          ; RESET
  .word Reset          ; IRQ

END
