import netP5.*;
import oscP5.*;

int canvasWidth = 350;
int canvasHeight = 24;

HourTheme[] themes;

PGraphics canvas; // https://processing.org/reference/PGraphics.html
Tx tx;

Insect insect;
ArrayList<Insect> mainInsects = new ArrayList();
ArrayList<Insect> bgInsects = new ArrayList();

int headSpecies = int(random(0, 4));
int bodySpecies = int(random(0, 4));
int legsSpecies = int(random(0, 4));
int paletteIndex = int(random(0, 12));

int darkerIndex = paletteIndex;
int middleIndex = paletteIndex;
int lightIndex = paletteIndex;

color darkerColor, middleColor, lightColor;

int h;
float hComplete;
int numberBugsBackground;
float[] hourSwitch = {0, 6, 8, 12, 18, 21, 22, 24};

OscP5 oscP5;
int totalPeople;

void settings() {
  // Find the larger scaling that fits your screen
  float scaling = 10;
  while (canvasWidth * scaling > displayWidth) scaling--;
  size(int(canvasWidth * scaling), int(canvasHeight * scaling));
  pixelDensity(1); // Do not remove this line
  noSmooth(); // Do not remove this line
}

void setup() {

  themes = new HourTheme[] {
    new HourTheme(b_midnight, bs_midnight, d_midnight, m_midnight),
    new HourTheme(b_sixAM, bs_sixAM, d_sixAM, m_sixAM),
    new HourTheme(b_eightAM, bs_eightAM, d_eightAM, m_eightAM),
    new HourTheme(b_noon, bs_noon, d_noon, m_noon),
    new HourTheme(b_sixPM, bs_sixPM, d_sixPM, m_sixPM),
    new HourTheme(b_ninePM, bs_ninePM, d_ninePM, m_ninePM),
    new HourTheme(b_tenPM, bs_tenPM, d_tenPM, m_tenPM),
  };

  frameRate(30);
  canvas = createGraphics(canvasWidth, canvasHeight);
  tx = new Tx(canvasWidth, canvasHeight);

  oscP5 = new OscP5(this, 8000);

  //DEFINE INSECT PLACEHOLDER
  //insect = new Insect(width / 2, height / 2, headSpecies, bodySpecies, legsSpecies, canvasWidth, canvasHeight, 8, darkerTonePalette[paletteIndex], middleTonePalette[paletteIndex], lightTonePalette[paletteIndex]);
///insect.initializeParts();
}

void oscEvent(OscMessage theOscMessage) {
  println("OSC received: " + theOscMessage.addrPattern());

  if (theOscMessage.checkAddrPattern("/person_count")) {
    int newTotal = theOscMessage.get(0).intValue();

    //trim if people left
    while (mainInsects.size() > newTotal) {
      mainInsects.remove(mainInsects.size() - 1);
    }
    totalPeople = newTotal;
  } else if (theOscMessage.addrPattern().contains("/person/") &&
    theOscMessage.addrPattern().endsWith("/pos")) {

    //get the person index
    String[] parts = theOscMessage.addrPattern().split("/");
    int personId = int(parts[2]); //index (0, 1, ...)

    //map the x and y from the camera to the canvas
    int x = int(map(theOscMessage.get(0).intValue(), 0, 640, -canvasWidth / 2, canvasWidth / 2));
    int y = int(map(theOscMessage.get(1).intValue(), 0, 480, 5, canvasHeight - 5));

    //see if insect with this ID already exists
    boolean found = false;
    for (Insect it : mainInsects) {
      if (it.id == personId) {
        it.targetX = x;
        it.targetY = y;
        found = true;
        break;
      }
    }
    //if not found, insert a new one
    if (!found) {
      Insect it = new Insect(personId, x, y, headSpecies, bodySpecies, legsSpecies, canvasWidth, canvasHeight, 8, darkerTonePalette[paletteIndex], middleTonePalette[paletteIndex], lightTonePalette[paletteIndex]);
      it.targetX = x;
      it.targetY = y;
      randomizeInsect(it);
      mainInsects.add(it);
    }
  }
}

void draw() {
  // Draw animation on a (offscreen) canvas
  h = hour();
  hComplete = hour() + minute() / 60.0 + second() / 3600.0;
  HourTheme theme = Gradient(hComplete);
  canvas.beginDraw();
  canvas.background(0);

  drawBackground(canvas, theme.bg1, theme.bg2, 0.4);

  int targetNumber = nrBugsBG(h);
  if (bgInsects.size() < targetNumber) {
    Insect bg = new Insect(0,
      random(canvasWidth), random(canvasHeight),
      int(random(4)), int(random(4)), int(random(4)),
      canvasWidth, canvasHeight,
      2,
      theme.bug1, theme.bug2, theme.bug2
      );


    bg.initializeParts();
    bg.initflock();
    bgInsects.add(bg);
  }

  if (bgInsects.size() > targetNumber) {
    bgInsects.remove(bgInsects.size()-1);
  }

  for (int i = 0; i < bgInsects.size(); i++) {
    Insect bg = bgInsects.get(i);
    /*if (frameCount % int(random(60,180)) == 0){
     bg.targetX = random(canvasWidth);
     bg.targetY = random(canvasHeight);
     }
     bg.update();*/
    bg.flock();
    bg.updateBackground();
    bg.display(canvas);
  }

  for (int i = 0; i < mainInsects.size(); i++) {
    Insect it = mainInsects.get(i);
    it.update(); //make it move
    it.display(canvas); //display each insect
  }
  //insect.display(canvas);
  canvas.endDraw();

  // Draw canvas on window
  image(canvas, 0, 0, width, height);

  // Send canvas to server
  tx.send(canvas);
}


//Randomize the entire insect
void randomizeInsect(Insect it) {
  int iHead = int(random(0, 4));
  int iBody = int(random(0, 4));
  int iLegs = int(random(0, 4));
  int iPalette = int(random(0, 12));

  int iDarker, iMiddle, iLight;
  float probPalette = random(1);
  if (probPalette >= 0.6) {
    iDarker = int(random(0, 12));
    iMiddle = int(random(0, 12));
    iLight = int(random(0, 12));
  } else {
    iDarker = iPalette;
    iMiddle = iPalette;
    iLight = iPalette;
  }

  it.defineVariation(iHead, iBody, iLegs);
  it.redefineColors(darkerTonePalette[iDarker], middleTonePalette[iMiddle], lightTonePalette[iLight]);
  it.updateInsectParts(iHead, iBody, iLegs);
}

//Update the fallback insect
void updateEntireInsect() {
  randomizeInsect(insect);
}

void drawBackground(PGraphics c, color c1, color c2, float noiseC) {
  c.loadPixels();
  for (int x=0; x<canvasWidth; x++) {
    for (int y=0; y<canvasHeight; y++) {
      float n = noise(x*noiseC + frameCount * 0.001, y*noiseC + frameCount * 0.001);
      if (n > 0.5) {
        c.pixels[y * canvasWidth + x] = c1;
      } else {
        c.pixels[y * canvasWidth + x] = c2;
      }
    }
  }
  c.updatePixels();
}

int nrBugsBG(int h) {
  int nrBugsBackground;
  if (h>= 9 && h<= 19) {
    float peakMax = abs(h-14); //14 sendo o pico do máximo de movimento
    nrBugsBackground = int(map(peakMax, 5, 0, 100, 60));
  } else if (h >= 6 && h < 9) {
    nrBugsBackground = int(map(h, 6, 9, 60, 40));
  } else if (h >= 19 && h < 23) {
    nrBugsBackground = int(map(h, 19, 23, 40, 20));
  } else {
    nrBugsBackground = int(map(h, 0, 6, 10, 20));
  }
  return constrain(nrBugsBackground, 1, 50); // ← garante mínimo de 1
}
/*
HourTheme getTheme(int h) {
 if(h < 6){
 return themes[0];
 }
 else if(h < 8){
 return themes[1];
 }
 else if (h < 12){
 return themes[2];
 }
 else if (h < 18){
 return themes[3];
 }
 else if (h < 21){
 return themes[4];
 }
 else if (h < 22){
 return themes[5];
 }
 else{
 return themes[6];
 }
 }*/

HourTheme lerpTheme(HourTheme a, HourTheme b, float amount) {
  return new HourTheme(
    lerpColor(a.bg1, b.bg1, amount),
    lerpColor(a.bg2, b.bg2, amount),
    lerpColor(a.bug1, b.bug1, amount),
    lerpColor(a.bug2, b.bug2, amount)
    );
}

HourTheme Gradient(float h) {
  for (int i = 0; i < hourSwitch.length - 1; i++) {
    if (h >= hourSwitch[i] && h < hourSwitch[i+1]) {//verifica em que intervalo a hora está
      float amount = map(h, hourSwitch[i], hourSwitch[i+1], 0, 1); //onde é que a posição se situa no intervalo
      int nextIndex = (i + 1) % themes.length; //e identifica o proximo intervalo
      return lerpTheme(themes[i], themes[nextIndex], amount);
    }
  }
  return themes[0]; // 24h → volta a 0h
}

void keyPressed() {
  if (key == 'h' || key == 'H') {
    headSpecies = (headSpecies + 1) % 4;
    insect.defineHeadVariation(headSpecies);
    insect.updateHeadPart(headSpecies);
  }
  if (key == 'b' || key == 'B') {
    bodySpecies = (bodySpecies + 1) % 4;
    insect.defineBodyVariation(bodySpecies);
    insect.updateBodyPart(bodySpecies);
  }
  if (key == 'l' || key == 'L') {
    legsSpecies = (legsSpecies + 1) % 4;
    insect.defineLegsVariation(legsSpecies);
    insect.updateLegsPart(legsSpecies);
  }
  if (key == ' ') {
    updateEntireInsect();
  }

  if (key == 'e' || key == 'E') {
    paletteIndex = (paletteIndex + 1) % 12;
    darkerColor = darkerTonePalette[paletteIndex];
    middleColor = middleTonePalette[paletteIndex];
    lightColor = lightTonePalette[paletteIndex];

    insect.redefineColors(darkerColor, middleColor, lightColor);
    insect.updateInsectParts(headSpecies, bodySpecies, legsSpecies);
  }
}
