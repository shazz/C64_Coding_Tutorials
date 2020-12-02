# 13 - No Borders!

## Why ????

When I'm writing this tutorial, Oct 2020, I guess there is no better topic than "Opening the borders!". But for the sake of this project, we will only open the top and bottom borders of the C64.

Why should you ask?
 1. Because it's fun
 2. Because it should not be possible (from the C64 specs)
 3. Because it will us a path to what we call Fullscreen effects

As you probably noticed when runnign any "normal" program or simply the BASIC on your C64, the top and the bottom of the screen are somewhat locked. You cannot really print or display anything in those 2 areas (same for the left and right border but that will be another tutorial)

But because the C64 is really the "Hacking machine" by excellence, a long time ago, demoscene coders found a way to open those borders in order to do things that nobody have seen before.

And in fact, opening the top and the bottom border is somewhat trivial (compared to other effects requiring to race the beam).

Ferris from Youth Uprising wrote a nice article some years ago and instead of paraphrasing, I will copy here an extract:

## Opening the borders by Ferris/YP

How it Works and How to Do it
-----------------------------

To open the borders on the C64, we trick the VIC chip to think that it's drawing the borders, when really it isn't :) The way we do this is actually very simple.

The VIC chip has two major control registers: $d011 and $d016. The one we're concerned with when opening the top/bottom borders is $d011 (and likewise, $d016 for the side borders). 
In both of these, we're looking for a single bit - bit 3.

In $d011, bit 3 controls whether the VIC should display 24 or 25 rows of text. If it's 0, the VIC will draw 24 rows. If it's 1, 25 rows will be drawn. By default, this bit (in both registers) is set to 1.

How is this useful to us? How is this relevant to our goal here?

The VIC has a border state for the top/bottom and the side borders. Each border type is either on or off. Here's what happens regarding the top/bottom border state:
- 1. When the C64 starts up, the border state is on.
- 2. Each frame, when the scanline reaches line 50 (line 50 if it will draw 25 rows of text; line 54 if it will draw 24 rows), the border state is turned off and the VIC begins drawing the screen contents.
- 3. The VIC continues its current operation until it finishes the last scanline of the character screen. 
     If bit 3 of $d011 has directed the VIC to draw 25 rows, this is row 250, else it's row 246. At this point, the border state is set to on again.
- 4. The VIC continues happily and the border state is not checked or switched again until the next screen refresh.

This is how the VIC normally operates. But look again at #3 and #4: "...the border state is set to on. 4. The VIC continues happily and the border state is not checked or switched again until the next screen refresh. 
One more time: "...the border state is not checked or switched again until the next screen refresh." 
If you haven't figured it out yet, this is the key to opening the borders.

What we're going to do is simply trick the VIC to make sure that the border state never actually gets set to on. And because it's only switched at the end of the last character screen scanline, this is actually very easy. :)

First, at the beginning of each frame, we're going to set bit 3 of $d011, so the VIC should draw 25 rows of text. This is the default, and it's probably set anyways. 
If not, we'll reset the bit after each frame, so you probably won't even have to do this step. 
Next, we'll do everything else we would normally do per frame, as long as this activity doesn't occur from scanlines 249 to 255. 
Then, we'll either set an interrupt to occur at line 249 or just poll $d012 until it returns this value (the timing here isn't too critical so either method would work). 
Once we've reached this line, we'll either delay until the VIC has finished drawing the current character line, or if there's nothing important there, then it doesn't matter. 
This is where we clear bit 3 of $d011, so that the VIC will draw 24 lines of text.

Wait a second here. We just set the VIC to draw 24 rows of text on the last scanline of the 25th row. Doesn't this seem a bit weird? Well, actually, it is :) 
But this has done everything needed to open the border. This is because now, the VIC won't check the border state at line 250, because it already assumed that it did so on line 246. 
This means the border won't be turned on for this frame.

But why did I tell you to make sure not to do anything from line 249 to line 255? Well, we need to set the VIC back to 25 rows for the next frame so this will work properly. 
If you do so at the beginning of each frame, then you won't have to worry. 
Otherwise, set a raster interrupt or poll for line 255, at which point you'll reset bit 3 of $d011.

## The code!

So to summarize Ferris' idea:
 1. Wait until rasterline 249 (or set a raster IRQ)
 2. Change the C64 to 24 rows mode
 3. Wait until rasterline 255 (or set a raster IRQ)
 4. Change back C64 to 25 rows mode

As simple as that.
Here are 2 versions of this principle, one using comparator on the `current rasterline ($d012)` register and one using raster IRQs

Wait/Compare (`no_border_cmp.basm`)
````
; No Border using CMP
; Adapted from Ferris / YUP
; Ported to bass by Shazz / TRSi

REG_SCREENCTL_1         = $d011              ; screen control register #1
REG_RASTERLINE          = $d012              ; raster line position 

    !org $c000

    ; Wait until scanline 249
    lda #$f9
    cmp REG_RASTERLINE
    bne * - 3

    ; Trick the VIC and open the border!!
    lda REG_SCREENCTL_1
    and #$f7
    sta REG_SCREENCTL_1

    ; Wait until scanline 255
    lda #$ff
    cmp REG_RASTERLINE
    bne * - 3

    ; Reset bit 3 for the next frame
    lda REG_SCREENCTL_1
    ora #$08
    sta REG_RASTERLINE
````

Chained IRQs (`no_border_irq.basm`)
````
; No Border using IRQ
; Adapted from Jesder / 0xc64
; Ported to bass by Shazz^TRSi

REG_INTSERVICE_LOW      = $0314              ; interrupt service routine low byte
REG_INTSERVICE_HIGH     = $0315              ; interrupt service routine high byte
REG_SCREENCTL_1         = $d011              ; screen control register #1
REG_RASTERLINE          = $d012              ; raster line position 
REG_INTFLAG             = $d019              ; interrupt flag register
REG_INTCONTROL          = $d01a              ; interrupt control register
REG_INTSTATUS_1         = $dc0d              ; interrupt control and status register #1
REG_INTSTATUS_2         = $dd0d              ; interrupt control and status register #2

    !org $0801 ; begin (2049)

    !byte $0b, $08, $01, $00, $9e, $32, $30, $36
    !byte $31, $00, $00, $00                ;= SYS 2061/RUN

    ; register first interrupt
    sei

    lda #$7f
    sta REG_INTSTATUS_1     ; turn off the CIA interrupts
    sta REG_INTSTATUS_2
    and REG_SCREENCTL_1     ; clear high bit of raster line
    sta REG_SCREENCTL_1

    ldy #249
    sty REG_RASTERLINE
    lda #<switch_border_off
    ldx #>switch_border_off
    sta REG_INTSERVICE_LOW
    stx REG_INTSERVICE_HIGH

    lda #$01                ; enable raster interrupts
    sta REG_INTCONTROL
    cli

forever                 
    bne forever

    ; IRQ routine trigged at rasterline 249

switch_border_off       
    inc REG_INTFLAG

    lda REG_SCREENCTL_1     ; switch to 24 row mode
    and #247
    sta REG_SCREENCTL_1

    ldy #252
    sty REG_RASTERLINE
    lda #<reset_screen_mode
    ldx #>reset_screen_mode
    sta REG_INTSERVICE_LOW
    stx REG_INTSERVICE_HIGH

    jmp $ea81               ; RTI+stuff from Kernal

reset_screen_mode       
    inc REG_INTFLAG

    lda REG_SCREENCTL_1     ; restore 25 row mode
    ora #08
    sta REG_SCREENCTL_1

    ldy #249
    sty REG_RASTERLINE
    lda #<switch_border_off
    ldx #>switch_border_off
    sta REG_INTSERVICE_LOW
    stx REG_INTSERVICE_HIGH

    jmp $ea81               ; RTI+stuff from Kernal
````

Running one or the other you should see something like this...


Wait? Did we just replace the borders by jails ????

## Restrictions

As you know, the VIC has 1000 bytes of screen memory. Not one more. So filling the borders is not possible like that. In fact this black pattern you saw on the bottom and top borders are the last byte of the screen memory (`$3fff`) repeated over and over.

So, to check this is the fact, in any of the 2 versions, simply add those 2 lines before the `sei` to clear the last byte:

````
    lda #$00
    sta $3fff
````