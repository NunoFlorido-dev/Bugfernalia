// --------------------------------------------------------------------------------------------------------------------------------------------
// SUPERCLASS FOR THE CREATION OF ANY BODY PART OF THE INSECT (SPECIES: TukTuk; Mondego; Praça; Pito)
// --------------------------------------------------------------------------------------------------------------------------------------------
abstract class BodyPart {
  int species;
  float size;
  float w;
  float h;
  float variation;
  color c1, c2, c3;
  float x, y;

  BodyPart(float x, float y, int species, float w, float h, float size, float variation, color c1, color c2, color c3) {
    this.species = species;
    this.size = size;
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.variation = variation;
    this.c1 = c1;
    this.c2 = c2;
    this.c3 = c3;
  }

  abstract void display(PGraphics c);
}

// --------------------------------------------------------------------------------------------------------------------------------------------
// HEAD
// --------------------------------------------------------------------------------------------------------------------------------------------

class Head extends BodyPart {
  Head(float x, float y, int species, float w, float h, float size, float variation, color c1, color c2, color c3) {
    super(x, y, species, w, h, size, variation, c1, c2, c3);
    this.species = species;
    this.w = w;
    this.x = x;
    this.y = y;
    this.h = h;
    this.size = size;
    this.variation = variation;
  }

  void tukTukHead(PGraphics c) {
    //float x = w / 2;
    //float y = h / 2;

    c.stroke(c1);
    c.fill(c2);
    c.ellipse(x + size, y, size * variation, size * variation);

    c.stroke(c3);
    c.noFill();
    c.arc(x + size, y, size * variation - 2, size * variation - 2, 0, PI);
  }

  void mondegoHead(PGraphics c) {
    c.rectMode(CENTER);
    //float x = w / 2;
    //float y = h / 2;

    c.stroke(c1);
    c.fill(c2);
    c.push();
    c.translate(x + size, y);

    c.rotate(QUARTER_PI * 7);
    c.line(0, 0, size, 0);
    c.rotate(HALF_PI);
    c.line(0, 0, size, 0);

    c.rotate(QUARTER_PI * 2);
    c.square(0, 0, size * variation);
    c.pop();

    c.stroke(c3);
    c.noFill();
    c.line(x + size + size/2, y, x + size/2, y);
  }

  void praçaHead(PGraphics c) {
    //float x = w / 2;
    //float y = h / 2;


    c.stroke(c1);
    c.fill(c2);
    c.line(x + size, y, x + size * variation, y);
    c.ellipse(x + size, y, size * variation, size * variation);

    c.stroke(c3);
    c.noFill();
    c.arc(x + size, y, size * variation - 2, size * variation - 2, 0, QUARTER_PI * 3);
  }

  void pitoHead(PGraphics c) {
    //float x = w / 2;
    //float y = h / 2;

    c.stroke(c1);
    c.fill(c2);

    c.push();
    c.translate(-size * 0.85, 0);
    c.beginShape();
    c.vertex(x + size * variation, y);
    c.vertex(x + size * variation * 1.5, y - size * variation / 2);
    c.vertex(x + size * variation * 2, y - size * variation / 4);
    c.vertex(x + size * variation * 1.65, y);
    c.vertex(x + size * variation * 2, y + size * variation / 4);
    c.vertex(x + size * variation * 1.5, y + size  * variation/ 2);
    c.vertex(x + size * variation, y);
    c.endShape(CLOSE);
    c.pop();

    c.stroke(c3);
    c.noFill();

    c.push();
    c.translate(-size * 0.85, 0);
    c.beginShape();
    c.vertex(x + size * variation, y);
    c.vertex(x + size * variation * 1.5, y - size * variation / 2);
    c.vertex(x + size * variation * 2, y - size * variation / 4);
    c.endShape();
    c.pop();
  }

  void display(PGraphics c) {
    if (species == 0) {
      tukTukHead(c);
    } else if (species == 1) {
      mondegoHead(c);
    } else if (species == 2) {
      praçaHead(c);
    } else if (species == 3) {
      pitoHead(c);
    }
  }
}

// --------------------------------------------------------------------------------------------------------------------------------------------
// BODY
// --------------------------------------------------------------------------------------------------------------------------------------------


class Body extends BodyPart {
  Body(float x, float y, int species, float w, float h, float size, float variation, color c1, color c2, color c3) {
    super(x, y, species, w, h, size, variation, c1, c2, c3);
    this.species = species;
    this.w = w;
    this.x = x;
    this.y = y;
    this.h = h;
    this.size = size;
    this.variation = variation;
  }

  void tukTukBody(PGraphics c) {
    //float x = w / 2;
    //float y = h / 2;


    c.stroke(c1);
    c.fill(c2);
    c.line(x - size, y, x, y);
    c.ellipse(x, y, size * variation, size * variation);

    c.stroke(c3);
    c.noFill();
    c.line(x - size / 4, y, x + size / 4, y);
  }

  void mondegoBody(PGraphics c) {
    rectMode(CENTER);
    //float x = w / 2;
    //float y = h / 2;

    c.stroke(c1);
    c.fill(c2);
    c.ellipse(x, y, size * variation, size * variation);

    c.stroke(c3);
    c.noFill();
    c.arc(x, y, size * variation - 1.5, size * variation - 1.5, PI, 3 * HALF_PI);
  }

  void praçaBody(PGraphics c) {
    //float x = w / 2;
    //float y = h / 2;

    c.stroke(c1);
    c.fill(c2);
    c.ellipse(x, y, size * variation, size * variation);

    c.stroke(c3);
    c.noFill();
    c.line(x - size / 2, y, x + size / 2, y);
  }

  void pitoBody(PGraphics c) {
    //float x = w / 2;
    //float y = h / 2;


    c.stroke(c1);
    c.fill(c2);

    c.ellipse(x, y, size * variation, size * variation * 0.5);

    c.fill(c3);
    c.noStroke();
    c.ellipse(x, y, size * 0.2, size * 0.2);
  }

  void display(PGraphics c) {
    if (species == 0) {
      tukTukBody(c);
    } else if (species == 1) {
      mondegoBody(c);
    } else if (species == 2) {
      praçaBody(c);
    } else if (species == 3) {
      pitoBody(c);
    }
  }
}

// --------------------------------------------------------------------------------------------------------------------------------------------
// LEGS
// --------------------------------------------------------------------------------------------------------------------------------------------


class Legs extends BodyPart {
  Legs(float x, float y, int species, float w, float h, float size, float variation, color c1, color c2, color c3) {
    super(x, y, species, w, h, size, variation, c1, c2, c3);
    this.species = species;
    this.w = w;
    this.x = x;
    this.y = y;
    this.h = h;
    this.size = size;
    this.variation = variation;
  }

  void tukTukLegs(PGraphics c) {
    //float x = w / 2;
    //float y = h / 2;

    c.push();
    c.translate(x - size, y - size / 2);
    c.rotate(QUARTER_PI);
    c.stroke(c1);
    c.fill(c2);
    c.ellipse(0, 0, size * variation, size * variation);

    c.stroke(c3);
    c.noFill();
    c.arc(0, 0, size * variation - 1.5, size * variation - 1.5, PI, 3 * HALF_PI);

    c.pop();

    c.push();
    c.translate(x - size, y + size / 2);
    c.rotate(-QUARTER_PI);
    c.stroke(c1);
    c.fill(c2);
    c.ellipse(0, 0, size * variation, size * variation);

    c.stroke(c3);
    c.noFill();
    c.arc(0, 0, size * variation - 1.5, size * variation - 1.5, PI, 3 * HALF_PI);
    c.pop();
  }

  void mondegoLegs(PGraphics c) {
    rectMode(CENTER);
    //float x = w / 2;
    //float y = h / 2;

    c.stroke(c1);
    c.fill(c2);
    c.line(x, y, x - size * variation, y - size * variation);
    c.line(x, y, x - size * variation, y + size * variation);


    float xt = x - size * variation;
    float yt = y - size * variation;
    c.line(xt, yt, xt - size * variation, yt);

    float xp = x - size * variation;
    float yp = y + size * variation;
    c.line(xp, yp, xp - size * variation, yp);
  }


  void praçaLegs(PGraphics c) {
    //float x = w / 2;
    //float y = h / 2;

    c.stroke(c1);
    c.fill(c2);
    c.line(x, y, x - size * variation, y - size * variation);
    c.line(x, y, x - size * variation, y + size * variation);


    float xt = x - size * variation;
    float yt = y - size * variation;
    c.line(xt, yt, xt - size * variation, yt);

    float xp = x - size * variation;
    float yp = y + size * variation;
    c.line(xp, yp, xp - size * variation, yp);
  }

  void pitoLegs(PGraphics c) {
    //float x = w / 2;
    //float y = h / 2;

    c.stroke(c1);
    c.fill(c2);
    c.line(x, y, x - size * variation, y - size * variation);
    c.line(x, y, x - size * variation, y + size * variation);


    c.line(x + size * variation / 4, y - size * variation / 2, x + size * variation / 4 + size / 4, y - size * variation / 2 - size * variation / 2);
    c.line(x + size * variation / 4, y + size * variation / 2, x + size * variation / 4 + size / 4, y + size * variation / 2 + size * variation / 2);



    float xt = x - size * variation;
    float yt = y - size * variation;
    c.line(xt, yt, xt - size * variation, yt);
    c.line(xt - size * variation, yt, xt - size * variation - size / 2, yt + 0.6);

    float xp = x - size * variation;
    float yp = y + size * variation;
    c.line(xp, yp, xp - size * variation, yp);
    c.line(xp - size * variation, yp, xp - size * variation - size / 2, yp - 0.6);
  }

  void display(PGraphics c) {
    if (species == 0) {
      tukTukLegs(c);
    } else if (species == 1) {
      mondegoLegs(c);
    } else if (species == 2) {
      praçaLegs(c);
    } else if (species == 3) {
      pitoLegs(c);
    }
  }
}
