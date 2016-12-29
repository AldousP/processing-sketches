int MIDX = width / 2; //<>//
int MIDY = height / 2;
int FRAME_RATE = 60;
int STROKE_WEIGHT = 1;

boolean DEBUG = false;

color DEBUG_COLOR;
color BACKGROUND_COLOR; 
color STROKE_COLOR_1;
color STROKE_COLOR_2;
color tmpColor;

int lastFrame;
float delta;

float CANVAS_PERCENTAGE = 0.9f;
float CANVAS_X;
float CANVAS_Y;
float CANVAS_WIDTH;
float CANVAS_HEIGHT;

int MAX_ATTEMPT_THRESHOLD = 100;
int globalAttempts = 0;
float spiralX;                                     // Current position of the spiral apparatus
float spiralY;
float spiralRadius = 0;                            // Current radius of the spiral apparatus 
float MIN_SPIRAL_RADIUS = 45;                                 // Smallest a spiral can be...
float MAX_SPIRAL_RADIUS = 90;                      // ...and vice versa
float currentGoalRadius = MAX_SPIRAL_RADIUS;       // First spiral is middle size
float INITIAL_RADIUS = currentGoalRadius;          // Used to compare the relative scale of all subsequent spirals for scaling
float spiralRotation = random(0, 360);
float lastRotation = 0;

float spiralRadiusPerSecond = 60;                  // The rate of expansion outward by the spiral algorithm
float acceleration = 1400;                          // Constant used to accelerate and then decelerate after the spiral is beyond the...
float decelerationThreshold = 1;                   // Deceleration Threshold. Which begins slowing down the spiral 
float MIN_ROTATION_SPEED = 200;                    // The slowest the spiral can get...
float MAX_ROTATION_SPEED = 2500;                    // and the fastest.
float rotationSpeed = MIN_ROTATION_SPEED;

boolean rotateClockwise = true;                    // Alternates on every new spiral location
float MIN_BRUSH_SIZE = 0.75;                       // The smallest a brush stroke can get...
float MAX_BRUSH_SIZE = 4.75;                       // and the largest.
float strokeLength = 64;                            // The length of the stroke extending behind the head of the stroke

float scaleDiff = 1;                               // Tracks of the scale of the current spiral relative to the first one. Used to scale speeds and stroke sizes.

boolean drawing = true;                            // True as long as there is a valid move in the spiral algorithm.
ArrayList<Circle> spirals;                         // Collection of all spirals that have been drawn

void setup() {
  strokeWeight(STROKE_WEIGHT);
  frameRate(FRAME_RATE);
  size(800, 800); 
  // SET VARIABLES THAT DEPEND ON WIDTH AND HEIGHT 
  DEBUG_COLOR = color(#000000);
  BACKGROUND_COLOR = color(#f4f4f4);
  STROKE_COLOR_1 =  color(#f47142);
  STROKE_COLOR_2 = color(#429bce); 
  CANVAS_WIDTH = (float)width * (float) CANVAS_PERCENTAGE;
  CANVAS_HEIGHT = height * CANVAS_PERCENTAGE;
  CANVAS_X = (width - CANVAS_WIDTH) / 2;
  CANVAS_Y = (height - CANVAS_HEIGHT) / 2;
  PVector temp = getPointInCanvas();
  spiralX = temp.x;
  spiralY = temp.y;
  background(BACKGROUND_COLOR);
  spirals = new ArrayList<Circle>();
}

void draw() {
  //background(BACKGROUND_COLOR);
  noFill();
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

  // Drawing is ended when there are no more valid locations to paint.
  if (!drawing) return;
  scaleDiff = currentGoalRadius / INITIAL_RADIUS;

  if (spiralRadius == 0) {
    println("setting last rotation to: " + spiralRotation );
    lastRotation = spiralRotation;
  }
  
  // Update spiral acceleration and rotations.
  spiralRadius += spiralRadiusPerSecond * delta;
  spiralRotation += (rotateClockwise ? 1 : -1) * (rotationSpeed * delta);
  float alpha = spiralRadius / currentGoalRadius;
  
  float diff = acceleration * delta;
  if (alpha > decelerationThreshold) {
    rotationSpeed -= diff;
  } else {
    rotationSpeed += diff;
  }
  rotationSpeed = clamp(rotationSpeed, MIN_ROTATION_SPEED, MAX_ROTATION_SPEED);

  // Then draw them
  noStroke();
  float invertRadius = currentGoalRadius - spiralRadius;
  float brushPosX = spiralY + cos(radians(spiralRotation)) * invertRadius;
  float brushPosY = spiralX + sin(radians(spiralRotation)) * invertRadius;
  float widthMod = random(.8, 1.2);
  float radius = (1 - alpha) * (MAX_BRUSH_SIZE  - MIN_BRUSH_SIZE);

  for (int i = 0; i < (strokeLength * alpha); i++) {
    brushPosX = spiralX + cos(radians(spiralRotation + i)) * invertRadius;
    brushPosY = spiralY + sin(radians(spiralRotation + i)) * invertRadius;
    tmpColor = color(STROKE_COLOR_1);
    tmpColor = lerpColor(tmpColor, STROKE_COLOR_2, alpha);
    fill (tmpColor);   
    ellipse(brushPosX, brushPosY, radius, radius);
  }

  // Render debug information
  if (DEBUG) {
    strokeWeight(1.8);
    noFill();
    stroke(0, 255, 0);
    float debugWidth = 16;
    ellipse(spiralX, spiralY, debugWidth, debugWidth);
    ellipse(brushPosX, brushPosY, debugWidth, debugWidth);
    ellipse(spiralX, spiralY, currentGoalRadius * 2, currentGoalRadius * 2);
    line(spiralX, spiralY, brushPosX, brushPosY);
    stroke(0, 0, 255);
    line(spiralX, spiralY, spiralX + currentGoalRadius, spiralY);
    PVector lastRotationPt = getPointOnCircumference(currentGoalRadius, lastRotation);
    fill(0, 0, 255);
    ellipse(lastRotationPt.x + spiralX, lastRotationPt.y + spiralY, 17, 17);
    fill(255, 0, 0);
    ellipse(CANVAS_X, CANVAS_Y, 15, 15);
    ellipse(CANVAS_X + CANVAS_WIDTH, CANVAS_Y + CANVAS_HEIGHT, 15, 15);
    int index = 0;
    for (Circle c : spirals) {
      noFill();     
      stroke(0, 255, 0);
      ellipse(c.midX, c.midY, c.radius * 2, c.radius * 2);
      text(index, c.midX, c.midY);
      index ++;
    }
  }

  // Pick a new position that is connected to the current spiral. If none are found, try a random point, if none can be found. Give up.
  if (alpha >= 1) {
    globalAttempts = 0;
    resetSpiralPosition();
  }
};

void resetSpiralPosition() {
  globalAttempts ++;

  if (globalAttempts > MAX_ATTEMPT_THRESHOLD) {
    drawingOver();
    return;
  }
  // Add current spiral to history
  spirals.add(new Circle(spiralX, spiralY, currentGoalRadius));
  float degree = random(0, 360);
  float prospectiveRadius = MAX_SPIRAL_RADIUS;
  PVector tmpPoint = getPointOnCircumference(currentGoalRadius, degree);
  float edgePointX = spiralX + tmpPoint.x;
  float edgePointY = spiralY + tmpPoint.y;
  Circle prospect = new Circle(spiralX + tmpPoint.x, spiralY + tmpPoint.y, prospectiveRadius);

  // Start at degree 0
  //  - Check to see if a circle that is created with the same radius as the current circle is...
  //    - Completely within the canvas
  //    - Not overlapping with any past circles    
  //  - Reduce radius if it is too wide and try again.
  //  - If the radius is below the MIN_RADIUS then increment the degree count and try again...
  //  - If the degree count is >= 359 then we've checked all that we can check and the simulation is over.
  int attempts = 0;
  degree = random(0, 360);
degreeSearch: 
  for (int i = 0; i < 360; i ++) {
    degree ++;
    prospectiveRadius = MAX_SPIRAL_RADIUS;
    while (prospectiveRadius > MIN_SPIRAL_RADIUS) {
      attempts ++;
      prospectiveRadius -= 1;

      tmpPoint = getPointOnCircumference(currentGoalRadius, degree);
      edgePointX = spiralX + tmpPoint.x;
      edgePointY = spiralY + tmpPoint.y;

      prospect.midX = edgePointX + (cos(radians(degree)) * prospectiveRadius);
      prospect.midY = edgePointY + (sin(radians(degree)) * prospectiveRadius); 
      prospect.radius = prospectiveRadius;      
      // Check for a valid option every increment.
      if (circleInCanvas(prospect) && !checkIfOverlaps(prospect, spirals) || attempts > 200000) {
        //ellipse(prospect.midX, prospect.midY, prospect.radius * 2, prospect.radius * 2);
        break degreeSearch;
      }
    }
  }

  // If there isn't a valid option, then the drawing is over.
  if (!circleInCanvas(prospect) || checkIfOverlaps(prospect, spirals)) {
    moveBrushToRandomPoint();
  } else {
    spiralRadius = 0;
    rotationSpeed = 0;
    spiralRotation = lastRotation;
    spiralX = prospect.midX;
    spiralY = prospect.midY;
    currentGoalRadius  = prospect.radius;
    println("[" + hour() + ":" + minute() + ":" + second() +   "] Moving brush to a new point ");
  }
  attempts = 0;
  rotateClockwise = !rotateClockwise;
}

// Used as a fallback if the alg can't find a point along the previous circle.
void moveBrushToRandomPoint() {
  PVector tmp;
  int attempts = 0;
  int attemptCap = width;
  do {
    attempts ++;
    tmp = getPointInCanvas();
  } while (pointInSpiral(tmp.x, tmp.y) && attempts < attemptCap);
  if (attempts < attemptCap) {
    spiralX = tmp.x;
    spiralY = tmp.y;
    resetSpiralPosition();
  }
}

// Called to end the drawing
void drawingOver() {
  drawing = false;
  println("drawing complete.");
}

void keyPressed() {
  if (key == ENTER) {
    DEBUG = !DEBUG;
  }
}

PVector getPointInCanvas() {
  return new PVector(
    random(CANVAS_X, CANVAS_X + CANVAS_WIDTH), 
    random(CANVAS_Y, CANVAS_Y + CANVAS_HEIGHT)
    );
}

PVector getPointOnCircumference(float radius, float angle) {
  return new PVector(cos(radians(angle)) * radius, sin(radians(angle)) * radius);
}

// Returns whether the entirety of the provided circle is within the canvas 
boolean circleInCanvas(Circle c) {
  boolean inCanvas = true;
  if (!pointInCanvas(c.midX, c.midY)) {
    return false;
  }
  float x = c.midX;
  float y = c.midY;

  float xDst = abs(x - CANVAS_X);
  float yDst = abs(y - CANVAS_Y);
  if (xDst < c.radius || yDst < c.radius) {
    inCanvas = false;
  }
  // Check the other sides of the canvas
  xDst = abs(x - (CANVAS_X + CANVAS_WIDTH));
  yDst = abs(x - (CANVAS_Y + CANVAS_HEIGHT));
  if (xDst < c.radius || yDst < c.radius) {
    inCanvas = false;
  }

  return inCanvas;
}

boolean checkIfOverlaps(Circle a, ArrayList<Circle> b) {
  //println("Checking if point overlaps....");
  boolean overlaps = false;
  for (Circle c : b) {
    if (a.overlaps(c)) {
      overlaps = true;
    }
  }
  return overlaps;
};

boolean pointInCanvas(float x, float y) {
  return ( (x > CANVAS_X && x < CANVAS_X + CANVAS_WIDTH) && ( y > CANVAS_Y && y < CANVAS_Y + CANVAS_HEIGHT));
}

boolean pointInSpiral(float x, float y) {
  boolean pointInSpiral = false;
  for (Circle c : spirals) {
    float dst = sqrt(pow(x - c.midX, 2) + pow(y - c.midY, 2));
    pointInSpiral =  dst < c.radius;
  }
  return pointInSpiral;
}

float clamp(float input, float low, float high) {
  if (input < low) {
    return low;
  } else if (input > high) {
    return high;
  } else {
    return input;
  }
}

class Circle {  
  float midX, midY, radius;

  Circle(float midX, float midY, float radius) {
    this.midX = midX;
    this.midY = midY;
    this.radius = radius;
  };

  void setRadius(float radius) {
    this.radius = radius;
  }

  boolean overlaps(Circle partner) {
    float dst = sqrt(pow(partner.midX - midX, 2) + pow(partner.midY - midY, 2));
    return dst < (radius + partner.radius);
  }
}