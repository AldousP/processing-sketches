int WIDTH = 600;
int HEIGHT = WIDTH;
int FRAME_RATE = 60;
int STROKE_WEIGHT = 2;

color BACKGROUND_COLOR;
color DRAW_COLOR;

int lastFrame;
float delta;
int offset;

void setup()
{
  BACKGROUND_COLOR = color(#1595c4);
  DRAW_COLOR = color(#ffa719);
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
  lastFrame = millis();
  fill(DRAW_COLOR);
  
  offset++;

  for (int i = 0; i < WIDTH; i++) {
    
    ellipse(i, sin(i + offset) * offset + HEIGHT / 2, 5 , 5);
  }
}