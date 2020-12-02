	processor	6502
	org	$1000

	lda #$80		; a = $80 (128) to set sprite pointer to $2000, see next line
	sta $07f8		; set default area for sprite pointer 0 to 128*64 = 8192 ($2000) when our sprite data is located. *64 because each sprite is 64K
	
	lda #$01		; a = 1 (lda #%0000001)
	sta $d015		; set 1 to register enable sprite 1 (Bit #x: 1 = Sprite #x is enabled, drawn onto the screen.)
	
	lda #5			; a = 10
	sta $d000		; set Sprite #0 X-coordinate (only bits #0-#7) to a
	lda #$80
	sta $d001		; set Sprite #0 Y-coordinate to 128

loop:
	jmp loop

	org $2000		; set sprite data to $2000 (8192)
	incbin "sprite3.spr"