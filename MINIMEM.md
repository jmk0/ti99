# Overview

Here are gathered some notes about things I've learned about
developing using the Mini Memory Command Module.

## Memory Footprint

If you have the manual for the Mini Memory, Appendix D describes how
memory is organized in the Mini Memory SRAM address space when using
it for assembly language program storage.

The data that matter most in this particular set of programs are:
   * ID Word, which identifies the memory space is being used for assembly.
   * First free address in medium memory, which tells the Mini Memory
     that the program memory is now in use.
   * Last free address in medium memory, which tells Mini Memory the
     other end of the data available for further use.

There are three memory locations used by the Mini Memory:
   1. The data starting at >7000 which keeps track of allocations.
   2. The program binary, usually starting at >7118.
   3. The user defined REF/DEF tables that start at >7FF8 and move
      back 8 bytes per entry (the first entry is at >7FF8->7FFF.

The easiest to explain is program binary.  This is the machine code
produced by the assembler from the assembly source code.  If you were
to use the Line-By-Line Assembler that came with the Mini Memory
module, this address would be starting at >7D00, but by using a cross
assembler, you now have >7118-7D00 available for your program that
would normally be taken up by the assembler, nearly an additional 3K
of program space that the assembler takes up.

The REF/DEF table.  Each entry in the table consists of 8 bytes.  The
first 6 bytes are the program name, e.g. "GREET ", and the final 2
bytes are the address of the start of that program.  This is typically
done by storing DATA referring to the label at the start of the
program.  For example, `DATA GREET` stores the address of the
instruction that starts at the label `GREET` in the assembly language
source.  This is resolved by the assembler.

The Mini Memory metadata.  A lot of this data is ignored here.  Only
the data described above really matter.  To simplify getting the first
free medium memory address, we use label references again, e.g. SLAST
in the `greet.asm` example.  The SLAST label is put after the final
program instruction and defined to be the first address after the
program using:

```
SLAST   EQU     $               ; 1st free address after code.
```

The `greet.asm` example also only uses one defined program name,
therefore the last free address is defined as `>8000-8` which sets the
last free address as the byte just before the REF/DEF table.

## Common Code

To address the needs of the Mini Memory, as described above, programs
are generally going to start with this:

```
        AORG    >7000           ; minimem begins at >7000
        DATA    >A55A           ; id word for assembly language storage
        DATA    >0000           ; identifiers for arguments
        DATA    >0000           ; etc. see mini memory appendix D
        DATA    >0000
        DATA    >0000
        DATA    >0000
        DATA    >0000
        DATA    >0000
        DATA    >0000
        DATA    >0000
        DATA    >0000
        DATA    >0000
        DATA    >0000
        DATA    >0000
        DATA    SLAST           ; first free address in medium memory
        DATA    >8000-8         ; last free address in medium memory
        AORG    >7118           ; put the program at the start of free space
```

And end with this, substituting GREET for your own program name and
program start label:

```
SLAST   EQU     $               ; 1st free address after code.
        AORG    >7FF8           ; Move to the name table
        TEXT    'GREET '        ; store "GREET " (always 6 chars) as pgm name
        DATA    GREET           ; store the address to our code
        END
```

These assembler statements fill in the data that the Mini Memory
needs.

## Data Encoding

I don't think it's discussed in the Mini Memory manual, but when
writing data to cassettes using the "S" command, Mini Memory adds a
small header to describe the contents of the saved image.  The LBLA
recommends saving >7000 through >7FFF and the procedures documented in
BUILD.md correspond to that.

The `mmkludge.py` script in the tools subdirectory adds this header,
which is a big endian binary header containing the 2-byte start
address of the data (typically >7000) and the 2-byte length of the
data, in bytes (typically >1000).

This header is only needed when loading from cassette via Easy Bug.
