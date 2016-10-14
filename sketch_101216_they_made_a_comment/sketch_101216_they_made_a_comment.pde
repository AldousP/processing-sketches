int WIDTH = 600;
int HEIGHT = WIDTH;
int MIDX = WIDTH / 2;
int MIDY = HEIGHT / 2;
int FRAME_RATE = 60;
int STROKE_WEIGHT = 4;

boolean DEBUG = true;

color DEBUG_COLOR;
color BACKGROUND_COLOR;
color DRAW_COLOR;
color TEXT_COLOR;

int lastFrame;
float delta;

float textSize = HEIGHT / 10;
float textPosX = WIDTH / 2;
float textPosY = HEIGHT / 2;

String lineAText = "\"You Made Work...";
float lineASlideTimer;
float lineASlideLength = 5;
PVector lineAStartPos = new PVector(WIDTH / 2, -HEIGHT / 2);
PVector lineAEndPos = new PVector(WIDTH / 2, HEIGHT / 2);
PVector lineAPos = new PVector(lineAStartPos.x, lineAStartPos.y);

String lineBText = " they made a comment.\"";
float lineBTextSize = HEIGHT / 16;
float lineBStartDelay = lineASlideLength;
float lineBSlideTimer;
float lineBSlideLength = 5;
PVector lineBStartPos = new PVector(WIDTH / 2, HEIGHT + HEIGHT / 2);
PVector lineBEndPos = new PVector(WIDTH / 2, HEIGHT / 2 + (HEIGHT / 4));
PVector lineBPos = new PVector(lineBStartPos.x, lineBStartPos.y);

float padding = 0.05;
float borderW = WIDTH - padding * 2 * WIDTH;
float borderH = HEIGHT - padding * 2 * HEIGHT;
float borderX = WIDTH * padding;
float borderY = HEIGHT * padding;
float borderStroke = padding * 12;

void setup()
{
  DEBUG_COLOR = color(#FFFFFF);
  BACKGROUND_COLOR = color(#2c3254);
  DRAW_COLOR = color(#FFFFFF);
  TEXT_COLOR = color(#FFFFFF);
  strokeWeight(STROKE_WEIGHT);
  frameRate(FRAME_RATE);
  size(1, 1); //Work around for Processing 3.
  surface.setSize(WIDTH, HEIGHT);  
  fill(DRAW_COLOR);
  stroke(DRAW_COLOR);
}

void draw() {
  delta = (millis() - lastFrame) / 1000f;
  lastFrame = millis();
  background(BACKGROUND_COLOR);
  
  if (DEBUG) {
    noFill();
    stroke(DEBUG_COLOR);
    line(-1, HEIGHT / 2, WIDTH + 1, HEIGHT / 2);
    line(WIDTH / 2, -1, WIDTH / 2, HEIGHT + 1);
  }
  
  // UPDATE TIMERS AND TEXT POSITION
  if (lineASlideTimer <  lineASlideLength) {
    lineASlideTimer += delta;
    // ONE TIME SLIDE
    if (lineASlideTimer > lineASlideLength)
      lineASlideTimer = lineASlideLength;
  }
  
 if (lineBSlideTimer <  lineBSlideLength + lineBStartDelay) {
    lineBSlideTimer += delta;
    // ONE TIME SLIDE
    if (lineBSlideTimer > lineBSlideLength + lineBStartDelay)
      lineBSlideTimer = lineBSlideLength + lineBStartDelay;
  }
  
  float alpha = alphaSmooth((float)lineASlideTimer / (float)lineASlideLength);
  lineAPos.y = lineAStartPos.y + ((lineAEndPos.y - lineAStartPos.y) * alpha);
  
  if (lineBSlideTimer > lineBStartDelay) {
    alpha = (float)(lineBSlideTimer - lineBStartDelay) / (float)lineBSlideLength;
   } else {
     alpha = 0;
   }
  
  alpha = alphaSmooth(alpha);
  println(alpha);
  lineBPos.y = lineBStartPos.y + ((lineBEndPos.y - lineBStartPos.y) * alpha);
  
  // DRAW TEXT
  fill(TEXT_COLOR);
  noStroke();
  textAlign(CENTER);
  textSize(textSize);
  text(lineAText, lineAPos.x, lineAPos.y);
  textSize(lineBTextSize);
  text(lineBText, lineBPos.x, lineBPos.y);
  
  // DRAW BORDER
  noFill();
  stroke(DRAW_COLOR);
  strokeWeight(borderStroke);
  rect(borderX, borderY, borderW, borderH);
}

float alphaSmooth (float alpha) {
  return alpha * alpha * (3 - 2 * (alpha));
}