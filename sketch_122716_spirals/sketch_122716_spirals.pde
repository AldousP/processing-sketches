int MIDX = width / 2; //<>//
int MIDY = height / 2;
int FRAME_RATE = 60;

boolean DEBUG = true;
boolean CLEAR_CANVAS = DEBUG;

color DEBUG_COLOR;
color BACKGROUND_COLOR; 
color STROKE_COLOR_1;                              // Color used at the onset of the spiral progress, slowly lerps to...
color STROKE_COLOR_2;                              // the color used towards the end of the spiral progress.
color tmpColor;                                    // Temp var used for performing color lerps.
float textSize = 20;                               // Global text size. Used in debugging.

int lastFrame;
float delta;

float CANVAS_PERCENTAGE = 0.75f;                   // Amount of the frame that the canvas will occupy.
float CANVAS_X;
float CANVAS_Y;
float CANVAS_WIDTH;
float CANVAS_HEIGHT;

int MAX_ATTEMPT_THRESHOLD = 10;                   // The amount of overall cycles the algorithm will attempt to perform before determining that no more moves can be made.
int globalAttempts = 0;
float spiralX;                                     // Current position of the spiral apparatus.
float spiralY;
float spiralRadius = 0;                            // Current radius of the spiral apparatus. 
float MIN_SPIRAL_RADIUS = 19;                      // Smallest a spiral can be...
float MAX_SPIRAL_RADIUS = 20;                      // ...and vice versa
float MIN_EXPANSION_PERCENTAGE = 1;               // Used to clamp the expansion percentage for new spirals.
float MAX_EXPANSION_PERCENTAGE = .25;
float currentGoalRadius = MAX_SPIRAL_RADIUS;       // First spiral is middle size.
float currentExpansionPercentage = .5;             // The percent of the goalRadius that the spiral will expand to (EX: Goal Radius of 10, with expansion of .9 will stop at a radius of 9) (Alpha is unaffected by this parameter.)
float INITIAL_RADIUS = currentGoalRadius;          // Used to compare the relative scale of all subsequent spirals for scaling.
float spiralStartingPosition = 90;                 // Where the spiral starts to spin on the circumference of the spiral.
float spiralRotation = 90; 

float spiralRadiusPerSecond = 4;                   // The rate of expansion outward by the spiral algorithm.
float acceleration = 50;                           // Constant used to accelerate and then decelerate after the spiral is beyond the...
float decelerationThreshold = .75;                 // Deceleration Threshold in percentage through spiral completion. Spiral starts decelerating when this is passed.
float MIN_ROTATION_SPEED = 100;                    // The slowest the spiral can get...
float MAX_ROTATION_SPEED = 700;                    // and the fastest.
float rotationSpeed = 0;                           // The current rotation speed.

boolean rotateClockwise = true;                    // Alternates on every new spiral location
boolean expandInwards = true;
float MIN_BRUSH_SIZE = 0.25;                       // The smallest a brush stroke can get...
float MAX_BRUSH_SIZE = 2.75;                       // and the largest.
float strokeLength = 100;                          // The length of the stroke extending behind the head of the stroke.

float scaleDiff = 1;                               // Tracks of the scale of the current spiral relative to the first one. Used to scale speeds and stroke sizes.

boolean drawing = true;                            // True as long as there is a valid move in the spiral algorithm.
ArrayList<Circle> spirals;                         // Collection of all spirals that have been drawn.


void setup() {
  frameRate(FRAME_RATE);
  size(1280, 720); 
  // SET VARIABLES THAT DEPEND ON WIDTH AND HEIGHT 
  DEBUG_COLOR = color(#000000);
  BACKGROUND_COLOR = color(#f4f4f4);
  STROKE_COLOR_1 =  color(#f442ce);
  STROKE_COLOR_2 = color(#429bce); 
  CANVAS_WIDTH = (float)width * (float) CANVAS_PERCENTAGE;
  CANVAS_HEIGHT = height * CANVAS_PERCENTAGE;
  CANVAS_X = (width - CANVAS_WIDTH) / 2;
  CANVAS_Y = (height - CANVAS_HEIGHT) / 2;
  spiralX = width / 2;
  spiralY = height / 2;
  background(BACKGROUND_COLOR);
  spirals = new ArrayList<Circle>();
}

void draw() {
  if (CLEAR_CANVAS && drawing) {
    background(BACKGROUND_COLOR);
  }

  noFill();
  delta = (millis() - lastFrame) / 1000f;
  lastFrame = millis();
  if (DEBUG) {
    noFill();
    strokeWeight(0.75);
    stroke(DEBUG_COLOR);
    line(CANVAS_X + CANVAS_WIDTH / 2, CANVAS_Y, CANVAS_X + CANVAS_WIDTH / 2, CANVAS_Y + CANVAS_HEIGHT);
    line(CANVAS_X, CANVAS_Y +CANVAS_HEIGHT / 2, CANVAS_X + CANVAS_WIDTH, CANVAS_Y + CANVAS_HEIGHT / 2);
    rect(CANVAS_X, CANVAS_Y, CANVAS_WIDTH, CANVAS_HEIGHT);
    noFill();
    noStroke();
  }

  if (!drawing) return;                                                     // Drawing ends after the threshold for random positional attempts is hit.
  scaleDiff = currentGoalRadius / INITIAL_RADIUS;

  // Update spiral data
  spiralRadius += spiralRadiusPerSecond * scaleDiff * delta;
  spiralRadius = clamp(spiralRadius, MIN_SPIRAL_RADIUS * scaleDiff, MAX_SPIRAL_RADIUS * scaleDiff);
  spiralRotation += (rotateClockwise ? 1 : -1) * (rotationSpeed * delta);
  float alpha = spiralRadius / currentGoalRadius;
  float diff = acceleration * delta;
  if (alpha > (decelerationThreshold * currentExpansionPercentage)) {
    rotationSpeed -= diff;
  } else {
    rotationSpeed += diff;
  }
  rotationSpeed = clamp(rotationSpeed, MIN_ROTATION_SPEED * scaleDiff, MAX_ROTATION_SPEED * scaleDiff);

  // Calculate the current brush data
  float brushRotation = spiralRadius;
  if (expandInwards) {
    brushRotation = currentGoalRadius - spiralRadius;
  }
  float brushPosX = spiralY + cos(radians(spiralRotation)) * brushRotation;
  float brushPosY = spiralX + sin(radians(spiralRotation)) * brushRotation;
  float radius = (1 - alpha) * (MAX_BRUSH_SIZE * scaleDiff  - MIN_BRUSH_SIZE * scaleDiff); // Strokes scaled to the relative size of the spiral.

  // Draw current spiral
  noStroke();
  // The length of the stroke gets longer as the brush approaches an alpha of 1. The opacity also fades.
  for (int i = 0; i < (strokeLength * alpha); i++) {
    int dirMod = rotateClockwise ? 1 : -1;
    brushPosX = spiralX + cos(radians(spiralRotation + i * dirMod)) * brushRotation;
    brushPosY = spiralY + sin(radians(spiralRotation + i * dirMod)) * brushRotation;
    tmpColor = color(STROKE_COLOR_1);
    tmpColor = lerpColor(tmpColor, STROKE_COLOR_2, alpha);
    fill (tmpColor);   
    ellipse(brushPosX, brushPosY, radius, radius);
  }

  noFill();
  // Render debug information
  if (DEBUG) {
    strokeWeight(1.8);
    stroke(0, 255, 0);
    float debugWidth = 16;

    // Render index over all past circles
    textSize(textSize);
    textAlign(CENTER, CENTER);
    int index = 0;
    for (Circle c : spirals) {
      if (!circleInCanvas(c) || checkIfOverlaps(c, spirals)) {
        stroke(255, 0, 0);        
      } else {
        stroke(0, 255, 0);
      }
      ellipse(c.midX, c.midY, c.radius * 2, c.radius * 2);

      text(index, c.midX, c.midY);
      index ++;
    }
    // Render shape of current spiral
    ellipse(brushPosX, brushPosY, debugWidth, debugWidth);
    ellipse(spiralX, spiralY, currentGoalRadius * 2, currentGoalRadius * 2);
    line(spiralX, spiralY, brushPosX, brushPosY);
    stroke(0, 0, 255, 40);
    line(spiralX, spiralY, spiralX + currentGoalRadius, spiralY);
    stroke(100, 0, 255, 255);
    line(spiralX, spiralY, spiralX + currentGoalRadius * currentExpansionPercentage, spiralY);
    PVector lastRotationPt = getPointOnCircumference(currentGoalRadius, spiralStartingPosition);
    stroke(0, 0, 255);
    ellipse(lastRotationPt.x + spiralX, lastRotationPt.y + spiralY, 5 * scaleDiff, 5 * scaleDiff);

    // Render spiral data over current spiral
    textSize(textSize * scaleDiff);
    fill(tmpColor);
    text(spiralRadius / (currentGoalRadius * currentExpansionPercentage), spiralX, spiralY);
    fill(0, 255, 0, 255);
    float speedAlpha = (rotationSpeed - MIN_ROTATION_SPEED * scaleDiff) / (MAX_ROTATION_SPEED * scaleDiff - MIN_ROTATION_SPEED * scaleDiff);
    tmpColor = lerpColor(color(0, 255, 0), color(255, 0, 0), speedAlpha);
    fill(tmpColor);
    text(rotationSpeed, spiralX, spiralY - textSize);
  }

  // Construct a new spiral that shares an edge with the current spiral. If none are found, try a random point, if none can be found. Give up.
  if (alpha >= 1 * currentExpansionPercentage) {
    globalAttempts = 0;
    resetSpiralPosition();
  }
};

boolean toggleRotationDirection() {
  return rotateClockwise = !rotateClockwise;
}

void resetSpiralPosition() {
    if (globalAttempts > MAX_ATTEMPT_THRESHOLD) {
      drawingOver();
      return;
    }
    globalAttempts ++;
    
  
  // Add current spiral to history
  spirals.add(new Circle(spiralX, spiralY, currentGoalRadius));
  float degree = spiralStartingPosition;
  float prospectiveRadius = MAX_SPIRAL_RADIUS;
  PVector tmpPoint = getPointOnCircumference(currentGoalRadius, degree);
  float edgePointX = spiralX + tmpPoint.x;
  float edgePointY = spiralY + tmpPoint.y;
  Circle prospect = new Circle(spiralX + tmpPoint.x, spiralY + tmpPoint.y, prospectiveRadius);

  //  - 
  //  - Check to see if a circle that is created with the MAX_SPIRAL_RADIUS along the edge of the current spiral is...
  //    - Completely within the canvas
  //    - Not overlapping with any past circles    
  //  - Reduce radius if it is too wide and try again.
  //  - If the radius is below the MIN_RADIUS then increment the degree count and try again...
  //  - If the degree count is >= 359 then we've checked all that we can check and the simulation is over.
  degree = random(0, 360);  // Start with a random origin point along the edge of the current spiral.
degreeSearch: 
  for (int i = 0; i < 360; i ++) {
    degree ++;
    prospectiveRadius = MAX_SPIRAL_RADIUS;
    while (prospectiveRadius > MIN_SPIRAL_RADIUS) {
      prospectiveRadius -= 0.1f; // Shrink the potential radius a bit. See if that helps the new circle fit

      tmpPoint = getPointOnCircumference(currentGoalRadius, degree);
      edgePointX = spiralX + tmpPoint.x;
      edgePointY = spiralY + tmpPoint.y;

      prospect.midX = edgePointX + (cos(radians(degree)) * prospectiveRadius);
      prospect.midY = edgePointY + (sin(radians(degree)) * prospectiveRadius); 
      prospect.radius = prospectiveRadius;      
      // Check for a valid option every increment.
      if (circleInCanvas(prospect) && !checkIfOverlaps(prospect, spirals)) {
        break degreeSearch;
      }
    }
  }

  // If there isn't a valid option, then try to find a random point.
  if (!circleInCanvas(prospect) || checkIfOverlaps(prospect, spirals)) {
    moveBrushToRandomPoint();
  } else {
    spiralRadius = 0;
    rotationSpeed = 0;
    spiralX = prospect.midX;
    spiralY = prospect.midY;
    spiralRotation = spiralStartingPosition;
    currentGoalRadius  = prospect.radius;
    toggleRotationDirection();
    globalAttempts = 0;
    currentExpansionPercentage = random(MIN_EXPANSION_PERCENTAGE, MAX_EXPANSION_PERCENTAGE);
    println("[" + hour() + ":" + minute() + ":" + second() + ":" + millis() +  "] New brush location (" + spirals.size()  + "): " + spiralX + ", " + spiralY 
      + " | Starting Spiral Rotation: " + spiralRotation 
      + " | Goal Radius: " + currentGoalRadius 
      + " | Overlaps?: " + checkIfOverlaps(prospect, spirals) 
      + " | Expansion Percentage: " + currentExpansionPercentage);
  }
}

// Used as a fallback if the alg can't find a point along the previous circle.
void moveBrushToRandomPoint() {
  PVector tmp;
  int attemptCap = 10;
  int attempts = 0;
  do {
    attempts ++;
    tmp = getPointInCanvas();
  } while (pointInSpiral(tmp.x, tmp.y) && attempts < attemptCap);
  
  // Implying we exited because we didn't reach our max attempt threshold
  if (attempts < attemptCap) {
    //spiralX = tmp.x;
    //spiralY = tmp.y;
  }
  resetSpiralPosition();
}

// Called to end the drawing
void drawingOver() {
  drawing = false;
      println("[" + hour() + ":" + minute() + ":" + second() + ":" + millis() +  "] drawing complete.");
}

void keyPressed() {
  if (key == ENTER) {
    DEBUG = !DEBUG;
  }
}

// Returns a point that is within the canvas
PVector getPointInCanvas() {
  return new PVector(
    random(CANVAS_X, CANVAS_X + CANVAS_WIDTH), 
    random(CANVAS_Y, CANVAS_Y + CANVAS_HEIGHT)
    );
}

// Returns a point bound to the radius and angle provided
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
  yDst = abs(y - (CANVAS_Y + CANVAS_HEIGHT));
  if (xDst < c.radius || yDst < c.radius) {
    inCanvas = false;
  }
  return inCanvas;
}

// Returns true when the provided circle overlaps with any of the proivded circles
boolean checkIfOverlaps(Circle a, ArrayList<Circle> b) {
  //println("Checking if point overlaps....");
  boolean overlaps = false;
  for (Circle c : b) {
    if (a != c && a.overlaps(c)) {
      overlaps = true;
    }
  }
  return overlaps;
};

// Returns true when the provided point is within the draw canvas
boolean pointInCanvas(float x, float y) {
  return ( (x > CANVAS_X && x < CANVAS_X + CANVAS_WIDTH) && ( y > CANVAS_Y && y < CANVAS_Y + CANVAS_HEIGHT));
}

// Returns true when the provided point is within any of the previous spirals
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

// Model of a circle.
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

  // Returns true when this circle is overlapping with the provided circle
  boolean overlaps(Circle partner) {
    float dst = sqrt(pow(partner.midX - midX, 2) + pow(partner.midY - midY, 2));
    return dst < (radius + partner.radius);
  }
}