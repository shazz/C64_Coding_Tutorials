	processor	6502
	org	$1000

loop:
	lda #$03  ; acc 3 (cyan)
	sta $d021 ; set window color to a=3
	sta $d020 ; set border color to a=3
	jmp loop  ; loop