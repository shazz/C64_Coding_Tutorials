	processor	6502
	org	$1000

	lda $4710	; a = $4710 background data from Thimandes
	sta $d020	; set border color to background data
	sta $d021	; set window color to background data
	ldx #$00	; x = 0

	; Thimandes settings
	; bitmap:     $2000 =>
	; charmem:    $3F40
	; colormem:   $4328
	; background: $4710

	; screen memory is 1000 bytes, starting at $0400

loaddccimage:
	lda $3f40,x	; load charmem+x to a
	sta $0400,x	; store to start of screen memory + x
	lda $4040,x	; copy charmem + x + 256 to  screen memory + x + 256
	sta $0500,x
	lda $4140,x ; copy charmem + x + 512 to  screen memory + x + 512
	sta $0600,x
	lda $4240,x ; copy charmem + x + 768 to  screen memory + x + 768
	sta $0700,x

	lda $4328,x ; copy colormem + x to $d800 Color RAM (1000 bytes, only bits #0-#3).
	sta $d800,x
	lda $4428,x ; copy colormem + x + 256 to color ram + x + 256
	sta $d900,x
	lda $4528,x ; copy colormem + x + 512 to color ram + x + 512
	sta $da00,x
	lda $4628,x ; copy colormem + x + 768 to color ram + x + 768
	sta $db00,x

	inx
	bne loaddccimage

	lda #$3b	; a = $3b = 0011 1011
	sta $d011	; set screen control register 1 to bitmap mode (bit 5=1 for bitmap) (Remember Default: $1B, %0001 1011)
	lda #$18	; a = $18 = 0001 1000
	sta $d016	; set screen control register 2 to multicolor mode (bit 4=1) (Default: $C8, %1100 1000)
	lda #$18	; a = $18 = 0001 100 0
	sta $d018	; set Memory setup register to char memory 4 (3 bits $2000-$27FF,) screen memory to 1 ($0400-$07FF)

loop:
	jmp loop

	org    $1FFE; $2000 - 2bytes PRG header
	INCBIN "dcc.PRG"

; Screen, Character memory and Bitmap adresses
; These are controlled by $D018.
; Bitmap

; $D018 = %xxxx0xxx -> bitmap is at $0000
; $D018 = %xxxx1xxx -> bitmap is at $2000

; Character memory

; $D018 = %xxxx000x -> charmem is at $0000
; $D018 = %xxxx001x -> charmem is at $0800
; $D018 = %xxxx010x -> charmem is at $1000
; $D018 = %xxxx011x -> charmem is at $1800
; $D018 = %xxxx100x -> charmem is at $2000
; $D018 = %xxxx101x -> charmem is at $2800
; $D018 = %xxxx110x -> charmem is at $3000
; $D018 = %xxxx111x -> charmem is at $3800

; Screen memory

; $D018 = %0000xxxx -> screenmem is at $0000
; $D018 = %0001xxxx -> screenmem is at $0400
; $D018 = %0010xxxx -> screenmem is at $0800
; $D018 = %0011xxxx -> screenmem is at $0c00
; $D018 = %0100xxxx -> screenmem is at $1000
; $D018 = %0101xxxx -> screenmem is at $1400
; $D018 = %0110xxxx -> screenmem is at $1800
; $D018 = %0111xxxx -> screenmem is at $1c00
; $D018 = %1000xxxx -> screenmem is at $2000
; $D018 = %1001xxxx -> screenmem is at $2400
; $D018 = %1010xxxx -> screenmem is at $2800
; $D018 = %1011xxxx -> screenmem is at $2c00
; $D018 = %1100xxxx -> screenmem is at $3000
; $D018 = %1101xxxx -> screenmem is at $3400
; $D018 = %1110xxxx -> screenmem is at $3800
; $D018 = %1111xxxx -> screenmem is at $3c00