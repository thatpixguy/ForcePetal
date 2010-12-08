enum state_type {
  WAIT_FOR_LF,
  ATTENTION,
  MEDITATION,
  SIGNAL
};


const int receiver_count = 2;
state_type states[receiver_count];
int attention[receiver_count];
int meditation[receiver_count];
int signal[receiver_count];

void setup() {
  // initialize both serial ports:
  Serial.begin(9600);
  Serial1.begin(57600);
  Serial2.begin(57600);

}


void process_input(byte b, int receiver) {
  state_type state = states[receiver];
  
  switch (state) {
  case WAIT_FOR_LF:
    if (b=='\n') {
      state = ATTENTION;
      attention[receiver] = 0;
    }
    break;
  case ATTENTION:
    if(b>='0' and b<='9') {
      attention[receiver]*=10;
      attention[receiver]+=b-'0';
    } else if (b==' ') {
      state = MEDITATION;
      meditation[receiver] = 0;
    } else {
      state = WAIT_FOR_LF;
    }
    break;
  case MEDITATION:
    if(b>='0' and b<='9') {
      meditation[receiver]*=10;
      meditation[receiver]+=b-'0';
    } else if (b==' ') {
      state = SIGNAL;
      signal[receiver] = 0;
    } else {
      state = WAIT_FOR_LF;
    }
    break;
  case SIGNAL:
    if(b>='0' and b<='9') {
      signal[receiver]*=10;
      signal[receiver]+=b-'0';
    } else {
      Serial.print(receiver);
      Serial.print(" ");
      Serial.print(attention[receiver]);
      Serial.print(" ");
      Serial.print(meditation[receiver]);
      Serial.print(" ");
      Serial.print(signal[receiver]);
      Serial.println();
      state = WAIT_FOR_LF;
    }
    break;
  } 
  
  states[receiver] = state;
  
}


void loop() {
  // read from port 1, send to port 0:
  if (Serial1.available()>0) {
    //int inByte = Serial1.read();
    //Serial.print(inByte, BYTE); 
    Serial.print("A["); 
    Serial.print(Serial1.read());//,BYTE); 
    Serial.print("]"); 

  }
  
  if (Serial2.available()>0) {
    //int inByte = Serial1.read();
    //Serial.print(inByte, BYTE); 
    Serial.print("B["); 
    Serial.print(Serial2.read());//,BYTE); 
    Serial.print("]");
  }

}
