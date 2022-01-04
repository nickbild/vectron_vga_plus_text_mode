// Data bus.
#define DATA0 2
#define DATA1 3
#define DATA2 4
#define DATA3 5
#define DATA4 6
#define DATA5 7
#define DATA6 8
#define DATA7 9

// Flip flop clocks.
#define C0 11
#define C1 15
#define C2 16

// 6502 interrupt.
#define INT 21

void setup() {
  Serial.begin(9600);

  pinMode(DATA0, OUTPUT);
  pinMode(DATA1, OUTPUT);
  pinMode(DATA2, OUTPUT);
  pinMode(DATA3, OUTPUT);
  pinMode(DATA4, OUTPUT);
  pinMode(DATA5, OUTPUT);
  pinMode(DATA6, OUTPUT);
  pinMode(DATA7, OUTPUT);

  pinMode(C0, OUTPUT);
  pinMode(C1, OUTPUT);
  pinMode(C2, OUTPUT);

  pinMode(INT, OUTPUT);


  digitalWrite(C0, LOW);
  digitalWrite(C1, LOW);
  digitalWrite(C2, LOW);

  digitalWrite(INT, HIGH);
}

uint8_t code = 97;

void loop() {
  Serial.println("Reset video now...");
  delay(8000);
  Serial.println("Go!");

  // VECTRON VGA PLUS TEXT MODE
  writeCharacter(7, 1, 118);
  writeCharacter(8, 1, 101);
  writeCharacter(9, 1, 99);
  writeCharacter(10, 1, 116);
  writeCharacter(11, 1, 114);
  writeCharacter(12, 1, 111);
  writeCharacter(13, 1, 110);

  writeCharacter(15, 1, 118);
  writeCharacter(16, 1, 103);
  writeCharacter(17, 1, 97);

  writeCharacter(19, 1, 112);
  writeCharacter(20, 1, 108);
  writeCharacter(21, 1, 117);
  writeCharacter(22, 1, 115);

  writeCharacter(24, 1, 116);
  writeCharacter(25, 1, 101);
  writeCharacter(26, 1, 120);
  writeCharacter(27, 1, 116);

  writeCharacter(29, 1, 109);
  writeCharacter(30, 1, 111);
  writeCharacter(31, 1, 100);
  writeCharacter(32, 1, 101);

  // READY.
  writeCharacter(0, 3, 114);
  writeCharacter(1, 3, 101);
  writeCharacter(2, 3, 97);
  writeCharacter(3, 3, 100);
  writeCharacter(4, 3, 121);
  writeCharacter(5, 3, 46);

  writeCharacter(0, 4, 127);

  // 
  for (int j=6; j<30; j++) {
    for (int i=0; i<40; i++) {
    
      writeCharacter(i, j, code);

      code += 1;
      if (code == 123) {
        code = 127;
      } else if (code == 128) {
        code = 1;
      } else if (code == 2) {
        code = 32;
      } else if (code == 38) {
        code = 39;
      } else if (code == 60) {
        code = 61;
      } else if (code == 62) {
        code = 63;
      } else if (code == 65) {
        code = 94;
      } else if (code == 95) {
        goto Done;
      }
      
    }
  }

Done:

// Fill screen with all characters:
//  for (int j=1; j<30; j++) {
//    for (int i=0; i<40; i++) {
//    
//      writeCharacter(i, j, code);
//
//      code += 1;
//      if (code == 123) {
//        code = 127;
//      } else if (code == 128) {
//        code = 1;
//      } else if (code == 2) {
//        code = 32;
//      } else if (code == 38) {
//        code = 39;
//      } else if (code == 60) {
//        code = 61;
//      } else if (code == 62) {
//        code = 63;
//      } else if (code == 65) {
//        code = 94;
//      } else if (code == 95) {
//        code = 97;
//      }
//      
//    }
//  }

  while (true) {}
}

void writeCharacter(uint8_t col, uint8_t row, uint8_t charCode) {
  // Row (0-29)
  digitalWrite(DATA0, bitRead(row, 0));
  digitalWrite(DATA1, bitRead(row, 1));
  digitalWrite(DATA2, bitRead(row, 2));
  digitalWrite(DATA3, bitRead(row, 3));
  digitalWrite(DATA4, bitRead(row, 4));
  digitalWrite(DATA5, bitRead(row, 5));
  digitalWrite(DATA6, bitRead(row, 6));
  digitalWrite(DATA7, bitRead(row, 7));

  digitalWrite(C0, HIGH);
  digitalWrite(C0, LOW);

  // Column (0-39)
  digitalWrite(DATA0, bitRead(col, 0));
  digitalWrite(DATA1, bitRead(col, 1));
  digitalWrite(DATA2, bitRead(col, 2));
  digitalWrite(DATA3, bitRead(col, 3));
  digitalWrite(DATA4, bitRead(col, 4));
  digitalWrite(DATA5, bitRead(col, 5));
  digitalWrite(DATA6, bitRead(col, 6));
  digitalWrite(DATA7, bitRead(col, 7));

  digitalWrite(C1, HIGH);
  digitalWrite(C1, LOW);

  // Character
  digitalWrite(DATA0, bitRead(charCode, 0));
  digitalWrite(DATA1, bitRead(charCode, 1));
  digitalWrite(DATA2, bitRead(charCode, 2));
  digitalWrite(DATA3, bitRead(charCode, 3));
  digitalWrite(DATA4, bitRead(charCode, 4));
  digitalWrite(DATA5, bitRead(charCode, 5));
  digitalWrite(DATA6, bitRead(charCode, 6));
  digitalWrite(DATA7, bitRead(charCode, 7));

  digitalWrite(C2, HIGH);
  digitalWrite(C2, LOW);

  digitalWrite(INT, LOW);
  digitalWrite(INT, HIGH);
  delay(5); // Give interrupt time to be serviced.
}
