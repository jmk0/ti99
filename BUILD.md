# Development Tools

These applications are built with the following tools, though other
tool chains may be perfectly usable:

https://github.com/endlos99/xdt99

Provides the assembler, as well as other useful tools for hacking on
the TI-99.  Requires python 3.6.

http://harmlesslion.com/software/classic99
https://github.com/tursilion/classic99

Provides the emulator for initial development.  The emulator enables a
quicker assemble-test cycle, since I don't have to spend time loading
from "cassette".  Requires windows.

https://github.com/dimhoff/ti99_4a_tape_decode

Allows the creation of wav files for loading data from cassette.  This
allows me to load programs without installing a Peripheral Expansion
or flash cartridge.  Requires python 2.


# Build Instructions

These are general build instructions for the applications in this
repository.  If needed, a similar file will exist in a given
application's subdirectoy.

## Mini Memory / Classic99

### Building

Build an object file using the xas99 assembler (part of xdt99
mentioned above), using a command-line like:

```
xas99.py -R greet.asm
```

Where `greet.asm` is the source file to build from.  This should
create a new file called `greet.obj`.

### Deploying

Copy the created .obj file (e.g. `greet.obj`) into one of the DSK
File-In-A-Directory (FIAD) locations under your Classic99
installation, e.g. DSK1.

### Testing

In Classic99, select the Mini Memory cartridge (Cartridge -> Apps ->
Mini Memory), press a key at the boot screen, then select "3" for Mini
Memory.

You'll be presented with the Mini Memory menu, and at this point you
should press "1" to Load and Run.  At the FILE NAME? prompt, enter the
path to your generated object file.  For example, if you built
`greet.obj` and copied it to the DSK1 directory, enter
"DSK1.GREET.OBJ" here.

If you did everything right, you'll be prompted for a FILE NAME again,
at which point you should just press enter.

The program name is the text sequence at the end of the .asm file.  In
the case of the GREET program, you'll see that the program name is
"GREET", naturally.

```
        TEXT    'GREET '        ; store "GREET " (always 6 chars) as pgm name
```

Do not add the space to the program name.  Just type "GREET" (in this
case) and hit enter.  The program should immediately run if everything
was done correctly.

Note that the program will stay in the Mini Memory unless you
   1. Re-initialize the Mini Memory, or
   2. Load some other application on top of it.
