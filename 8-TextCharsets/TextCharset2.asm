	processor	6502
	org	$1000

	jsr $e544		; ROM routine to clear the screen Clear screen.Input: – Output: – Used registers: A, X, Y.

	lda #$0			; a = $0
	sta $d020		; set border color to black
	sta $d021		; set window color to black

	lda #$18		; a = $18 = 0001 100 0
	sta $d018		; set Memory setup register to char memory 4 (3 bits $2000-$27FF,) screen memory to 1 ($0400-$07FF)
	ldx #$00		; x = 0

write:
	lda msg,x		; a = charAt(msg)
	jsr $ffd2		; KERNAL function to write to output:
					; CHROUT. Write byte to default output.
					; (If not screen, must call OPEN and CHKOUT beforehands.)
					; Input: A = Byte to write.
					; Output: –
					; Used registers: –
					; Real address: ($0326), $F1CA.
	inx				; x++
	cpx #40			; loop if x != 40 (msg length)
	bne write
	ldx #$00		; reset x

setcolor:
	lda #$05		; a = 5  => color for font is green
	sta $d800,x		; colorRAM(x) = 5
	inx				; x++
	cpx #$40		; do it 40 times
	bne setcolor

loop:
	jmp loop

msg: .byte "WELCOME TO THE MATRIX - THE 8BITS MATRIX"

	org	$1ffe	; $2000 - 2 header bytes
	INCBIN	"aeg_collection_12.64c"