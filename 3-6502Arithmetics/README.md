Continuing from the previous tutorial, this tutorial will focus on basic arithmetic’s on 6502/6510 microprocessor programming – to get you all started.

Let’s say we got a program that got a black background. If something happens, we would like to change that background into a brown color. If you take a look at figure 3.1, you can see that the black color is the index 00, and the brown color is the index 08.

To do this, we create an application that increases the color 8 times, and put that into the color display.

Listing 3.1 – INY

    processor   6502
org    $1000

loop:    ldy #$00
sty $d020
iny
iny
iny
iny
iny
iny
iny
iny
sty $d021
jmp loop

In listing 3.1, we store the index of the black color in Y and then copy it to the border and main window memory. Then “something happens” and we would like to create the main window brown by increasing the index stored in Y eight times.

Let’s say we would like to increase this 55 times. That would have been many INY instructions, and also a big and messy code. We could also use a loop. But the 6502 language got a specific set of instruction to do addition and subtraction.

Let me introduce you to the add with carry (ADC) and subtract with carry (SBC)

Add and subtract
You can add a value to the accumulator ( A ) register by using the ADC instruction. If you load the value of #$00 into the A register, and want to add #$08 to it, so the A register will contain #$00+#$08 = #$08, you can use the ADC instruction. But before you use the ADC instruction, you need to clear the carry flag with the CLC instruction. Let’s take a look at an example.

Create a new asm source file, and name it something like example5.asm.
Start by doing the usual stuff:

    processor   6502
org    $1000

Next, we create our main loop. We start by loading the A register with the value of #$00 (color black) and store it in the border memory.

loop:    lda #$00
sta $d020

Next we clear the carry flag:
             clc

Then we use it to add #$08 to the existing value in the A register
             adc #$08

..and store it in the main screen area.
             sta $d021
jmp loop

The whole source should look like Listing 3.2.

Listing 3.2 – ADC/CLC

    processor   6502
org    $1000

loop:    lda #$00
sta $d020
clc
adc #$08
sta $d021
jmp loop

The result should be similar as in the image below:

It’s also possible to subtract a value from the A register by using SBC and the Set Carry SEC. The next example is quite similar, but here we set the border to brown, and then set the main window to black.

Listing 3.3 – SBC/SEC

    processor   6502
org    $1000

loop:    lda #$08
sta $d020
sec
sbc #$08
sta $d021
jmp loop

The result should be similar to this:

Bit shifting
The last thing we will go through in this tutorial is bit shifting. If we shift the bits that are in a given memory to the left, the value there will be multiplied by two, and if you shift them to the right, the value will de divided by two.

Say you got the following bits:

0010 = 2

Shifting this to the left:

0100 = 4

and again:

1000 = 8

and vice versa when going to the right.

To shift to the left, use the instruction ASL, and to shift to the right, use the instruction LSR.

Listing 3.4 shows a program that does shifting. It first displays a purple color (index 4 in Fig 3.1) and then shifts the bits to the left, making it to index 8 (brown).

Listing 3.4 – ASL

    processor   6502
org    $1000

loop:    lda #$00
sta $d020
clc
adc #$04
sta $d021
asl $d021
jmp loop

As you can see the in the image, the color changes between the purple and the brown color.
