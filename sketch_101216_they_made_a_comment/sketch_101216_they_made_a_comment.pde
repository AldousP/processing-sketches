int WIDTH = 600;
int HEIGHT = WIDTH;
int MIDX = WIDTH / 2;
int MIDY = HEIGHT / 2;
int FRAME_RATE = 60;
int STROKE_WEIGHT = 4;

color BACKGROUND_COLOR;
color DRAW_COLOR;

int lastFrame;
float delta;

float textPosX = 0;
float textPosY = HEIGHT / 2;
float textMoveSpeed;
float textSize = 64;
String text = "They made a comment";

float ballTimer = 0;
float ballLength = 5;

int weight = 0;

void setup()
{
  BACKGROUND_COLOR = color(#cba5cc);
  DRAW_COLOR = color(#FFFFFF);
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

  
  //textPosX += 100 * delta;
  
  ballTimer += delta;
  
  if (ballTimer > ballLength) {
    ballTimer -= ballLength;
  }
  
  //float ballAlpha = ballTimer / ballLength;
  //float ballPos = ballAlpha * WIDTH;
  
  //fill(DRAW_COLOR); 
  //ellipse(ballPos, HEIGHT / 2, 32, 32);

  //int slowDown = 20;
  //ballAlpha = ((ballAlpha * (slowDown - 1)) + 1) / slowDown; 
  //println(ballAlpha);
  //ballPos = ballAlpha * WIDTH;
  //ellipse(ballPos, HEIGHT / 4, 32, 32);
  
  //stroke(DRAW_COLOR);
  //fill(DRAW_COLOR);
  //textSize(textSize);
  ////text(text, textPosX, textPosY);
  
  //float alpha = (float)ballTimer / ballLength;
  //float modAlpha = sin((float)((alpha * Math.PI) / 2));
  //float x = HEIGHT * modAlpha;
  //ellipse(x, HEIGHT / 2, 5, 5);
  
  int N = 600;
  int A = 0;
  int B = WIDTH;
  float v;
  float x;
  for (int i = 0; i < N; i++) {
    v = i / N;
    v = 0.5 - cos((float)(-v * Math.PI)) * 0.5;
    x = (A * v) + (B * (1 - v));
    ellipse(, HEIGHT / 2, 15, 15);
  } 
}

float smoothStep(float x) {
  return (x) * (x) * (3 - 2 * (x));
}