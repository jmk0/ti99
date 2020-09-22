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
VMBW    EQU     >6028           ; VDP multi-byte write routine location
CHARW   EQU     >0AB8           ; VDP address of 'W' character pattern
MSG1    DATA    >008B           ; VDP target memory location of WELCOME! message
        DATA    >0008           ; length of welcome message in bytes
        TEXT    'WELCOME!'      ; Message to display
GREET   LIMI    1               ; Enable interrupts so QUIT works
        LI      R1,MSG1         ; Put the address of MSG1 into R1
        MOV     *R1+,R0         ; Put the message target mem location in R0
        MOV     *R1+,R2         ; Put the message len in R2
        ; Note the above leaves R1 pointing to the message text.
        BLWP    @VMBW           ; Write the message to the VDP
FREEZE  JMP     FREEZE          ; And loop forever.
SLAST   EQU     $               ; 1st free address after code.
        AORG    >7FF8           ; Move to the name table
        TEXT    'GREET '        ; store "GREET " (always 6 chars) as pgm name
        DATA    GREET           ; store the address to our code
        END
