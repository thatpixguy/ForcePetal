import processing.opengl.*;

import processing.serial.*;

float scale;

Serial port;
PFont font;

PImage backgroundImage;
PImage backgroundMaskImage;
PImage meditationImage;
PImage attentionImage;

ArrayList serialLog;

float attentionSum[];
float meditationSum[];

void setup() {
  //scale = 0.5;
  scale = 0.8; // for my teenyweeny netbook
  // scale = 1.0; // for the real deal
  size(int(1280*scale),int(760*scale)); 
  background(0);

  font = loadFont("CenturyGothic-48.vlw");
  textFont(font);
  
  //println(PFont.list());
  //textFont(createFont("PMingLiu",30,true));

  //font = loadFont("PMingLiU-48.vlw");
  //font = loadFont("PMingLiU-48.vlw");

  textFont(font);

  serialLog = new ArrayList();
  
  backgroundImage = loadImage("petal-background.png");
  backgroundMaskImage = loadImage("petal-background-with-holes.png");
  attentionImage = loadImage("green-goo.png");
  meditationImage = loadImage("red-goo.png");  


  attentionSum = new float[2];
  meditationSum = new float[2];
  
  smooth();

  println(Serial.list());
  try {
    port = new Serial(this,Serial.list()[1],9600);
  } catch ( Exception e ) {
  }

  if (port!=null) port.bufferUntil(10);
}

void draw() {
  scale(scale); // scale for my teenyweeny netbook

  //background(backgroundImage);
  image(backgroundImage,0,0);

  float f;

  drawSerialLog();
  rectMode(CORNERS);
  noStroke();


  f = attentionSum[0];
  image(attentionImage,-635*(1-f)+0*(f),177);

  //f = meditationSum[0];
  f = 0.5;
  //image(meditationImage,-635*(1-f)+0*(f),342);
  blend(meditationImage,0,0,meditationImage.width,meditationImage.height,int((-635*(1-f)+f)*scale),int(343*scale),int(meditationImage.width*scale),int(meditationImage.height*scale),LIGHTEST);
  //blend(meditationImage,0,0,50,50,300,342,50,50,MULTIPLY);

  // 342

  f = attentionSum[1];
  image(attentionImage,645*f+1280*(1-f),177);

  f = meditationSum[1];
  image(meditationImage,645*f+1280*(1-f),342);


  image(backgroundMaskImage,0,0);
}

void addToSerialLog(String s) {
  serialLog.add(s);
  while (serialLog.size()>(height/g.textLeading)) {
    serialLog.remove(0);
  }  
  
  //drawLog();
}

void drawSerialLog() {
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
  
  float targetTime = 180; //secs
  float frequency = 2; //samples per second
  float attentionAverage = 40;
  float meditationAverage = 40;

  float factor;

  //float attentionMax = 100;
  
  //TODO make use of these values to work out a factor for
  // throttling the addtion of attention
  
  //attentionSum[player]+=attention/attentionMax
  factor = 1.0/(attentionAverage*frequency*targetTime);
  
  //attentionSum[player]+=attention/(100.0*120*5);
  attentionSum[player]+=attention*factor;

  factor = 1.0/(meditationAverage*frequency*targetTime);
  
  //meditationSum[player]+=meditation/(100.0*120*5);
  meditationSum[player]+=meditation*factor;
  
  //println(attentionSum[player]);
  
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
