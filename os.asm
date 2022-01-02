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
; 		$0000-$000A - Named variables
; 		$0100-$01FF - 6502 stack
;		$7FF0-$7FFF - 16-bit Decoder
;			$7FF0 - Data input: Row
;			$7FF1 - Data input: Column
;			$7FF2 - Data input: RAM Value
;			$7FF3 - Data output: Address 0-7
;			$7FF4 - Data output: Address 8-15
;			$7FF5 - Data output: Address 16-17
;			$7FF6 - Data output: RAM Value
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

num1Low
		.byte #$00
num1Mid
		.byte #$00
num1High
		.byte #$00
num2Low
		.byte #$00
num2Mid
		.byte #$00
num2High
		.byte #$00
resultLow
		.byte #$00
resultMid
		.byte #$00
resultHigh
		.byte #$00

charCode
		.byte #$00

bit0
		.byte #$00
bit1
		.byte #$00
bit2
		.byte #$00
bit3
		.byte #$00
bit4
		.byte #$00
bit5
		.byte #$00
bit6
		.byte #$00
bit7
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


Add24BitNumbers
	clc
	lda num1Low
	adc num2Low
	sta num1Low
	
	lda num1Mid
	adc num2Mid
	sta num1Mid

	lda num1High
	adc num2High
	sta num1High

	rts


NextAddressRow
	; Add 392 to address.
	clc
	lda addrLow
	adc #$88
	sta addrLow
	
	lda addrMid
	adc #$01
	sta addrMid

	lda addrHigh
	adc #$00
	sta addrHigh

	rts


DrawOneCharacterLine
	; Bit 0
	lda #$01
	bit charCode
	bne DrawOneCharacterLine1 	; Branch if bit set to '1'
	lda #$18
	jmp DrawOneCharacterLine2
DrawOneCharacterLine1
	lda #$1F
DrawOneCharacterLine2
	sta data
	sta bit0					; Precalculate for duplicate row to follow.
	jsr WriteData

	; Bit 1
	lda #$02
	bit charCode
	bne DrawOneCharacterLine3 	; Branch if bit set to '1'
	lda #$18
	jmp DrawOneCharacterLine4
DrawOneCharacterLine3
	lda #$1F
DrawOneCharacterLine4
	sta data
	sta bit1					; Precalculate for duplicate row to follow.
	jsr WriteData

	; Bit 2
	lda #$04
	bit charCode
	bne DrawOneCharacterLine5 	; Branch if bit set to '1'
	lda #$18
	jmp DrawOneCharacterLine6
DrawOneCharacterLine5
	lda #$1F
DrawOneCharacterLine6
	sta data
	sta bit2					; Precalculate for duplicate row to follow.
	jsr WriteData

	; Bit 3
	lda #$08
	bit charCode
	bne DrawOneCharacterLine7 	; Branch if bit set to '1'
	lda #$18
	jmp DrawOneCharacterLine8
DrawOneCharacterLine7
	lda #$1F
DrawOneCharacterLine8
	sta data
	sta bit3					; Precalculate for duplicate row to follow.
	jsr WriteData

	; Bit 4
	lda #$10
	bit charCode
	bne DrawOneCharacterLine9 	; Branch if bit set to '1'
	lda #$18
	jmp DrawOneCharacterLine10
DrawOneCharacterLine9
	lda #$1F
DrawOneCharacterLine10
	sta data
	sta bit4					; Precalculate for duplicate row to follow.
	jsr WriteData

	; Bit 5
	lda #$20
	bit charCode
	bne DrawOneCharacterLine11 	; Branch if bit set to '1'
	lda #$18
	jmp DrawOneCharacterLine12
DrawOneCharacterLine11
	lda #$1F
DrawOneCharacterLine12
	sta data
	sta bit5					; Precalculate for duplicate row to follow.
	jsr WriteData

	; Bit 6
	lda #$40
	bit charCode
	bne DrawOneCharacterLine13 	; Branch if bit set to '1'
	lda #$18
	jmp DrawOneCharacterLine14
DrawOneCharacterLine13
	lda #$1F
DrawOneCharacterLine14
	sta data
	sta bit6					; Precalculate for duplicate row to follow.
	jsr WriteData

	; Bit 7
	lda #$80
	bit charCode
	bne DrawOneCharacterLine15 	; Branch if bit set to '1'
	lda #$18
	jmp DrawOneCharacterLine16
DrawOneCharacterLine15
	lda #$1F
DrawOneCharacterLine16
	sta data
	sta bit7					; Precalculate for duplicate row to follow.
	jsr WriteData

	rts


DrawDuplicateCharacterLine
	lda bit0
	sta data
	jsr WriteData

	lda bit1
	sta data
	jsr WriteData

	lda bit2
	sta data
	jsr WriteData

	lda bit3
	sta data
	jsr WriteData

	lda bit4
	sta data
	jsr WriteData

	lda bit5
	sta data
	jsr WriteData

	lda bit6
	sta data
	jsr WriteData

	lda bit7
	sta data
	jsr WriteData

	rts


DrawCharacterLines
	.byte #$DA ; phx - mnemonic unknown to DASM.

	; Get offset to first byte (horizontal line) of character in ROM, then retrieve character code.
	ldx $7FF2
	lda $9500,x
	sta charCode

	jsr DrawOneCharacterLine
	jsr NextAddressRow
	
	jsr DrawDuplicateCharacterLine
	jsr NextAddressRow

	; Line 2
	ldx $7FF2
	lda $9600,x
	sta charCode

	jsr DrawOneCharacterLine
	jsr NextAddressRow

	jsr DrawDuplicateCharacterLine
	jsr NextAddressRow

	; Line 3
	ldx $7FF2
	lda $9700,x
	sta charCode

	jsr DrawOneCharacterLine
	jsr NextAddressRow

	jsr DrawDuplicateCharacterLine
	jsr NextAddressRow

	; Line 4
	ldx $7FF2
	lda $9800,x
	sta charCode

	jsr DrawOneCharacterLine
	jsr NextAddressRow

	jsr DrawDuplicateCharacterLine
	jsr NextAddressRow

	; Line 5
	ldx $7FF2
	lda $9900,x
	sta charCode

	jsr DrawOneCharacterLine
	jsr NextAddressRow

	jsr DrawDuplicateCharacterLine
	jsr NextAddressRow

	; Line 6
	ldx $7FF2
	lda $9A00,x
	sta charCode

	jsr DrawOneCharacterLine
	jsr NextAddressRow

	jsr DrawDuplicateCharacterLine
	jsr NextAddressRow

	; Line 7
	ldx $7FF2
	lda $9B00,x
	sta charCode

	jsr DrawOneCharacterLine
	jsr NextAddressRow

	jsr DrawDuplicateCharacterLine
	jsr NextAddressRow

	; Line 8
	ldx $7FF2
	lda $9C00,x
	sta charCode

	jsr DrawOneCharacterLine
	jsr NextAddressRow

	jsr DrawDuplicateCharacterLine
	
	.byte #$FA ; plx

	rts


DrawTextIsr	ORG $8500
	lda #$03
	sta $7FF7				; WE/CE high
	
	; Convert row and column into starting memory address.
	; ((row * 16) * 400) + (col * 8)

	; Zero the numbers to add.
	lda #$00
	sta num1Low
	sta num1Mid
	sta num1High
	sta num2Low
	sta num2Mid
	sta num2High

	; Load row value to memory, multiply by 16.
	lda $7FF0
	sta num2Low
	
	ldx #$10
DrawTextIsr1
	jsr Add24BitNumbers
	dex
	bne DrawTextIsr1

	; Multiply the above value by 400.
	lda num1Low
	sta num2Low
	lda num1Mid
	sta num2Mid
	lda num1High
	sta num2High

	lda #$00
	sta num1Low
	sta num1Mid
	sta num1High

	ldx #$FF
DrawTextIsr2
	jsr Add24BitNumbers
	dex
	bne DrawTextIsr2

	ldx #$91
DrawTextIsr3
	jsr Add24BitNumbers
	dex
	bne DrawTextIsr3

	; Save result thus far.
	lda num1Low
	sta resultLow
	lda num1Mid
	sta resultMid
	lda num1High
	sta resultHigh

	; Add the column value to memory.
	
	; Zero the numbers to add.
	lda #$00
	sta num1Low
	sta num1Mid
	sta num1High
	sta num2Low
	sta num2Mid
	sta num2High
	
	; Load the column value into memory.
	lda $7FF1
	sta num2Low

	; Multiply column value by 8.
	ldx #$08
DrawTextIsr4
	jsr Add24BitNumbers
	dex
	bne DrawTextIsr4

	; Add column offset to previously saved value.
	lda resultLow
	sta num2Low
	lda resultMid
	sta num2Mid
	lda resultHigh
	sta num2High

	jsr Add24BitNumbers	; After this point, the starting address is stored in num1...

	lda num1Low
	sta addrLow
	lda num1Mid
	sta addrMid
	lda num1High
	sta addrHigh
	
	; Now draw the character at this position.
	jsr DrawCharacterLines

	lda #$01
	sta $7FF7				; CE low (read mode)
	
	rti


;;;;
; Character Definitions
;;;;

CharacterLines1	ORG $9500
	.byte #$AA
	.byte #$C1

CharacterLines2	ORG $9600
	.byte #$AA
	.byte #$C1


CharacterLines3	ORG $9700
	.byte #$AA
	.byte #$C1

CharacterLines4	ORG $9800
	.byte #$AA
	.byte #$C1

CharacterLines5	ORG $9900
	.byte #$AA
	.byte #$C1

CharacterLines6	ORG $9A00
	.byte #$AA
	.byte #$C1

CharacterLines7	ORG $9B00
	.byte #$AA
	.byte #$C3

CharacterLines8	ORG $9C00
	.byte #$AA
	.byte #$C1
