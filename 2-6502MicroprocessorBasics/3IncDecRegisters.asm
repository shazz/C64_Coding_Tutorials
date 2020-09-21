	processor	6502
	org	$1000

loop:
	ldy #$03	; y = 3 (cyan)
	sty $d020	; border = y
	iny			; y = 4 (purple)
	sty $d021	; window = y
	jmp loop