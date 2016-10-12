int WIDTH = 600;
int HEIGHT = 600;
int MIDX = WIDTH / 2;
int MIDY = HEIGHT / 2;
int FRAME_RATE = 60;
int STROKE_WEIGHT = 3;

color BACKGROUND_COLOR;
color DRAW_COLOR;

int lastFrame;
float delta;
float rectW = WIDTH / 16;
float rectH = rectW;

int gridX = 3;
int gridY = 1;

float gridSubdivisionX = WIDTH / gridX;
float gridSubdivisionY = HEIGHT / gridY;

float drawPosX = 0;
float drawPosY = 0;

float linePos = 0;
float lineSpeed = 100;
float accelerationRange = .05;

color LINE_COLOR;

float[][] currentRotation;
float[][] rotationSpeed;

float maxRotationSpeed = 300;
float decayRate = 25;

int Y_AXIS = 1;
int X_AXIS = 2;

void setup()
{
  LINE_COLOR = color(#f44283);
  BACKGROUND_COLOR = color(#33a4aa);
  DRAW_COLOR = color(#f9fbfc);
  strokeWeight(STROKE_WEIGHT);
  frameRate(FRAME_RATE);
  size(1, 1); //Work around for Processing 3.
  surface.setSize(WIDTH, HEIGHT);  
  //fill(DRAW_COLOR);
  stroke(DRAW_COLOR);
  rectMode(CENTER);

  //INITIALIZE SPEED VALUES
  currentRotation = new float[gridX][gridY];
  rotationSpeed = new float[gridX][gridY];
}

void draw() {
  delta = (millis() - lastFrame) / 1000f;
  lastFrame = millis();
 
  // RESET THE CAMERA
  translate(width/2, height/2);
  background(#f77471);

  linePos += lineSpeed * delta;

  if (linePos > WIDTH)
    linePos = linePos - WIDTH;
    
  ////// DRAW THE SEQUENCER LINE //////
  //stroke(LINE_COLOR);
  //line(linePos - (WIDTH / 2) , (HEIGHT/2 + 1), linePos - (WIDTH / 2) , - (WIDTH / 2));
  //line((linePos - WIDTH * accelerationRange) - (WIDTH / 2) , (HEIGHT/2 + 1), (linePos - WIDTH * accelerationRange) - (WIDTH / 2) , - (WIDTH / 2));
  //line((linePos + WIDTH * accelerationRange) - (WIDTH / 2) , (HEIGHT/2 + 1), (linePos + WIDTH * accelerationRange) - (WIDTH / 2) , - (WIDTH / 2));
  //fill(LINE_COLOR);
  //textSize(36);
  //text((linePos / WIDTH), linePos - (WIDTH / 2), (HEIGHT/2 + 1));

  // DRAW THE BOXES
  drawPosX = (gridSubdivisionX / 2 + -1 * (WIDTH / 2));
  drawPosY = (gridSubdivisionY / 2 + -1 * (HEIGHT / 2));
  int progress = 0;
  for (int i = 0; i < gridX; i++) {
    for (int j = 0; j < gridY; j++) {
      float currRotation = currentRotation[i][j];
      float currentPosition = (float)progress / (float) (gridX);
      currentPosition += ((float)1 / (float)(gridX) / 2);
      float distanceFromLine = shortestDistance(currentPosition, (linePos / WIDTH), 0, 1);

      if (Math.abs(distanceFromLine) < accelerationRange) {
        rotationSpeed[i][j] += (maxRotationSpeed * (1 - Math.abs(distanceFromLine)) * delta);
      }
      currentRotation[i][j] += rotationSpeed[i][j] * delta;

      translate(drawPosX, drawPosY);
      rotate(radians(currRotation));
      stroke(#9e9e9e);
      //line(0, 99900, 0, -99999);
      //line(99999, 0, -99999, 0);
      noStroke();
      fill(DRAW_COLOR);
      rect(0, 0, rectW, rectH);
      // DRAW SPEED
      fill(#AAAAAA);
      rotate(-radians(currRotation));
      translate(-drawPosX, -drawPosY);
      drawPosY += gridSubdivisionY;

      rotationSpeed[i][j] -= (decayRate * delta);
      if (rotationSpeed[i][j] < 0) {
        rotationSpeed[i][j] = 0;
      }
    }
    progress ++;

    drawPosX += gridSubdivisionX;
    drawPosY = (gridSubdivisionY / 2 + -1 * (HEIGHT / 2));
  }

  ////// DEBUG ///////
  //draw a red dot at 
  //the center of the sketch
  //fill(255, 0, 0);
  //stroke(128, 0, 0);
  //ellipse(0, 0, 20, 20);  
  //line(0, 999, 0, -999);
  //line(999, 0, -999, 0);
}

float shortestDistance(float pt1, float pt2, float floor, float ceil) {
  if (floor > ceil || pt1 < floor || pt1 > ceil || pt2 < floor || pt2 > ceil) {
    println("[WARN]: A provided value exceeds bounds.");
    return 0; //Numbers are outside of range
  }
  float distance = pt2 - pt1;
  float midPoint = (ceil - floor) / 2;
  if (Math.abs(distance) > midPoint) {
    if (pt1 > pt2) {
      distance = (ceil - pt1) + (pt2 - floor);
    } else {
      distance = -1 * ((pt1 - floor) + (ceil - pt2));
    }
  }
  return distance;
}