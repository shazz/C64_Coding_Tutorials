	processor	6502
	org	$1000

loop:
	lda $d012	; a = Read: Current raster line (bits #0-#7).
	cmp #100	; if line is 100, change the color, happens only one time per frame.
				; if raster line = 255, that's outside the visible area, no middle flipping
	bne loop
	inc $d021	; then window color++
	inc $d020	; then border color++
	jmp loop	; loop