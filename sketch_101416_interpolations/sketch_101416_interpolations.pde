
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

float sequenceLength = 1;
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

  float alpha = sequenceTimer / sequenceLength;
  
  float ballPosX = alpha * sequenceDistance + sequenceStartPoint;
  float ballPosY = (sequenceDistance / 5) * 1 + sequenceStartPoint;
 
  noFill();
  stroke(DRAW_COLOR);
  rect(sequenceStartPoint, sequenceStartPoint, sequenceDistance, sequenceDistance);
  ellipse(ballPosX, ballPosY, ballSize, ballSize);
  ballPosY = (sequenceDistance / 5) * 2 + sequenceStartPoint;
  ellipse(ballPosX, ballPosY, ballSize, ballSize);
  ballPosY = (sequenceDistance / 5) * 3 + sequenceStartPoint;
  ellipse(ballPosX, ballPosY, ballSize, ballSize);
  ballPosY = (sequenceDistance / 5) * 3 + sequenceStartPoint;
  ellipse(ballPosX, ballPosY, ballSize, ballSize);
}