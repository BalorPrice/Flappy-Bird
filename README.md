# Flappy-Bird

Sam Coupé version of Flappy Bird

Written in Z80 assembler for a 512K Sam Coupé computer. This code was written in two weeks and shouldn't be used as examples of good coding style. I'm not kidding.  If you just want to play it:

http://scenedamage.com/cookingcircle/FlappyBird/Flappy-Bird.dsk
https://www.worldofsam.org/products/flappy-bird


CREDITS

In addition to my code, the source includes:

    Graphics based heavily from the original by .GEARS studio
    Music originally written by Maxo, https://maxoisnuts.bandcamp.com/track/george-pt-2
    Protracker player routines and Sam Coupe Diskimage manager by Andrew Collier
    Keyboard reading and redefine routines adapted from an original by Steve Taylor
    Various maths routines written/collated by Milos Bazelides
    SAMDOS2 binary, needed for loading of object file from the compiled diskimage.

COMPILING AND PLAYING

This version is compiled with pyZ80, a freely-available Z80 cross-assembler found at https://github.com/simonowen/pyz80. After installing PYZ80 you can compile the diskimage by running make_bb.bat. You'll need to amend the filepaths in this file for your system.

It can be run in SimCoupe or ASCD, both up-to-date popular emulators for the original machine, from https://wwww.simcoupe.org/ and http://www.keprt.cz/sam/

This can be used on a real Sam by converting the diskimage to a floppy disk with SAMDisk by Simon Owen, available from http://simonowen.com/samdisk/.

GETTING STARTED

The game is split into several modules. Reading the source is best started in the auto.asm module, which includes overall game structure and includes other modules.