  processor 6502
  include "include/vcs.h"
  include "include/macro.h"

  include "include/variables.h"
  include "include/constants.h"

  SEG
  ORG $F000

Reset

StartOfFrame


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
