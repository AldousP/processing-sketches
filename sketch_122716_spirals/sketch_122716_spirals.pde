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
float maxSpiralDisplacementRadius = 72;
float minSpiralRadius = 3;
float spiralRadiusPerSecond = 15;
float acceleration = 150;
float BASE_ROTATION_SPEED = 100;
float MAX_ROTATION_SPEED = 720;

// Degrees per second
float rotationSpeed = BASE_ROTATION_SPEED;
boolean rotateClockwise = false;
float brushCurrentRadius = 0;
float brushCurrentRotation = 0;
boolean drawing = true;

ArrayList<Circle> spirals;

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
  brushX = CANVAS_X + CANVAS_WIDTH / 2;
  brushY = CANVAS_Y + CANVAS_HEIGHT / 2;
  maxSpiralRadius = 36;
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

  fill(DRAW_COLOR);
  float brushPosX = brushX + cos(radians(brushCurrentRotation)) * brushCurrentRadius;
  float brushPosY = brushY + sin(radians(brushCurrentRotation)) * brushCurrentRadius;
  float widthMod = random(.5, 1.5);
  ellipse(brushPosX, brushPosY, brushCurrentRadius / 16 * widthMod, brushCurrentRadius / 16 * widthMod);

  brushCurrentRadius += spiralRadiusPerSecond * delta;
  brushCurrentRotation += (rotateClockwise ? 1 : -1) * rotationSpeed * delta;
  float alpha = brushCurrentRadius / maxSpiralRadius;
  rotationSpeed += ((alpha > .5 ? -1 : 1) * (acceleration * delta));
  rotationSpeed = clamp(rotationSpeed, BASE_ROTATION_SPEED, MAX_ROTATION_SPEED);

  if (DEBUG) {
    strokeWeight(CANVAS_WIDTH / 512);
    noFill();
    stroke(0, 255, 0);
    float debugWidth = CANVAS_WIDTH / 32;
    ellipse(brushX, brushY, debugWidth, debugWidth);
    ellipse(brushPosX, brushPosY, debugWidth, debugWidth);
    ellipse(brushX, brushY, maxSpiralRadius * 2, maxSpiralRadius * 2);
    line(brushX, brushY, brushPosX, brushPosY);
    stroke(0, 128, 255);
    line(brushX, brushY, brushX + maxSpiralRadius, brushY);
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

  if (brushCurrentRadius > maxSpiralRadius) {
    resetSpiralPosition();
  }
};

void resetSpiralPosition() {
  // Add current spiral to history
  spirals.add(new Circle(brushX, brushY, maxSpiralRadius));
  float degree = random(0, 360);
  float prospectiveRadius = maxSpiralDisplacementRadius;
  PVector tmpPoint = getPointOnCircumference(maxSpiralRadius, degree);
  float edgePointX = brushX + tmpPoint.x;
  float edgePointY = brushY + tmpPoint.y;
  Circle prospect = new Circle(brushX + tmpPoint.x, brushY + tmpPoint.y, prospectiveRadius);

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
    prospectiveRadius = maxSpiralDisplacementRadius;
    while (prospectiveRadius > minSpiralRadius) {
      attempts ++;
      println("ATTEMPTS: " + attempts + " DEGREE: " + degree + " RADIUS: " + prospectiveRadius);
      prospectiveRadius -= 1;

      tmpPoint = getPointOnCircumference(maxSpiralRadius, degree);
      edgePointX = brushX + tmpPoint.x;
      edgePointY = brushY + tmpPoint.y;

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
    brushCurrentRadius = 0;
    brushCurrentRotation = degree;
    brushX = prospect.midX;
    brushY = prospect.midY;
    maxSpiralRadius = prospect.radius;
  }
}

void moveBrushToRandomPoint() {
  PVector tmp;
  int attempts = 0;
  int attemptCap = width * height;
  do {
    attempts ++;
    println("Repositioning. attempt: " + attempts);
    tmp = getPointInCanvas();
  } while (pointInSpiral(tmp.x, tmp.y) && attempts < attemptCap);
  
  if (attempts < attemptCap) {
    brushX = tmp.x;
    brushY = tmp.y;
    resetSpiralPosition();
  }
}

void drawingOver() {
  drawing = false;
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