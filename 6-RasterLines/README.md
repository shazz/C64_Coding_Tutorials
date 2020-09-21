A raster line is the line that is being redrawn on the screen. You can create a lot of cool effects and implement smart logic that happens when the video signal reaches a specific raster line of your choice.

The screen is redrawn 50 times per second, from top to bottom, from the left to the right. This can be used to synchronize your logic with the screen refresh (and also with the clock!).

The current raster line is stored in the memory location $d012.

Let’s go back to our example in tutorial #1 where we changed the background color on the main area, using the following code:

    processor   6502
org    $1000

loop:    inc $d021
jmp loop

This resulted in something similar to the screen below:

Now, let’s implement the same example, but synced with the screen refresh. The code is really short, so I’ll just give you the complete listing.

        processor   6502
org    $1000

loop:     lda $d012
cmp #$ff
bne    loop
inc $d021
jmp loop

What this code does is to first load the value of d012 into the accumulator. And we check if it equals the value of ff (could be anything you want really).

Note: The screen size goes from 0 – 319, and the byte in d012 only got the range of 0 – 255. To get the rest of the screen, you can use the high bit in d011. If this is set, the value in d012 will contain the raster lines after 255. Smilefjes In other words, d011 is the 8th bit of d012.

Now, if you run the code above, you will get a screen that flashes different colors 50 times per second, without the color distortion that is created due to interrupts and timing.

Raster interrupts covered in tutorial 10 is a really important topic. It can be used to create a lot of cool effects like rendering more than 8 hardware sprites, split your screen into sections (one displaying hiQ graphics, other part displaying a font) and so on.

Have fun! 
