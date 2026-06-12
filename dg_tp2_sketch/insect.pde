class Insect {
  float x, y;
  float size, w, h;
  int headSpeciesIndex, bodySpeciesIndex, legsSpeciesIndex;
  Head head;
  Body body;
  Legs legs;

  float vH, vB, vL;
  color c1, c2, c3;

  float targetX, targetY; //target x and y for motion/lerping
  float lerpSpeed = 0.05;

  Insect(float tempX, float tempY, int tempHeadSpecies, int tempBodySpecies, int tempLegsSpecies, float tempW, float tempH, float tempSize, color tempC1, color tempC2, color tempC3) {
    headSpeciesIndex = tempHeadSpecies;
    bodySpeciesIndex = tempBodySpecies;
    legsSpeciesIndex = tempLegsSpecies;
    x = tempX;
    y = tempY;
    w = tempW;
    h = tempH;
    size = tempSize;

    c1 = tempC1;
    c2 = tempC2;
    c3 = tempC3;
  }

  //update its position
  void update() {
    x = lerp(x, targetX, lerpSpeed);
    y = lerp(y, targetY, lerpSpeed);
    updateInsectParts(headSpeciesIndex, bodySpeciesIndex, legsSpeciesIndex);
  }


  //initialize its variation, colors and parts
  void initializeParts() {
    defineVariation(headSpeciesIndex, bodySpeciesIndex, legsSpeciesIndex);
    redefineColors(c1, c2, c3);
    updateInsectParts(headSpeciesIndex, bodySpeciesIndex, legsSpeciesIndex);
  }

  //functions to define variations

  void defineHeadVariation(int a) {
    if (a == 0) {
      vH = random(0.8, 0.95);
    } else if (a == 1) {
      vH = random(0.8, 0.89);
    } else if (a == 2) {
      vH = random(0.7, 0.75);
    } else if (a == 3) {
      vH = random(1, 1.5);
    }
  }

  void defineBodyVariation(int a) {
    if (a == 0) {
      vB = random(0.97, 1.18);
    } else if (a == 1) {
      vB = random(0.55, 0.87);
    } else if (a == 2) {
      vB = random(1.3, 1.54);
    } else if (a == 3) {
      vB = random(0.55, 0.87);
    }
  }

  void defineLegsVariation(int a) {
    if (a == 0) {
      vL = random(0.48, 0.83);
    } else if (a == 1) {
      vL = random(0.6, 0.7);
    } else if (a == 2) {
      vL = random(0.4, 0.8);
    } else if (a == 3) {
      vL = random(0.4, 0.8);
    }
  }

  void defineVariation(int a, int b, int c) {
    defineHeadVariation(a);
    defineBodyVariation(b);
    defineLegsVariation(c);
  }

  //redefining the color palette of the insect
  void redefineColors(int a, int b, int c) {
    c1 = a;
    c2 = b;
    c3 = c;
  }

 //display the insect
  void display(PGraphics c) {
    legs.display(c);
    body.display(c);
    head.display(c);
  }
  
  //update its parts

  void updateHeadPart(int a) {
    headSpeciesIndex = a;

    head = new Head(x, y, headSpeciesIndex, w, h, size, vH, c1, c2, c3);
  }

  void updateBodyPart(int a) {
    bodySpeciesIndex = a;

    body = new Body(x, y, bodySpeciesIndex, w, h, size, vH, c1, c2, c3);
  }

  void updateLegsPart(int a) {
    legsSpeciesIndex = a;

    legs = new Legs(x, y, legsSpeciesIndex, w, h, size, vH, c1, c2, c3);
  }

  void updateInsectParts(int a, int b, int c) {
    updateHeadPart(a);
    updateBodyPart(b);
    updateLegsPart(c);
  }
}
