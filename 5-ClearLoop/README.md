## 5 - Clear loop

In the previous tutorials we created stuff that rendered a sprite and changed the color on things. In this tutorial, we will clear the screen to a black color.

To clear the screen, we should set the color of the border and the main screen to a given color, like black, and then we must clear the characters on the screen. This can be done by setting them to the character SPACE.

To do this, first we put the index for black into the accumulator, and store this into the border and the main screen.
````
    processor   6502
org    $1000

        lda #$00
sta $d020
sta $d021
````

Next we copy the value in the accumulator into the x-register.

````
tax
````

Then we put the value of `#$20` in to the accumulator. `#$20` is the value of the SPACE character.
````
lda #$20
````

Now we are ready to put the value inserted in the accumulator into every character on the screen memory. This will be done by creating a loop that goes through the entire screen memory. The screen memory is located at `$0400` and ends at `$07FF`.

Linus Åkerlund of Fairlight shared a smart way of looping through the screen memory. Before the loop starts, x contains the value 0. If we decrement it, it will become `FF` (`255`), and then go all the way down to 0 again, setting all the characters to space in the range `0400-04FF`, `0500-05FF`, `0600-06FF` and `0700` to `07FF`.
````
loop:   sta $0400,x
sta $0500,x
sta $0600,x
sta $0700,x
dex
bne loop
````

The last instruction is new; bne will jump (branch) to loop if `X` is not zero. That means that when we start, `X` will be 0, and right before the bne operation, we will decrease it so it contains `FF`. This means that the loop will go all the way from `FF` to `00` before exiting the loop.

Listing 5.1 – Clear loop
````
    processor   6502
org    $1000

        lda #$00
sta $d020
sta $d021
tax
lda #$20
loop:   sta $0400,x
sta $0500,x
sta $0600,x
sta $0700,x
dex
bne loop
````

That’s it for clearing the screen. When the clear loop is done, you can continue doing what else you want the program to do.


