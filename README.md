![](/files/screens_by_peter/complete_all_levels_msg.bmp)

# Junkbot

This project extracts all of [Junkbot](https://en.brickimedia.org/wiki/Junkbot)'s source code and assets for preservation purposes. Previously, it was all buried within a 20+ year old Adobe Director project.

Note that the `.ls` files are written in "[Lingo](<https://en.wikipedia.org/wiki/Lingo_(programming_language)>)" (Adobe Director), not "[LINGO](https://www.lindo.com/index.php/products/lingo-and-optimization-modeling)" (mathematical modelling), or "[LiveScript](https://en.wikipedia.org/wiki/LiveScript_(programming_language))" (JS).

## Project structure

### Files

The `/files/` directory contains all extracted scripts (`.ls`), images (`.bmp`), sounds (`.wav` / `.mp3`), Flash animations (`.swf`), and text (`.txt`).

To try and keep a bit of structure, scripts are organised according to their "cast" (group) in the original project (e.g. `editor`, or `sound`), and with their script type (`cast_` / `behavior_` / `movie_` / `parent_`) as a prefix.

A few interesting areas to highlight:

- **All game sounds / music**: [`/files/sound/`](/files/sound/)
- **All level data**: [`/files/levels/`](/files/levels/)
- **All bricks**: [`/files/legoparts/`](/files/legoparts/)
- **Secret in-dev names of levels**: [`/files/catalog/catalog text.txt`](/files/catalog/catalog%20text.txt)
- **Animation components**: [`/files/dynamic/`](/files/dynamic/), filenames constructed by [`behaviour_legoparts manager.ls`](/files/Internal/behavior_legoparts%20manager.ls).

And a few asset bugs:

- One of [the walking animations](https://raw.githubusercontent.com/JakeSteam/junkbot-code/main/files/dynamic/MINIFIG_WALK_R_1_s2.bmp) has a mysterious pink thing ([`1.bmp`](https://raw.githubusercontent.com/JakeSteam/junkbot-code/main/files/dynamic/1.bmp)) in the top left.
- Some assets (e.g. [`MINIFIG_walk_l_10_s1`](https://raw.githubusercontent.com/JakeSteam/junkbot-code/main/files/dynamic/MINIFIG_walk_l_10_s1.bmp) & [`MINIFIG_walk_l_1_s1`](https://raw.githubusercontent.com/JakeSteam/junkbot-code/main/files/dynamic/MINIFIG_walk_l_1_s1.bmp)) have a single coloured pixel in the bottom left corner.

And just some assets I like:

| [![](/files/screens_by_peter/119.bmp)](/files/screens_by_peter/119.bmp) | [![](/files/screens_by_peter/122.bmp)](/files/screens_by_peter/122.bmp) | [![](/files/screens_by_peter/plaque_president.bmp)](/files/screens_by_peter/plaque_president.bmp) |
| :---------------------------------------------------------------------: | :---------------------------------------------------------------------: | :-----------------------------------------------------------------------------------------------: |

### Reference

The `/reference/` directory contains a few useful files:

- `director_reference.pdf`: Adobe's official 1,426 page guide to Director programming (in Lingo). Whilst this is useful for specific function definitions, Lingo itself is pretty readable if you know other languages.
- `junkbot2_13g_asp.dcr`: The original Junkbot game, taken from [an Archive.org backup](https://web.archive.org/web/20020803205407/http://www.lego.com:80/build/junkbot/junkbot.asp?x=x&login=0).
- `junkbot2_13g_asp.dir`: The `.dcr` file decompiled ([guide](https://blog.jakelee.co.uk/decompiling-adobe-director-files/)).

## Modified assets

### SWA sound files

Some sound files were originally `.SWA`, which can't easily be played. Luckily, this format is just `.MP3` with extra data, so renaming to `.MP3` made them playable. Thanks, ["hp3" from 2004](https://board.flashkit.com/board/showthread.php?368011-SWA-to-WAV&s=8ddbd4570a8a14ad3138caa3912c99d0&p=3051963&viewfull=1#post3051963)!

### 1-bit Bitmaps

A few bitmaps were exported with a bit depth of 1 (e.g. black and white). These didn't work properly on modern OS, so have been converted to a bit depth of 8.

The affected files are the 9 "cursor" files inside `Internal`.

## Utilities

- [AntRenamer](https://antp.be/software/renamer) for bulk filename / extension changing.
- n0samu's [DirectorCastRipper](https://github.com/n0samu/DirectorCastRipper) for asset extraction (although I did most of it manually).
- If you're using VSCode, I recommend Mark Hughes' "[Lingo Syntax Highlighting](https://marketplace.visualstudio.com/items?itemName=markhughes.director-lingo)" extension.
- 1j01's [HTML5 rewrite](https://1j01.github.io/janitorial-android/#junkbot).
