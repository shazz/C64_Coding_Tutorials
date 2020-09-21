We are not going to introduce many new things in this tutorial, just use what you know to create more than one interrupt. Interrupts can be used to split you screen into different sections.

An important note is that these “interrupts” is your bridge to how it will be done when you get to a more advanced level (will be covered in a later part) and is intended for beginners. These will get you going, but know that there is a better and more correct way to do interrupts. In how I teach, I find it easier to start this way and then move to the correct way when the basic understanding is in place.

Anyways, say you want one part of your screen to render an image, and then once the image is rendered, you want to render some text. That means that you must set up your screen to support both graphic mode and text mode. This can be done with interrupts!

I’m going to create a program that splits the screen into two, where the first part got a purple color and the second part got a green color. We split the screen on every refresh using two interrupts.
The first interrupt does some logic before changing the IRQ vector to point to another “IRQ function” before returning to the main loop. The other interrupt does some logic, triggers another raster interrupt, changes the IRQ vector back to the original and returns to the main loop.

Not much is changed since the previous tutorial. We start with the exact same logic until the main loop starts to run:

processor    6502
org    $0810

; initiate music
lda #$00
tax
tay
jsr $1000

        ;clear screen
jsr $e544

        ; disable interrupts
sei
lda #$7f
sta $dc0d
sta $dd0d
lda #$01
sta $d01a

        ; set text mode
lda #$1b
ldx #$08
ldy #$14
sta $d011
stx $d016
sty $d018

        ; init irq
lda #<irq
ldx #>irq
sta $0314
stx $0315

        ; create rater interrupt
ldy #$00
sty $d012

        ; clear interrupts and ACK irq
lda $dc0d
lda $dd0d
asl $d019
cli

loop:    jmp loop

In the first irq, we set the color of the border and mainscreen, updates the music..

irq:  lda #$04
sta $d020
sta $d021

        jsr $1006

..and then use the same logic as earlier to set the IRQ vector to point to irq2.

        lda #<irq2
ldx #>irq2
sta $0314
stx $0315

We set the next raster interrupt at line 160:

        ldy #160
sty $d012

        asl $d019
jmp    $ea81

The code for the 2nd interrupt is very similar to the first one. We set the color of the border and the screen, and then set the IRQ-vector to point on irq.

irq2:
lda #$05
sta $d020
sta $d021

        lda #<irq
ldx #>irq
sta $0314
stx $0315

        ldy #$00
sty $d012

        asl $d019
jmp    $ea81

Finally, we set the music at location $1000-7e:

    org $1000-$7e
INCBIN “music.sid”

As I said, nothing new here really. Interrups are really handy when it comes to splitting the screen and timing. One thing to remember is that these interrups are not stable, so you might see some jittering or artifacts on the screen. It’s all about timing. We are going to see how to create stable interrupts in a later tutorial.

Note: You are not limited to only have two interrupts. Feel free to play around a bit, make some lines and so on.

An excerise for you:
Try to see if you can get the position of the split to move up and down. It might not be as easy as you thing, but you should be able to do this by now! Smilefjes som blunker

Listing 10.1 – More than one interrupt

processor    6502
org    $0810

; initiate music
lda #$00
tax
tay
jsr $1000

        ;clear screen
jsr $e544

        ; disable interrupts
sei
lda #$7f
sta $dc0d
sta $dd0d
lda #$01
sta $d01a

        ; set text mode
lda #$1b
ldx #$08
ldy #$14
sta $d011
stx $d016
sty $d018

        ; init irq
lda #<irq
ldx #>irq
sta $0314
stx $0315

        ; create rater interrupt at line 0
ldy #$00
sty $d012

        ; clear interrupts and ACK irq
lda $dc0d
lda $dd0d
asl $d019
cli

loop:    jmp loop

irq:  lda #$04
sta $d020
sta $d021

        jsr $1006

        lda #<irq2
ldx #>irq2
sta $0314
stx $0315

        ; Create raster interrupt at line 160
ldy #160
sty $d012

        asl $d019
jmp    $ea81

irq2:
lda #$05
sta $d020
sta $d021

        lda #<irq
ldx #>irq
sta $0314
stx $0315

        ldy #$00
sty $d012

        asl $d019
jmp    $ea81

    org $1000-$7e
INCBIN “music.sid”


