	processor	6502
	org	$1000

loop:
	ldy #$00	; y = 0 (black)
	sty $d020	; set border to black
	iny			; y = y + 8
	iny
	iny
	iny
	iny
	iny
	iny
	iny
	sty $d021	; set window color to 8 (orange)
	jmp loop