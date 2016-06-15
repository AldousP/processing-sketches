int PADDING;
int WIDTH;
int HEIGHT;
int CIRCLE_COUNT;
int FRAME_RATE;
float SIZE_INCREMENT;
float CIRCLE_MIN_SIZE;
float CIRCLE_MAX_SIZE;
float CIRCLE_SIZE_INCREMENT;
float TEMP_CIRCLE_SIZE_INCREMENT;
float startingCircleSize;
color BACKGROUND_COLOR;
color CIRCLE_COLOR;

void setup()
{
  BACKGROUND_COLOR = color(#212F3C);
  CIRCLE_COLOR = color(#FADBD8);

  FRAME_RATE = 60;
  WIDTH = 600;
  HEIGHT = WIDTH;
  CIRCLE_COUNT = 7;
  CIRCLE_SIZE_INCREMENT = 0.05f;
  CIRCLE_MIN_SIZE = WIDTH / 64;
  CIRCLE_MAX_SIZE = WIDTH / 16;
  PADDING = WIDTH / 16;
  startingCircleSize = CIRCLE_MAX_SIZE; 

  frameRate(FRAME_RATE);
  size(1, 1); //Work around for Processing 3.
  surface.setSize(WIDTH, HEIGHT);
}

void draw() {
  background(BACKGROUND_COLOR);
  stroke(0, 0, 0, 0);
  fill(CIRCLE_COLOR);
  println(frameCount % FRAME_RATE);

  float dividend = (WIDTH - PADDING * 2) / CIRCLE_COUNT;
  for (int i = 0; i < CIRCLE_COUNT; i ++) {
    for (int j = 0; j < CIRCLE_COUNT; j ++) {
      ellipse(PADDING + dividend / 2 + dividend * i, PADDING + dividend / 2 + dividend * j, startingCircleSize, startingCircleSize);
      updateCircleSize();
    }
  }
}

void updateCircleSize() {
  startingCircleSize += CIRCLE_SIZE_INCREMENT / (frameCount % FRAME_RATE);
  if (CIRCLE_SIZE_INCREMENT < 0) {
    if (startingCircleSize <= CIRCLE_MIN_SIZE) {
      startingCircleSize = CIRCLE_MIN_SIZE;
      CIRCLE_SIZE_INCREMENT = -1 * CIRCLE_SIZE_INCREMENT;
    }
  } else {
    if (startingCircleSize >= CIRCLE_MAX_SIZE) {
      startingCircleSize = CIRCLE_MAX_SIZE;
      CIRCLE_SIZE_INCREMENT = -1 * CIRCLE_SIZE_INCREMENT;
    }
  }
}