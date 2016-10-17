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

float rainTimer;
float rainInterval = 1;

float tension = 0.045f;
float dampening = 0.005f;
float spread = 0.45f;

float waterLine;

float[] polygon;

float unit = 50;
int springsPerUnit = 1;

void setup() {
  strokeWeight(STROKE_WEIGHT);
  frameRate(FRAME_RATE);
  size(600, 600); 
  // SET VARIABLES THAT DEPEND ON WIDTH AND HEIGHT   
  waterLine =  height - height / 3;
  DEBUG_COLOR = color(#ba73a4);
  BACKGROUND_COLOR = color(#73baaa);
  DRAW_COLOR = color(#FFFFFF);

  float polygonX = width / 2;
  float polygonY = height / 2;

  polygon = polygon(polygonX, polygonY, width / 4, 4);

  springs = new Spring[polygon.length / 2];

  Spring s;
  for (int i = 0; i < springs.length; i++) {
    s = new Spring();
    s.x = polygon[i * 2];
    s.y = polygon[i * 2 + 1];
    s.speed = 0;
    
    springs[i] = s;
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
  strokeWeight(1);
  int length = polygon.length;
  float lastX = polygon[length - 2];
  float lastY = polygon[length - 1];
  for (int i = 0; i < polygon.length; i+= 2) {
    line(lastX, lastY, polygon[i], polygon[i + 1]);
    lastX = polygon[i];
    lastY = polygon[i + 1];
  }

  for (int i = 0; i < springs.length; i ++) {
    float alpha = (float) i / (float)springs.length;
    Spring col = springs[i];
    col.render();
  }
}

void keyPressed() {
  if (key == '1') {
    splash(0, 50);
  }

  if (key == '2') {
    splash(32, 50);
  }

  if (key == '3') {
    splash(64, 50);
  }

  if (key == '4') {
    splash(96, 50);
  }

  if (key == '5') {
    splash(128, 50);
  }
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
  for (int i = max(0, index - 0); i < min(springs.length - 1, index + 1); i++)
    springs[index].speed = speed;
}


float[] polygon(float x, float y, float radius, int npoints) {
  float[] polygon = new float[npoints * 2];
  float angle = TWO_PI / npoints;
  beginShape();
  int i = 0;
  for (float a = 0; a < TWO_PI; a += angle) {
    float sx = x + cos(a) * radius;
    float sy = y + sin(a) * radius;
    polygon[i] = sx;
    polygon[i + 1] = sy;
    i+= 2;
  }
  return polygon;
}

class Spring {
  float length = 20;
  float currentLength = 2;
  float x;
  float y;
  float rotation = 180;
  float speed;
  
  void update(float dampening, float tension) {
    float diff = length - currentLength;
    speed += tension * diff - speed * dampening;
    currentLength += speed;
  }

  void render() {
    noFill();
    stroke(DRAW_COLOR);
    ellipse(x, y, 15, 15);
    stroke(DEBUG_COLOR);
    float oX = cos(radians(rotation)) * length + x;
    float oY = sin(radians(rotation)) * length + y;
    ellipse(oX, oY, 15, 15);
  }
}