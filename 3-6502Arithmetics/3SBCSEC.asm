	processor	6502
	org	$1000

loop:
	lda #$08	; a=8 (orange)
	sta $d020	; set border to a=orange
	sec			; set carry
	sbc #$08	; a=a-8 = 0 (black)
	sta $d021	; set window to a=0
	jmp loop