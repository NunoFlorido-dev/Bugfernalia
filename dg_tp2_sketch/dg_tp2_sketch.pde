import netP5.*;
import oscP5.*;

int canvasWidth = 350;
int canvasHeight = 24;

PGraphics canvas; // https://processing.org/reference/PGraphics.html
Tx tx;

Insect insect;
ArrayList<Insect> mainInsects = new ArrayList();

int headSpecies = int(random(0, 4));
int bodySpecies = int(random(0, 4));
int legsSpecies = int(random(0, 4));
int paletteIndex = int(random(0, 12));

int darkerIndex = paletteIndex;
int middleIndex = paletteIndex;
int lightIndex = paletteIndex;

color darkerColor, middleColor, lightColor;

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
  frameRate(30);
  canvas = createGraphics(canvasWidth, canvasHeight);
  tx = new Tx(canvasWidth, canvasHeight);

  oscP5 = new OscP5(this, 8000);

  //DEFINE INSECT PLACEHOLDER
  insect = new Insect(width / 2, height / 2, headSpecies, bodySpecies, legsSpecies, canvasWidth, canvasHeight, 8, darkerTonePalette[paletteIndex], middleTonePalette[paletteIndex], lightTonePalette[paletteIndex]);
  insect.initializeParts();
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
    int personIndex = int(parts[2]) - 1; //index (0, 1, ...)

    //map the x and y from the camera to the canvas
    int x = int(map(theOscMessage.get(0).intValue(), 0, 640, -canvasWidth - 20, canvasWidth/2 + 20));
    int y = int(map(theOscMessage.get(1).intValue(), 0, 480, -32.5, canvasHeight + 5));

    if (personIndex < mainInsects.size()) {
      Insect it = mainInsects.get(personIndex);
      it.targetX = x;
      it.targetY = y;
    } else {
      //if it is higher, create a new insect
      Insect it = new Insect(x, y, headSpecies, bodySpecies, legsSpecies, canvasWidth, canvasHeight, 8, darkerTonePalette[paletteIndex], middleTonePalette[paletteIndex], lightTonePalette[paletteIndex]);
      //make the actual x and y the ones he moves to
      it.targetX = x;
      it.targetY = y;
      randomizeInsect(it); //randomize its values before adding it
      mainInsects.add(it); //add it to the arraylist
    }
  }
}

void draw() {
  // Draw animation on a (offscreen) canvas
  canvas.beginDraw();
  canvas.background(0);
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
