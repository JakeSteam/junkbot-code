# Junkbot Code

This project aims to extract all of Junkbot's source code (and potentially assets) for preservation purposes. Since it is currently buried within an Adobe Director project, they're unsearchable.

Note that these `.ls` files are written in "[Lingo](<https://en.wikipedia.org/wiki/Lingo_(programming_language)>) (Adobe Director)", not "[LINGO](https://www.lindo.com/index.php/products/lingo-and-optimization-modeling) (mathematical modelling).

If you're using VSCode, I recommend Mark Hughes' "[Lingo Syntax Highlighting](https://marketplace.visualstudio.com/items?itemName=markhughes.director-lingo)" extension.

## Files

The `/code/` directory contains all extracted scripts, whilst the `/reference/` directory contains a few useful files:

- [director_reference.pdf](/reference/director_reference.pdf): Adobe's official 1,426 page guide to Director coding (Lingo). Whilst this useful for specific function definitions, Lingo itself is pretty readable if you know other languages.
- [`junkbot2_13g_asp.dcr`]: The original Junkbot game, taken from [an Archive.org backup](https://web.archive.org/web/20020803205407/http://www.lego.com:80/build/junkbot/junkbot.asp?x=x&login=0).
- [`junkbot2_13g_asp.dir`]: The `.dcr` file decompiled ([guide](https://blog.jakelee.co.uk/decompiling-adobe-director-files/)).

## Organisation

To try and keep a bit of structure, scrips are organised according to their grouping in the game files (e.g. `editor`, or `sound`), and with their [script type](<https://en.wikipedia.org/wiki/Lingo_(programming_language)#Scripting>) (`cast_` / `behavior_` / `movie_`) as a prefix.
