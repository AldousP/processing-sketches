int PADDING;
int WIDTH;
int HEIGHT;
int CIRCLE_COUNT;
float SIZE_INCREMENT;
float CIRCLE_MIN_SIZE;
float CIRCLE_MAX_SIZE;
float CIRCLE_SIZE_INCREMENT;
float circleSize;
color BACKGROUND;

void setup()
{
  BACKGROUND = color(#331947);

  WIDTH = 600;
  HEIGHT = WIDTH;
  CIRCLE_COUNT = 7;
  CIRCLE_SIZE_INCREMENT = .05;
  CIRCLE_MIN_SIZE = WIDTH / 64;
  CIRCLE_MAX_SIZE = WIDTH / 16;
  PADDING = WIDTH / 16;
  circleSize = CIRCLE_MAX_SIZE; 
  
  frameRate(60);
  size(1, 1); //Work around for Processing 3.
  surface.setSize(WIDTH, HEIGHT);
}

void draw() {
  background(BACKGROUND);
  stroke(0, 0, 0, 0);
  float dividend = (WIDTH - PADDING * 2) / CIRCLE_COUNT;
  for (int i = 0; i < CIRCLE_COUNT; i ++) {
    for (int j = 0; j < CIRCLE_COUNT; j ++) {
      ellipse(PADDING + dividend / 2 + dividend * i, PADDING + dividend / 2 + dividend * j, circleSize, circleSize);
    }
  }
  circleSize += CIRCLE_SIZE_INCREMENT;
  if (CIRCLE_SIZE_INCREMENT < 0) {
    if (circleSize <= CIRCLE_MIN_SIZE) {
      circleSize = CIRCLE_MIN_SIZE;
      CIRCLE_SIZE_INCREMENT = -1 * CIRCLE_SIZE_INCREMENT;
    }
  } else {
    if (circleSize >= CIRCLE_MAX_SIZE) {
      circleSize = CIRCLE_MAX_SIZE;
      CIRCLE_SIZE_INCREMENT = -1 * CIRCLE_SIZE_INCREMENT;
    }
  }
}