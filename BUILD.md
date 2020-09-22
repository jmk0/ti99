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

### Execution

In Classic99, select the Mini Memory cartridge (Cartridge -> Apps ->
Mini Memory), press a key at the boot screen, then select "3" for Mini
Memory.

You'll be presented with the Mini Memory menu, and at this point you
should press "1" TO LOAD AND RUN.  At the FILE NAME? prompt, enter the
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

## Mini Memory / Cassette

### Building

Building a deployable file for loading from cassette (real or not)
requires a slightly different procedure than loading object files.
You need to generate a binary image of the memory contents, and then
add a data header for the Mini Memory module.

First, build the binary image.  This should result in a 4K file that
fills the entire contents of the Mini Memory's SRAM.  The object file
in the other build process does not include the data that is not part
of the assembled code, but this process does.  It's just the way the
Mini Memory works.

```
xas99.py -b -R greet.asm
```

The `-b` option tells xas99 to produce the binary file needed for this
process.  The output file in this case is `greet.bin`

Additionally, Mini Memory requires that the data include a small
header that indicates the starting address and length of the data in
the file.  This is done using the `mmkludge.py` script in the tools
subdirectory of this package.

```
../tools/mmkludge.py greet.bin
```

Writes out a new file called `greet.mm` (or, alternately, a name of
your chosing if you add it to the command line to mmkludge) that
contains the required header.

Finally, the output file from the above must be converted into a .wav
file to be used as a cassette recording.  You can do that with the
referenced ti99_4a_tape_encode script like so:

```
ti99_4a_tape_encode.py greet.mm greet.wav
```

### Deploying

You should be able to put the .wav file on whatever device you're
using to play into your TI-99.  If your device refuses to play it, try
converting the .wav file into stereo.  I use Audacity for this
purpose.

Start up your TI-99 with the Mini Memory module in.  Press a key to
get to the menu and select "2" for the Easy Bug tool.  Press a key
again to dismiss the Easy Bug help page.

At this point you should have a simple prompt of "?".  Press "L" to
start loading from cassette, and follow the normal cassette loading
procedure.  When prompted to "PRESS CASSETTE STOP", you can press
enter, and get the "?" prompt again.  Press QUIT (Fn-= on original
hardware or alt-= on Classic99) to return to the boot screen.

### Execution

If you have already loaded the data as described above, and are at the
boot screen, press any key for the menu, then select "3" for Mini
Memory.

Now press "2" for RUN.  At the program name prompt, enter the name of
the program you loaded, e.g. "GREET" and hit enter.  If everything
worked out correctly, the program should run.  Otherwise you'll get an
error message.

### Testing the WAV file with Classic99

You can confirm if the produced .wav file is sufficient by going
through the deployment procedure using Classic99.  In this case, when
you're prompted to rewind the cassette, use the Disk -> Tape ->
Load/Rewind Tape menu options and select the .wav file you want to
load.  Go through the normal cassette loading process and it should
say "DATA OK" at the end.

Note: I've noticed that Classic99 will play back the cassette audio
through the speakers, but with a delay, so there will be a few seconds
where the emulator has already said "DATA OK" but you can still hear
it through the speakers.  This doesn't seem to prevent successful
load.

# Troubleshooting

## Object Files

Copying the .obj file to Classic99's virtual disks probably requires
specific options for the instructions to work.  In my case, the
options for DSK1 are:

   * Disk Type: Files (FIAD)
   * Path: .\DSK1\
   * Write TIFILES headers
   * Recognize TIFILES headers
   * Read Windows Text as DV files (this is probably the important one)
   * Read Windows files without ext. as DF128

## Cassette Virtualization

I had a lot of trouble getting to where I could read "cassette"
recordings.  Feeding audio from my desktop didn't work, nor did my
Surface Book nor iPod touch.  What did ultimately work was my Zoom H2n
recorder and a really old Fujitsu T4210 Lifebook.

When using the Zoom device, I had the microphone (red cable) connected
to line in and the playback (white cable) connected to line out.  I
left the control cable (black 2.5mm) unconnected as the Zoom uses a
more sophisticated control mechanism than a simple on-off relay-type
found in old cassette recorders.

Recording with the Zoom typically resulted in a recording that was too
quiet for the TI to be able to properly read on play-back, so I'd have
to normalize the audio at the very least.  WAV files generated through
other programs (e.g. ti994a_type_encode) were also generated as mono,
and the Zoom device refuses to play mono back so I have to convert
those files to stereo first.  That is, of course, a limitation with
the Zoom and not the TI.

Note that the voltage levels for playback need to be upwards of 3V
peak to peak (+/- about 1.5V) in order for the TI to be able to
process the data.  You probably won't be able to measure this with a
multimeter, though, you'd really need an oscilloscope.  This is
necessary but not sufficient, as my desktop outputs 3Vp-p just fine
but the TI still can't process the data.
