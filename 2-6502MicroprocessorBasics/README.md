## 2 - 6502 Microprocessor Basics

Now that I started writing about C-64 programming, I decided to write one more article about it. If you want more, please comment so I know if this is an interesting topic.

This article is all about writing code for the heart of the Commodore 64, the 6502 microprocessor. It’s function is to control the C-64, so you can think of it as the C-64s brain.

You control the brain by giving it instructions. These instructions are given to the processor by writing the 6502 machine language.

In the previous article about C-64 we created a simple program that changed the background of the border and the main screen to a lot of different random colors. In this tutorial, we are going more deep into the general 6502 microprocessor language.

### Programming the 6502 Microprocessor

The 6502 microprocessor language consists of many different instructions and commands, that all work together to give functionality and graphics to your own programs. You can move data between registers (a register is basically a container(variable) where you can store data), and execute commands. You can move data into registers, and from registers to memory locations.

We got three registers in the 6502 that can be used to move data.


In table 1, we can see the different registers. We got the `A` register (accumulator), and the X and Y registers. Each of them can hold one byte (0-255 in decimal, `00-FF` in hex and `00000000-11111111` in binary).

To move data to/from a register, we can use various move-instructions:

Let’s write a program that changes the background color of both the border and the main screen into a specific color.

First we will need to tell `dasm` that we are writing a program for the 6502 processor, and that our program should start in the memory located at `$1000`.

````
    processor   6502
org    $1000
````

Next we create the loop that changes the color of our border/main screen into a cyan color. First we create the loop label, and load the Accumulator register with the value of 3. If you write a hex number with the # symbol in front of it, it will load the Accumulator (`A`) with the hex number as a value. If you load it without the # symbol, it will load `A` with the content of the memory location.
````
loop:    lda #$03
````
Next, we will move the value in the A register into the register that holds the color for the background/main screen.
````
sta $d021
sta $d020
````
And then we jump back to the loop label, so the program doesn’t end in a split second.
````
jmp loop
````
The complete listing of the program should be like this:
Listing 2.1 – Change screen to a given color.
````
    processor   6502
org    $1000

loop:    lda #$03
sta $d021
sta $d020
jmp loop
````

Now, compile this code by browsing to the source code file and writing the command
`dasm example2.asm –oexample2.prg`. Then load this into the emulator by writing the command `x64 example2.prg`.

Now that the program is loaded, run it from the emulator by writing `SYS 4096` and hit [Enter].

The result should be like this:

Pretty nice, right?

Next, let’s do some more work with moving data between the registers.

Instead of using the A register, you could have used the `X` or `Y` register instead. So in all, you can use all three registers to move or copy bytes between registers and memory locations.

### Relative addressing
Let’s put the `X` register to use. Let’s create a new program that displays the exact same result as the example above, but instead we use relative addressing.

Listing 2.2 – Relative addressing
````
    processor   6502
org    $1000

loop:    ldx #$20
lda #$03
sta $d000,X
sta $d001,X
jmp loop
````
As you can see, the code for this program is quite different, but the result is the same as above. First we store the value of `$20` in the `X` register, and the value of `$03` in the `A` register (cyan). Then we copy the value of `A` (color `$03`) into the memory location `$d000`+`X` that equals `$d000`+`$20` (=`$d020`, the border color), and then we copy A into `$d001`+`$20` (=`$d021`, the main screen). The result is the same as above, but we use relative addressing when storing data into the memory.

We can also move data between registers by using instructions named `TXA`, `TYA`, `TAX` and `TAY`. `TXA` transfers the data in `X` to `A`, `TAX` moves the data in `A` to `X` and so on. Only the register that the data is moved to will be affected by the transfer.

We have seen that the `INC` command can increase the value in a memory location by 1 (same as memorylocation += 1, or memorylocation = memorylocation + 1). You can also decrease it using `DEC`. It is also possible to increase and decrease the X and Y registers by using `INX`, `INY`, `DEX`, `DEY`.

In the next example, we are making a program that colors the border with the cyan color (`#$03`) and then colors the main screen with the cyan color + 1 (`#$04`) = purple.

Listing 2.3 – Increase/decrease registers
````
    processor   6502
org    $1000

loop:    ldy #$03
sty $d020
iny
sty $d021
jmp loop
````

In this example, we simply load #$03 into the Y register, and store in into the border memory location `$d020`. Then we increase `Y` = `#$03` + `#$01` = `#$04` = the code for purple, and store that into the main screen memory `$d021`.

The result can be seen in the image below.


And that’s how far this tutorial goes. Until next time! 
