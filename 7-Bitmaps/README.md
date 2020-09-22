## 7 - Bitmaps

In this tutorial we are going to cover two things. First we will look at one way of creating bitmaps/images for our C-64 programs by using a tool for Windows. Next we will load the image we created into our own program and render it.

### Creating bitmaps

Before you can draw your bitmap, you will need a tool. The tool I like to use is named Timanthes v3, and can be downloaded below.

imageDownload Timanthes 3.0 beta by Mirage of Focus:  http://noname.c64.org/csdb/release/?id=75871

Load Timanthes and you will see an environment much similar to other painting programs in front of you. When painting for the Commodore 64 you must be aware of a few limitations. The Commodore 64 supports a few different graphic modes. The one introduced here is a pretty common one and will work as a basis to understand the rest of them.

The format we are implementing is named MultiColor and got a resolution of 160×200 pixels, with the support of 16 colors. As you can see, the resolution of the images is smaller than the screen. One pixel in the image represents 2×1 pixels when rendered on the screen. Another important attribute with this mode is that the screen is divided into 40×25 attribute cells, where each attribute cell is 4×8 pixels in size. Each is also limited to contain the maximum of 4 colors.

Confused? Let me break it down for you:

The image is 160×200 in size…

..where one pixel in the image represents 2×1 pixels in screen size:
image In this picture, I drew ONE line across 8 pixels, and another line down 8 pixels. Notice that the width of one pixel spans across two pixels when rendered.

I also mentioned that this image mode splits the image into 40×25 attribute cells:

where each of the cells contains 4×8 pixels (8×8 in real):
image This is one cell. It contains 4 pixels you can draw in the x-axis and then 8 pixels you can draw in the y-axis. One pixel in the x-axis represents 2 pixels in screen size.

Also, one cell can only contain the maximum of 4 colors, including the background. If you try to draw more than 4 colors in Timanthes, a red pixel will show on the colors that exceed the limit, and must be corrected.

Now, the first thing you will see when loading Timanthes is that you got a drawing area and some floating windows. Move these into a position you like. Now, in the layers window, notice that you got two layers. This is how it should be when exporting your image to a prg file. You NEED to have two layers. I usually draw on the 2nd layer.

Also, on the right side of the layer preview image, you can see what type of layer your dealing with:

This is where you select what kind of graphic mode you want the image in. Select Layer 2 (it’s probably already selected) and click the properties button:

You will see a popup window:

In Mode, select “Bitmap multicolor” and click OK.

Now, select a color from the Colors window. This is the palette. This mode support 16 different colors. You can modify each color from this window. But remember, 16 in total is the limit. 

Now, draw any image. My result was this, the logo of my group in the demoscene. File is in the repo.

Now it’s time to export your image from Timanthes. Click File and Export As, the type must be .PRG and you can name it whatever you want. I named mine dcc.prg. Press OK and a new popup will show:

You can leave it like this for this example, but these values are the values we are going to use when loading the image into memory and displaying it!

A list of other graphic modes can be found here: http://www.studiostyle.sk/dmagic/gallery/gfxmodes.htm

Loading and displaying the image in your program

Keep in mind that one image takes about 2000 bytes in memory, so it has to be loaded into $2000, $4000, $6000 and so on, and not in $2456.

Let’s write our code. A complete listing can be seen below.

First of all, we set the background color to the one that the image is using. When you exported the image, you noticed that the background is stored in $4710. Load the value from here into the `d020` and `d021` memory.

````
processor 6502
org $1000

lda $4710
sta $d020
sta $d021
````

Now we will create a loop that copies the data to screen RAM that starts at `$0400`. The data (in one way, we use characters (the cells), but more on this later) for our image is located at `$3f40` (as we noticed when we exported the image). We use the same method for copying as in the earlier example where we cleared the screen.

First, set the x-register to zero, and start the copying:

````
ldx #$00
loaddccimage:
lda $3f40,x
sta $0400,x
lda $4040,x
sta $0500,x
lda $4140,x
sta $0600,x
lda $4240,x
sta $0700,x
````

Also, we must copy the color RAM for our image located at `$4328` (specified when exporting the image) to $d800. We add this to the loop:

````
lda $4328,x
sta $d800,x
lda $4428,x
sta $d900,x
lda $4528,x
sta $da00,x
lda $4628,x
sta $db00,x
````

One last thing has to be done in the loop, and that is to increase x. If x does not equal zero, branch to the loaddccimage label.

````
inx
bne loaddccimage
````

The loop will now loop until x is zero, copying all data into the correct memory. Once this is done, the image is loaded and ready to display! Smilefjes

The next thing we need to do is to tell “the system” that we want to enter bitmap mode, and that the mode is a multicolor mode.

`$d011` must be set to what mode we want to go into. To got into bitmap mode, we set `$d011` to `3b`:

````     
lda #$3b
sta $d011
````

Now we are in bitmap mode.

Next, we must turn on multicolor-mode. This is done by putting the value in `$d016` to `18`.

````
lda #$18
sta $d016
````

Now, we are in bitmap multicolor-mode!

The last thing we need to do is to tell the VIC that the screen RAM is at 0400 and that the bitmap is at `$2000`. If we put in the value 18, the first numer (1) is where we want the screen RAM, and the last numer is where the bitmap is. How does this work? First, we know that out screen RAM is located at 0400 and is 0400 bytes long. We count how many times we need to “add” 400 bytes to reach to the desired screen RAM from `0000`. So, `0000`+`0400` = `0400`. Thats one time. Next, we must count how many times until we reach `2000`. Thats 8 times. To set that the screen RAM is at `0400` and the bitmap is at `2000`, we `$d018` to `#$18`:

````
lda #$18
sta $d018
````

This might sound confusing. The screen memory is 400 bytes long, so it has to start on a memory address that is a multiple of 400. If you don’t change where the screen memory is, it’s located at `$0400` by default like in this example.

Now, let’s add an infinite loop so that our program won’t just exit once the image is rendered:

````
loop:
jmp loop
````
That’s it for loading the image. One final thing remains, and that is to include our image file and put it into the memory. When we exported, we specified that we wanted to have the image at the memory location `$2000`. Now, a PRG file got a header that is 2 bytes long. That means that we want to include the file in location `$2000`-`2` bytes = `$1FFE`:

````
org    $1FFE
INCBIN “dcc.PRG”
````

If you compile and run this, the emulator will display the image as seen below. 

A complete listing of our code can be found in listing 7-1.

Listing 7.1 – Complete listing for rendering your multicolor image

````
    processor   6502
org    $1000

lda $4710
sta $d020
sta $d021
ldx #$00
loaddccimage:
lda $3f40,x
sta $0400,x
lda $4040,x
sta $0500,x
lda $4140,x
sta $0600,x
lda $4240,x
sta $0700,x
lda $4328,x
sta $d800,x
lda $4428,x
sta $d900,x
lda $4528,x
sta $da00,x
lda $4628,x
sta $db00,x
inx
bne loaddccimage

lda #$3b
sta $d011
lda #$18
sta $d016
lda #$18
sta $d018

loop:
jmp loop

    org    $1FFE
INCBIN “dcc.PRG”
````
