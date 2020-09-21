	processor	6502
	org	$1000

loop:
	lda #$00	; a = 0
	sta $d020	; set border to black (0)
	clc			; clear carry
	adc #$08	; a=a+8
	sta $d021	; set window color to 8 (orange)
	jmp loop