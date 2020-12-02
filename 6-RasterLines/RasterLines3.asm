; Open Top/Bottom Borders
; 
; Platform: C64
; Code: Jesder / 0xc64
; Site: http://www.0xc64.com
; Compiler: win2c64 (http://www.aartbik.com)
;

                        ; common register definitions

REG_INTSERVICE_LOW      .equ $0314              ; interrupt service routine low byte
REG_INTSERVICE_HIGH     .equ $0315              ; interrupt service routine high byte
REG_SCREENCTL_1         .equ $d011              ; screen control register #1
REG_RASTERLINE          .equ $d012              ; raster line position 
REG_INTFLAG             .equ $d019              ; interrupt flag register
REG_INTCONTROL          .equ $d01a              ; interrupt control register
REG_INTSTATUS_1         .equ $dc0d              ; interrupt control and status register #1
REG_INTSTATUS_2         .equ $dd0d              ; interrupt control and status register #2
REG_BORDER_COL          .equ $d020              ; border color
REG_WINDOW_COL          .equ $d021              ; window color

                
                        ; program start
                        processor	6502
                        org	$0801			; begin (2049)

                        .byte $0b, $08, $01, $00, $9e, $32, $30, $36
                        .byte $31, $00, $00, $00 ;= SYS 2061


                        lda #6
                        sta REG_BORDER_COL
                        ; register first interrupt

                        sei

                        lda #$7f                ; 0111 1111
                        sta REG_INTSTATUS_1     ; turn off the CIA interrupts
                        sta REG_INTSTATUS_2

                        ; lda #$1b                ; 0001 1011
                        ; sta REG_SCREENCTL_1
                        ; and REG_SCREENCTL_1     ; clear high bit of raster line
                        ; sta REG_SCREENCTL_1

                        ldy #30
                        sty REG_RASTERLINE

                        lda REG_SCREENCTL_1
                        ora #$80
                        sta REG_SCREENCTL_1

                        lda #<set_first_raster
                        ldx #>set_first_raster
                        sta REG_INTSERVICE_LOW
                        stx REG_INTSERVICE_HIGH

                        lda #$01                ; enable raster interrupts
                        sta REG_INTCONTROL
                        cli
        
forever                 
                        bne forever

set_first_raster        inc REG_INTFLAG

                        inc REG_BORDER_COL ; 6

                        repeat 22
                        nop                ; 2*rep
                        repend

                        dec REG_BORDER_COL ; 6

                        jmp $ea81           

