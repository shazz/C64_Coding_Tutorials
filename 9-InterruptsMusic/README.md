In this tutorial we will take a look at one of the most important topic when it comes to C-64 programming – Interrupts.

Interrupts are used to pause whatever the machine is doing at a given condition, and do another task. When the interrupt is complete, your program will continue to run where it was interrupted.

An interrupt might be a timer interrupt that happens when a given amount of cycles has passed, a raster interrupt, a collision interrupt and so on. You can have multiple interrupts during a screen refresh. If you have interrupts enabled, and don’t use them to time your program, your application will be jerky and flickering.

There are two types if interrupts. One is Interrupt Request (IRQ), the one we are going to program in this tutorial, and then another one named Non-Maskable Interrupt (NMI). The difference between these is only that you can turn off the IRQ’s, but not the NMI’s (unless you do a trick).

We are also going to introduce two new instructions, SEI and CLI:
– SEI (SEt I(nterrupt) flag) instruction does disable interrupts.
– CLI (CLear I(nterrupt) flag) instruction does enable interrupts.

There is an initialization process when creating interrupts. During this, it’s very important to disable interrupts just to make sure another interrupt won’t ruin the init process. Smilefjes (If not, your application MIGHT crash)

The example in this tutorial will use interrupts to play music. Playing music in a program is very simple. Only a music file (.sid) and 5 lines of code is required. You also need to find some numbers that will be used to locate, init and play the music using a SID-player tool.

You can create your own music, but since I’m nothing near a musician, I downloaded a music and used this in our example. The file is named music.sid, and the title of the song is “Masses Zak”. I got the file from High Voltage SID Collection, a page with a huge archive of C-64 music. Be sure to take a look! Smilefjes

Before we start, download this music file:
Source at GitHub

You also need a tool that can play music files, just to find out some information about the file, like where in the memory it will be stored. Most files will be at $1000, but not all. Smilefjes
The SID player I use is named Sidplay2 for Windows and can be downloaded here.

Now, download and start Sidplay 2, open “music.sid” (can be downloaded above) and the music will start playing. Now click File->Properties to see a long list with information regarding the SID-file:

What’s important to note is the Load range, Init address and Play address. These will be used when we init and play our song (d’Oh).

Let the programming begin!

As usual, we start by telling the compiler what processor we are programming for, and where in the memory our program should start.

    processor    6502
org    $0810

But wait, we are starting on $0810 instead of $1000? Why is this? Well, our music file will be loaded into $1000 (Load range), so we simply move the start address for our program to $0810. To run our program, start it in the emulator and write SYS 2064 (decimal of 0810 hex)

Next we initiate the music. This is done but putting the value 00 into the x- and y-registers, and call the subroutine that resets the SID-chip. The properties in the SID file stated that the init routine for the music is at $1000, so that’s what we want to do. Smilefjes

             lda #$00
tax
tay
jsr $1000

Now we are going to initiate the interrupts. First we need to turn off the interrupts:
             sei

Then we put the value 7f into $dc0d and $dd0d to disable the CIA I, CIA II and VIC interrupts (timer, keyboard,…, interrupts)
             lda #$7f
sta $dc0d
sta $dd0d

We also need to enable raster interrupts. We do this by inserting 01 into $d01a.
             lda #$01
sta $d01a

Next we tell the VIC that we want to enter single-color text mode. Inserting 1b into $d011 means “Enter text-mode”, and inserting 08 into $d016 means “Use single-color”. We also tell the VIC that our screen RAM is at $0400 and that we want to use the default charset by inserting 14 into $d018 (see earlier tutorials for more information about how this works).
             lda #$1b
ldx #$08
ldy #$14
sta $d011
stx $d016
sty $d018

Now we are at the meat of this tutorial. What we will do next is to load the interrupt handlers codes lower and high part into the interrupt vector at $0314-$0315. “irq” is the label where the code for our interrupt is located, so all we do is to insert a pointer to this into $0314-$0315:
             lda #<irq
ldx #>irq
sta $0314
stx $0315

Then we need to create the trigger for out interrupt at “irq”. We want a raster interrupt at any line (in this example $7e) to trigger the interrupt.
             ldy #$7e
sty $d012

Then we clear pending interrupts (the CIA 1, CIA 2 and VIC interrupts).
             lda $dc0d
lda $dd0d
asl $d019

Now that the interrupt is initiated, we can enable interrupts and start with the program logic. In this example, we are only running an infinite loop:
             cli
loop:     jmp loop     ; infinite loop

Next is the code for our interrupt. What this does is to first run a sub routine at $1006 (the play SID-file routine for music.sid (remember the properties of the sid file)):
irq:       jsr $1006

Then we ACK the interrupt with asl $d019. This is done because we don’t want the interrupt to be called again right after we return from it.
             asl $d019

Then we jump to a subroutine that restores the stack and returns from the interrupt. If you want to save 3 cycles, you could write this manually, but for simplicity, we jump to $ea81 (see below for what you can replace this with if you want to write the code yourself):
             jmp    $ea81

The last thing we do is loading the music into $1000. But a SID file got an offset of $7e so we need to subtract this from $1000 so the file is correctly placed in memory.

    org $1000-$7e
INCBIN “music.sid”

That’s if for basic interrupt. We will be more advanced in a later tutorial as interrupts are really important when it comes to C-64 programming.

A complete listing of our example is in listing 9.1.

Listing 9.1 – Interrupts and music

processor    6502
org    $0810

             lda #$00
tax
tay
jsr $1000
sei
lda #$7f
sta $dc0d
sta $dd0d
lda #$01
sta $d01a
lda #$1b
ldx #$08
ldy #$14
sta $d011
stx $d016
sty $d018
lda #<irq
ldx #>irq
ldy #$7e
sta $0314
stx $0315
sty $d012
lda $dc0d
lda $dd0d
asl $d019
cli
loop:    jmp loop
irq:      jsr $1006
asl $d019
jmp    $ea81

    org $1000-$7e
INCBIN “music.sid”


