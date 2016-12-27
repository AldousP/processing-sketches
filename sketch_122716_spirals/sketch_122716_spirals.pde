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
float minSpiralRadius = 5;
float spiralRadiusPerSecond = 15;
float acceleration = 150;
float BASE_ROTATION_SPEED = 0;
float MAX_ROTATION_SPEED = 700;

// Degrees per second
float rotationSpeed = BASE_ROTATION_SPEED;
boolean rotateClockwise = false;
float brushCurrentRadius = 0;
float brushCurrentRotation = 0;

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
  maxSpiralRadius = 72;
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
    strokeWeight(CANVAS_WIDTH / 256);
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
    for (Circle c : spirals) {
      noFill();
      strokeWeight(1);
      stroke(0, 255, 0);
      ellipse(c.midX, c.midY, c.radius * 2, c.radius * 2);
    }
  }

  if (brushCurrentRadius > maxSpiralRadius) {
    resetSpiralPosition();
  }
};

void resetSpiralPosition() {
  // Add current spiral to history
  spirals.add(new Circle(brushX, brushY, maxSpiralRadius));

  println("Finding new point...");

  // Get a random point on the circumference of the current spiral;
  float activeSpiralRadius = brushCurrentRadius;
  float degree = random(0, 360);
  PVector edgePointDiff = getPointOnCircumference(activeSpiralRadius, degree);
  float edgeX = edgePointDiff.x + brushX;
  float edgeY = edgePointDiff.y + brushY;
  float prospectiveRadius = activeSpiralRadius;

  float goalX = edgeX + cos(radians(degree)) * prospectiveRadius;
  float goalY = edgeY + sin(radians(degree)) * prospectiveRadius;
  
  // Keep shrinking the radius and rechecking
  while(pointInSpiral(goalX, goalY) || pointInCanvas(goalX, goalY)) {
    goalX = edgeX + cos(radians(degree)) * prospectiveRadius;
    goalY = edgeY + sin(radians(degree)) * prospectiveRadius;
    strokeWeight(0.45);
    fill(0, 255, 0); 
    line(goalX, goalY, edgeX, edgeY);
    noStroke();
    fill(255, 0, 0);
    ellipse(goalX, goalY, 5, 5);
    fill(255, 0, 0);
    ellipse(edgeX, edgeY, 5, 5);
    
    // Try a new random point;
    if (prospectiveRadius < 3) {
      prospectiveRadius = activeSpiralRadius;
      degree = random(0, 360);
    }
    
    println(prospectiveRadius);
    prospectiveRadius -= 1;
  }  
  
  
  println("New pos: " + brushX + ", " + brushY);
}


PVector getPointOnCircumference(float radius, float angle) {
  return new PVector(cos(radians(angle)) * radius, sin(radians(angle)) * radius);
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