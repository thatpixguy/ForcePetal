import processing.serial.*;

Serial port;
PFont font;

PImage backgroundImage;

ArrayList serialLog;

float attentionSum[];
float meditationSum[];

void setup() {
  size(1280,760);
  
  //font = loadFont("CenturyGothic-48.vlw");
  //textFont(font,18);
  
  println(PFont.list());
  textFont(createFont("PMingLiu",30,true));
  
  println(Serial.list());
  port = new Serial(this,Serial.list()[12],9600);

  port.bufferUntil(10);
  
  serialLog = new ArrayList();
  
  backgroundImage = loadImage("brain-battle-01.jpg");
  
  attentionSum = new float[2];
  meditationSum = new float[2];
  
  smooth();
}

void draw() {
  //background(0);
  image(backgroundImage,0,0);

  drawSerialLog();
  rectMode(CORNERS);
  rect(645,177,1280,308);
  fill(0,255,0);
  float f = attentionSum[1];
  rect(645*f+1280*(1-f),177,1280,308);
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
  if (signal>100) {
    return;
  }
  
  float targetTime = 180; //secs
  float frequency = 2; //samples per second
  float attentionAverage = 40;
  float meditationAverage = 40;

  //float attentionMax = 100;
  
  //TODO make use of these values to work out a factor for
  // throttling the addtion of attention
  
  //attentionSum[player]+=attention/attentionMax
  float factor = 1.0/(attentionAverage*frequency*targetTime);
  
  //attentionSum[player]+=attention/(100.0*120*5);
  attentionSum[player]+=attention*factor;

  float factor = 1.0/(meditationAverage*frequency*targetTime);
  
  //meditationSum[player]+=meditation/(100.0*120*5);
  meditationSum[player]+=meditation*factor;
  
  println(attentionSum[player]);
  
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
