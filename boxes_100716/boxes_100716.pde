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

float rectW = 200;
float rectH = 200;
float i;
float stroke = 15;
float waveLength = 1;
float waveTimer;
float waveZoomInterval = 1;

void setup()
{
  BACKGROUND_COLOR = color(#3a3e44);
  DRAW_COLOR = color(#ffffff);
  strokeWeight(STROKE_WEIGHT);
  frameRate(FRAME_RATE);
  size(1, 1); //Work around for Processing 3.
  surface.setSize(WIDTH, HEIGHT);  
  fill(DRAW_COLOR);
  stroke(DRAW_COLOR);
}

void draw() {
  delta = (millis() - lastFrame) / 1000f;
  lastFrame = millis();
  
  waveTimer += delta;
  if (waveTimer > waveZoomInterval) {
    waveTimer -= waveZoomInterval;
    waveLength -= 0.5f;
  }
  background(BACKGROUND_COLOR);  
  float perc;
  float baseY = HEIGHT / 2;
  for (int i = 0; i < 600; i ++) {
    perc = (float) i / (float) WIDTH;    
    float x = (float) (perc * (2 * Math.PI));
    float y = baseY + (HEIGHT / 2) * sin(waveLength * x);
    stroke(DRAW_COLOR);
    fill(DRAW_COLOR);
    ellipse(i, y, stroke, stroke);
  }

  
}