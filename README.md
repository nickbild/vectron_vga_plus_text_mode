# Vectron VGA Plus Text Mode

Vectron VGA Plus Text Mode simplifes displaying text with retro computers and microcontrollers by hiding the pixel-level details.  Supply only row and column positions, and an ASCII character code, to write text to a 40x30 character VGA display.

![](https://raw.githubusercontent.com/nickbild/vectron_vga_plus_text_mode/main/media/text_mode_angle_sm.jpg)

## How It Works

Vectron VGA Plus Text Mode accepts row, column, and character codes into 8-bit flip flop registers from external systems.  Using a 6502 processor and pre-programmed ROM chip [code here](https://github.com/nickbild/vectron_vga_plus_text_mode/blob/main/os.asm), these values are translated into a series of pixels to be drawn at x,y coordinates on the screen.  Both the program, and the library of available ASCII characters are stored in the ROM.  Instructions to draw each pixel are stored in 8-bit flip flop output registers where they can interface with and control a [Vectron VGA Plus](https://github.com/nickbild/vectron_vga_plus) VGA adapter.

To write a single 8x8 character to the screen without Text Mode would require writing 64 individual pixels, and performing all of the associated instructions and data transformations.  This would keep a typical 6502 computer pretty busy just writing to the screen, and would also perform poorly.  Text Mode allows for the same result with just a few instructions.

At the heart of the design is a 65C02 processor to handle the somewhat complex calculations that would be difficult to perform with only logic chips, and would require a high part count.  I think using a microprocessor in this board is well within the bounds of acceptable for a pure retro computing device, considering that the Commodore 1541 disk drive, for example, also had its own 6502 to handle processing.

An Arudino sketch that can be used to write characters using Text Mode [is here](https://github.com/nickbild/vectron_vga_plus_text_mode/tree/main/ardunio_tester).  KiCad design files are [available here](https://github.com/nickbild/vectron_vga_plus_text_mode/tree/main/kicad).

## Media

Vectron VGA Plus Text Mode:

![](https://raw.githubusercontent.com/nickbild/vectron_vga_plus_text_mode/main/media/text_mode_sm.jpg)

Vectron VGA Plus Text Mode attached to Vectron VGA Plus, with an Arduino Mega 2560 requesting the characters to be written on screen:

![](https://raw.githubusercontent.com/nickbild/vectron_vga_plus_text_mode/main/media/full_setup_w_arduino_angle_sm.jpg)

![](https://raw.githubusercontent.com/nickbild/vectron_vga_plus_text_mode/main/media/text_mode_with_vga_plus_close_sm.jpg)

All characters in a repeating pattern:

![](https://raw.githubusercontent.com/nickbild/vectron_vga_plus_text_mode/main/media/screenshot_all_chars_sm.jpg)

Text mode interface:

![](https://raw.githubusercontent.com/nickbild/vectron_vga_plus_text_mode/main/media/screenshot_prompt_sm.jpg)

Breadboard prototype (with a few components removed to place on the PCB):

![](https://raw.githubusercontent.com/nickbild/vectron_vga_plus_text_mode/main/media/breadboard_prototype_sm.jpg)

## Bill of Materials

- 1 x WDC 65C02 processor
- 1 x AS6C62256A-70PCN 32KB RAM
- 1 x AT28C256-15PU 32KB ROM
- 1 x 8 MHz oscillator
- 4 x 3.3k ohm resistors
- 2 x 220 uF capacitors
- 1 x push button
- 2 x 7432
- 1 x 7408
- 1 x 7404
- 2 x 74682
- 1 x 74154
- 8 x 74374
- Female headers
- PCB ([KiCad design files](https://github.com/nickbild/vectron_vga_plus_text_mode/tree/main/kicad))

## About the Author

[Nick A. Bild, MS](https://nickbild79.firebaseapp.com/#!/)
