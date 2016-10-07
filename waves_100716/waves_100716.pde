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

float strokeTimer = 0;
float strokeIntervalLength = 3;
float strokeMinSize = 5;
float strokeMaxSize = 15;

float strokeRange = .1;

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
  lastFrame = millis();

  // Manage timer for length of stroke.
  strokeTimer += delta;
  if(strokeTimer >= strokeIntervalLength) {
    strokeTimer -= strokeIntervalLength;
  }
  float strokeProgress = (float) strokeTimer / (float) strokeIntervalLength;
  background(BACKGROUND_COLOR);
  stroke(DRAW_COLOR);
  fill(DRAW_COLOR);
  
  float perc;
  float baseY = HEIGHT / 2;
  for (int i = 0; i < 600; i ++) {
    perc = (float)i / (float) WIDTH;
    float x = (float) (perc * (2 * Math.PI));
    float y = baseY + (HEIGHT / 2) * sin(x);
    float stroke = strokeMinSize;
    float floor = strokeProgress - strokeRange;
    float ceil = strokeProgress + strokeRange;

    if (perc > floor && perc < ceil) {
      if (perc > strokeProgress) {
        stroke = lerp(strokeMinSize, strokeMaxSize, (ceil - perc) / strokeRange);
      } else {
        stroke = lerp(strokeMinSize, strokeMaxSize, (perc - floor) / strokeRange);
      }
    } 
     
    ellipse(i, y, stroke, stroke);
  }
}