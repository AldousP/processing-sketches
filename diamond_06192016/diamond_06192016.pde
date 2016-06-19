int WIDTH = 600;
int HEIGHT = WIDTH;
int MIDX = WIDTH / 2;
int MIDY = HEIGHT / 2;
int FRAME_RATE = 60;
int STROKE_WEIGHT = 4;
int DIAMOND_VERTICES = 8;
float SUBDIVISION = 360 / DIAMOND_VERTICES;
float DIAMOND_HEIGHT = HEIGHT * 0.75f;
float DEGREES_PER_SECOND = 45;
float V_SCALING_FACTOR = 0.2;
float MAX_RADIUS = WIDTH / 4;
float MIN_RADIUS = 0;
float RADIUS_INCREMENT = 25;

color BACKGROUND_COLOR;
color DRAW_COLOR;

int lastFrame;
float delta;
float baseDegree = 0;
float tempDegree;
float x = 0;
float y;
float lastX1;
float lastY1;
float lastX2;
float lastY2;
float radius;

void setup()
{
  BACKGROUND_COLOR = color(#FF6B6B);
  DRAW_COLOR = color(#4ECDC4);
  strokeWeight(STROKE_WEIGHT);
  frameRate(FRAME_RATE);
  size(1, 1); //Work around for Processing 3.
  surface.setSize(WIDTH, HEIGHT);  
  fill(DRAW_COLOR);
  stroke(DRAW_COLOR);
  println(MIN_RADIUS);
  println(MAX_RADIUS);
}

void draw() {
  delta = (millis() - lastFrame) / 1000f;
  background(BACKGROUND_COLOR);
  
  radius += RADIUS_INCREMENT * delta;
  
  if ( ((RADIUS_INCREMENT < 0) && radius < MIN_RADIUS) || ((RADIUS_INCREMENT > 0) && radius > MAX_RADIUS)) {
    RADIUS_INCREMENT *= -1;  
  }  
                    

  baseDegree +=  DEGREES_PER_SECOND * delta;
  baseDegree = baseDegree % 360;
  for (int i = 0; i < DIAMOND_VERTICES; i++) {
    tempDegree = baseDegree + SUBDIVISION * i;
    tempDegree = tempDegree % 360;
      x = (sin(radians(tempDegree)) * radius) + MIDX;
      y = (cos(radians(tempDegree)) * radius * V_SCALING_FACTOR) + MIDY;
      line(x, y, MIDX, MIDY + DIAMOND_HEIGHT / 2);
      line(x, y, MIDX, MIDY - DIAMOND_HEIGHT / 2);
      line(x, y, lastX1, lastY1);
      lastX1 = x;
      lastY1 = y;
      
      x = (sin(radians(tempDegree)) * radius / 2) + MIDX;
      y = (cos(radians(tempDegree)) * radius / 2 * V_SCALING_FACTOR) + MIDY;
      line(x, y, MIDX, MIDY + DIAMOND_HEIGHT / 2);
      line(x, y, MIDX, MIDY - DIAMOND_HEIGHT / 2);
      line(x, y, lastX2, lastY2);
      lastX2 = x;
      lastY2 = y;
  }
  lastFrame = millis();
}