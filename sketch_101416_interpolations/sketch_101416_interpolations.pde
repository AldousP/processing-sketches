
int MIDX = width / 2;
int MIDY = height / 2;
int FRAME_RATE = 60;
int STROKE_WEIGHT = 1;

boolean DEBUG = true;

color DEBUG_COLOR;
color BACKGROUND_COLOR;
color DRAW_COLOR;

int lastFrame;
float delta;

float padding = 0.05;

float sequenceLength = 5;
float sequenceTimer;
float sequenceStartPoint;
float sequenceEndPoint;
float sequenceDistance;

float ballSize = 32;

void setup()
{
  strokeWeight(STROKE_WEIGHT);
  frameRate(FRAME_RATE);
  size(600, 600); 
  // SET VARIABLES THAT DEPEND ON WIDTH AND HEIGHT 
  sequenceStartPoint = width * padding;
  sequenceEndPoint = width - sequenceStartPoint;
  sequenceDistance = sequenceEndPoint - sequenceStartPoint;

  DEBUG_COLOR = color(#FFFFFF);
  BACKGROUND_COLOR = color(#467796);
  DRAW_COLOR = color(#FFFFFF);
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

  sequenceTimer+= delta;
  if (sequenceTimer > sequenceLength)
    sequenceTimer -= sequenceLength;

  float alpha = (float)sequenceTimer / (float)sequenceLength;

  float ballPosX;
  float ballPosY;

  noFill();
  stroke(DRAW_COLOR);
  rect(sequenceStartPoint, sequenceStartPoint, sequenceDistance, sequenceDistance);
  noStroke();

  ballPosX = alpha * sequenceDistance + sequenceStartPoint;
  ballPosY = (sequenceDistance / 5) * 1 + sequenceStartPoint;
  fill(#77ffff);
  ellipse(ballPosX, ballPosY, ballSize, ballSize);

  ballPosX = alphaSmooth(alpha) * sequenceDistance + sequenceStartPoint;
  ballPosY = (sequenceDistance / 5) * 2 + sequenceStartPoint;
  fill(#a82d2d);
  ellipse(ballPosX, ballPosY, ballSize, ballSize);

  ballPosX = pow(alpha, 6) * sequenceDistance + sequenceStartPoint;
  ballPosY = (sequenceDistance / 5) * 3 + sequenceStartPoint;
  fill(#0cafb7);
  ellipse(ballPosX, ballPosY, ballSize, ballSize);

  ballPosX = pow(alpha, 12) * sequenceDistance + sequenceStartPoint;
  ballPosY = (sequenceDistance / 5) * 4 + sequenceStartPoint;
  fill(#2fb70c);
  ellipse(ballPosX, ballPosY, ballSize, ballSize);
}

float alphaSmooth(float alpha) {
  return alpha * alpha * alpha * (alpha * (alpha * 6 - 15) + 10);
}