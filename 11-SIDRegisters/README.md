# 11 - SID Registers

- [11 - SID Registers](#11---sid-registers)
  - [Let's take a quick look at the SID Memory Map](#lets-take-a-quick-look-at-the-sid-memory-map)
  - [Let's pmake some sound!](#lets-pmake-some-sound)
  - [What about a simple audio analyzer?](#what-about-a-simple-audio-analyzer)
  - [Adding some cool music](#adding-some-cool-music)
  - [Let's sync to the music!](#lets-sync-to-the-music)

## Let's take a quick look at the SID Memory Map

I extracted the registers list from one of my prefered source: http://unusedino.de/ec64/technical/aay/c64/sidmain.htm

````
Address                 Read/Write  Description
$D400/54272/SID+0       WO          Voice 1: Frequency Control - Low-Byte
$D401/54273/SID+1       WO          Voice 1: Frequency Control - High-Byte
$D402/54274/SID+2       WO          Voice 1: Pulse Waveform Width - Low-Byte
$D403/54275/SID+3       WO          Voice 1: Pulse Waveform Width - High-Nybble
$D404/54276/SID+4       WO          Voice 1: Control Register
$D405/54277/SID+5       WO          Voice 1: Attack / Decay Cycle Control
$D406/54278/SID+6       WO          Voice 1: Sustain / Release Cycle Control
$D407/54279/SID+7       WO          Voice 2: Frequency Control - Low-Byte
$D408/54280/SID+8       WO          Voice 2: Frequency Control - High-Byte
$D409/54281/SID+9       WO          Voice 2: Pulse Waveform Width - Low-Byte
$D40A/54282/SID+10      WO          Voice 2: Pulse Waveform Width - High-Nybble
$D40B/54283/SID+11      WO          Voice 2: Control Register
$D40C/54284/SID+12      WO          Voice 2: Attack / Decay Cycle Control
$D40D/54285/SID+13      WO          Voice 2: Sustain / Release Cycle Control
$D40E/54286/SID+14      WO          Voice 3: Frequency Control - Low-Byte
$D40F/54287/SID+15      WO          Voice 3: Frequency Control - High-Byte
$D410/54288/SID+16      WO          Voice 3: Pulse Waveform Width - Low-Byte
$D411/54289/SID+17      WO          Voice 3: Pulse Waveform Width - High-Nybble
$D412/54290/SID+18      WO          Voice 3: Control Register
$D413/54291/SID+19      WO          Voice 3: Attack / Decay Cycle Control
$D414/54292/SID+20      WO          Voice 3: Sustain / Release Cycle Control
$D415/54293/SID+21      WO          Filter Cutoff Frequency: Low-Nybble
$D416/54294/SID+22      WO          Filter Cutoff Frequency: High-Byte
$D417/54295/SID+23      WO          Filter Resonance Control / Voice Input Control
$D418/54296/SID+24      WO          Select Filter Mode and Volume
$D419/54297/SID+25      RO          Analog/Digital Converter: Game Paddle 1
$D41A/54298/SID+26      RO          Analog/Digital Converter: Game Paddle 2
$D41B/54299/SID+27      RO          Oscillator 3 Output
$D41C/54300/SID+28      RO          Envelope Generator 3 Output
````

Without going in the details of the registers, we can quickly see some interesting thimgs:
- We have 3 voices
- For each voice, some controls of the ADSR envelop (Attack, Decay, Sustain, Release), frequency,... 
- A filter with some controls
- 2 outputs: voice 3 oscillator and envelope generator which are the only ones we can read (if we forget the paddle registers)

## Let's pmake some sound!

To understand a little bit more some of those registers, let's make a small program to play a sound. We'll use the 3rd voice because it may help for the next section. But feel free to try with voice 0 or 1.

The most important concept to understand to start from my point of view: the gate (aka bit 0 of the 3 control registers). The gate is as the name says, the gate between the Delay and the Sustain steps of the note.

![ASDR](ADSR_Envelope_Graph.png)

Or basically, if you consider the C64 as a piano to get a concrete example, the gate is the moment you remove your finder from a key.
So in our little application, we'll set up a counter (using IRQ based on rasterline) to mimic this behavior:
- at a given counter value, we'll push the key: clear the gate and set the voice registers
- at another and latter counter value, we´ll release the key: set the gate so that the Sustain step can start.

Here is a table which is really helpful, the conversion table between hi/lo bytes values for frequencies and musical notes:
https://sta.c64.org/cbm64sndfreq.html

Here is the code:
````
	processor	6502
	org	$0810

	; set interrupts registers
	sei			; disable  interrupt

	lda #$7f	; a = $7f = %0111 1111
	sta $dc0d	; Set Interrupt control to enable all timers interrupts
	sta $dd0d	; Set Interrupt control to enable all timers interrupts

	lda #$01	; a = 1
	sta $d01a	; set Interrupt control register to enable raster interrupts only

	; set screen
	lda #$1b	; a = $1b = 0001 1011
	ldx #$08	; x = $8 = 0000 1000
	ldy #$14	; y = $14 = 0001 010 0

	sta $d011	; Screen control register #1 = a => in text mode
	stx $d016	; Screen control register #2 = x => 40 columns mode
	sty $d018	; Set memory setup register to charmem at 1000-$17FF and screen ram to $0400-$07FF

	lda #<irq	; Set IRQ address low byte in a
	ldx #>irq	; Set IRQ address high byte in x
	ldy #$7e	; y = $7e = 126
	sta $0314	; set Execution address   of interrupt service routine to low byte irq address
	stx $0315	; set Execution address+1 of interrupt service routine to high byte irq address
	sty $d012	; set Raster line to generate interrupt at raster line 126

	; read interrupt registes clear them
	lda $dc0d	; read interrupt control register 1 in a
	lda $dd0d	; read interrupt control register 2 in a
	asl $d019	; Ack raster interrupt

	cli			; enable interrupts

loop:
    lda counter     ; let's  skip 120 frames, about 2 seconds between press and release
    cmp #120
    beq play_note   ; press  
    cmp #240
    beq stop_note   ; release

    jmp loop

play_note:
    jsr note_on     ; call a sub routine to set the SID registers
    jmp loop

stop_note:
    jsr note_off    ; call a sub routine to set the gate
	jmp loop

irq:
	inc $d020

	lda #$01
	sta $d019       ; Ack any raster interrupt
    inc counter     ; increment frame counter

    ; save oscillator voice 3, forget it now, useful in the next chapter!
    lda $d41b
    sta $c400 

	dec $d020

	jmp $ea81	    ; Others can be ended with JMP $EA81, which simply goes to the end of the kernel handler.

note_on:

    ; reset gate
    lda #%00000000    
    sta $d412

    ; set a A-2 (LA, 2th octave), $0747
    lda $47
    sta $d40e
    lda $07
    sta $d40f

    ; set pulse wave duty
    lda #0
    sta $d410
    sta $d411

    ; set control: triangle wave + gate
    lda #%00010001
    sta $d412

    ; set attack(15) / decay(8)
    lda $f8
    sta $d413

    ; set sustain(8) / release(8)
    lda $88
    sta $d414

    ; Set filtermode: no filter, max volume 
    lda $%00001111
    sta $d418

    rts

note_off:

    ; set control: triangle wave + gate off
    lda #%00010000
    sta $d412

    rts

counter: .byte 00
````


## What about a simple audio analyzer?

As a little exercise, would be great to add some kind of visualization in sync with the music isn't it?
But we don't have access to the SID registers as they are write only, except the upper 8 output bits of Oscillator 3.

Hum... so are we stuck ? Will we have to disassemble the SID Player and modify it?
We could but we can be smarter or at least sneaker. Let's be the man in the middle between the music player routine and the SID chip. How to do that? Don't you remember the previous tutorial where we replayed Cybernoid II?

If you check the code, in order to access the player routine located "behind" the BASIC ROM, we had to disable it using the `$1 Processor Port Register`. If you check again this register, you'll notice something interesting:

````
Bits #0-#2: Configuration for memory areas $A000-$BFFF, $D000-$DFFF and $E000-$FFFF. Values:
%x00: RAM visible in all three areas.

    %x01: RAM visible at $A000-$BFFF and $E000-$FFFF.
    %x10: RAM visible at $A000-$BFFF; KERNAL ROM visible at $E000-$FFFF.
    %x11: BASIC ROM visible at $A000-$BFFF; KERNAL ROM visible at $E000-$FFFF.
    %0xx: Character ROM visible at $D000-$DFFF. (Except for the value %000, see above.)
    %1xx: I/O area visible at $D000-$DFFF. (Except for the value %100, see above.)
...
````

Yes! As we disabled for a few cycles the BASIC ROM, we can also disable temporarly the I/O area where the SID Registers are! (`$D400`-`$D41C`) by setting `%100` to the first 3 bits of this register!

So what we will have to do in our `IRQ`:
 1. Disable the I/O area
 2. Call the SID player as usual which will think to write the SID registers
 3. Copy the SID registers to some temporary RAM location (outside the I/O area)
 4. Enable the I/O area
 5. Copy the saved SID registers to the SID Registers
 6. Plot something nice using the saved registers

## Adding some cool music

This is time to implement this idea and see if it works and doesn't slow down too much our code (by doing 2 copies). Let's use one of my prefered SID tune, "A Mind Is Born" from lft (SID 8580 prefered). Here is the PSID data:

````
+------------------------------------------------------+
|   SIDPLAY - Music Player and C64 SID Chip Emulator   |
|          Sidplay V2.0.9, Libsidplay V2.1.1           |
+------------------------------------------------------+
| Title        : A Mind Is Born                        |
| Author       : Linus Akesson                         |
| Released     : 2017                                  |
+------------------------------------------------------+
| File format  : PlaySID one-file format (PSID)        |Cybernoid_II
| Filename(s)  : A_Mind_Is_Born.sid                    |
| Condition    : No errors                             |
| Playlist     : 1/1 (tune 1/1[1])                     |
| Song Speed   : CIA (PAL)                             |
| Song Length  : UNKNOWN                               |
+------------------------------------------------------+
| Addresses    : DRIVER = $1100-$11FF, INIT = $101C    |
|              : LOAD   = $1000-$10C6, PLAY = $1000    |
| SID Details  : Filter = Yes, Model = 8580            |
| Environment  : Real C64                              |
+------------------------------------------------------+
````

Nothind different from what we learned before:
 1. Init the PSID (`$101C`), no need to disable the KERNAL or the BASIC ROM
 2. Setup the IRQ and call the routine (`$1000`)

````
	processor	6502
	org	$0810

	; set interrupts registers
	sei			; disable  interrupt

	; lda #<irq	; Set IRQ address low byte in a
	; ldx #>irq	; Set IRQ address high byte in x
	; sta $0314	; set Execution address   of interrupt service routine to low byte irq address
	; stx $0315	; set Execution address+1 of interrupt service routine to high byte irq address

	; lda #$7f	; a = $7f = %0111 1111
	; sta $dc0d	; Set Interrupt control to enable all timers interrupts
	; ; sta $dd0d	; Set Interrupt control to enable all timers interrupts

	; lda #$1b	; a = $1b = 0001 1011
	; sta $d01b
	; lda #$01	; a = 1
	; sta $d01a	; set Interrupt control register to enable raster interrupts only

	lda #$7f	; a = $7f = %0111 1111
	sta $dc0d	; Set Interrupt control to enable all timers interrupts
	sta $dd0d	; Set Interrupt control to enable all timers interrupts

	lda #$01	; a = 1
	sta $d01a	; set Interrupt control register to enable raster interrupts only

	; set screen
	lda #$1b	; a = $1b = 0001 1011
	ldx #$08	; x = $8 = 0000 1000
	ldy #$14	; y = $14 = 0001 010 0,  $24 = 0010 010 0

	sta $d011	; Screen control register #1 = a => in text mode
	stx $d016	; Screen control register #2 = x => 40 columns mode
	sty $d018	; Set memory setup register to charmem at 1000-$17FF and screen ram to $0400-$07FF => bad as driver is in $0400?

	lda #<irq	; Set IRQ address low byte in a
	ldx #>irq	; Set IRQ address high byte in x
	ldy #$7e	; y = $7e
	sta $0314	; set Execution address   of interrupt service routine to low byte irq address
	stx $0315	; set Execution address+1 of interrupt service routine to high byte irq address
	sty $d012	; set Raster line to generate interrupt at raster line $7e = 126

	; read interrupt registes clear them
	lda $dc0d	; read interrupt control register 1 in a
	lda $dd0d	; read interrupt control register 2 in a
	asl $d019	; Ack raster interrupt

	; init player
	jsr $101C	; jump to SID player init

	cli			; enable interrupts
loop:
	jmp loop

irq:
	lda #$01
	sta $d019
	; asl $d019	; Ack any raster interrupt

	inc $d020
	jsr $1000	; call SID player
	dec $d020

	jmp $ea81	; Others can be ended with JMP $EA81, which simply goes to the end of the kernel handler.

; SID details
; | Addresses    : DRIVER = $1100-$11FF, INIT = $101C    |
; |              : LOAD   = $1000-$10C6, PLAY = $1000    |
; | SID Details  : Filter = Yes, Model = 8580            |

	org $1000-$7c-2
	INCBIN "A_Mind_Is_Born.sid"

````

Let's now modify the IRQ routine to steal the SID registers values:

````
irq:
	lda #$01
	sta $d019   ; ack the interrupts

    lda #$34    ; Disable I/O ($34 = %0110100) => 100 to disable  
    sta $01

	inc $d020   ; show raster time (start) 
	jsr $1000	; call SID player

    ldx #$18    ; let's copy the 24 SID registers somewhere
save_sid:
    lda $d400,x ; pointer to the RAM area hidden by the SID registers "normally"
    sta $c400,x ; temp space in RAM, nothing here
    dex
    bpl save_sid

	lda #$37 	; Enable the I/O area
    sta $01

    ldx #$18    ; let's restore the 24 SID registers
restore_sid:
    lda $c400,x ; pointer to our temp storage
    sta $d400,x ; real SID registers
    dex
    bpl restore_sid

    dec $d020   ; show raster time (end)

    ; this where we will insert our visualization routine!

	jmp $ea81	; Others can be ended with JMP $EA81, which simply goes to the end of the kernel handler.
````

Ok, the hijacking of the SID registers is in place, let's check it still works!

## Let's sync to the music!

What do we have now to sync a little graphical effect with the music?
 - A copy of the SID registers (inputs)
 - The voice 3 upper 8 bits output

Let's take a look at lft's tune: https://deepsid.chordian.net/?file=/MUSICIANS/L/Lft/A_Mind_is_Born.sid

As you can see the ramping bass line is on voice 3 while the generated melody on voice 2 and the rythm on voice 1.
 