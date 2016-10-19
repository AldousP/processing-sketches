
int FRAME_RATE = 60;
int STROKE_WEIGHT = 1;

boolean DEBUG = true;

color DEBUG_COLOR;
color BACKGROUND_COLOR;
color DRAW_COLOR;

int lastFrame;
float delta;

int MIDX;
int MIDY;

void setup()
{
  strokeWeight(STROKE_WEIGHT);
  frameRate(FRAME_RATE);
  size(600, 600); 
  // SET VARIABLES THAT DEPEND ON WIDTH AND HEIGHT 
  MIDX = width / 2;
  MIDY = height / 2;
  DEBUG_COLOR = color(#FFFFFF);
  BACKGROUND_COLOR = color(#FFFFFF);
  DRAW_COLOR = color(#222222);
}

void draw() {
  delta = (millis() - lastFrame) / 1000f;
  lastFrame = millis();
  background(BACKGROUND_COLOR);
  if (DEBUG) {
    noFill();
    stroke(DEBUG_COLOR);
    line(-1, height / 2, height + 1, height / 2);
    line(width / 2, -1, width / 2, height + 1);
  }
  fill(DRAW_COLOR);
  ellipse(MIDX, MIDY, 30, 30);
}