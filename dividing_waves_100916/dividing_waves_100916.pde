int WIDTH = 600;
int HEIGHT = WIDTH;
int MIDX = WIDTH / 2;
int MIDY = HEIGHT / 2;
int FRAME_RATE = 60;
int STROKE_WEIGHT = 4;

color BACKGROUND_COLOR;
color WAVE_COLOR_1;
color WAVE_COLOR_2;
color WAVE_COLOR_3;

boolean firstTime = true;

int lastFrame;
float delta;

float strokeTimer = 0;
float strokeIntervalLength = 2.5;
float strokeMinSize = 3;
float strokeMaxSize = 60;

float strokeRange = .15;

int cosCo = 1;

void setup()
{
  BACKGROUND_COLOR = color(#14455b);
  WAVE_COLOR_1 = color(#30ace5);
  WAVE_COLOR_2 = color(#30e5d5);
  WAVE_COLOR_3 = color(#309ce5);

  strokeWeight(STROKE_WEIGHT);
  frameRate(FRAME_RATE);
  size(1, 1); //Work around for Processing 3.
  surface.setSize(WIDTH, HEIGHT);  
  fill(WAVE_COLOR_1);
  stroke(WAVE_COLOR_1);
}

void draw() {
  delta = (millis() - lastFrame) / 1000f;
  lastFrame = millis();

  // Manage timer for length of stroke.
  strokeTimer += delta;
  if (strokeTimer >= strokeIntervalLength) {
    strokeTimer -= strokeIntervalLength;
    cosCo ++;
  }
  float strokeProgress = (float) strokeTimer / (float) strokeIntervalLength;
  background(BACKGROUND_COLOR);
  stroke(WAVE_COLOR_1);
  fill(WAVE_COLOR_1);
  
  float perc;
  float baseY = HEIGHT / 2;
  for (int i = 0; i < 600; i ++) {
    perc = (float)i / (float) WIDTH;
    float distanceFromStrokeProgress = shortestDistance(perc, strokeProgress, 0, 1);
    float stroke = strokeMinSize;
    if (Math.abs(distanceFromStrokeProgress) < strokeRange) {
      float alpha = (distanceFromStrokeProgress / strokeRange);
      if (alpha < 0) {
        alpha = 1 - (alpha + 1);
      }
      stroke = lerp(strokeMaxSize, strokeMinSize, alpha);
    }
    
    float x = (float) (perc * (2 * Math.PI));
    float y = baseY + (HEIGHT / 2) * sin(x);
    
    //stroke(WAVE_COLOR_1);
    //fill(WAVE_COLOR_1);
    //ellipse(i, y, stroke, stroke);
    
    y = baseY + (HEIGHT / 2) * (cos(x * cosCo));
    stroke(WAVE_COLOR_2);
    fill(WAVE_COLOR_2);
    ellipse(i, y, stroke, stroke);
    
    //y = HEIGHT - (baseY + (HEIGHT / 2) * (cos(x)/6));
    //stroke(WAVE_COLOR_3);
    //fill(WAVE_COLOR_3);
    //ellipse(i, y, stroke, stroke);
    
    //stroke(255, 0, 0);
    //line(strokeProgress * WIDTH, -999, strokeProgress * WIDTH, 999);
    //line((strokeProgress - strokeRange) * WIDTH, -999, (strokeProgress - strokeRange) * WIDTH, 999);
    //line((strokeProgress + strokeRange) * WIDTH, -999, (strokeProgress + strokeRange) * WIDTH, 999);
  }
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