# Junkbot Code

This project aims to extract all of Junkbot's source code (and potentially assets) for preservation purposes. Since it is all buried within an Adobe Director project, it's currently unsearchable.

Note that these `.ls` files are written in "[Lingo](<https://en.wikipedia.org/wiki/Lingo_(programming_language)>)" (Adobe Director), not "[LINGO](https://www.lindo.com/index.php/products/lingo-and-optimization-modeling)" (mathematical modelling).

If you're using VSCode, I recommend Mark Hughes' "[Lingo Syntax Highlighting](https://marketplace.visualstudio.com/items?itemName=markhughes.director-lingo)" extension.

## Files

The `/code/` directory contains all extracted scripts, whilst the `/reference/` directory contains a few useful files:

- `director_reference.pdf`: Adobe's official 1,426 page guide to Director coding (Lingo). Whilst this useful for specific function definitions, Lingo itself is pretty readable if you know other languages.
- `junkbot2_13g_asp.dcr`: The original Junkbot game, taken from [an Archive.org backup](https://web.archive.org/web/20020803205407/http://www.lego.com:80/build/junkbot/junkbot.asp?x=x&login=0).
- `junkbot2_13g_asp.dir`: The `.dcr` file decompiled ([guide](https://blog.jakelee.co.uk/decompiling-adobe-director-files/)).

To try and keep a bit of structure, scrips are organised according to their grouping in the game files (e.g. `editor`, or `sound`), and with their script type (`cast_` / `behavior_` / `movie_` / `parent_`) as a prefix.

The initial script name capitalisation has been kept, hence the inconsistencies! Some files also had no name, so their numeric ID has been used instead.

The file groups seem to be:

- `Internal`: Intended for core functionality, such as displaying text, the overall game loop, etc. This appears to be a mixture of prebuilt and new scripts.

## Modified

### 1-bit Bitmaps

A few bitmaps were exported with a bit depth of 1 (e.g. black and white). This doesn't work on modern OS, so they have been converted into 16 depth bitmaps.

### SWA sound files

Some sound files were originally `.SWA`, which can't easily be played. Luckily, this format is just `.MP3` with extra data, so renaming to `.MP3` made them playable. Thanks, ["hp3" from 2004](https://board.flashkit.com/board/showthread.php?368011-SWA-to-WAV&s=8ddbd4570a8a14ad3138caa3912c99d0&p=3051963&viewfull=1#post3051963)!

## Missing

### Text

There is misc text scattered around the game files, these aren't currently exported as they also contain formatting, fonts, layout, all things that can't be easily represented. I might export a plaintext version of these.

### Flash Movies

Currently, I can't get the any of the "Flash Movie" files. They can be played within Adobe Director, but not exported. As a last resort, these could just be screen captured, but this isn't ideal. The full list is:

- In `screens_by_peter`, `portrait_2` (148x130, 50 frames): The winning animation with paper raining down upon Junkbot.
- In `loading`, `intro_anim` (200x200, 480 frames): The entire intro animation.
