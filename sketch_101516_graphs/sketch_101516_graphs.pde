int MIDX = width / 2;
int MIDY = height / 2;
int FRAME_RATE = 60;
int STROKE_WEIGHT = 1;

boolean DEBUG = true;

color DEBUG_COLOR;
color BACKGROUND_COLOR;
color DRAW_COLOR;

float E = (float) Math.E;

int lastFrame;
float delta;

float padding = 0.05;
float xPaddingOffset;
float yPaddingOffset;
float canvasWidth;
float canvasHeight;

float pointSize = 1;

float modelXRangeLow = -6.28;
float modelXRangeHigh = 6.28;
float modelInc = .001;

float modelYRangeLow = -10;
float modelYRangeHigh = 10;

float camSpeed = .5f;

float xPower = 0;


void setup()
{
  strokeWeight(STROKE_WEIGHT);
  frameRate(FRAME_RATE);
  size(600, 600); 
  // SET VARIABLES THAT DEPEND ON WIDTH AND HEIGHT   
  xPaddingOffset = width * padding;
  yPaddingOffset = height * padding;
  canvasWidth = width - xPaddingOffset * 2;
  canvasHeight = height - yPaddingOffset * 2; 

  DEBUG_COLOR = color(#FFFFFF);
  BACKGROUND_COLOR = color(#12747c);
  DRAW_COLOR = color(#FFFFFF);
}

void draw() {
  delta = (millis() - lastFrame) / 1000f;
  lastFrame = millis();
  background(BACKGROUND_COLOR);

  // DRAW GRAPH BORDER
  noFill();
  stroke(DRAW_COLOR);
  rect(xPaddingOffset, yPaddingOffset, canvasWidth, canvasHeight);
  noStroke();

  fill(DRAW_COLOR);

  // DRAW RANGE TEXT
  textAlign(CENTER);
  text(modelXRangeLow, xPaddingOffset, yPaddingOffset + canvasHeight / 2);
  text(modelXRangeHigh, xPaddingOffset + canvasWidth, yPaddingOffset + canvasHeight / 2);
  text(modelYRangeLow, xPaddingOffset + canvasWidth / 2, yPaddingOffset + canvasHeight);
  text(modelYRangeHigh, xPaddingOffset + canvasWidth / 2, yPaddingOffset);

  stroke(DRAW_COLOR);
  if (modelXRangeLow < 0 && modelXRangeHigh > 0) {
    float linePosX = (abs(modelXRangeLow) / (modelXRangeHigh - modelXRangeLow)) * canvasWidth + xPaddingOffset;
    line(linePosX, yPaddingOffset, linePosX, yPaddingOffset + canvasHeight);
  }

  if (modelYRangeLow < 0 && modelYRangeHigh > 0) {
    float linePosY = height - ((abs(modelYRangeLow) / (modelYRangeHigh - modelYRangeLow)) * canvasHeight + yPaddingOffset);
    line(xPaddingOffset, linePosY, xPaddingOffset + canvasWidth, linePosY);
  }

  float alpha;
  float xPos, yPos;
  float modelYVal;
  for (float modelX = modelXRangeLow; modelX < modelXRangeHigh; modelX += modelInc) {
    alpha = (modelX - modelXRangeLow) / (modelXRangeHigh - modelXRangeLow);
    xPos = canvasWidth * alpha + xPaddingOffset;

    // GRAPHING FUNCTION 
    //modelYVal = (modelX + 2) / (pow(modelX, 2) + 1 );
    modelYVal = pow(E, -pow(modelX, xPower));

    alpha = 1 - ((modelYVal - modelYRangeLow) / (modelYRangeHigh - modelYRangeLow));
    if (alpha > 1) {
      alpha = 1.1;
    }

    if (alpha < 0) {
      alpha = -.1;
    }
    yPos = ((canvasHeight * alpha) + yPaddingOffset);
    ellipse(xPos, yPos, pointSize, pointSize);
  }
  
  xPower += 1 * delta;

  //modelYRangeHigh += camSpeed * delta;
  //modelYRangeLow += camSpeed * delta;
}

float alphaSmooth(float alpha) {
  return alpha * alpha * alpha * (alpha * (alpha * 6 - 15) + 10);
}