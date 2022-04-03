;;;;
; Vectron VGA Plus Text Mode
;
; v2.0 - implement stack to minimize interrupt handling time.
;
; Nick Bild
; nick.bild@gmail.com
; February 2022
;
; Reserved memory:
;
; $0000-$7EFF - RAM
; 		$0000-$0017 - Named variables
;		$00C0-$00EF - Key press stack
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
;		$8500		- IRQ Handler
;		$9500-$9CFF - Character Data
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

SaveRow
		.byte #$00
SaveCol
		.byte #$00
SaveChar
		.byte #$00		


StartExe	ORG $8000

	sei						; Disable interrupts.

	; Write blank VGA signal to both RAM chips.

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

	lda #$01
	sta $7FF7				; CE low (read mode)

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

	lda #$01
	sta $7FF7				; CE low (read mode)

	cli						; Enable interrupts.


; Do nothing - wait for an interrupt.
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

	; Finish last row.
	lda #$18		; 24
	sta data

	ldy #$10
SetupVGA4
	jsr WriteData
	dey
	bne SetupVGA4
	
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


	; 320 * 8;  8 * 24;  48 * 16;  24 * 24
	
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

	ldx #$08
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

	ldx #$18
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

	; Get requested character.
	ldx SaveChar

	; Get offset to first byte (horizontal line) of character in ROM, then retrieve character code.
	lda $9500,x
	sta charCode

	jsr DrawOneCharacterLine
	jsr NextAddressRow
	
	jsr DrawDuplicateCharacterLine
	jsr NextAddressRow

	; Line 2
	lda $9600,x
	sta charCode

	jsr DrawOneCharacterLine
	jsr NextAddressRow

	jsr DrawDuplicateCharacterLine
	jsr NextAddressRow

	; Line 3
	lda $9700,x
	sta charCode

	jsr DrawOneCharacterLine
	jsr NextAddressRow

	jsr DrawDuplicateCharacterLine
	jsr NextAddressRow

	; Line 4
	lda $9800,x
	sta charCode

	jsr DrawOneCharacterLine
	jsr NextAddressRow

	jsr DrawDuplicateCharacterLine
	jsr NextAddressRow

	; Line 5
	lda $9900,x
	sta charCode

	jsr DrawOneCharacterLine
	jsr NextAddressRow

	jsr DrawDuplicateCharacterLine
	jsr NextAddressRow

	; Line 6
	lda $9A00,x
	sta charCode

	jsr DrawOneCharacterLine
	jsr NextAddressRow

	jsr DrawDuplicateCharacterLine
	jsr NextAddressRow

	; Line 7
	lda $9B00,x
	sta charCode

	jsr DrawOneCharacterLine
	jsr NextAddressRow

	jsr DrawDuplicateCharacterLine
	jsr NextAddressRow

	; Line 8
	lda $9C00,x
	sta charCode

	jsr DrawOneCharacterLine
	jsr NextAddressRow

	jsr DrawDuplicateCharacterLine
	
	.byte #$FA ; plx

	rts


DrawTextIsr		ORG $8500
	; Ensure inputs are consistent across both writes.
	lda $7FF0
	sta SaveRow
	lda $7FF1
	sta SaveCol
	lda $7FF2
	sta SaveChar

	; Draw twice to support Vectron VGA Plus v2.0.
	jsr DrawText
	jsr DrawText

	rti


DrawText
	lda #$03
	sta $7FF7				; WE/CE high
	
	; Convert row and column into starting memory address.
	; ((row * 16) * 400) + (col * 8)

	; Zero the numbers to multiply.
	lda #$00
	sta num1Mid
	sta num1High

	; Load row value to memory, multiply by 16.
	lda SaveRow
	sta num1Low

	clc
	asl num1Low		; x2
	rol num1Mid
	rol num1High
	asl num1Low		; x4
	rol num1Mid
	rol num1High
	asl num1Low		; x8
	rol num1Mid
	rol num1High
	asl num1Low		; x 16
	rol num1Mid
	rol num1High

	; Save *16 value.
	lda num1Low
	sta resultLow
	lda num1Mid
	sta resultMid
	lda num1High
	sta resultHigh
	
	;;; Multiply the *16 value by 400.

	; First, multiply by 256.
	clc
	asl num1Low		; x2
	rol num1Mid
	rol num1High
	asl num1Low		; x4
	rol num1Mid
	rol num1High
	asl num1Low		; x8
	rol num1Mid
	rol num1High
	asl num1Low		; x 16
	rol num1Mid
	rol num1High
	asl num1Low		; x 32
	rol num1Mid
	rol num1High
	asl num1Low		; x 64
	rol num1Mid
	rol num1High
	asl num1Low		; x 128
	rol num1Mid
	rol num1High
	asl num1Low		; x 256
	rol num1Mid
	rol num1High

	; Now multiply *16 value by 128.
	lda resultLow
	sta num2Low
	lda resultMid
	sta num2Mid
	lda resultHigh
	sta num2High

	clc
	asl num2Low		; x2
	rol num2Mid
	rol num2High
	asl num2Low		; x4
	rol num2Mid
	rol num2High
	asl num2Low		; x8
	rol num2Mid
	rol num2High
	asl num2Low		; x 16
	rol num2Mid
	rol num2High
	asl num2Low		; x 32
	rol num2Mid
	rol num2High
	asl num2Low		; x 64
	rol num2Mid
	rol num2High
	asl num2Low		; x 128
	rol num2Mid
	rol num2High

	; Add numbers together - *384 result (*256 result + *128 result)
	jsr Add24BitNumbers

	; Now multiply *16 value by 16.
	lda resultLow
	sta num2Low
	lda resultMid
	sta num2Mid
	lda resultHigh
	sta num2High

	clc
	asl num2Low		; x2
	rol num2Mid
	rol num2High
	asl num2Low		; x4
	rol num2Mid
	rol num2High
	asl num2Low		; x8
	rol num2Mid
	rol num2High
	asl num2Low		; x 16
	rol num2Mid
	rol num2High

	; Add this to the *384 result to get *400.
	jsr Add24BitNumbers

	;;; Add the column value to memory.
	
	; Zero the numbers to add.
	lda #$00
	sta num2Mid
	sta num2High
	
	; Load the column value into memory.
	lda SaveCol
	sta num2Low

	; Multiply column value by 8.
	clc
	asl num2Low		; x2
	rol num2Mid
	rol num2High
	asl num2Low		; x4
	rol num2Mid
	rol num2High
	asl num2Low		; x8
	rol num2Mid
	rol num2High

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
	
	rts


;;;;
; Character Definitions
;;;;

CharacterLines1	ORG $9500

	ORG $9501
	.byte #%11111111

	ORG $9520
	.byte #%00000000
	.byte #%00011000
	.byte #%01100110
	.byte #%00100100
	.byte #%00011000
	.byte #%00000000
	.byte #%00000000
	.byte #%00001100
	.byte #%00011000
	.byte #%00001100
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00111110
	.byte #%00001100
	.byte #%00111110
	.byte #%00111110
	.byte #%00111000
	.byte #%01111111
	.byte #%00111110
	.byte #%01111111
	.byte #%00111110
	.byte #%00111110
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00111110
	.byte #%00111110
	.byte #%00011100
	.byte #%00111111
	.byte #%00111110
	.byte #%00011111
	.byte #%01111111
	.byte #%01111111
	.byte #%00111110
	.byte #%01100011
	.byte #%00111110
	.byte #%01111000
	.byte #%00110011
	.byte #%00000011
	.byte #%01100011
	.byte #%01100011
	.byte #%00111110
	.byte #%00111111
	.byte #%00111110
	.byte #%00111111
	.byte #%00111110
	.byte #%00111111
	.byte #%01100011
	.byte #%01100011
	.byte #%01100011
	.byte #%01000001
	.byte #%00110011
	.byte #%00111111

	ORG $955E
	.byte #%00011100
	.byte #%00000000
	.byte #%00000000
	.byte #%00011100
	.byte #%00111111
	.byte #%00111110
	.byte #%00011111
	.byte #%01111111
	.byte #%01111111
	.byte #%00111110
	.byte #%01100011
	.byte #%00111110
	.byte #%01111000
	.byte #%00110011
	.byte #%00000011
	.byte #%01100011
	.byte #%01100011
	.byte #%00111110
	.byte #%00111111
	.byte #%00111110
	.byte #%00111111
	.byte #%00111110
	.byte #%00111111
	.byte #%01100011
	.byte #%01100011
	.byte #%01100011
	.byte #%01000001
	.byte #%00110011
	.byte #%00111111
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%01111111

CharacterLines2	ORG $9600

	ORG $9601
	.byte #%11111111

	ORG $9620
	.byte #%00000000
	.byte #%00011000
	.byte #%01100110
	.byte #%00100100
	.byte #%01111110
	.byte #%01100011
	.byte #%00000000
	.byte #%00001100
	.byte #%00001100
	.byte #%00011000
	.byte #%01100110
	.byte #%00011000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%01100011
	.byte #%00001100
	.byte #%01100011
	.byte #%01100011
	.byte #%00111100
	.byte #%00000011
	.byte #%01100011
	.byte #%01100011
	.byte #%01100011
	.byte #%01100011
	.byte #%00011000
	.byte #%00011000
	.byte #%00000000
	.byte #%01111110
	.byte #%00000000
	.byte #%01000011
	.byte #%01100011
	.byte #%00111110
	.byte #%01100011
	.byte #%01100011
	.byte #%00110011
	.byte #%00000011
	.byte #%00000011
	.byte #%01100011
	.byte #%01100011
	.byte #%00001000
	.byte #%00110000
	.byte #%00011011
	.byte #%00000011
	.byte #%01110111
	.byte #%01100111
	.byte #%01100011
	.byte #%01100011
	.byte #%01100011
	.byte #%01100011
	.byte #%01100011
	.byte #%00001100
	.byte #%01100011
	.byte #%01100011
	.byte #%01100011
	.byte #%01100011
	.byte #%00110011
	.byte #%00110000

	ORG $965E
	.byte #%00110110
	.byte #%00000000
	.byte #%00000000
	.byte #%00111110
	.byte #%01100011
	.byte #%01100011
	.byte #%00110011
	.byte #%00000011
	.byte #%00000011
	.byte #%01100011
	.byte #%01100011
	.byte #%00001000
	.byte #%00110000
	.byte #%00011011
	.byte #%00000011
	.byte #%01110111
	.byte #%01100111
	.byte #%01100011
	.byte #%01100011
	.byte #%01100011
	.byte #%01100011
	.byte #%01100011
	.byte #%00001100
	.byte #%01100011
	.byte #%01100011
	.byte #%01100011
	.byte #%01100011
	.byte #%00110011
	.byte #%00110000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%01111111

CharacterLines3	ORG $9700

	ORG $9701
	.byte #%11111111

	ORG $9720
	.byte #%00000000
	.byte #%00011000
	.byte #%01100110
	.byte #%01111110
	.byte #%00000011
	.byte #%00110011
	.byte #%00000000
	.byte #%00001100
	.byte #%00000110
	.byte #%00110000
	.byte #%00111100
	.byte #%00011000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%01100000
	.byte #%01110011
	.byte #%00001110
	.byte #%01100000
	.byte #%01100000
	.byte #%00110110
	.byte #%00111111
	.byte #%00000011
	.byte #%00110000
	.byte #%01100011
	.byte #%01100011
	.byte #%00011000
	.byte #%00011000
	.byte #%00000000
	.byte #%01111110
	.byte #%00000000
	.byte #%01110000
	.byte #%01110011
	.byte #%00110110
	.byte #%01100011
	.byte #%00000011
	.byte #%01100011
	.byte #%00000011
	.byte #%00000011
	.byte #%00000011
	.byte #%01100011
	.byte #%00001000
	.byte #%00110000
	.byte #%00001111
	.byte #%00000011
	.byte #%01111111
	.byte #%01101111
	.byte #%01100011
	.byte #%01100011
	.byte #%01100011
	.byte #%01100011
	.byte #%00000011
	.byte #%00001100
	.byte #%01100011
	.byte #%01100011
	.byte #%01100011
	.byte #%00111110
	.byte #%00110011
	.byte #%00110000

	ORG $975E
	.byte #%01100011
	.byte #%00000000
	.byte #%00000000
	.byte #%00110110
	.byte #%01100011
	.byte #%00000011
	.byte #%01100011
	.byte #%00000011
	.byte #%00000011
	.byte #%00000011
	.byte #%01100011
	.byte #%00001000
	.byte #%00110000
	.byte #%00001111
	.byte #%00000011
	.byte #%01111111
	.byte #%01101111
	.byte #%01100011
	.byte #%01100011
	.byte #%01100011
	.byte #%01100011
	.byte #%00000011
	.byte #%00001100
	.byte #%01100011
	.byte #%01100011
	.byte #%01100011
	.byte #%00111110
	.byte #%00110011
	.byte #%00110000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%01111111

CharacterLines4	ORG $9800

	ORG $9801
	.byte #%11111111

	ORG $9820
	.byte #%00000000
	.byte #%00011000
	.byte #%00000000
	.byte #%00100100
	.byte #%00111110
	.byte #%00011000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000110
	.byte #%00110000
	.byte #%01111110
	.byte #%01111110
	.byte #%00000000
	.byte #%01111110
	.byte #%00000000
	.byte #%00110000
	.byte #%01101011
	.byte #%00001100
	.byte #%00110000
	.byte #%00111100
	.byte #%00110011
	.byte #%01100000
	.byte #%00111111
	.byte #%00011000
	.byte #%00111110
	.byte #%01111110
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00011000
	.byte #%01110011
	.byte #%01100011
	.byte #%00111111
	.byte #%00000011
	.byte #%01100011
	.byte #%00011111
	.byte #%00011111
	.byte #%01110011
	.byte #%01111111
	.byte #%00001000
	.byte #%00110000
	.byte #%00000111
	.byte #%00000011
	.byte #%01101011
	.byte #%01111011
	.byte #%01100011
	.byte #%00111111
	.byte #%01100011
	.byte #%00111111
	.byte #%00111110
	.byte #%00001100
	.byte #%01100011
	.byte #%01100011
	.byte #%01101011
	.byte #%00011100
	.byte #%00011110
	.byte #%00011000

	ORG $985E
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%01100011
	.byte #%00111111
	.byte #%00000011
	.byte #%01100011
	.byte #%00011111
	.byte #%00011111
	.byte #%01110011
	.byte #%01111111
	.byte #%00001000
	.byte #%00110000
	.byte #%00000111
	.byte #%00000011
	.byte #%01101011
	.byte #%01111011
	.byte #%01100011
	.byte #%00111111
	.byte #%01100011
	.byte #%00111111
	.byte #%00111110
	.byte #%00001100
	.byte #%01100011
	.byte #%01100011
	.byte #%01101011
	.byte #%00011100
	.byte #%00011110
	.byte #%00011000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%01111111

CharacterLines5	ORG $9900

	ORG $9901
	.byte #%11111111

	ORG $9920
	.byte #%00000000
	.byte #%00011000
	.byte #%00000000
	.byte #%01111110
	.byte #%01100000
	.byte #%00001100
	.byte #%00000000
	.byte #%00000000
	.byte #%00000110
	.byte #%00110000
	.byte #%00111100
	.byte #%01111110
	.byte #%00011000
	.byte #%01111110
	.byte #%00000000
	.byte #%00011000
	.byte #%01100111
	.byte #%00001100
	.byte #%00001100
	.byte #%01100000
	.byte #%01111111
	.byte #%01100000
	.byte #%01100011
	.byte #%00011000
	.byte #%01100011
	.byte #%01100000
	.byte #%00000000
	.byte #%00011000
	.byte #%00000000
	.byte #%01111110
	.byte #%00000000
	.byte #%00001100
	.byte #%00000011
	.byte #%01111111
	.byte #%01100011
	.byte #%00000011
	.byte #%01100011
	.byte #%00000011
	.byte #%00000011
	.byte #%01100011
	.byte #%01100011
	.byte #%00001000
	.byte #%00110000
	.byte #%00001111
	.byte #%00000011
	.byte #%01100011
	.byte #%01110011
	.byte #%01100011
	.byte #%00000011
	.byte #%01100011
	.byte #%00011111
	.byte #%01100000
	.byte #%00001100
	.byte #%01100011
	.byte #%00110110
	.byte #%01111111
	.byte #%00111110
	.byte #%00001100
	.byte #%00001100

	ORG $995E
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%01111111
	.byte #%01100011
	.byte #%00000011
	.byte #%01100011
	.byte #%00000011
	.byte #%00000011
	.byte #%01100011
	.byte #%01100011
	.byte #%00001000
	.byte #%00110000
	.byte #%00001111
	.byte #%00000011
	.byte #%01100011
	.byte #%01110011
	.byte #%01100011
	.byte #%00000011
	.byte #%01100011
	.byte #%00011111
	.byte #%01100000
	.byte #%00001100
	.byte #%01100011
	.byte #%00110110
	.byte #%01111111
	.byte #%00111110
	.byte #%00001100
	.byte #%00001100
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%01111111

CharacterLines6	ORG $9A00

	ORG $9A01
	.byte #%11111111

	ORG $9A20
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00100100
	.byte #%00111111
	.byte #%01100110
	.byte #%00000000
	.byte #%00000000
	.byte #%00001100
	.byte #%00011000
	.byte #%01100110
	.byte #%00011000
	.byte #%00011000
	.byte #%00000000
	.byte #%00011000
	.byte #%00001100
	.byte #%01100011
	.byte #%00001100
	.byte #%00000011
	.byte #%01100011
	.byte #%00110000
	.byte #%01100011
	.byte #%01100011
	.byte #%00011000
	.byte #%01100011
	.byte #%01100011
	.byte #%00011000
	.byte #%00011000
	.byte #%00000000
	.byte #%01111110
	.byte #%00000000
	.byte #%00000000
	.byte #%01000011
	.byte #%01100011
	.byte #%01100011
	.byte #%01100011
	.byte #%00110011
	.byte #%00000011
	.byte #%00000011
	.byte #%01100011
	.byte #%01100011
	.byte #%00001000
	.byte #%00110110
	.byte #%00011011
	.byte #%00000011
	.byte #%01100011
	.byte #%01100011
	.byte #%01100011
	.byte #%00000011
	.byte #%00111110
	.byte #%00111011
	.byte #%01100011
	.byte #%00001100
	.byte #%01100011
	.byte #%00011100
	.byte #%01110111
	.byte #%01100011
	.byte #%00001100
	.byte #%00000110

	ORG $9A5E
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%01100011
	.byte #%01100011
	.byte #%01100011
	.byte #%00110011
	.byte #%00000011
	.byte #%00000011
	.byte #%01100011
	.byte #%01100011
	.byte #%00001000
	.byte #%00110110
	.byte #%00011011
	.byte #%00000011
	.byte #%01100011
	.byte #%01100011
	.byte #%01100011
	.byte #%00000011
	.byte #%00111110
	.byte #%00111011
	.byte #%01100011
	.byte #%00001100
	.byte #%01100011
	.byte #%00011100
	.byte #%01110111
	.byte #%01100011
	.byte #%00001100
	.byte #%00000110
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%01111111

CharacterLines7	ORG $9B00

	ORG $9B01
	.byte #%11111111

	ORG $9B20
	.byte #%00000000
	.byte #%00011000
	.byte #%00000000
	.byte #%00100100
	.byte #%00011000
	.byte #%01100011
	.byte #%00000000
	.byte #%00000000
	.byte #%00011000
	.byte #%00001100
	.byte #%00000000
	.byte #%00011000
	.byte #%00001100
	.byte #%00000000
	.byte #%00011000
	.byte #%00000110
	.byte #%00111110
	.byte #%00111111
	.byte #%01111111
	.byte #%00111110
	.byte #%00110000
	.byte #%00111110
	.byte #%00111110
	.byte #%00011000
	.byte #%00111110
	.byte #%00111110
	.byte #%00011000
	.byte #%00001100
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00001100
	.byte #%00111110
	.byte #%01100011
	.byte #%00111111
	.byte #%00111110
	.byte #%00011111
	.byte #%01111111
	.byte #%00000011
	.byte #%00111110
	.byte #%01100011
	.byte #%00111110
	.byte #%00011100
	.byte #%00110011
	.byte #%00111111
	.byte #%01100011
	.byte #%01100011
	.byte #%00111110
	.byte #%00000011
	.byte #%01110000
	.byte #%01110011
	.byte #%00111110
	.byte #%00001100
	.byte #%00111110
	.byte #%00001000
	.byte #%01100011
	.byte #%01000001
	.byte #%00001100
	.byte #%00111111

	ORG $9B5E
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%01100011
	.byte #%00111111
	.byte #%00111110
	.byte #%00011111
	.byte #%01111111
	.byte #%00000011
	.byte #%00111110
	.byte #%01100011
	.byte #%00111110
	.byte #%00011100
	.byte #%00110011
	.byte #%00111111
	.byte #%01100011
	.byte #%01100011
	.byte #%00111110
	.byte #%00000011
	.byte #%01110000
	.byte #%01110011
	.byte #%00111110
	.byte #%00001100
	.byte #%00111110
	.byte #%00001000
	.byte #%01100011
	.byte #%01000001
	.byte #%00001100
	.byte #%00111111
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%01111111

CharacterLines8	ORG $9C00

	ORG $9C01
	.byte #%11111111

	ORG $9C20
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000

	ORG $9C5E
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000
	.byte #%00000000

	.byte #%00000010
