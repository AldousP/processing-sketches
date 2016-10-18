int MIDX = width / 2;
int MIDY = height / 2;
int FRAME_RATE = 60;
int STROKE_WEIGHT = 1;

boolean DEBUG = true;

color DEBUG_COLOR;
color BACKGROUND_COLOR;
color DRAW_COLOR;

float E = (float) Math.E;

int lastFrame;
float delta;

Spring[] springs;

float tension = 0.065f;
float dampening = 0.05f;
float spread = 0.45f;

float waterLine;

float[] polygon;

float unit = 50;
int springsPerSide = 2;
int verts = 16;

void setup() {
  strokeWeight(STROKE_WEIGHT);
  frameRate(FRAME_RATE);
  size(600, 600); 
  // SET VARIABLES THAT DEPEND ON WIDTH AND HEIGHT   
  DEBUG_COLOR = color(#ba73a4);
  BACKGROUND_COLOR = color(#73baaa);
  DRAW_COLOR = color(#FFFFFF);

  float polygonX = width / 2;
  float polygonY = height / 2;

  polygon = polygon(polygonX, polygonY, width / 3, verts);
  springs = new Spring[(polygon.length / 2) * springsPerSide];

  Spring s;
  int springIndex = 0;
  for (int v = 0; v < verts; v++) {

    int index = v;

    float px1 = polygon[index * 2];
    float py1 = polygon[index * 2 + 1];

    index ++;
    if (index > verts - 1) {
      index = 0;
    }

    float px2 = polygon[index * 2];
    float py2 = polygon[index * 2 + 1];

    float midX = (px1 + px2) / 2;
    float midY = (py1 + py2) / 2;

    float distance = sqrt(pow(px2 - px1, 2) + pow(py2 - py1, 2));

    for (int i = 0; i < springsPerSide; i ++) {
      s = new Spring();
      if (i == 0) {
        s.rotation = getRelativeRotationOfPoint(px1, py1, polygonX, polygonY);
      } else {
        s.rotation = getRelativeRotationOfPoint(midX, midY, polygonX, polygonY);
      }

      float rot = getRelativeRotationOfPoint(px1, py1, px2, py2);
      PVector point = PVector.fromAngle(radians(rot));

      point.setMag( ((float)i / (float)springsPerSide) * abs(distance));
      s.x = point.x + px1;
      s.y = point.y + py1;
      springs[springIndex] = s;
      springIndex ++;
    }
  }
}

void draw() {
  delta = (millis() - lastFrame) / 1000f;
  lastFrame = millis();
  background(BACKGROUND_COLOR);

  noStroke();
  fill(DRAW_COLOR);
  updateSimulation();

  stroke(DRAW_COLOR);
  strokeWeight(10);
  int length = springs.length;
  float lastX = springs[length - 1].oX;
  float lastY = springs[length - 2].oY;
  
  for (int i = 0; i < springs.length; i+= 1) {
    Spring sp = springs[i];
    float x = sp.oX;
    float y = sp.oY;
    line(lastX, lastY, x, y);
    lastX = x;
    lastY = y; 
  }

  for (int i = 0; i < springs.length; i ++) {
    float alpha = (float) i / (float)springs.length;
    Spring col = springs[i];
    col.render();
  }
}

void keyPressed() {
  int index = 0;
  if (key == '1') {
    index = 1;
  }

  if (key == '2') {
    index = 2;
  }

  if (key == '3') {
    index = 3;
  }

  if (key == '4') {
    index = 4;
  }

  if (key == '5') {
    index = 5;
  }

  if (index == 0) return;
  float indexFloat = ((verts * springsPerSide) / 5) * index - 1;
  splash((int)indexFloat, 50);
}

float alphaSmooth(float alpha) {
  return alpha * alpha * alpha * (alpha * (alpha * 6 - 15) + 10);
}

float getAngle(PVector vec) {
  return (float)Math.atan2(vec.y, vec.x);
}

void updateSimulation() {
  for (int i = 0; i < springs.length; i++)
    springs[i].update(dampening, tension);

  float[] lDeltas = new float[springs.length];
  float[] rDeltas = new float[springs.length];

  // do some passes where springs pull on their neighbours
  for (int j = 0; j < 8; j++)
  {
    for (int i = 0; i < springs.length; i++)
    {
      if (i > 0)
      {
        lDeltas[i] = spread * (springs[i].currentLength - springs[i - 1].currentLength);
        springs[i - 1].speed += lDeltas[i];
      }
      if (i < springs.length - 1)
      {
        rDeltas[i] = spread * (springs[i].currentLength - springs[i + 1].currentLength);
        springs[i + 1].speed += rDeltas[i];
      }
    }

    for (int i = 0; i < springs.length; i++)
    {
      if (i > 0)
        springs[i - 1].currentLength += lDeltas[i];
      if (i < springs.length - 1)
        springs[i + 1].currentLength += rDeltas[i];
    }
  }
}

void splash(int index, float speed) { 
  springs[index].speed = speed;
}


float[] polygon(float x, float y, float radius, int npoints) {
  float[] polygon = new float[npoints * 2];
  float angle = TWO_PI / npoints;
  beginShape();
  int i = 0;
  for (int pt = 0; pt < npoints; pt++) {
    float sx = x + cos(pt * angle) * radius;
    float sy = y + sin(pt * angle) * radius;
    polygon[i] = sx;
    polygon[i + 1] = sy;
    i+= 2;
  }
  return polygon;
}

public float getRelativeRotationOfPoint(float originX, float originY, float ptX, float ptY) {
  float result = degrees(atan2(ptY - originY, ptX - originX));
  if (result < 0) {
    result += 360;
  }
  return result;
}

class Spring {
  float length = 40;
  float currentLength = 40;
  float x;
  float y;
  float rotation = 180;
  float speed;
  float oX;
  float oY;

  void update(float dampening, float tension) {
    float diff = length - currentLength;
    speed += tension * diff - speed * dampening;
    currentLength += speed;
    
    oX = cos(radians(rotation)) * currentLength + x;
    oY = sin(radians(rotation)) * currentLength + y;
  }

  void render() {
    noFill();
    stroke(DRAW_COLOR);
    ellipse(x, y, 15, 15);
    stroke(DEBUG_COLOR);
    ellipse(oX, oY, 15, 15);
    line(oX, oY, x, y);
  }
}