## 1 - Quickstart

I noticed that a lot of people are creating graphical programs to the Commodore 64 again, so I decided to let you know of the tools I use, and how you can use them to create C-64 apps on Linux. I might write more articles on C64 programming if there’s an interest for it. If you want more, let me know by writing a comment to this article

Note: You do not need to own a Commodore 64 to create programs. In this article, I’m going to use a cross assembler and an emulator.

### Cross Assembler?

A cross assembler enables you to assemble the code on your computer, and then later transfer the code to a real C64 or an emulator to run the program. In my opinion, this makes it a lot easier to create programs with modern editors is a lot easier to use then the editors on the C64.

The cross assemblers that we will be using are named `dasm` and `cc65`, they be downloaded and installed like that

#### dasm

````
sudo apt-get install -Y wget
wget https://github.com/dasm-assembler/dasm/releases/download/2.20.14/dasm-2.20.14-linux-x64.tar.gz
tar -xzf https://github.com/dasm-assembler/dasm/releases/download/2.20.14/dasm-2.20.14-linux-x64.tar.gz
sudo cp dasm /usr/local/
````

#### cc65

````
sudo apt-get install -Y build-essentials git 
git clone https://github.com/cc65/cc65.git
cd cc65
make
sudo cp bin/* /usr/local/bin/
````

Hope you did it, `dasm` is the assembler we are going to use in this first article.

### Emulator?

Next you will need an emulator. The emulator will make it possible to run any Commodore 64 program on your PC. If you are creating a program for a C-64 using an emulator, remember to test the program on a real device as there might be some differences.

The emulator I use is named `Vice`, and you can get it from here. Download and install this now, as this is the emulator we are going to use in this article.

````
sudo apt-get install vice
wget http://www.zimmers.net/anonftp/pub/cbm/crossplatform/emulators/VICE/vice-3.3.tar.gz
tar -zxvf vice-3.3.tar.gz
cd vice-3.3/data
sudo cp C64/chargen C64/kernal C64/basic /usr/lib/vice/C64
sudo cp DRIVES/d1541II DRIVES/d1571cr DRIVES/dos* /usr/lib/vice/DRIVES/
````

Set up the tools, and running them
Let’s see how the tools work. The assemblers, `dasm` or `cc65`, are very simple to use. 

### Programming your first C-64 program

The first thing you need when writing a program for the C64 on Linux is a text editor. Feel free to use whatever text-editor you want, I recommend Visual Code which is available for linux with syntax highligning as free extensions. You can download it from: https://code.visualstudio.com/download

Create a new source code file names `test.asm`. You should now be in a blank `test.asm` file and be ready to type in some code.

We are going to write some code, then compile the code to a .prg file using `dasm`, and then run it using `x64`. There are many different assemblers for compiling C64 programs (6502 microprocessor), and as they all got their differences I suggest you learn one and stick with it.

The first thing `dasm` needs is to know what processor we are going to target. The C64 got a 6510, close variant of the 6502 microprocessor, so this is the  latter we will target.

The first line of our program is:

````
    processor   6502
````

Next we need to tell the compiler where in the memory the program should start. We want to start it at the memory address `$1000` (hexadecimal). If you convert this to the decimal system, you get `4096`.

````
    org    $1000
````

We want this program to change the background of the main window. 

![C64 screen](https://github.com/shazz/C64_Coding_Tutorials/raw/master/1-Quickstart/docs/image6.png)

If you take a look at the image above where the emulator is running, you can see that we got a light blue border, and a dark blue “main window” area. To do this, we need to change a value that represents the color in a specific memory location. The main window color is stored in the memory located at `$d021`, and the border color is located at `$d020`.

We are going to loop this process and change the screen color based on the number we have in `$d021` before, and increase this by using a loop.

````
loop:    inc $d021
jmp loop
````

We start by creating a label in the code named `loop` followed by a colon. This will make it possible to jump to this location from other parts of our code. Next, we increase the number that already exist in `$d021`, and then we jump back to the line of code that is located after the loop label.

Your code should look something like this:

Listing 1.1 – Change color of the main area.

````
     processor   6502
org    $1000

loop: inc $d021
jmp loop
````

### Building the code

Now, all that is left is to build our program and run it on the emulator.
Start a terminal sessions (or within Visual Code) and browse to the folder your code is located, to build our program, write the following command:
`dasm test.asm –otest.prg`.

Normally, `dasm` shoud only says something like `Complete. (0)` and a file `test.prg` should be created.

Please note the spacing before the first two lines (processor and org), `dasm` requires this to assemble the source code.

Let’s run it in the emulator. Type the command x64 test.prg and hit [Enter]. Then you will see the emulator starting. Then go into the `File` menu and select `smart attach disk/tape ...` then select the program `test.prg` where it is located.

![C64 screen](https://github.com/shazz/C64_Coding_Tutorials/raw/master/1-Quickstart/docs/image10.png)

All that is left is to run the application from the emulator. To do this, type the command `SYS 4096` in the emulator….
….and hit [ENTER].

The application should now be running, giving you a result that looks something like this:

![C64 screen](https://github.com/shazz/C64_Coding_Tutorials/raw/master/1-Quickstart/docs/image11.png)

The reason you had to type `SYS 4096` in the emulator was because we specified that we want out application to start at that memory location.

Congratulations, you just made your first C64 program!

Let’s change the color of the border instead of the main area. All you need to do is to change the value in `$d020` instead of `$d021`. Go and change this value, compile and load it in the emulator. Run it to see that we are now changing the main border instead of the main screen area.

![C64 screen](https://github.com/shazz/C64_Coding_Tutorials/raw/master/1-Quickstart/docs/image12.png)

An exercise for you is to change the color of both the border and the main area, so the result will be something like this:

![C64 screen](https://github.com/shazz/C64_Coding_Tutorials/raw/master/1-Quickstart/docs/image13.png)

### Using makefiles and cc65

When we will build more complicated programs, including multiple source files, binary data (tables, images, music...) we will quickly need a better way to assemble our programs and the good old `Makefile` will help. So letś define a template for our future programs using `cc65`, condifurations and `Makefile`.

#### Create a default cc65 configuration

Create a file named `c64-asm.cfg` and add:
````
FEATURES {
    STARTADDRESS: default = $0801;
}
SYMBOLS {
    __LOADADDR__: type = import;
}
MEMORY {
    ZP:       file = "", start = $0002,  size = $00FE,      define = yes;
    LOADADDR: file = %O, start = %S - 2, size = $0002;
    MAIN:     file = %O, start = %S,     size = $A000 - %S;
}
SEGMENTS {
    ZEROPAGE: load = ZP,       type = zp,  optional = yes;
    LOADADDR: load = LOADADDR, type = ro;
    EXEHDR:   load = MAIN,     type = ro,  optional = yes;
    CODE:     load = MAIN,     type = rw;
    RODATA:   load = MAIN,     type = ro,  optional = yes;
    DATA:     load = MAIN,     type = rw,  optional = yes;
    BSS:      load = MAIN,     type = bss, optional = yes, define = yes;
}
````

#### Create the Makefile

````
CA65   = ca65
CL65   = cl65
LD65   = ld65

BINDIR = bin

DEMOS = $(BINDIR)/window.prg $(BINDIR)/border.prg

all: $(DEMOS) $(EXAMPLES)

$(BINDIR)/window.prg: window.s
	$(CL65) -t c64 -C c64-asm.cfg -u __EXEHDR__ $< -o $@

$(BINDIR)/border.prg: border.s
	$(CL65) -t c64 -C c64-asm.cfg -u __EXEHDR__ $< -o $@

clean:
	rm -f *.o
````

#### Converting our source files to cc65

`cc65` (or in fact its assembler `cl65`) uses a syntax which differs a little from `dasm` and have to use the `.s` extension.

 1. No need to define the processor and the origin, already set by the `c64-asm.cfg` config file and the Makefile options
 1. That's it!
 
So your 2 examples should look like:

window.s
````
; Set window color

loop:
	inc $d021
	jmp loop
````

border.s
````
; Set border color

loop:
	inc $d020
	jmp loop
````

Now time to test it! Just type in a terminal `make`, now your `prg` should be in thr `bin` directory! Test them using `vice`.
