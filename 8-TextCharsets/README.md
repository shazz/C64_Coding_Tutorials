## 8 - Text Charsets

In the previous tutorial, we learned how to create and render a bitmap, and how to enter bitmap-mode.

In this tutorial, we are going to use almost the same concepts, but instead of rendering bitmaps, we are rendering text. We are also going to use a custom charset instead of the pretty boring charset that’s default.

The default charset look like this:

First of all, I’m not good at creating fonts so I won’t teach you how to do this. Instead we are going to download a charset that is named Scrap Writer III 17. Don’t know who created it but if anyone knows, please let me know so I can add proper credits.

The Scrap Writer III 17 charset look like this:

Donwload the charset here: scrap_writer_iii_17.64c

Download other charsets from this page: http://kofler.dot.at/c64/ but remember, some of them might be copyrighted.

Rendering text

Rendering text is quite simple. All you need is to either use the default charset or a custom charset. Also, you will need the text you want to render.

Let’s write our program.

First, we want to clear the screen. You could use the method we created earlier, but to keep this example to the point, I’m going to use a function that is included on the Commodore 64 and located at $e544. This routine clears the screen.

Also, we want to set the screen color and the border color to something greenish.

````
    processor   6502
org    $1000

jsr $e544
lda #$0d
sta $d020
lda #$05
sta $d021
````

Then we load the custom charset, using the same method as in the previous tutorial about rendering bitmaps. Our screen memory is at $0400 and charset at $2000.

````
lda #$18
sta $d018
````

Now it’s time for the meat of this tutorial. The loop that writes the text! First, we set the x-register to zero. Then we load the x’th character of msg (declared in the bottom) into the accumulator.
````
ldx #$00
write:     lda    msg,x
````

Once it’s loaded, we jump to a subroutine that writes text to the screen. This routine is located at $ffd2. All it does is to write the value in the accumulator to the screen.
````
jsr    $ffd2
````
The text we want to render is 54 character long. We loop through each of the characters and write it to the screen.
````
inx
cpx    #54
bne    write
````
Next we are setting the color of our characters. This could be done in the loop above, but just to split the different functionality, I decided to create another loop that does this. The color is stored at $d800 and so on. We do this for each of the 54 characters.

````
ldx #$00
setcolor: lda #$07
sta $d800,x
inx
cpx #$54
bne setcolor
````
In the end, we create an infinite loop so we can see what we rendered.
````
loop:        jmp loop
````

Then we need to load our data. We create msg that contain the text we want to render
````
msg        .byte “C64 programming tutorial by digitalerr0r of Dark Codex”
````

And then we include our custom charset

````
    org    $1ffe
INCBIN “scrap_writer_iii_17.64c”
````

And that’s it for rendering text. If you run this example, you will see the same result as below.

Listing 8.1 – Rendering text
````
    processor   6502
org    $1000

jsr $e544
lda #$0d
sta $d020
lda #$05
sta $d021
lda #$18
sta $d018

ldx #$00
write:      lda    msg,x
jsr    $ffd2
inx
cpx    #54
bne    write

ldx #$00
setcolor:  lda #$07
sta $d800,x
inx
cpx #$54
bne setcolor
loop:        jmp loop

msg        .byte “C64 programming tutorial by digitalerr0r of Dark Codex”

    org    $1ffe
INCBIN “scrap_writer_iii_17.64c”
````

