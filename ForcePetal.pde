import processing.serial.*;


State state;

float scale;

boolean blink = true;

boolean debug = false;

int winner;

Serial port;
PFont font;

PImage backgroundImage;
PImage backgroundMaskImage;
PImage meditationImage;
PImage attentionImage;

PImage[] attentionBubbles = new PImage[3];
  
PImage[] meditationBubbles = new PImage[3];


ArrayList serialLog;

LowPassFilter[] attentionSum = 
  {new LowPassFilter(0.001), new LowPassFilter(0.001)};
LowPassFilter[] meditationSum = 
  {new LowPassFilter(0.001), new LowPassFilter(0.001)};

LowPassFilter guide;

boolean fakeData;
float lastFakeDataTime;


void setup() {
  scale = min(screen.width/1280.0,screen.height/720.0); // auto-scale
  // scale = 0.8; // for my teenyweeny netbook
  // scale = 1.0; // for the real deal
  size(int(1280*scale),int(720*scale)); 

  noCursor();

  setState(State.SET);

  guide = new LowPassFilter(0.001);

  font = loadFont("HelveticaNeue-Medium-76.vlw");
  textFont(font,48);
  
  serialLog = new ArrayList();
  
  backgroundImage = loadImage("petal-background.png");
  backgroundMaskImage = loadImage("petal-background-with-holes.png");
  attentionImage = loadImage("green-goo.png");
  meditationImage = loadImage("red-goo.png");  
  
  attentionBubbles[0] = loadImage("green-bubble-small.png");
  attentionBubbles[1] = loadImage("green-bubble-medium.png");
  attentionBubbles[2] = loadImage("green-bubble-big.png");

  meditationBubbles[0] = loadImage("red-bubble-small.png");
  meditationBubbles[1] = loadImage("red-bubble-medium.png");
  meditationBubbles[2] = loadImage("red-bubble-big.png");

  smooth();

  fakeData = false;
  lastFakeDataTime = 0;

  println(Serial.list());
  try {
    port = new Serial(this,Serial.list()[1],9600);
  } catch ( Exception e ) {
  }

  if (port!=null) port.bufferUntil(10);
}

void setState(State s) {
  // leaving state actions
  
  state = s;
  
  // entering state actions
  if (s==State.SET) {
    for(int i=0;i<2;++i) {
      attentionSum[i].set(0);
      meditationSum[i].set(0);
    }
    winner = -1;
  } else if(s==State.GO) {
  } else if(s==State.TEST) {
  } else if(s==State.FINISH) {
    if (winner>=0) {
      port.write(winner);
    }
  }
}

void keyPressed() {
  if (key=='f') {
    fakeData^=true;
  } else if (key=='d') {
    debug^=true;
  } else if (key=='r') {
    setState(State.READY);
  } else if (key=='s') {
    setState(State.SET);
  } else if (key=='g') {
    setState(State.GO);
  } else if (key=='t') {
    setState(State.TEST);
  } else if (key=='i') {
    setState(State.IDLE);
  }
}

void generateFakeData() {
  if(fakeData) {
    float currentTime = millis();
    if(lastFakeDataTime+500<currentTime) {
      processData(0,(int)random(0,100),(int)random(0,100),0);
      processData(1,(int)random(0,100),(int)random(0,100),0);
      lastFakeDataTime=currentTime;
    }
  }
}

void centerText(String s,float x, float y) {
  float w = textWidth(s);
  text(s,x-(w/2.0),y);
}

void draw() {
  scale(scale); // scale for my teenyweeny netbook

  if(state == State.GO) {
    for(int i=0;i<2;++i) {
      if(attentionSum[i].read()>=1 && meditationSum[i].read()>=1) {
        winner = i;
	setState(State.FINISH);
      }
    }
  }

  generateFakeData();

  image(backgroundImage,0,0);

  float f;


  drawSerialLog();
  rectMode(CORNERS);
  noStroke();


  f = constrain(attentionSum[0].read(),0,1);
  blend(attentionImage,
    0,0,
    attentionImage.width,attentionImage.height,
    int((-635*(1-f)+f)*scale),int(177*scale),
    int(attentionImage.width*scale),int(attentionImage.height*scale),
    LIGHTEST);


  f = constrain(meditationSum[0].read(),0,1);
  blend(meditationImage,
    0,0,
    meditationImage.width,meditationImage.height,
    int((-635*(1-f)+f)*scale),int(342*scale),
    int(meditationImage.width*scale),int(meditationImage.height*scale),
    LIGHTEST);

  f = constrain(attentionSum[1].read(),0,1);
  blend(attentionImage,
    0,0,
    attentionImage.width,attentionImage.height,
    int((645*f+1280*(1-f))*scale),int(177*scale),
    int(attentionImage.width*scale),int(attentionImage.height*scale),
    LIGHTEST);

  f = constrain(meditationSum[1].read(),0,1);
  blend(meditationImage,
    0,0,
    meditationImage.width,meditationImage.height,
    int((645*f+1280*(1-f))*scale),int(342*scale),
    int(meditationImage.width*scale),int(meditationImage.height*scale),
    LIGHTEST);

  image(backgroundMaskImage,0,0);
 
  if(state == State.FINISH) {
    fill(255);
    centerText("WINNER!!!",(winner*640)+320,160);
  } else if (state == State.READY) {
    fill(255);
    centerText("READY?",640,360);
  } else if (state == State.SET) {
    fill(255);
    centerText("GET SET...",640,360);
  } else if (state == State.GO) {
    fill(255);
    centerText("GO!!!",640,360);
    //XXX only show for a few seconds!
  }
  
  if (debug) {
    if (fakeData) {
      fill(255,255,0);
      centerText("fake data is fake",1280/2,720/2.0);
    }
    if (blink^=true) {
      noStroke();
      fill(0,255,0);
      rect(10,10,20,20);
    }
    fill(255);
    centerText(""+mouseX+","+mouseY,mouseX,mouseY);
  }

  if (debug) {
  stroke(255,0,0);
  float x = mouseX;
  line(x,0,x,mouseY);
  stroke(0,0,255);
  x = guide.write(x);
  line(x,mouseY,x,height);
  }

}

void addToSerialLog(String s) {
  serialLog.add(s);
  while (serialLog.size()>(height/g.textLeading*scale)) {
    serialLog.remove(0);
  }  
  
}

void drawSerialLog() {
  if (!debug) 
    return;
  /*
  stroke(0x22);
  
  for(float y=g.textLeading;y<760;y+=g.textLeading){
    line(0,y,1280,y);
  }
  */

  String s = "";
  for(int i=0;i<serialLog.size();++i) {
    s+=serialLog.get(i);
  }
  
  fill(0x55);
  
  text(s,10,g.textLeading);
}

void processData(int player, int attention, int meditation, int signal) {
  //println("processData for player: "+player);
  //println("attention: "+attention);
  //println("meditation: "+meditation);
  //println("signal: "+signal);
  if (signal>100) {
    return;
  }

  if (!(state==State.TEST || state==State.GO)) {
    return;
  }
  
  float targetTime = 180; //secs
  float frequency = 2; //samples per second
  float attentionAverage = 40;
  float meditationAverage = 40;

  float factor;

  factor = 1.0/(attentionAverage*frequency*targetTime);
  
  attentionSum[player].write(attentionSum[player].mLastInput+attention*factor);

  factor = 1.0/(meditationAverage*frequency*targetTime);
  
  meditationSum[player].write(meditationSum[player].mLastInput+meditation*factor);
  
}

void serialEvent(Serial p) {
  String s = p.readString();
  addToSerialLog(s);
 
  String[] prefix = split(s,":");
  if (prefix.length>0) {
    int player = int(prefix[0]);
    if (prefix.length>1) {
      String[] tokens = split(prefix[1].trim()," ");
      if (tokens.length>=3) {
        try {
          int attention = Integer.parseInt(tokens[0]);
          int meditation = Integer.parseInt(tokens[1]);
          int signal = Integer.parseInt(tokens[2]);
          //println("attention :" + attention);
          //println("meditation :" + meditation);
          //println("signal :" + signal);

          processData(player,attention,meditation,signal);

        } catch (java.lang.NumberFormatException e) {
        }
      }   
    }
  }  
   
}
