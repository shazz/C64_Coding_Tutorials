I noticed that a lot of people are creating graphical programs to the Commodore 64 again, so I decided to let you know of the tools I use, and how you can use them to create C-64 apps in Windows. I might write more articles on C-64 programming if there’s an interest for it. If you want more, let me know by writing a comment to this article

Note: You do not need to own a Commodore 64 to create programs. In this article, I’m going to use a cross assembler and an emulator.

Cross Assembler?
A cross assembler enables you to assemble the code on your computer, and then later transfer the code to a real C-64 or an emulator to run the program. In my opinion, this makes it a lot easier to create programs as the editors in Windows is a lot easier to use then the editors on the C-64.

The cross assembler I’m using is named DASM, and can be downloaded from here. Download this now, as this is the assembler we are going to use in this article.

Emulator?
Next you will need an emulator. The emulator will make it possible to run any Commodore 64 program on your PC. If you are creating a program for a C-64 using an emulator, remember to test the program on a real device as there might be some differences.

The emulator I use is named WinVICE, and you can get it from here. Download this now, as this is the emulator we are going to use in this article.

Set up the tools, and running them
Let’s see how the tools work. The assembler, DASM, is very simple to use. I usually add the DASM.exe to the environment variables, as well as the emulator x64.exe.

Programming your first C-64 program
The first thing you need when writing a program for the C-64 on Windows is a text editor. I use Visual Studio 2010 for this, but feel free to use whatever text-editor you want (Notepad, UltraEdit, …).

Create a new source code file names test.asm. You should now be in a blank test.asm file and be ready to type in some code.

We are going to write some code, then compile the code to a .prg file using DASM, and then run it using x64. There are many different assemblers for compiling C-64 programs (6502 microprocessor), and as they all got their differences I suggest you learn one and stick with it.

The first thing DASM needs is to know what processor we are going to target. The C-64 got a 6502 microprocessor, so this is the processor we want to target.

The first line of our program is:
    processor   6502
Next we need to tell the compiler where in the memory the program should start. We want to start it at the memory address $1000 (hex decimal). If you convert this to the decimal system, you get 4096.
    org    $1000
We want this program to change the background of the main window. If you take a look at the image above where the emulator is running, you can see that we got a light blue border, and a dark blue “main window” area. To do this, we need to change a value that represents the color in a specific memory location. The main window color is stored in the memory located at $d021, and the border color is located at $d020.

We are going to loop this process and change the screen color based on the number we have in $d021 before, and increase this by using a loop.

loop:    inc $d021
jmp loop

We start by creating a label in the code named “loop” followed by a colon. This will make it possible to jump to this location from other parts of our code. Next, we increase the number that already exist in $d021, and then we jump back to the line of code that is located after the loop label.

Your code should look something like this:

Listing 1.1 – Change color of the main area.
     processor   6502
org    $1000

loop:
     inc $d021
jmp loop

Building the code
Now, all that is left is to build our program and run it on the emulator.
Start cmd again again and browse to the folder your code is located. Assuming that you correctly added the location to DASM.exe in your Paths variable, you will be able to build a program from wherever you want in your system.

To build our program, write the following command into cmd.exe
”dasm test.asm –otest.prg”

Please note the spacing before the first two lines (processor and org), dasm requires this to compile.

Let’s run it in the emulator. Type the command x64 test.prg and hit [Enter]. Then  you will see the emulator starting, and loading the program TEST.PRG into the memory.

All that is left is to run the application from the emulator. To do this, type the command “SYS 4096” in the emulator….
….and hit ENTER.

The application should now be running, giving you a result that looks something like this:

The reason you had to type SYS 4096 in the emulator was because we specified that we want out application to start at that memory location.

Congratulations, you just made your first C-64 program!

Let’s change the color of the boarder instead of the main area. All you need to do is to change the value in  $d020 instead of $d021. Go and change this value, compile and load it in the emulator. Run it to see that we are now changing the main border instead of the main screen area.

An exercise for you is to change the color of both the boarder and the main area, so the result will be something like this:


