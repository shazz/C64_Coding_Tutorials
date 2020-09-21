	processor	6502
	org	$1000

	jsr $e544		; ROM routine to clear the screen Clear screen.Input: – Output: – Used registers: A, X, Y.

	lda #$0d		; a = $0d (light green)
	sta $d020		; set border color to light green

	lda #$05		; a = 5 (green)
	sta $d021		; set window color to green

	lda #$18		; a = $18 = 0001 100 0
	sta $d018		; set Memory setup register to char memory 4 (3 bits $2000-$27FF,) screen memory to 1 ($0400-$07FF)
	ldx #$00		; x = 0

write:
	lda    msg,x	; a = charAt(msg)
	jsr    $ffd2	; KERNAL function to write to output:
					; CHROUT. Write byte to default output.
					; (If not screen, must call OPEN and CHKOUT beforehands.)
					; Input: A = Byte to write.
					; Output: –
					; Used registers: –
					; Real address: ($0326), $F1CA.
	inx				; x++
	cpx    #54		; loop if x != 54 (msg length)
	bne    write
	ldx #$00		; reset x

setcolor:
	lda #$07		; a = 7 (%0000 0111) => color for font is yellow
	sta $d800,x		; colorRAM(x) = 7
	inx				; x++
	cpx #$54		; do it 54 times
	bne setcolor

loop:
	jmp loop

msg: .byte "C64 programming tutorial by digitalerr0r of Dark Codex"

	org	$1ffe	; $2000 - 2 header bytes
	INCBIN	"scrap_writer_iii_17.64c"