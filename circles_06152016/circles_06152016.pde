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
color BACKGROUND_COLOR;
color CIRCLE_COLOR;
float STAGGER_SIZE;
float DEGREE_INCREMENT;
float degree = 0;
float sizePercentage = 0;

void setup()
{
  BACKGROUND_COLOR = color(#212F3C);
  CIRCLE_COLOR = color(#FADBD8);

  FRAME_RATE = 60;
  WIDTH = 600;
  HEIGHT = WIDTH;
  CIRCLE_COUNT = 7;
  CIRCLE_SIZE_INCREMENT = 0.05f;
  CIRCLE_MIN_SIZE = WIDTH / 128;
  CIRCLE_MAX_SIZE = WIDTH / 32;
  PADDING = WIDTH / 16;
  STAGGER_SIZE = 50;
  DEGREE_INCREMENT = 0.05;

  frameRate(FRAME_RATE);
  size(1, 1); //Work around for Processing 3.
  surface.setSize(WIDTH, HEIGHT);
}

void draw() {
  background(BACKGROUND_COLOR);
  stroke(0, 0, 0, 0);
  fill(CIRCLE_COLOR);

  float dividend = (WIDTH - PADDING * 2) / CIRCLE_COUNT;
  int position = 1;
  for (int i = 0; i < CIRCLE_COUNT; i ++) {
    for (int j = 0; j < CIRCLE_COUNT; j ++) {
      float circleSize = (CIRCLE_MIN_SIZE + (CIRCLE_MAX_SIZE - CIRCLE_MIN_SIZE) * sizePercentage);
      float percentage = ((position * 100) / (CIRCLE_COUNT * CIRCLE_COUNT));
      percentage = percentage / 100;
      float swell = STAGGER_SIZE * (1 - Math.abs(sizePercentage - percentage));
      ellipse(PADDING + dividend / 2 + dividend * i, PADDING + dividend / 2 + dividend * j, circleSize + swell, circleSize + swell);
      position ++;
    }
  }
  updateSizePercentage();
}

void updateSizePercentage() {
  degree += DEGREE_INCREMENT;
  sizePercentage = (float)(Math.sin(degree) / 2 + 0.5f);
}