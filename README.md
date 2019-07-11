# Walls

Atari 2600 game programmed in 6502 Assembly

<br>

## Assembling

Walls is designed to use the [DASM](http://dasm-dillon.sourceforge.net/) assembler for
building the Atari 2600 ROM. As such, you will need to download and install the assembler
and configure the system path to run it. Because **DASM has troubles with Unix newline
characters**, be sure to run the command `unix2dos` on all of the assembly files if you
are attempting to assemble the code on Linux. The provided file `assemble.sh` automatically
assembles the code by running the command `dasm`, but you might need to modify it depending
on how you configured the system paths.

<br>

## Running

Walls has been tested using the following emulators:

- **[Stella](https://stella-emu.github.io/)** - A Multi-Platform Atari 2600 VCS Emulator
- **[z26](http://www.whimsey.com/z26/)** - An Atari 2600 Emulator

After assembling the source code, `assemble.sh` has methods to automatically run these
emulators for testing purposes. Once again, you might need to modify this file depending
on how you configured the system paths.
