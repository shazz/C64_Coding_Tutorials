In this tutorial we will take a quick look at how to render a sprite on the very nice standard C-64 background. Check out Sprite Pad for Windows to create sprites but for now, feel free to download the following sprite file: sprite1.prg

In the GitHub repo, there is another Sprite named sprite2.spr and the source in GitHub is using, as well as the SpritePad project file. Feel free to try both to see the difference.

Sprites are 2d images that you can move over a background, like a player character, a sun, a tree, an enemy and so on. You can have up to 8 sprites rendered at the same time.To render a sprite, you will have to enable it, give it a position, and have a pointer to its data.

Let’s do it step by step. First of all, we need to tell the compiler what processor we are writing our program for, and the entry point for it:

    processor   6502
org    $1000

Pointer to sprite data

Next, we need to create a pointer to our sprite data located at $2000 (you can put them in another location, but in this tutorial, we will put the data in $2000). The sprite pointers are the 8 bytes at the end of the screen memory (0400 – 0800):

One sprite takes 64 bytes of data, and 6410 (dec system) equals to 4016 (hex). If we set the pointer for sprite 1 (07f8) to #$00, the data for the sprite will be located at 0000. If we set it to #$01, the data will be located at 0040, if we set it to 2, the data will be located at 0080, if we set it to 3, it will be located at 00C0. How do I count this? 4016 * #number in pointer16 = where the memory for the sprite is located. Our sprite data will be located at $2000. So what value will we need to insert into 07f8? 4016 * 8016 = 200016, in other words, 8016.

We load the value 80 into A, and insert A into 07f8:

    lda #$80
sta $07f8

Enable sprites

Next, we must turn on the sprite. You can use up to 8 sprites, and one byte FF equals 1111 1111, 8 bits. Each of these bits controls if a sprite is enabled or not, and is located in the $d015 block. We only want to enable sprite 1, so we set the first bit to 1 and the rest will remain 0.

This can be done in two ways, either by inserting the hex value, or the binary value. If you insert the hex value #$01, the result will be 0000 0001 and sprite 1 is enabled. If you insert #$02, the result in binary will be 0000 0010 and sprite 2 will be enabled. But if you insert #$03, the result will be 0000 0011, enabling both sprite 1 and 2!

You can also directly use the binary value by using #%0000001,#%0000010 and #%0000011.

We will use the hex value, and enable sprite 1:
    lda #$01
sta $d015

(Or like this if you want to use binary:

    lda #%0000001
sta $d015
)

Set the XY position of the sprite

Next, we must set the XY-coordinates for our sprite. The coordinate memory is located from $d000. Both the X and the Y coordinate will need at least one byte each. To handle this, the first sprites X coordinate is located in $d000, and its Y coordinate is located at $d001. The 2nd sprites X coordinate is located at $d002, and its Y coordinate at $d003. The thirds X is at $d004, and Y at $d005, and so on. If we load the value #$80 into $d000 and $d001, the first sprite will be located at coordinate #$80,#$80 = 128,128 in pixels.
    lda #$80
sta $d000
sta $d001

The last thing we do is to actually load our sprite into the memory at $2000:
* = $2000
INCBIN “sprite1.prg”

Now, what we did was to first set the pointer to the data for our sprite, then we enabled the sprite, then sat the coordinates, and in the end loaded the data for our sprite.

Listing 4.1 – Complete listing for sprite example.

    processor   6502
org    $1000

         lda #$80
sta $07f8
lda #$01
sta $d015
lda #$80
sta $d000
sta $d001

loop: jmp loop

* = $2000
INCBIN “sprite1.prg”

If you take this application and compile it, you will see the result below:

..and don’t ask what that sprite is, I’m not a designer! Open-mouthed smile
Is your sprite different? I changed it a bit, so it should now just be a P.

That’s the end of this tutorial.. or is it? Hey? How wide is the C-64 screen? 320. And how large is one byte? 255.. and? Well, if 255 is the max we can insert into the sprites X coordinate, how can we move it all across the screen? Hmm.. good question.

Moving a sprite across the 255 limit

The answer is pretty simple. At the memory location $d010, we got 8 more bits to set. If the first bit in $d010 is set to 1, the position of sprite 1s X coordinate is:

256 + the value in d000

And this is the same for all of the 8 sprites.
So there you have it, see you next time 
