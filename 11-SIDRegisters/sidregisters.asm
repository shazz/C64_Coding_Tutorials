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

	; read interrupt registers clear them
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
	sta $d019   ; Ack any raster interrupt

	inc $d020

    lda #$34    ; Disable I/O ($34 = %0110100) => 100 to disable  
    sta $01

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
    lda $c400,x ; pointer to our RAM temp space
    sta $d400,x ; poke real SID registers
    dex
    bpl restore_sid

    ; save oscillator 3 
    lda $d41b
    sta $c41b    

	dec $d020

    ; this is where we will insert our visualization routine!

	jmp $ea81	; Others can be ended with JMP $EA81, which simply goes to the end of the kernel handler.

; SID details
; | Addresses    : DRIVER = $1100-$11FF, INIT = $101C    |
; |              : LOAD   = $1000-$10C6, PLAY = $1000    |
; | SID Details  : Filter = Yes, Model = 8580            |

	org $1000-$7c-2
	INCBIN "A_Mind_Is_Born.sid"

