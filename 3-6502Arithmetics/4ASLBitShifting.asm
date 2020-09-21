	processor	6502
	org	$1000

loop:
	lda #$00	; a = 0
	sta $d020	; border = 0 (black)
	clc			; clear carry
	adc #$04	; a=a+4
	sta $d021	; set window to purple (4)
	asl $d021	; window = window << 1 = 8 (orange)
	jmp loop	; per block the window should change from orange to purple