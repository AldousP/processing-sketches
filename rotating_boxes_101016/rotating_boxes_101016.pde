int WIDTH = 800;
int HEIGHT = WIDTH;
int MIDX = WIDTH / 2;
int MIDY = HEIGHT / 2;
int FRAME_RATE = 60;
int STROKE_WEIGHT = 4;

color BACKGROUND_COLOR;
color DRAW_COLOR;

int lastFrame;
float delta;
float rectW = WIDTH / 16;
float rectH = rectW;

int gridX = 8;
int gridY = 8;

float gridSubdivisionX = WIDTH / gridX;
float gridSubdivisionY = HEIGHT / gridY;

float drawPosX = 0;
float drawPosY = 0;

void setup()
{
  BACKGROUND_COLOR = color(#33a4aa);
  DRAW_COLOR = color(#edf6f7);
  strokeWeight(STROKE_WEIGHT);
  frameRate(FRAME_RATE);
  size(1, 1); //Work around for Processing 3.
  surface.setSize(WIDTH, HEIGHT);  
  fill(DRAW_COLOR);
  stroke(DRAW_COLOR);
  rectMode(CENTER);
}

void draw() {
  delta = (millis() - lastFrame) / 1000f;
  lastFrame = millis();

  // RESET THE CAMERA
  translate(width/2, height/2);
  background(#ffffff);


  // DRAW THE BOXES
  drawPosX = (gridSubdivisionX / 2 + -1 * (WIDTH / 2));
  drawPosY = (gridSubdivisionY / 2 + -1 * (HEIGHT / 2));
  int progress = 0;
  for (int i = 0; i < gridX; i ++) {
    for (int j = 0; j < gridY; j++) {
      float perc =  (float)progress / (float)(gridX * gridY);
      float normalizedSin = sin;
      normalizedSin /= 2;
      normalizedSin += 0.5f;
      float distanceFromSequence = shortestDistance(perc, normalizedSin, 0, 1);
      translate(drawPosX, drawPosY);
      //A rotate(radians(currentRotation));
      stroke(#9e9e9e);
      
      //line(0, 99900, 0, -99999);
      //line(99999, 0, -99999, 0);
      fill(0, 0, 0);
      fill(255, 255, 255);
      noFill();
      ellipse(0, 0, rectW * 2 * normalizedSin, rectH * 2 * normalizedSin);
      rect(0, 0, rectW, rectH);
      fill(0, 0, 255);
      //B rotate(-radians(currentRotation));
      translate(-drawPosX, -drawPosY);
      drawPosY += gridSubdivisionY;
      progress ++;
    }
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