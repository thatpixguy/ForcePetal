const int receiver_count = 2;
const int buffer_length = 128;
int index[receiver_count];
char buffer[receiver_count][buffer_length];

void setup() {
  // initialize both serial ports:
  Serial.begin(9600);
  Serial1.begin(57600);
  Serial2.begin(57600);

  for(int receiver=0;receiver<receiver_count;++receiver) {
    index[receiver]=0;
    buffer[receiver][0]=0;
  }

  pinMode(8,OUTPUT);
  digitalWrite(8,LOW);
  pinMode(9,OUTPUT);
  digitalWrite(9,LOW);

}


void process_byte(byte b, int receiver) {
  if (b=='\n') {
    Serial.print(receiver);
    Serial.print(":");
    Serial.println(buffer[receiver]);
    index[receiver]=0;
    buffer[receiver][0]=0;
  } else {
    buffer[receiver][index[receiver]++]=b;
    buffer[receiver][index[receiver]]=0;
    
  }  
}


void loop() {
  if(Serial.available()) {
    char b = Serial.read();
    if (b=='0') {
      digitalWrite(8,HIGH);
      delay(500);
      digitalWrite(8,LOW);
    }
    if (b=='1') {
      digitalWrite(9,HIGH);
      delay(500);
      digitalWrite(9,LOW);
    }
  }
  // to avoid flooding...
  while(Serial1.available() or Serial2.available()) {
    
    if (Serial1.available())
      process_byte(Serial1.read(),0);
  
    if (Serial2.available())
      process_byte(Serial2.read(),1);

  }

}
