	processor	6502
	org	$1000

loop:
	lda $d012	; a = Read: Current raster line (bits #0-#7).
	cmp #251	; if line is between 50 and 251, change the color, happens only one time per frame.
				; if raster line = 255, that's outside the visible area, no middle flipping
	bne loop
	inc $d021	; then window color++
	; inc $d020	; then border color++
	jmp loop	; loop

;  RSEL|  Display window height   | First line  | Last line
;  ----+--------------------------+-------------+----------
;    0 | 24 text lines/192 pixels |   55 ($37)  | 246 ($f6)
;    1 | 25 text lines/200 pixels |   51 ($33)  | 250 ($fa)

;  CSEL|   Display window width   | First X coo. | Last X coo.
;  ----+--------------------------+--------------+------------
;    0 | 38 characters/304 pixels |   31 ($1f)   |  334 ($14e)
;    1 | 40 characters/320 pixels |   24 ($18)   |  343 ($157)