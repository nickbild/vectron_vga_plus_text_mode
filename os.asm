;;;;
; Vectron 65 Operating System
;
; Nick Bild
; nick.bild@gmail.com
; November 2020
;
; Reserved memory:
;
; $0000-$7EFF - RAM
; 		$0000-$0006 - Named variables
;			$0020-$00D7 - Tiny Basic variables/config
; 		$0100-$01FF - 6502 stack
;     $0200-$5100 - Tiny Basic user program
;     $5101-$5130 - Display row 1
;     $5201-$5230 - Display row 2
;     $5301-$5330 - Display row 3
;     $5401-$5430 - Display row 4
;     $5501-$5530 - Display row 5
;     $5601-$5630 - Display row 6
;     $5701-$5730 - Display row 7
;     $5801-$5830 - Display row 8
;     $5901-$5930 - Display row 9
;     $5A01-$5A30 - Display row 10
;     $5B01-$5B30 - Display row 11
;     $5C01-$5C30 - Display row 12
;     $5D01-$5D30 - Display row 13
;     $5E01-$5E30 - Display row 14
;     $5F01-$5F30 - Display row 15
;     $6001-$6030 - Display row 16
;     $6101-$6130 - Display row 17
;     $6201-$6230 - Display row 18
;     $6301-$6330 - Display row 19
;     $6401-$6430 - Display row 20
;     $6501-$6530 - Display row 21
;     $6601-$6630 - Display row 22
;     $6701-$6730 - Display row 23
;     $6801-$6830 - Display row 24
;     $6901-$6930 - Display row 25
;     $6A01-$6A30 - Display row 26
;     $6B01-$6B30 - Display row 27
;     $6C01-$6C30 - Display row 28
; $7F00 - Display Interrupt
; $7FE0-$7FEF - 6522 VIA (For keyboard input, AY-3-8910, SD card)
; $7FF0-$7FFF - 6522 VIA (For VGA display)
; $8000-$FFFF - ROM
; 		$FFFA-$FFFB - NMI IRQ Vector
; 		$FFFC-$FFFD - Reset Vector - Stores start address of this ROM.
; 		$FFFE-$FFFF - IRQ Vector
;;;;

		processor 6502

		; Named variables in RAM.
		ORG $0000
; Keyboard
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
	lda #$01
	sta $7FF7				; WE (FF top)
	sta $7FF8				; CE (FF bottom)

	; Write VGA signal timings for a blank screen to memory.
	jsr SetupVGA

	cli						; Enable interrupts.


; Do nothing.  Just wait for an interrupt signal.
MainLoop:
	; Visible lines and vertical front porch.
	lda #$18		; 24
	sta data

	jsr WriteData

	; Vertical sync.

	; vertical back porch


    jmp MainLoop


SetupVGA
	rts


IncAddress
	clc
	lda  #$01
	adc  addrLow
	sta  addrLow

	lda  #$00
	adc  addrMid
	sta  addrMid

	lda  #$00
	adc  addrHigh
	sta  addrHigh

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
	lda #$00
	sta $7FF7				; WE (FF top)
	sta $7FF8				; CE (FF bottom)
	; nop
	lda #$01
	sta $7FF7				; WE (FF top)
	sta $7FF8				; CE (FF bottom)

	; Increment address counter.
	jsr IncAddress

	rts


DrawTextIsr	ORG $9000
	lda $7FF0
    sta $7FF6

	lda $7FF1
    sta $7FF6

	lda $7FF2
    sta $7FF6

	rti
