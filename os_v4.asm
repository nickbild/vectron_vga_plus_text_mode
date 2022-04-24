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

addrLowSave
		.byte #$00
addrMidSave
		.byte #$00
addrHighSave
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
	jsr WriteDataInit
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
	jsr WriteDataInit
	dex
	bne Visible1

	ldx #$49
Visible2
	jsr WriteDataInit
	dex
	bne Visible2

	lda #$10		; 16
	sta data

	ldx #$30
Visible3
	jsr WriteDataInit
	dex
	bne Visible3

	lda #$18		; 24
	sta data

	ldx #$18
Visible4
	jsr WriteDataInit
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
	jsr WriteDataInit
	dex
	bne VSync1

	ldx #$41
VSync2
	jsr WriteDataInit
	dex
	bne VSync2

	lda #$08		; 8
	sta data

	ldx #$08
VSync3
	jsr WriteDataInit
	dex
	bne VSync3

	lda #$00		; 0
	sta data

	ldx #$30
VSync4
	jsr WriteDataInit
	dex
	bne VSync4

	lda #$08		; 8
	sta data

	ldx #$18
VSync5
	jsr WriteDataInit
	dex
	bne VSync5


	; 320 * 8;  8 * 8;  48 * 0;  24 * 8
	
	lda #$08		; 8
	sta data

	ldx #$FF
VSync6
	jsr WriteDataInit
	dex
	bne VSync6

	ldx #$41
VSync7
	jsr WriteDataInit
	dex
	bne VSync7

	lda #$08		; 8
	sta data

	ldx #$08
VSync8
	jsr WriteDataInit
	dex
	bne VSync8

	lda #$00		; 0
	sta data

	ldx #$30
VSync9
	jsr WriteDataInit
	dex
	bne VSync9

	lda #$08		; 8
	sta data

	ldx #$18
VSync10
	jsr WriteDataInit
	dex
	bne VSync10


	; 320 * 8;  8 * 24;  48 * 16;  24 * 24
	
	lda #$08		; 8
	sta data

	ldx #$FF
VSync11
	jsr WriteDataInit
	dex
	bne VSync11

	ldx #$41
VSync12
	jsr WriteDataInit
	dex
	bne VSync12

	lda #$18		; 24
	sta data

	ldx #$08
VSync13
	jsr WriteDataInit
	dex
	bne VSync13

	lda #$10		; 16
	sta data

	ldx #$30
VSync14
	jsr WriteDataInit
	dex
	bne VSync14

	lda #$18		; 24
	sta data

	ldx #$18
VSync15
	jsr WriteDataInit
	dex
	bne VSync15

	.byte #$7A ; ply
	.byte #$FA ; plx

	rts


; This version requires the data value to be stored at 'data'.
WriteDataInit
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
	inc addrLow
	bne IncAddress1Init
	inc addrMid
	bne IncAddress1Init
	inc addrHigh
IncAddress1Init

	rts


; This version requires the data value to be in the accumulator.
WriteData
	; Set up the address and data output flip flops.

	; Accumulator has data value when this sub is called.
	sta $7FF6

	lda addrLow
	sta $7FF3

	lda addrMid
	sta $7FF4

	lda addrHigh
	sta $7FF5

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
	inc addrLow
	bne IncAddress1
	inc addrMid
	bne IncAddress1
	inc addrHigh
IncAddress1

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


DrawCharacterLines
	.byte #$DA ; phx - mnemonic unknown to DASM.

	; Get requested character.
	ldx SaveChar

	; Get offset to first byte (horizontal line) of character in ROM, then retrieve character code.

	; Line 1
	lda $9500,x		; line 1, byte 0
	jsr WriteData
	lda $9D00,x		; line 1, byte 1
	jsr WriteData
	lda $A500,x		; line 1, byte 2
	jsr WriteData
	lda $AD00,x		; line 1, byte 3
	jsr WriteData
	lda $B500,x		; line 1, byte 4
	jsr WriteData
	lda $BD00,x		; line 1, byte 5
	jsr WriteData
	lda $C500,x		; line 1, byte 6
	jsr WriteData
	lda $CD00,x		; line 1, byte 7
	jsr WriteData
	jsr NextAddressRow

	lda $9500,x		; line 1, byte 0
	jsr WriteData
	lda $9D00,x		; line 1, byte 1
	jsr WriteData
	lda $A500,x		; line 1, byte 2
	jsr WriteData
	lda $AD00,x		; line 1, byte 3
	jsr WriteData
	lda $B500,x		; line 1, byte 4
	jsr WriteData
	lda $BD00,x		; line 1, byte 5
	jsr WriteData
	lda $C500,x		; line 1, byte 6
	jsr WriteData
	lda $CD00,x		; line 1, byte 7
	jsr WriteData
	jsr NextAddressRow
	

	; Line 2
	lda $9600,x		; line 1, byte 0
	jsr WriteData
	lda $9E00,x		; line 1, byte 1
	jsr WriteData
	lda $A600,x		; line 1, byte 2
	jsr WriteData
	lda $AE00,x		; line 1, byte 3
	jsr WriteData
	lda $B600,x		; line 1, byte 4
	jsr WriteData
	lda $BE00,x		; line 1, byte 5
	jsr WriteData
	lda $C600,x		; line 1, byte 6
	jsr WriteData
	lda $CE00,x		; line 1, byte 7
	jsr WriteData
	jsr NextAddressRow

	lda $9600,x		; line 1, byte 0
	jsr WriteData
	lda $9E00,x		; line 1, byte 1
	jsr WriteData
	lda $A600,x		; line 1, byte 2
	jsr WriteData
	lda $AE00,x		; line 1, byte 3
	jsr WriteData
	lda $B600,x		; line 1, byte 4
	jsr WriteData
	lda $BE00,x		; line 1, byte 5
	jsr WriteData
	lda $C600,x		; line 1, byte 6
	jsr WriteData
	lda $CE00,x		; line 1, byte 7
	jsr WriteData
	jsr NextAddressRow

	; Line 3
	lda $9700,x		; line 1, byte 0
	jsr WriteData
	lda $9F00,x		; line 1, byte 1
	jsr WriteData
	lda $A700,x		; line 1, byte 2
	jsr WriteData
	lda $AF00,x		; line 1, byte 3
	jsr WriteData
	lda $B700,x		; line 1, byte 4
	jsr WriteData
	lda $BF00,x		; line 1, byte 5
	jsr WriteData
	lda $C700,x		; line 1, byte 6
	jsr WriteData
	lda $CF00,x		; line 1, byte 7
	jsr WriteData
	jsr NextAddressRow

	lda $9700,x		; line 1, byte 0
	jsr WriteData
	lda $9F00,x		; line 1, byte 1
	jsr WriteData
	lda $A700,x		; line 1, byte 2
	jsr WriteData
	lda $AF00,x		; line 1, byte 3
	jsr WriteData
	lda $B700,x		; line 1, byte 4
	jsr WriteData
	lda $BF00,x		; line 1, byte 5
	jsr WriteData
	lda $C700,x		; line 1, byte 6
	jsr WriteData
	lda $CF00,x		; line 1, byte 7
	jsr WriteData
	jsr NextAddressRow

	; Line 4
	lda $9800,x		; line 1, byte 0
	jsr WriteData
	lda $A000,x		; line 1, byte 1
	jsr WriteData
	lda $A800,x		; line 1, byte 2
	jsr WriteData
	lda $B000,x		; line 1, byte 3
	jsr WriteData
	lda $B800,x		; line 1, byte 4
	jsr WriteData
	lda $C000,x		; line 1, byte 5
	jsr WriteData
	lda $C800,x		; line 1, byte 6
	jsr WriteData
	lda $D000,x		; line 1, byte 7
	jsr WriteData
	jsr NextAddressRow

	lda $9800,x		; line 1, byte 0
	jsr WriteData
	lda $A000,x		; line 1, byte 1
	jsr WriteData
	lda $A800,x		; line 1, byte 2
	jsr WriteData
	lda $B000,x		; line 1, byte 3
	jsr WriteData
	lda $B800,x		; line 1, byte 4
	jsr WriteData
	lda $C000,x		; line 1, byte 5
	jsr WriteData
	lda $C800,x		; line 1, byte 6
	jsr WriteData
	lda $D000,x		; line 1, byte 7
	jsr WriteData
	jsr NextAddressRow

	; Line 5
	lda $9900,x		; line 1, byte 0
	jsr WriteData
	lda $A100,x		; line 1, byte 1
	jsr WriteData
	lda $A900,x		; line 1, byte 2
	jsr WriteData
	lda $B100,x		; line 1, byte 3
	jsr WriteData
	lda $B900,x		; line 1, byte 4
	jsr WriteData
	lda $C100,x		; line 1, byte 5
	jsr WriteData
	lda $C900,x		; line 1, byte 6
	jsr WriteData
	lda $D100,x		; line 1, byte 7
	jsr WriteData
	jsr NextAddressRow

	lda $9900,x		; line 1, byte 0
	jsr WriteData
	lda $A100,x		; line 1, byte 1
	jsr WriteData
	lda $A900,x		; line 1, byte 2
	jsr WriteData
	lda $B100,x		; line 1, byte 3
	jsr WriteData
	lda $B900,x		; line 1, byte 4
	jsr WriteData
	lda $C100,x		; line 1, byte 5
	jsr WriteData
	lda $C900,x		; line 1, byte 6
	jsr WriteData
	lda $D100,x		; line 1, byte 7
	jsr WriteData
	jsr NextAddressRow

	; Line 6
	lda $9A00,x		; line 1, byte 0
	jsr WriteData
	lda $A200,x		; line 1, byte 1
	jsr WriteData
	lda $AA00,x		; line 1, byte 2
	jsr WriteData
	lda $B200,x		; line 1, byte 3
	jsr WriteData
	lda $BA00,x		; line 1, byte 4
	jsr WriteData
	lda $C200,x		; line 1, byte 5
	jsr WriteData
	lda $CA00,x		; line 1, byte 6
	jsr WriteData
	lda $D200,x		; line 1, byte 7
	jsr WriteData
	jsr NextAddressRow

	lda $9A00,x		; line 1, byte 0
	jsr WriteData
	lda $A200,x		; line 1, byte 1
	jsr WriteData
	lda $AA00,x		; line 1, byte 2
	jsr WriteData
	lda $B200,x		; line 1, byte 3
	jsr WriteData
	lda $BA00,x		; line 1, byte 4
	jsr WriteData
	lda $C200,x		; line 1, byte 5
	jsr WriteData
	lda $CA00,x		; line 1, byte 6
	jsr WriteData
	lda $D200,x		; line 1, byte 7
	jsr WriteData
	jsr NextAddressRow

	; Line 7
	lda $9B00,x		; line 1, byte 0
	jsr WriteData
	lda $A300,x		; line 1, byte 1
	jsr WriteData
	lda $AB00,x		; line 1, byte 2
	jsr WriteData
	lda $B300,x		; line 1, byte 3
	jsr WriteData
	lda $BB00,x		; line 1, byte 4
	jsr WriteData
	lda $C300,x		; line 1, byte 5
	jsr WriteData
	lda $CB00,x		; line 1, byte 6
	jsr WriteData
	lda $D300,x		; line 1, byte 7
	jsr WriteData
	jsr NextAddressRow

	lda $9B00,x		; line 1, byte 0
	jsr WriteData
	lda $A300,x		; line 1, byte 1
	jsr WriteData
	lda $AB00,x		; line 1, byte 2
	jsr WriteData
	lda $B300,x		; line 1, byte 3
	jsr WriteData
	lda $BB00,x		; line 1, byte 4
	jsr WriteData
	lda $C300,x		; line 1, byte 5
	jsr WriteData
	lda $CB00,x		; line 1, byte 6
	jsr WriteData
	lda $D300,x		; line 1, byte 7
	jsr WriteData
	jsr NextAddressRow

	; Line 8
	lda $9C00,x		; line 1, byte 0
	jsr WriteData
	lda $A400,x		; line 1, byte 1
	jsr WriteData
	lda $AC00,x		; line 1, byte 2
	jsr WriteData
	lda $B400,x		; line 1, byte 3
	jsr WriteData
	lda $BC00,x		; line 1, byte 4
	jsr WriteData
	lda $C400,x		; line 1, byte 5
	jsr WriteData
	lda $CC00,x		; line 1, byte 6
	jsr WriteData
	lda $D400,x		; line 1, byte 7
	jsr WriteData
	jsr NextAddressRow

	lda $9C00,x		; line 1, byte 0
	jsr WriteData
	lda $A400,x		; line 1, byte 1
	jsr WriteData
	lda $AC00,x		; line 1, byte 2
	jsr WriteData
	lda $B400,x		; line 1, byte 3
	jsr WriteData
	lda $BC00,x		; line 1, byte 4
	jsr WriteData
	lda $C400,x		; line 1, byte 5
	jsr WriteData
	lda $CC00,x		; line 1, byte 6
	jsr WriteData
	lda $D400,x		; line 1, byte 7
	jsr WriteData
	
	.byte #$FA ; plx

	rts


DrawTextIsr		ORG $8600
	; Ensure inputs are consistent across both writes.
	lda $7FF0
	sta SaveRow
	lda $7FF1
	sta SaveCol
	lda $7FF2
	sta SaveChar

	; Draw twice to support Vectron VGA Plus v2.0.
	jsr DrawText
	
	; Address has already been calculated on the first write,
	; so retrieve that value and skip code that calculates it.
	lda #$03
	sta $7FF7				; WE/CE high

	lda addrLowSave
	sta addrLow
	lda addrMidSave
	sta addrMid
	lda addrHighSave
	sta addrHigh

	jsr DrawText2

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
	sta addrLowSave
	lda num1Mid
	sta addrMid
	sta addrMidSave
	lda num1High
	sta addrHigh
	sta addrHighSave

DrawText2	
	; Now draw the character at this position.
	jsr DrawCharacterLines

	lda #$01
	sta $7FF7				; CE low (read mode)
	
	rts


;;;;
; Character Definitions
;;;;

	ORG $9500

	ORG $9501
	.byte #$1F

	ORG $9520
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F

	ORG $955E
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F


	ORG $9600

	ORG $9601
	.byte #$1F

	ORG $9620
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18

	ORG $965E
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F


	ORG $9700

	ORG $9701
	.byte #$1F

	ORG $9720
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18

	ORG $975E
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F


	ORG $9800

	ORG $9801
	.byte #$1F

	ORG $9820
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18

	ORG $985E
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F


	ORG $9900

	ORG $9901
	.byte #$1F

	ORG $9920
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18

	ORG $995E
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F


	ORG $9A00

	ORG $9A01
	.byte #$1F

	ORG $9A20
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18

	ORG $9A5E
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F


	ORG $9B00

	ORG $9B01
	.byte #$1F

	ORG $9B20
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F

	ORG $9B5E
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F


	ORG $9C00

	ORG $9C01
	.byte #$1F

	ORG $9C20
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18

	ORG $9C5E
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18


	ORG $9D00

	ORG $9D01
	.byte #$1F

	ORG $9D20
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F

	ORG $9D5E
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F


	ORG $9E00

	ORG $9E01
	.byte #$1F

	ORG $9E20
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18

	ORG $9E5E
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F


	ORG $9F00

	ORG $9F01
	.byte #$1F

	ORG $9F20
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18

	ORG $9F5E
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F


	ORG $A000

	ORG $A001
	.byte #$1F

	ORG $A020
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18

	ORG $A05E
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F


	ORG $A100

	ORG $A101
	.byte #$1F

	ORG $A120
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18

	ORG $A15E
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F


	ORG $A200

	ORG $A201
	.byte #$1F

	ORG $A220
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F

	ORG $A25E
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F


	ORG $A300

	ORG $A301
	.byte #$1F

	ORG $A320
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F

	ORG $A35E
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F


	ORG $A400

	ORG $A401
	.byte #$1F

	ORG $A420
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18

	ORG $A45E
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18


	ORG $A500

	ORG $A501
	.byte #$1F

	ORG $A520
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F

	ORG $A55E
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F


	ORG $A600

	ORG $A601
	.byte #$1F

	ORG $A620
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18

	ORG $A65E
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F


	ORG $A700

	ORG $A701
	.byte #$1F

	ORG $A720
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18

	ORG $A75E
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F


	ORG $A800

	ORG $A801
	.byte #$1F

	ORG $A820
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18

	ORG $A85E
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F


	ORG $A900

	ORG $A901
	.byte #$1F

	ORG $A920
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F

	ORG $A95E
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F


	ORG $AA00

	ORG $AA01
	.byte #$1F

	ORG $AA20
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F

	ORG $AA5E
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F


	ORG $AB00

	ORG $AB01
	.byte #$1F

	ORG $AB20
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F

	ORG $AB5E
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F


	ORG $AC00

	ORG $AC01
	.byte #$1F

	ORG $AC20
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18

	ORG $AC5E
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18


	ORG $AD00

	ORG $AD01
	.byte #$1F

	ORG $AD20
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F

	ORG $AD5E
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F


	ORG $AE00

	ORG $AE01
	.byte #$1F

	ORG $AE20
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18

	ORG $AE5E
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F


	ORG $AF00

	ORG $AF01
	.byte #$1F

	ORG $AF20
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18

	ORG $AF5E
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F


	ORG $B000

	ORG $B001
	.byte #$1F

	ORG $B020
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F

	ORG $B05E
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F


	ORG $B100

	ORG $B101
	.byte #$1F

	ORG $B120
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F

	ORG $B15E
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F


	ORG $B200

	ORG $B201
	.byte #$1F

	ORG $B220
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18

	ORG $B25E
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F


	ORG $B300

	ORG $B301
	.byte #$1F

	ORG $B320
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F

	ORG $B35E
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F


	ORG $B400

	ORG $B401
	.byte #$1F

	ORG $B420
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18

	ORG $B45E
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18


	ORG $B500

	ORG $B501
	.byte #$1F

	ORG $B520
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F

	ORG $B55E
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F


	ORG $B600

	ORG $B601
	.byte #$1F

	ORG $B620
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F

	ORG $B65E
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F


	ORG $B700

	ORG $B701
	.byte #$1F

	ORG $B720
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F

	ORG $B75E
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F


	ORG $B800

	ORG $B801
	.byte #$1F

	ORG $B820
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F

	ORG $B85E
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F


	ORG $B900

	ORG $B901
	.byte #$1F

	ORG $B920
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18

	ORG $B95E
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F


	ORG $BA00

	ORG $BA01
	.byte #$1F

	ORG $BA20
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18

	ORG $BA5E
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F


	ORG $BB00

	ORG $BB01
	.byte #$1F

	ORG $BB20
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F

	ORG $BB5E
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F


	ORG $BC00

	ORG $BC01
	.byte #$1F

	ORG $BC20
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18

	ORG $BC5E
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18


	ORG $BD00

	ORG $BD01
	.byte #$1F

	ORG $BD20
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F

	ORG $BD5E
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F


	ORG $BE00

	ORG $BE01
	.byte #$1F

	ORG $BE20
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F

	ORG $BE5E
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F


	ORG $BF00

	ORG $BF01
	.byte #$1F

	ORG $BF20
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F

	ORG $BF5E
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F


	ORG $C000

	ORG $C001
	.byte #$1F

	ORG $C020
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18

	ORG $C05E
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F


	ORG $C100

	ORG $C101
	.byte #$1F

	ORG $C120
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18

	ORG $C15E
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F


	ORG $C200

	ORG $C201
	.byte #$1F

	ORG $C220
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18

	ORG $C25E
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F


	ORG $C300

	ORG $C301
	.byte #$1F

	ORG $C320
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F

	ORG $C35E
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F


	ORG $C400

	ORG $C401
	.byte #$1F

	ORG $C420
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18

	ORG $C45E
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18


	ORG $C500

	ORG $C501
	.byte #$1F

	ORG $C520
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18

	ORG $C55E
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F


	ORG $C600

	ORG $C601
	.byte #$1F

	ORG $C620
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18

	ORG $C65E
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F


	ORG $C700

	ORG $C701
	.byte #$1F

	ORG $C720
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18

	ORG $C75E
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F


	ORG $C800

	ORG $C801
	.byte #$1F

	ORG $C820
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18

	ORG $C85E
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F


	ORG $C900

	ORG $C901
	.byte #$1F

	ORG $C920
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18

	ORG $C95E
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F


	ORG $CA00

	ORG $CA01
	.byte #$1F

	ORG $CA20
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18

	ORG $CA5E
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F


	ORG $CB00

	ORG $CB01
	.byte #$1F

	ORG $CB20
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18

	ORG $CB5E
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F
	.byte #$1F
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$1F


	ORG $CC00

	ORG $CC01
	.byte #$1F

	ORG $CC20
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18

	ORG $CC5E
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18


	ORG $CD00

	ORG $CD01
	.byte #$1F

	ORG $CD20
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18

	ORG $CD5E
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18


	ORG $CE00

	ORG $CE01
	.byte #$1F

	ORG $CE20
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18

	ORG $CE5E
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18


	ORG $CF00

	ORG $CF01
	.byte #$1F

	ORG $CF20
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18

	ORG $CF5E
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18


	ORG $D000

	ORG $D001
	.byte #$1F

	ORG $D020
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18

	ORG $D05E
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18


	ORG $D100

	ORG $D101
	.byte #$1F

	ORG $D120
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18

	ORG $D15E
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18


	ORG $D200

	ORG $D201
	.byte #$1F

	ORG $D220
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18

	ORG $D25E
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18


	ORG $D300

	ORG $D301
	.byte #$1F

	ORG $D320
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18

	ORG $D35E
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18


	ORG $D400

	ORG $D401
	.byte #$1F

	ORG $D420
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18

	ORG $D45E
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18
	.byte #$18


	; Indicate end of ROM.
	.byte #%00000010
