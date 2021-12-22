;;;;
; Vectron VGA Plus Text Mode
;
; Nick Bild
; nick.bild@gmail.com
; December 2021
;
; Reserved memory:
;
; $0000-$7EFF - RAM
; 		$0000-$0003 - Named variables
; 		$0100-$01FF - 6502 stack
;		$7FF0-$7FFF - 16-bit Decoder
;			$7FF0 - Data input: Row
;			$7FF1 - Data input: Column
;			$7FF2 - Data input: Value
;			$7FF3 - Data output: Address 0-7
;			$7FF4 - Data output: Address 8-15
;			$7FF5 - Data output: Address 16-17
;			$7FF6 - Data output: Value
;			$7FF7 - Data output: WE/CE
; $8000-$FFFF - ROM
; 		$FFFA-$FFFB - NMI IRQ Vector
; 		$FFFC-$FFFD - Reset Vector - Stores start address of this ROM.
; 		$FFFE-$FFFF - IRQ Vector
;;;;

		processor 6502

		; Named variables in RAM.
		ORG $0000
addrLow
		.byte #$00
addrMid
		.byte #$00
addrHigh
		.byte #$00
data
		.byte #$00


StartExe	ORG $8000

	sei						; Disable interrupts.

	; Set Vectron VGA Plus memory counter to 0.
	lda #$00
	sta addrLow
	sta addrMid
	sta addrHigh

	; Set inital state of WE/CE on Vectron VGA Plus.
	lda #$03
	sta $7FF7				; WE/CE high
	
	; Write VGA signal timings for a blank screen to memory.
	jsr SetupVGA

	cli						; Enable interrupts.


; Do nothing.  Just wait for an interrupt signal.
MainLoop:
    jmp MainLoop


SetupVGA
	; Visible lines and vertical front porch.

	; 489 * visible line.
	ldy #$FF
SetupVGA1
	jsr DrawVisibleLine
	dey
	bne SetupVGA1

	ldy #$EA
SetupVGA2
	jsr DrawVisibleLine
	dey
	bne SetupVGA2

	; Vertical sync.
	jsr VSync

	; vertical back porch
	ldy #$21
SetupVGA3
	jsr DrawVisibleLine
	dey
	bne SetupVGA3
	
	rts


DrawVisibleLine
	.byte #$DA ; phx - mnemonic unknown to DASM.
	.byte #$5A ; phy

	; 328 * 24;  48 * 16;  24 * 24
	
	lda #$18		; 24
	sta data

	ldx #$FF
Visible1
	jsr WriteData
	dex
	bne Visible1

	ldx #$49
Visible2
	jsr WriteData
	dex
	bne Visible2

	lda #$10		; 16
	sta data

	ldx #$30
Visible3
	jsr WriteData
	dex
	bne Visible3

	lda #$18		; 24
	sta data

	ldx #$18
Visible4
	jsr WriteData
	dex
	bne Visible4
 
	.byte #$7A ; ply
	.byte #$FA ; plx

	rts


VSync
	.byte #$DA ; phx - mnemonic unknown to DASM.
	.byte #$5A ; phy

	; 320 * 24;  8 * 8;  48 * 0;  24 * 8
	
	lda #$18		; 24
	sta data

	ldx #$FF
VSync1
	jsr WriteData
	dex
	bne VSync1

	ldx #$41
VSync2
	jsr WriteData
	dex
	bne VSync2

	lda #$08		; 8
	sta data

	ldx #$08
VSync3
	jsr WriteData
	dex
	bne VSync3

	lda #$00		; 0
	sta data

	ldx #$30
VSync4
	jsr WriteData
	dex
	bne VSync4

	lda #$08		; 8
	sta data

	ldx #$18
VSync5
	jsr WriteData
	dex
	bne VSync5


	; 320 * 8;  8 * 8;  48 * 0;  24 * 8
	
	lda #$08		; 8
	sta data

	ldx #$FF
VSync6
	jsr WriteData
	dex
	bne VSync6

	ldx #$41
VSync7
	jsr WriteData
	dex
	bne VSync7

	lda #$08		; 8
	sta data

	ldx #$08
VSync8
	jsr WriteData
	dex
	bne VSync8

	lda #$00		; 0
	sta data

	ldx #$30
VSync9
	jsr WriteData
	dex
	bne VSync9

	lda #$08		; 8
	sta data

	ldx #$18
VSync10
	jsr WriteData
	dex
	bne VSync10


	; 320 * 8;  24 * 24;  48 * 16;  8 * 24
	
	lda #$08		; 8
	sta data

	ldx #$FF
VSync11
	jsr WriteData
	dex
	bne VSync11

	ldx #$41
VSync12
	jsr WriteData
	dex
	bne VSync12

	lda #$18		; 24
	sta data

	ldx #$18
VSync13
	jsr WriteData
	dex
	bne VSync13

	lda #$10		; 16
	sta data

	ldx #$30
VSync14
	jsr WriteData
	dex
	bne VSync14

	lda #$18		; 24
	sta data

	ldx #$08
VSync15
	jsr WriteData
	dex
	bne VSync15

	.byte #$7A ; ply
	.byte #$FA ; plx

	rts


IncAddress
	inc addrLow
	bne IncAddress1
	inc addrMid
	bne IncAddress1
	inc addrHigh

IncAddress1
	rts


WriteData
	; Set up the address and data output flip flops.
	lda addrLow
	sta $7FF3

	lda addrMid
	sta $7FF4

	lda addrHigh
	sta $7FF5

	lda data
	sta $7FF6

	; Latch data into Vectron VGA Plus memory.
	lda #$02
	sta $7FF7				; WE low
	lda #$00
	sta $7FF7				; WE/CE low
	
	lda #$02
	sta $7FF7				; WE low
	lda #$03
	sta $7FF7				; WE/CE high

	; Increment address counter.
	jsr IncAddress

	rts


DrawTextIsr	ORG $8500
	; lda $7FF0
    ; sta $7FF6

	; lda $7FF1
    ; sta $7FF6

	; lda $7FF2
    ; sta $7FF6

	rti
