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
int GRID_FONT_SIZE = 32;
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
Polynomial function;

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

  PALETTE_HEIGHT = CANVAS_Y * PALETTE_PERCENTAGE;
  PALETTE_WIDTH = CANVAS_WIDTH * PALETTE_PERCENTAGE;
  PALETTE_Y = CANVAS_Y + CANVAS_HEIGHT;
  PALETTE_X = CANVAS_X;

  GRID_X = CANVAS_X + (CANVAS_WIDTH - (CANVAS_WIDTH * GRID_PERCENTAGE)) / 2;
  GRID_Y = CANVAS_Y + (CANVAS_HEIGHT - (CANVAS_HEIGHT * GRID_PERCENTAGE)) / 2;
  GRID_WIDTH = CANVAS_WIDTH * GRID_PERCENTAGE;
  GRID_HEIGHT = CANVAS_HEIGHT * GRID_PERCENTAGE;
  GRID_FONT = createFont("georgia.ttf", GRID_FONT_SIZE);

  FUNCTION_CENTER_X = CANVAS_X + (CANVAS_WIDTH / 2);
  FUNCTION_CENTER_Y = CANVAS_Y;
  FUNCTION_HEIGHT  = height / 16;
  float functionBottomY = CANVAS_Y + FUNCTION_HEIGHT / 2;
  FUNCTION_BASELINE_Y = functionBottomY - FUNCTION_HEIGHT * FUNCTION_BASELINE_PERCENTAGE;

  // Init function
  function = new Polynomial();
  //function.addTerm(new Term(5, 3));
  //function.addTerm(new Term(3, 2));
  function.addTerm(new Term(1, 2));
  recalculateFunctionBox();
}

void draw() {
  delta = (millis() - lastFrame) / 1000f;
  runTime += delta;
  lastFrame = millis();
  background(BACKGROUND_COLOR);
  if (DEBUG) {
    drawDebug();
    drawSpinner();
    drawGrid();
    drawPalette();
    drawTime();
  }

  // Sketch specific methods
  drawAxis();
  drawGraph();
  drawPolynomial();
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
  text((GRID_UPPER_X - GRID_LOWER_X) / 2, midX, midY + GRID_FONT_SIZE);
  midX = GRID_X;
  midY = (GRID_Y + GRID_HEIGHT) / 2;
  text((GRID_UPPER_Y - GRID_LOWER_Y) / 2, midX - GRID_FONT_SIZE, midY);
  line(midX - 10, midY, midX + 10, midY);
}

void drawGraph() {
  PVector tmp = graphToCanvas(GRID_LOWER_X, GRID_LOWER_Y);
  float lastX = tmp.x;
  float lastY = tmp.y;
  strokeWeight(4);
  stroke(GRID_COLOR, "o");
  for (float x = GRID_LOWER_X; x < GRID_UPPER_X; x += .01) {
    tmp = graphToCanvas(x, function.solveForX(x));
    line(lastX, lastY, tmp.x, tmp.y);
    lastX = tmp.x;
    lastY = tmp.y;
  }
}

void drawPolynomial () {
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

PVector graphToCanvas(float x, float y) {
  float xAlpha = clamp(x, GRID_LOWER_X, GRID_UPPER_X) / (GRID_UPPER_X - GRID_LOWER_X);
  float yAlpha = clamp(y, GRID_LOWER_Y, GRID_UPPER_Y) / (GRID_UPPER_Y - GRID_LOWER_Y);
  return new PVector(GRID_X + GRID_WIDTH * xAlpha, (GRID_Y + GRID_HEIGHT) - GRID_HEIGHT * yAlpha);
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

void keyPressed() {
  if (key == ENTER) {
    DEBUG = !DEBUG;
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