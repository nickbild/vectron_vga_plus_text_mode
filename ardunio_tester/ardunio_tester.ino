// Data bus.
#define D0 2
#define D1 3
#define D2 4
#define D3 5
#define D4 6
#define D5 7
#define D6 8
#define D7 9

// Flip flop clocks.
#define C0 14
#define C1 15
#define C2 16

// 6502 interrupt.
#define INT 21

void setup() {
  Serial.begin(9600);
  
  pinMode(D0, OUTPUT);
  pinMode(D1, OUTPUT);
  pinMode(D2, OUTPUT);
  pinMode(D3, OUTPUT);
  pinMode(D4, OUTPUT);
  pinMode(D5, OUTPUT);
  pinMode(D6, OUTPUT);
  pinMode(D7, OUTPUT);

  pinMode(C0, OUTPUT);
  pinMode(C1, OUTPUT);
  pinMode(C2, OUTPUT);

  pinMode(INT, OUTPUT);


  digitalWrite(C0, LOW);
  digitalWrite(C1, LOW);
  digitalWrite(C2, LOW);
  
  digitalWrite(INT, HIGH);
}

void loop() {
  digitalWrite(D0, LOW);
  digitalWrite(D1, LOW);
  digitalWrite(D2, LOW);
  digitalWrite(D3, LOW);
  digitalWrite(D4, LOW);
  digitalWrite(D5, LOW);
  digitalWrite(D6, LOW);
  digitalWrite(D7, LOW);

  digitalWrite(C0, HIGH);
  digitalWrite(C0, LOW);
  


  digitalWrite(D0, LOW);
  digitalWrite(D1, HIGH);
  digitalWrite(D2, LOW);
  digitalWrite(D3, LOW);
  digitalWrite(D4, LOW);
  digitalWrite(D5, LOW);
  digitalWrite(D6, LOW);
  digitalWrite(D7, LOW);

  digitalWrite(C1, HIGH);
  digitalWrite(C1, LOW);



  digitalWrite(D0, HIGH);
  digitalWrite(D1, LOW);
  digitalWrite(D2, HIGH);
  digitalWrite(D3, LOW);
  digitalWrite(D4, LOW);
  digitalWrite(D5, LOW);
  digitalWrite(D6, LOW);
  digitalWrite(D7, LOW);

  digitalWrite(C2, HIGH);
  digitalWrite(C2, LOW);




  digitalWrite(INT, LOW);
  delay(1);
  digitalWrite(INT, HIGH);

  delay(500);
}
