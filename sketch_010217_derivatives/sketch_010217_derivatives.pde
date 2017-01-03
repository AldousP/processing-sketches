import java.text.DecimalFormat;

float runTime = 0;
int FRAME_RATE = 60;
float STROKE_WEIGHT = .01;

boolean DEBUG = true;
boolean CANVAS_GRID = true;
int CANVAS_GRID_SUBDIV_X = 16;
int CANVAS_GRID_SUBDIV_Y = 16;
float CANVAS_GRID_OPACITY = 0.25;
String title = "derivatives";
String date = "01.02.17";

color DEBUG_COLOR;
PFont DEBUG_FONT;
color BACKGROUND_COLOR;
color DRAW_COLOR;
float spinnerRotation = 0;
int spinnerOrbs = 20;
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
float PALETTE_X;
float PALETTE_Y;
float PALETTE_HEIGHT;
float PALETTE_WIDTH;
float PALETTE_PERCENTAGE = 0.45;                   // Amount of space between bottom of the bottom of the canvas to the bottom of the page that the palette will fill

int lastFrame;
float delta;
ArrayList<Integer> palette = new ArrayList();
DecimalFormat df = new DecimalFormat(".#");

// Sketch specific variables
float GRID_LOWER_X = 0;
float GRID_UPPER_X = 1;
float GRID_LOWER_Y = 0;
float GRID_UPPER_Y = 1;
float GRID_SUBDIVISIONS = 1;
float GRID_PERCENTAGE = 0.75;                     // Percentage of the canvas space that the grid will be drawn on.
float GRID_X;
float GRID_Y;
float GRID_WIDTH;
float GRID_HEIGHT;
float GRID_STROKE_WEIGHT = 0.75;
int GRID_FONT_SIZE;
PFont GRID_FONT;
color GRID_COLOR = color(0, 255, 0);
float FUNCTION_BOX_WIDTH;
float FUNCTION_FONT_SIZE = 16;
float FUNCTION_CENTER_X;
float FUNCTION_CENTER_Y;
float FUNCTION_BASELINE_PERCENTAGE = 0.25;
float FUNCTION_BASELINE_Y;
float FUNCTION_WIDTH;
float FUNCTION_HEIGHT;

float FUNCTION_TERM_PADDING = 0;
float GRAPH_ANIMATION_LENGTH  = 5;
float GRAPH_ANIMATION_BALL_MIN_RADIUS = 15;
float GRAPH_ANIMATION_BALL_MAX_RADIUS = 20;
float CTRL_PT_GRAB_RADIUS = 35;
color CTRL_PT_COLOR = color(66, 203, 244);
float graphAnimationDelta;
int pulseCount = 5;
boolean animating = true;
int limitCount = 0;
ArrayList<PVector> limits = new ArrayList<PVector>();
ArrayList<PVector> ballPositions = new ArrayList<PVector>();
ArrayList<LimitAnimation> limitAnimations = new ArrayList<LimitAnimation>();
Polynomial function;
int controlPointIndex = 0;
float ctrlA = .25;
float ctrlB = .75;
int lastIndex = -1;
boolean mouseInEitherPoint = false;
float animationRadius;

void setup() {
  strokeWeight(STROKE_WEIGHT);
  frameRate(FRAME_RATE);
  size(700, 700); 
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
  PALETTE_HEIGHT = CANVAS_Y * PALETTE_PERCENTAGE;
  PALETTE_WIDTH = CANVAS_WIDTH * PALETTE_PERCENTAGE;
  PALETTE_Y = CANVAS_Y + CANVAS_HEIGHT;
  PALETTE_X = CANVAS_X;

  // Sketch settings
  GRID_X = CANVAS_X + (CANVAS_WIDTH - (CANVAS_WIDTH * GRID_PERCENTAGE)) / 2;
  GRID_Y = CANVAS_Y + (CANVAS_HEIGHT - (CANVAS_HEIGHT * GRID_PERCENTAGE)) / 2;
  GRID_WIDTH = CANVAS_WIDTH * GRID_PERCENTAGE;
  GRID_HEIGHT = CANVAS_HEIGHT * GRID_PERCENTAGE;
  GRID_FONT_SIZE = width / 36;
  GRID_FONT = createFont("georgia.ttf", GRID_FONT_SIZE);

  FUNCTION_CENTER_X = CANVAS_X + (CANVAS_WIDTH / 2);
  FUNCTION_CENTER_Y = CANVAS_Y;
  FUNCTION_HEIGHT  = height / 16;
  float functionBottomY = CANVAS_Y + FUNCTION_HEIGHT / 2;
  FUNCTION_BASELINE_Y = functionBottomY - FUNCTION_HEIGHT * FUNCTION_BASELINE_PERCENTAGE;

  // Init function x4-2x2+x
  function = new Polynomial();
  //function.addTerm(new Term(1, 4));
  //function.addTerm(new Term(2, 2));
  function.addTerm(new Term(1, 2));
  recalculateFunctionBox();

  float alpha;
  float range = GRID_UPPER_X - GRID_LOWER_X;
  float x, y;
  for (int i = 1; i <= limitCount; i++) {
    alpha = (float)i / (float)limitCount;
    x = alpha * range;
    y = function.solveForX(x);
    limits.add(new PVector(x, y));
  }
}

void draw() {
  delta = (millis() - lastFrame) / 1000f;
  runTime += delta;
  lastFrame = millis();
  background(BACKGROUND_COLOR);

  pollForInput();
  if (DEBUG) {
    drawDebug();
    drawSpinner();
    drawGrid();
    drawPalette();
    drawTime();
  }

  // Sketch specific methods
  if (animating) {
    drawAnimation();
  } else {
    drawGraph();
  }
  drawAxis();
  drawPolynomial();
  drawControlPoints();
  drawSlopeData();
  graphAnimationDelta += delta;
}

void pollForInput() {
  if (mousePressed) {
    float clampX = clamp(mouseX, GRID_X, GRID_X + GRID_WIDTH);
    float clampY = clamp(mouseY, GRID_Y, GRID_Y + GRID_HEIGHT);
    ellipse(clampX, clampY, 15, 15);
    boolean inA, inB;
    noFill();
    stroke(255, 0, 0);
    float graphRange = GRID_UPPER_X - GRID_LOWER_X;
    float x = graphRange * ctrlA;
    float y = function.solveForX(x);
    PVector screenConversion = graphToCanvas(x, y);
    Circle tmp = new Circle(screenConversion.x, screenConversion.y, CTRL_PT_GRAB_RADIUS);
    fill(255, 0, 0);
    inA = tmp.pointInCircle(clampX, clampY);
    x = graphRange * ctrlB;
    y = function.solveForX(x);
    screenConversion = graphToCanvas(x, y);
    tmp = new Circle(screenConversion.x, screenConversion.y, CTRL_PT_GRAB_RADIUS);
    inB = tmp.pointInCircle(clampX, clampY);
    mouseInEitherPoint = inA || inB;
    // Modify based on overlaps
    if (inA) {
      if (inB) {
        switch (lastIndex) {
        case -1:
          inA = true;
          inB = false;
          break;
        case 0:
          inA = true;
          inB = false;
          break;
        case 1:
          inA = false;
          inB = true;
          break;
        }
      }
    }

    if (inA) {
      ctrlA = (clampX - GRID_X) / (GRID_WIDTH);
      lastIndex = 0;
    } 

    if (inB) {
      lastIndex = 1;
      ctrlB = (clampX - GRID_X) / (GRID_WIDTH);
    }
  }
}

void drawAnimation() {
  float alpha = graphAnimationDelta / GRAPH_ANIMATION_LENGTH;
  alpha = clamp(function.solveForX(alpha), 0, 1);
  float currentX = GRID_LOWER_X + (GRID_UPPER_X - GRID_LOWER_X) * alpha;
  float currentY = function.solveForX(currentX);
  PVector tmp = graphToCanvas(currentX, currentY);
  noStroke();
  fill(GRID_COLOR);
  float pulseLength = GRAPH_ANIMATION_LENGTH / pulseCount; 
  float range = GRAPH_ANIMATION_BALL_MAX_RADIUS - GRAPH_ANIMATION_BALL_MIN_RADIUS;
  float modAlpha = graphAnimationDelta % pulseLength;
  if (modAlpha > 0.5) { 
    modAlpha = 1 - ((modAlpha - .5) * 2);
  } else {
    modAlpha *= 2;
  }
  animationRadius = modAlpha * range + GRAPH_ANIMATION_BALL_MIN_RADIUS;
  ellipse(tmp.x, tmp.y, animationRadius, animationRadius);
  if (alpha <= 1) {
    ballPositions.add(new PVector(tmp.x, tmp.y));
  }
  stroke(GRID_COLOR, "o");
  noFill();
  strokeWeight(2.5);
  PVector lastPos = ballPositions.get(0);
  for (PVector pos : ballPositions) {
    line(pos.x, pos.y, lastPos.x, lastPos.y);
    lastPos = pos;
  }
  float limitTmpAlpha;
  for (int i = 1; i <= limitCount; i++) {
    limitTmpAlpha = (float)i / (float) limitCount;
    if (alpha > limitTmpAlpha) {
      stroke(color(255, 255, 255), "0");
      tmp = limits.get(i - 1);
      boolean aboveHalf = tmp.y > (GRID_UPPER_Y - GRID_LOWER_Y) / 2;
      if (limitAnimations.size() <= i) {
        limitAnimations.add(new LimitAnimation(tmp.x, tmp.y, aboveHalf));
      }
      tmp = graphToCanvas(tmp.x, tmp.y);
      ellipse(tmp.x, tmp.y, GRAPH_ANIMATION_BALL_MAX_RADIUS, GRAPH_ANIMATION_BALL_MAX_RADIUS);
    }
  }

  for (LimitAnimation la : limitAnimations) {
    fill(color(255, 255, 255), "o");
    tmp = graphToCanvas(la.x, la.y);
    ellipse(tmp.x, tmp.y, 2, 2);
    la.render(delta);
  }
}

// Draw the X and Y axis of the graph
void drawAxis() {
  fill(255, 255, 255);
  strokeWeight(GRID_STROKE_WEIGHT);
  stroke(color(255, 255, 255), "o");
  line(GRID_X, GRID_Y, GRID_X, GRID_Y + GRID_HEIGHT);
  line(GRID_X, GRID_Y + GRID_HEIGHT, GRID_X + GRID_WIDTH, GRID_Y + GRID_HEIGHT);
  textFont(GRID_FONT);
  textAlign(CENTER);
  text(GRID_LOWER_X, GRID_X, GRID_Y + GRID_HEIGHT + GRID_FONT_SIZE);
  text(GRID_UPPER_X, GRID_X + GRID_WIDTH, GRID_Y + GRID_HEIGHT + GRID_FONT_SIZE);
  text(GRID_UPPER_Y, GRID_X, GRID_Y - GRID_FONT_SIZE / 2);
  // Draw mid points
  float midX = GRID_X + GRID_WIDTH / 2;
  float midY = GRID_Y + GRID_HEIGHT;
  textSize(GRID_FONT_SIZE / 2);
  line(midX, midY - 10, midX, midY + 10);
  text(GRID_LOWER_X + (GRID_UPPER_X - GRID_LOWER_X) / 2, midX, midY + GRID_FONT_SIZE);
  midX = GRID_X;
  midY = (GRID_Y) + GRID_HEIGHT / 2;
  text(GRID_LOWER_Y + (GRID_UPPER_Y - GRID_LOWER_Y) / 2, midX - GRID_FONT_SIZE, midY);
  line(midX - 10, midY, midX + 10, midY);
  
  if (GRID_LOWER_Y < 0) {
    PVector tmp = graphToCanvas(GRID_LOWER_X, 0);
    PVector tmp2 = graphToCanvas(GRID_UPPER_X, 0);
    line(tmp.x, tmp.y, tmp2.x, tmp2.y);
  }
  
  if (GRID_LOWER_X < 0) {
    PVector tmp = graphToCanvas(0, GRID_LOWER_Y);
    PVector tmp2 = graphToCanvas(0, GRID_UPPER_Y);
    line(tmp.x, tmp.y, tmp2.x, tmp2.y);
  }
}

void drawGraph() {
  PVector tmp = graphToCanvas(GRID_LOWER_X, GRID_LOWER_Y);
  float lastX = tmp.x;
  float lastY = tmp.y;
  strokeWeight(10);
  stroke(GRID_COLOR, "o");
  for (float x = GRID_LOWER_X; x <= GRID_UPPER_X; x += .0125) {
    tmp = graphToCanvas(x, function.solveForX(x));
    line(lastX, lastY, tmp.x, tmp.y);
    lastX = tmp.x;
    lastY = tmp.y;
  }
}

// Draw the control points
void drawControlPoints() {
  // Calculate current alpha.
  float graphAlpha = graphAnimationDelta / GRAPH_ANIMATION_LENGTH;
  graphAlpha = function.solveForX(graphAlpha);
  float textSize = animationRadius;
  // Draw ctrl points A and B
  float range = GRID_UPPER_X - GRID_LOWER_X;
  float x = range * ctrlA;
  float y = function.solveForX(x);
  PVector tmp = graphToCanvas(x, y);

  textSize(textSize);
  textAlign(RIGHT, BOTTOM);
  float r = red(CTRL_PT_COLOR);
  float g = green(CTRL_PT_COLOR);
  float b = blue(CTRL_PT_COLOR);
  fill(color(r, g, b, 255 * graphAlpha), "");
  stroke(color(r, g, b, 255 * graphAlpha), "");
  // Only draw if the animation has extended this far...
  if (graphAlpha > ctrlA) {
    ellipse(tmp.x, tmp.y, textSize, textSize);
    // Highlight if user is grabbing.
    if (lastIndex == 0 && mouseInEitherPoint) {
      noFill();
      ellipse(tmp.x, tmp.y, textSize * 2, textSize * 2);
    }
    // Render control point name
    fill(255, 255, 255, graphAlpha * 255);
    text("a", tmp.x + textSize / 2, tmp.y + textSize / 2);
  }

  x = range * ctrlB;
  y = function.solveForX(x);
  tmp = graphToCanvas(x, y);
  fill(color(r, g, b, 255 * graphAlpha), "");
  stroke(color(r, g, b, 255 * graphAlpha), "");
  // Only draw if the animation has extended this far...
  if (graphAlpha > ctrlB) {
    if (x > GRID_UPPER_X) {
      ellipse(tmp.x + textSize, tmp.y, textSize / 4, textSize / 4);
    }
    if (y > GRID_UPPER_Y) {
      ellipse(tmp.x, tmp.y - textSize, textSize / 4, textSize / 4);
    }
    ellipse(tmp.x, tmp.y, textSize, textSize);
    // Highlight if user is grabbing.
    if (lastIndex == 1 && mouseInEitherPoint) {
      noFill();
      ellipse(tmp.x, tmp.y, textSize * 2, textSize * 2);
    }
    // Render control point name
    fill(255, 255, 255, graphAlpha * 255);
    text("b", tmp.x + textSize / 2, tmp.y + textSize / 2);
  }
}

void drawSlopeData() {
  // Calculate current alpha.
  float graphAlpha = graphAnimationDelta / GRAPH_ANIMATION_LENGTH;
  graphAlpha = function.solveForX(graphAlpha);
 
  
   
  
}

void drawPolynomial () {
  fill(255, 255, 255);
  textSize(GRID_FONT_SIZE);
  float functionLeftX = FUNCTION_CENTER_X - FUNCTION_WIDTH / 2;
  float functionLeftY = FUNCTION_CENTER_Y;
  noFill();
  if (DEBUG) {
    strokeWeight(1);
    stroke(color(255, 255, 255), "o");
    rect(functionLeftX, functionLeftY - FUNCTION_HEIGHT / 2, FUNCTION_WIDTH, FUNCTION_HEIGHT);
  }
  textAlign(LEFT);
  text("y=", functionLeftX, FUNCTION_BASELINE_Y);
  float currentX = functionLeftX + textWidth("y=") + FUNCTION_TERM_PADDING;
  Term t;
  for (int i = 0; i < function.getTermCount(); i++) {
    t = function.getTerm(i);
    textAlign(LEFT);
    String val = t.toString();
    if (i == 0 && t.coefficient > 0 && val.substring(0, 1).equals("+")) {
      val = val.substring(1, val.length());
    }
    text(val, currentX, FUNCTION_BASELINE_Y); // Coeff. 
    currentX += textWidth(val) + FUNCTION_TERM_PADDING;
  }
}

void drawDebug() {
  if (DEBUG) {
    fill(#FFFFFF);
    noFill();
    strokeWeight(STROKE_WEIGHT);
    stroke(DEBUG_COLOR, "overridden");
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
    fill(color(255, 255, 255, 255 * alpha), "overridden");
    float currentDegree = (360 / spinnerOrbs) * i + spinnerRotation;
    float orbX = SPINNER_WIDTH / 2 + cos(radians(currentDegree)) * radius;
    float orbY = SPINNER_HEIGHT / 2 + sin(radians(currentDegree)) * radius;
    ellipse(orbX, orbY, radius, radius);
  }
}

void drawGrid() {
  if (CANVAS_GRID) {
    strokeWeight(STROKE_WEIGHT);
    stroke(color(255, 255, 255, 255 * CANVAS_GRID_OPACITY), "overridden");
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

void drawPalette() {
  noFill();
  stroke(#FFFFFF, "overridden");
  strokeWeight(STROKE_WEIGHT);
  rect(PALETTE_X, PALETTE_Y, PALETTE_WIDTH, PALETTE_HEIGHT);
  noStroke();
  float chipWidth = PALETTE_WIDTH / palette.size();
  float chipHeight = PALETTE_HEIGHT;
  for (int i = 0; i < palette.size(); i++) {
    fill(palette.get(i));
    rect(PALETTE_X + chipWidth * i, PALETTE_Y, chipWidth, chipHeight);
  }
}

void drawTime() {
  fill(color(255, 255, 255, 128), "overridden");
  textAlign(RIGHT, CENTER);
  textSize(24);  
  int millis = (int)((runTime - (floor(runTime))) * 1000);
  int seconds = (int)(runTime - (millis / 1000)) % 60;
  int minutes = floor(runTime / (60)) % 60;
  int hours = (floor(runTime / (60)) / 60) % 24;  
  String timeFormat = String.format("%s:%s:%s:%03dms", hours, minutes, seconds, millis);
  text(timeFormat, PALETTE_X + CANVAS_WIDTH, PALETTE_Y + 24);
}

// Classes used in graph
class Polynomial {
  private ArrayList<Term> terms = new ArrayList();

  float solveForX(float x) {
    float sum = 0;
    for (Term t : terms) {
      sum += t.solveForX(x);
    }
    return sum;
  }

  int getTermCount() {
    return terms.size();
  }

  void addTerm(Term t) {
    terms.add(t);
  }

  Term getTerm(int index) {
    return terms.get(index);
  }
}

class Term {
  int coefficient;
  int degree;
  String superScript = "\u2070";

  Term(int coefficient, int degree) {
    this.coefficient = coefficient;
    this.degree = degree;
  } 

  float solveForX(float x) {
    return coefficient * (pow(x, degree));
  }

  String toString() {
    StringBuilder sb = new StringBuilder();
    sb.append(coefficient > 0 ? "+" : "");
    sb.append(coefficient);
    sb.append("x");
    sb.append(superScript(degree));
    return sb.toString();
  }
}

String superScript(int value) {
  switch(value) {
  case 0: 
    return "\u2070";
  case 1: 
    return "";
  case 2: 
    return "\u00B2";
  case 3: 
    return "\u00B3";
  case 4: 
    return "\u2074";
  case 5: 
    return "\u2075";
  case 6: 
    return "\u2076";
  case 7: 
    return "\u2077";
  case 8: 
    return "\u2078";
  case 9: 
    return "\u2079";
  default:
    return "\u2070";
  }
}

class LimitAnimation {
  float x;
  float y;
  float animationDelta = 0;
  float animationLength = 2;
  boolean aboveHalf;
  float lineLength = GRID_HEIGHT / 16;

  LimitAnimation(float x, float y, boolean aboveHalf) {
    this.x = x;
    this.y = y;
    this.aboveHalf = aboveHalf;
  }

  void render(float delta) {
    PVector tmp = graphToCanvas(x, y);
    float canvasX = tmp.x;
    float canvasY = tmp.y;
    animationDelta += delta;
    float alpha = animationDelta / animationLength;
    alpha = clamp(function.solveForX(alpha), 0, 1);
    float lineX = canvasX;
    float lineY;
    if (aboveHalf) {
      lineY = canvasY + lineLength * alpha;
    } else {
      lineY = canvasY - lineLength * alpha;
    }
    stroke(255, 255, 255);
    strokeWeight(0.75);
    line(lineX, canvasY, lineX, lineY);
    fill(255, 255, 255, 255 * alpha);
    float textSize = GRID_HEIGHT / 48;
    float limitSize = GRID_HEIGHT / 36;
    textSize(textSize);
    if (aboveHalf) {
      lineY = canvasY + lineLength;
      textAlign(CENTER, TOP);
    } else {
      lineY = canvasY - lineLength;
      textAlign(CENTER, BOTTOM);
    }
    text("lim X -> " + nf(x, 3, 2), canvasX, ((aboveHalf ? 1 : -1)) * limitSize + lineY);
    textSize(limitSize);
    text(nf(y, 3, 2), canvasX, lineY + ((aboveHalf ? 1 : -1)) * (2 * limitSize)) ;
  }
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

void fill(color c, String s) {
  if (!palette.contains(c)) {
    palette.add(c);
  }
  fill(c);
}

void stroke(color c, String s) {
  if (!palette.contains(c)) {
    palette.add(c);
  }
  stroke(c);
}

void recalculateFunctionBox() {
  float functionWidth = 0;
  textFont(GRID_FONT);
  functionWidth += textWidth("y=");

  Term t;
  String s;
  for (int i = 0; i < function.getTermCount(); i ++) {
    t = function.getTerm(i);
    s = t.toString();
    if (i == 0 && t.coefficient > 0 && s.substring(0, 1).equals("+")) {
      s = s.substring(1, s.length());
    }
    functionWidth += textWidth(s);
    if (i != function.getTermCount() - 1) {
      functionWidth += FUNCTION_TERM_PADDING;
    }
  }
  FUNCTION_WIDTH = functionWidth;
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

  boolean pointInCircle(float x, float y) {
    float dst = sqrt(pow(x - midX, 2) + pow(y - midY, 2));
    return  dst < radius;
  }
}

PVector graphToCanvas(float x, float y) {
  float xAlpha = clamp(x, GRID_LOWER_X, GRID_UPPER_X) / (GRID_UPPER_X - GRID_LOWER_X);
  float yAlpha = clamp(y, GRID_LOWER_Y, GRID_UPPER_Y) / (GRID_UPPER_Y - GRID_LOWER_Y);
  return new PVector(GRID_X + GRID_WIDTH * xAlpha, (GRID_Y + GRID_HEIGHT) - GRID_HEIGHT * yAlpha);
} 

PVector canvasToGraph(float x, float y) {
  float xAlpha = clamp(x, CANVAS_X, CANVAS_X + CANVAS_WIDTH);
  float yAlpha = clamp(y, CANVAS_Y, CANVAS_Y - CANVAS_HEIGHT);
  return new PVector(GRID_X + GRID_WIDTH * xAlpha, (GRID_Y + GRID_HEIGHT) - GRID_HEIGHT * yAlpha);
} 

void keyPressed() {
  if (key == ENTER) {
    DEBUG = !DEBUG;
  }
}