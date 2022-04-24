from posixpath import split
import re


defs1 = """
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
"""

defs2 = """
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
"""

defs3 = """
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
"""

defs4 = """
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
"""

defs5 = """
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
"""

defs6 = """
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
"""

defs7 = """
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
"""

defs8 = """
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
"""

def processLine(defs, loc, newLoc, byteNumber):
    line = defs.split("\n")

    print (line[0])
    print (re.sub('CharacterLines.\s+', '	', line[1]).replace(loc, newLoc))
    print (line[2])
    print (line[3].replace(loc, newLoc))
    parseByte(line[4], byteNumber)
    print (line[5])
    print (line[6].replace(loc, newLoc))
    parseByte(line[7], byteNumber)
    parseByte(line[8], byteNumber)
    parseByte(line[9], byteNumber)
    parseByte(line[10], byteNumber)
    parseByte(line[11], byteNumber)
    parseByte(line[12], byteNumber)
    parseByte(line[13], byteNumber)
    parseByte(line[14], byteNumber)
    parseByte(line[15], byteNumber)
    parseByte(line[16], byteNumber)
    parseByte(line[17], byteNumber)
    parseByte(line[18], byteNumber)
    parseByte(line[19], byteNumber)
    parseByte(line[20], byteNumber)
    parseByte(line[21], byteNumber)
    parseByte(line[22], byteNumber)
    parseByte(line[23], byteNumber)
    parseByte(line[24], byteNumber)
    parseByte(line[25], byteNumber)
    parseByte(line[26], byteNumber)
    parseByte(line[27], byteNumber)
    parseByte(line[28], byteNumber)
    parseByte(line[29], byteNumber)
    parseByte(line[30], byteNumber)
    parseByte(line[31], byteNumber)
    parseByte(line[32], byteNumber)
    parseByte(line[33], byteNumber)
    parseByte(line[34], byteNumber)
    parseByte(line[35], byteNumber)
    parseByte(line[36], byteNumber)
    parseByte(line[37], byteNumber)
    parseByte(line[38], byteNumber)
    parseByte(line[39], byteNumber)
    parseByte(line[40], byteNumber)
    parseByte(line[41], byteNumber)
    parseByte(line[42], byteNumber)
    parseByte(line[43], byteNumber)
    parseByte(line[44], byteNumber)
    parseByte(line[45], byteNumber)
    parseByte(line[46], byteNumber)
    parseByte(line[47], byteNumber)
    parseByte(line[48], byteNumber)
    parseByte(line[49], byteNumber)
    parseByte(line[50], byteNumber)
    parseByte(line[51], byteNumber)
    parseByte(line[52], byteNumber)
    parseByte(line[53], byteNumber)
    parseByte(line[54], byteNumber)
    parseByte(line[55], byteNumber)
    parseByte(line[56], byteNumber)
    parseByte(line[57], byteNumber)
    parseByte(line[58], byteNumber)
    parseByte(line[59], byteNumber)
    parseByte(line[60], byteNumber)
    parseByte(line[61], byteNumber)
    parseByte(line[62], byteNumber)
    parseByte(line[63], byteNumber)
    parseByte(line[64], byteNumber)
    parseByte(line[65], byteNumber)
    print (line[66])
    print (line[67].replace(loc, newLoc))
    parseByte(line[68], byteNumber)
    parseByte(line[69], byteNumber)
    parseByte(line[70], byteNumber)
    parseByte(line[71], byteNumber)
    parseByte(line[72], byteNumber)
    parseByte(line[73], byteNumber)
    parseByte(line[74], byteNumber)
    parseByte(line[75], byteNumber)
    parseByte(line[76], byteNumber)
    parseByte(line[77], byteNumber)
    parseByte(line[78], byteNumber)
    parseByte(line[79], byteNumber)
    parseByte(line[80], byteNumber)
    parseByte(line[81], byteNumber)
    parseByte(line[82], byteNumber)
    parseByte(line[83], byteNumber)
    parseByte(line[84], byteNumber)
    parseByte(line[85], byteNumber)
    parseByte(line[86], byteNumber)
    parseByte(line[87], byteNumber)
    parseByte(line[88], byteNumber)
    parseByte(line[89], byteNumber)
    parseByte(line[90], byteNumber)
    parseByte(line[91], byteNumber)
    parseByte(line[92], byteNumber)
    parseByte(line[93], byteNumber)
    parseByte(line[94], byteNumber)
    parseByte(line[95], byteNumber)
    parseByte(line[96], byteNumber)
    parseByte(line[97], byteNumber)
    parseByte(line[98], byteNumber)
    parseByte(line[99], byteNumber)
    parseByte(line[100], byteNumber)
    parseByte(line[101], byteNumber)
    print (line[102])
    
    return


def parseByte(line, byteNumber):
    line = line.replace("	.byte #%", "")
    pos = 7 - byteNumber
    print("	.byte #$0{0}".format(line[pos]))

    return


processLine(defs1, "95", "95", 0)
processLine(defs1, "95", "9D", 1)
processLine(defs1, "95", "A5", 2)
processLine(defs1, "95", "AD", 3)
processLine(defs1, "95", "B5", 4)
processLine(defs1, "95", "BD", 5)
processLine(defs1, "95", "C5", 6)
processLine(defs1, "95", "CD", 7)

processLine(defs2, "96", "96", 0)
processLine(defs2, "96", "9E", 1)
processLine(defs2, "96", "A6", 2)
processLine(defs2, "96", "AE", 3)
processLine(defs2, "96", "B6", 4)
processLine(defs2, "96", "BE", 5)
processLine(defs2, "96", "C6", 6)
processLine(defs2, "96", "CE", 7)

processLine(defs3, "97", "97", 0)
processLine(defs3, "97", "9F", 1)
processLine(defs3, "97", "A7", 2)
processLine(defs3, "97", "AF", 3)
processLine(defs3, "97", "B7", 4)
processLine(defs3, "97", "BF", 5)
processLine(defs3, "97", "C7", 6)
processLine(defs3, "97", "CF", 7)

processLine(defs4, "98", "98", 0)
processLine(defs4, "98", "A0", 1)
processLine(defs4, "98", "A8", 2)
processLine(defs4, "98", "B0", 3)
processLine(defs4, "98", "B8", 4)
processLine(defs4, "98", "C0", 5)
processLine(defs4, "98", "C8", 6)
processLine(defs4, "98", "D0", 7)

processLine(defs5, "99", "99", 0)
processLine(defs5, "99", "A1", 1)
processLine(defs5, "99", "A9", 2)
processLine(defs5, "99", "B1", 3)
processLine(defs5, "99", "B9", 4)
processLine(defs5, "99", "C1", 5)
processLine(defs5, "99", "C9", 6)
processLine(defs5, "99", "D1", 7)

processLine(defs6, "9A", "9A", 0)
processLine(defs6, "9A", "A2", 1)
processLine(defs6, "9A", "AA", 2)
processLine(defs6, "9A", "B2", 3)
processLine(defs6, "9A", "BA", 4)
processLine(defs6, "9A", "C2", 5)
processLine(defs6, "9A", "CA", 6)
processLine(defs6, "9A", "D2", 7)

processLine(defs7, "9B", "9B", 0)
processLine(defs7, "9B", "A3", 1)
processLine(defs7, "9B", "AB", 2)
processLine(defs7, "9B", "B3", 3)
processLine(defs7, "9B", "BB", 4)
processLine(defs7, "9B", "C3", 5)
processLine(defs7, "9B", "CB", 6)
processLine(defs7, "9B", "D3", 7)

processLine(defs8, "9C", "9C", 0)
processLine(defs8, "9C", "A4", 1)
processLine(defs8, "9C", "AC", 2)
processLine(defs8, "9C", "B4", 3)
processLine(defs8, "9C", "BC", 4)
processLine(defs8, "9C", "C4", 5)
processLine(defs8, "9C", "CC", 6)
processLine(defs8, "9C", "D4", 7)
