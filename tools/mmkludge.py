#!/usr/bin/python3

# add data to binary image for mini memory loading, that includes a
# presumed start address (0x7000) and the file size (typically 0x1000)

import os
import sys

if ((len(sys.argv) < 2) or (len(sys.argv) > 3)):
    print("usage: {} input-file [output-file]".format(sys.argv[0]))
    sys.exit(1)
infile = sys.argv[1]
if (len(sys.argv) == 3):
    outfile = sys.argv[2]
else:
    outfile,ext = os.path.splitext(infile)
    outfile = outfile + ".mm"
sz = os.path.getsize(infile)
print("Writing output to",outfile)

# Note that 0x7000 is assumed to be the starting address of the Mini
# Memory binary.  It probably won't work if you use something else.

with open(infile, 'rb') as inp, open(outfile, 'wb') as outp:
    b = bytearray(b'\x70\x00')
    outp.write(b)
    b = sz.to_bytes(2,'big')
    outp.write(b)
    outp.write(inp.read())
