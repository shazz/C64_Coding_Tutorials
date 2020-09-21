	processor	6502
	org	$1000

	lda #$00	; a = 0
	sta $d020	; border = 0 (black)
	sta $d021	; window = 0 (black)
	tax			; x = a = 0
	lda #$20	; a = $20 (SPACE)

	; screen memory is 1000 bytes, starting at $0400
	; so how to quickly clear the screen, text mode, using SPACE characters ? ($20)

loop:
	sta $0400,x	; set 0 to start of screen memory+x
	sta $0500,x	; set 0 to start of screen memory+256+x
	sta $0600,x ; set 0 to start of screen memory+512+x
	sta $0700,x ; set 0 to start of screen memory+768+x
	dex			; x = x - 1 (so first become 0-1 = 255)
	bne loop	; loop