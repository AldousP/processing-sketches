int MIDX = width / 2;
int MIDY = height / 2;
int FRAME_RATE = 60;
int STROKE_WEIGHT = 1;

boolean DEBUG = false;

color DEBUG_COLOR;
color BACKGROUND_COLOR;
color DRAW_COLOR;

int lastFrame;
float delta;

float CANVAS_PERCENTAGE = 0.8f;
float CANVAS_X;
float CANVAS_Y;
float CANVAS_WIDTH;
float CANVAS_HEIGHT;
float brushX;
float brushY;
float brushWidth = 1;
float maxSpiralRadius;
float spiralRadiusPerSecond = 9;
float baseAcceleration = -1.25;
float maxAcceleration = 1.25;
float acceleration = baseAcceleration;

// Degrees per second
float rotationSpeed = 720;
boolean rotateClockwise = false;
float brushCurrentRadius = 0;
float brushCurrentRotation = 0;


void setup()
{
  strokeWeight(STROKE_WEIGHT);
  frameRate(FRAME_RATE);
  size(600, 600); 
  // SET VARIABLES THAT DEPEND ON WIDTH AND HEIGHT 
  DEBUG_COLOR = color(#000000);
  BACKGROUND_COLOR = color(#F9F9F9);
  DRAW_COLOR = color(#000000); 
  CANVAS_WIDTH = (float)width * (float)CANVAS_PERCENTAGE;
  CANVAS_HEIGHT = height * CANVAS_PERCENTAGE;
  CANVAS_X = (width - CANVAS_WIDTH) / 2;
  CANVAS_Y = (height - CANVAS_HEIGHT) / 2;
  brushX = CANVAS_X + CANVAS_WIDTH / 4;
  brushY = CANVAS_Y + CANVAS_HEIGHT / 2;
  maxSpiralRadius = CANVAS_WIDTH / 16;
  background(BACKGROUND_COLOR);
}

void draw() {
    //background(BACKGROUND_COLOR);

  delta = (millis() - lastFrame) / 1000f;
  lastFrame = millis();
  if (DEBUG) {
    noFill();
    stroke(DEBUG_COLOR);
    line(-1, height / 2, height + 1, height / 2);
    line(width / 2, -1, width / 2, height + 1);
    rect(CANVAS_X, CANVAS_Y, CANVAS_WIDTH, CANVAS_HEIGHT);
    noFill();
    noStroke();
  }

  fill(DRAW_COLOR);
  float brushPosX = brushX + cos(radians(brushCurrentRotation)) * brushCurrentRadius;
  float brushPosY = brushY + sin(radians(brushCurrentRotation)) * brushCurrentRadius;
  ellipse(brushPosX, brushPosY, brushCurrentRadius / 40, brushCurrentRadius / 40);

  brushCurrentRadius += spiralRadiusPerSecond * delta;
  brushCurrentRotation += (rotateClockwise ? 1 : -1) * rotationSpeed * delta;
  
  float alpha = brushCurrentRadius / maxSpiralRadius;
  
  rotationSpeed += acceleration;
  acceleration += delta *  ((alpha > .35 ? -1 : 1) * (alpha * (maxAcceleration - baseAcceleration))); 
  println(acceleration);
  
  if (DEBUG) {
    strokeWeight(CANVAS_WIDTH / 256);
    noFill();
    stroke(0, 255, 0);
    float debugWidth = CANVAS_WIDTH / 32;
    ellipse(brushX, brushY, debugWidth, debugWidth);
    ellipse(brushPosX, brushPosY, debugWidth, debugWidth);
    line(brushX, brushY, brushPosX, brushPosY);
    stroke(0, 128, 255);
    line(brushX, brushY, brushX + maxSpiralRadius, brushY);
  }
  
   
  if (brushCurrentRadius > maxSpiralRadius) {
    brushCurrentRadius = 0;
    brushCurrentRotation = 0;
    rotateClockwise = !rotateClockwise;
    brushX = brushPosX;
    brushY = brushPosY;
    acceleration = baseAcceleration;
  };
}