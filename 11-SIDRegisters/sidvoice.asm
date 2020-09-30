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
    lda counter
    cmp #120
    beq play_note
    cmp #240
    beq stop_note

    jmp loop

play_note:
    jsr note_on
    jmp loop

stop_note:
    jsr note_off
	jmp loop

irq:
	inc $d020

	lda #$01
	sta $d019   ; Ack any raster interrupt
    inc counter ; increment frame counter

    ; save oscillator voice 3
    lda $d41b
    sta $c400 

	dec $d020

	jmp $ea81	; Others can be ended with JMP $EA81, which simply goes to the end of the kernel handler.

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
