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

PVector[][] boxes;
int gridX = 16;
int gridY = 16;
float gridXDivision; 
float gridYDivision;

float slideTimer;
float slideLength = 10;
float pauseLength = 4;

float startX;
float endX;

boolean exiting;


void setup()
{
  strokeWeight(STROKE_WEIGHT);
  frameRate(FRAME_RATE);
  size(600, 600); 
  // SET VARIABLES THAT DEPEND ON WIDTH AND HEIGHT 
  gridXDivision = width / gridX;
  gridYDivision = height / gridY;
  
  startX = -width;
  endX = gridXDivision / 2;
  DEBUG_COLOR = color(#4286f4);
  BACKGROUND_COLOR = color(#22497f);
  DRAW_COLOR = color(#FFFFFF); 

  boxes = new PVector[gridX][gridY];
  for (int i = 0; i < gridX; i ++) {
    for (int j = 0; j < gridY; j ++) {
      boxes[i][j] = new PVector(gridXDivision * (i), gridYDivision * (j) + gridYDivision / 2);
    }
  }
}

void draw() {
  
  delta = (millis() - lastFrame) / 1000f;
  lastFrame = millis();
  slideTimer += delta;
  
  if (!exiting && slideTimer > slideLength + pauseLength) {
    exiting = true;
    startX += width;
    endX += width;
    slideTimer -= slideLength + pauseLength;
  }
  background(BACKGROUND_COLOR);
  if (DEBUG) {
    noFill();
    stroke(DEBUG_COLOR);
    line(-1, height / 2, height + 1, height / 2);
    line(width / 2, -1, width / 2, height + 1);
  }

  fill(DRAW_COLOR);
  stroke(DEBUG_COLOR);
  float slideAlpha = slideTimer / slideLength;
  if (slideAlpha > 1)
    slideAlpha = 1;
  int index = 1;
  rectMode(CENTER);
  for (int i = 0; i < gridX; i ++) {
    for (int j = 0; j < gridY; j ++) {
      PVector pos = boxes[i][j];
      rect(pos.x, pos.y, gridXDivision * 0.45, gridYDivision * 0.45);
      float modAlpha = pow(slideAlpha, gridX * gridY - index + 1);
      if (modAlpha < 0) {
        modAlpha = 0;
      }      
      
      pos.x = lerp(gridXDivision / 2 + (gridXDivision * i) + startX, gridXDivision * i + endX, alphaSmooth(modAlpha));          
      index ++;
    }
  }
}

float alphaSmooth(float alpha) {
  return alpha * alpha * alpha * (alpha * (alpha * 6 - 15) + 10);
}