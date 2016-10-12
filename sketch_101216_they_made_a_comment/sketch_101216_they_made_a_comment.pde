int WIDTH = 600;
int HEIGHT = WIDTH;
int MIDX = WIDTH / 2;
int MIDY = HEIGHT / 2;
int FRAME_RATE = 60;
int STROKE_WEIGHT = 4;

color BACKGROUND_COLOR;
color DRAW_COLOR;

int lastFrame;
float delta;

void setup()
{
  BACKGROUND_COLOR = color(#60c4f2);
  DRAW_COLOR = color(#f2bc60);
  strokeWeight(STROKE_WEIGHT);
  frameRate(FRAME_RATE);
  size(1, 1); //Work around for Processing 3.
  surface.setSize(WIDTH, HEIGHT);  
  fill(DRAW_COLOR);
  stroke(DRAW_COLOR);
}

void draw() {
  delta = (millis() - lastFrame) / 1000f;
  background(BACKGROUND_COLOR);
  stroke(DRAW_COLOR);
 
  lastFrame = millis();
}