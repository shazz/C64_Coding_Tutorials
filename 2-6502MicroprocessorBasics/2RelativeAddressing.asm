	processor	6502
	org	$1000

loop:
	ldx #$20		; x = $20
	lda #$03		; a = 3 (cyan)
	sta $d000,X		; $d000+$20 = $d020 (border) = a
	sta $d001,X		; $d001+$20 = $d021 (window) = a
	jmp loop
