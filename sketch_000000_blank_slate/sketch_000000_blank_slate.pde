int MIDX = width / 2;
int MIDY = height / 2;
int FRAME_RATE = 60;
float STROKE_WEIGHT = .01;

boolean DEBUG = true;
boolean CANVAS_GRID = true;
int CANVAS_GRID_SUBDIV_X = 16;
int CANVAS_GRID_SUBDIV_Y = 16;
float CANVAS_GRID_OPACITY = 0.25;
String title = "blank_slate";
String date = "00.00.00";

color DEBUG_COLOR;
color BACKGROUND_COLOR;
color DRAW_COLOR;
float spinnerRotation = 0;
int spinnerOrbs = 30;
boolean spinnerAccelerating = true;
float spinnerRotationSpeed = 100;
float spinnerAcceleration = 50;
float spinnerAccelerationInterval = 1080;
float spinnerDecay = 25;
float SPINNER_HEIGHT;
float SPINNER_WIDTH;

float CANVAS_PERCENTAGE = 0.85f;                   // Amount of the frame that the canvas will occupy.
float CANVAS_X;
float CANVAS_Y;
float CANVAS_WIDTH;
float CANVAS_HEIGHT;

int lastFrame;
float delta;

void setup()
{
  strokeWeight(STROKE_WEIGHT);
  frameRate(FRAME_RATE);
  size(1280, 720); 
  // SET VARIABLES THAT DEPEND ON WIDTH AND HEIGHT 
  DEBUG_COLOR = color(#FFFFFF);
  BACKGROUND_COLOR = color(#2d3138);
  DRAW_COLOR = color(#FFFFFF); 
  CANVAS_WIDTH = (float) width * (float) CANVAS_PERCENTAGE;
  CANVAS_HEIGHT = height * CANVAS_PERCENTAGE;
  CANVAS_X = (width - CANVAS_WIDTH) / 2;
  CANVAS_Y = (height - CANVAS_HEIGHT) / 2;
  SPINNER_WIDTH = (width - CANVAS_WIDTH) / 2;
  SPINNER_HEIGHT = (height - CANVAS_HEIGHT) / 2;
}

void draw() {
  delta = (millis() - lastFrame) / 1000f;
  lastFrame = millis();
  background(BACKGROUND_COLOR);
  drawDebug();
  drawSpinner();
  drawGrid();
}

// Util Methods
float clamp(float input, float low, float high) {
  if (input < low) {
    return low;
  } else if (input > high) {
    return high;
  } else {
    return input;
  }
}

// Boilerplate Methods
void drawSpinner() {
  // Control the loading spinner
  spinnerRotationSpeed -= spinnerDecay * delta;
  if (spinnerAccelerating) {
    spinnerRotationSpeed += spinnerAcceleration * delta;
  }
  if (spinnerRotation > spinnerAccelerationInterval) {
    spinnerAccelerating = !spinnerAccelerating;
    spinnerRotation -= spinnerAccelerationInterval;
  }
  spinnerRotation += clamp(spinnerRotationSpeed, 0, 1000) * delta;
  float shortest = (SPINNER_HEIGHT < SPINNER_WIDTH ? SPINNER_HEIGHT : SPINNER_WIDTH);
  float radius = shortest / 6; 
  for (int i = 0; i < spinnerOrbs; i ++) {
    float alpha = i / (float)spinnerOrbs;
    fill(255, 255, 255, 255 * alpha);
    float currentDegree = (360 / spinnerOrbs) * i + spinnerRotation;
    float orbX = SPINNER_WIDTH / 2 + cos(radians(currentDegree)) * radius;
    float orbY = SPINNER_HEIGHT / 2 + sin(radians(currentDegree)) * radius;
    ellipse(orbX, orbY, radius, radius);
  }
}

void drawGrid() {
  if (CANVAS_GRID) {
    strokeWeight(STROKE_WEIGHT);
    stroke(#FFFFFF, CANVAS_GRID_OPACITY * 255);
    float cursorX;
    float cursorY;
    for (int i = 0; i < CANVAS_GRID_SUBDIV_X; i ++) {
      cursorX = CANVAS_X + CANVAS_WIDTH / CANVAS_GRID_SUBDIV_X * i;
      cursorY = CANVAS_Y;
      line(cursorX, cursorY, cursorX, cursorY + CANVAS_HEIGHT);
    }
    for (int i = 0; i < CANVAS_GRID_SUBDIV_Y; i ++) {
      cursorX = CANVAS_X;
      cursorY = CANVAS_Y + CANVAS_HEIGHT / CANVAS_GRID_SUBDIV_Y * i;
      line(cursorX, cursorY, cursorX + CANVAS_WIDTH, cursorY);
    }
  }
}

void drawDebug() {
  if (DEBUG) {
    noFill();
    strokeWeight(STROKE_WEIGHT);
    stroke(DEBUG_COLOR);
    // Render format
    rect(CANVAS_X, CANVAS_Y, CANVAS_WIDTH, CANVAS_HEIGHT); 
    noStroke();
    float shortest = (SPINNER_HEIGHT < SPINNER_WIDTH ? SPINNER_HEIGHT : SPINNER_WIDTH);
    // Render sketch info
    textAlign(RIGHT, CENTER);
    float textSize = shortest / 4;
    textSize(textSize);
    text(date, CANVAS_X + CANVAS_WIDTH, CANVAS_Y - textSize);
    text(title, CANVAS_X + CANVAS_WIDTH, CANVAS_Y - textSize * 2);
  }
}