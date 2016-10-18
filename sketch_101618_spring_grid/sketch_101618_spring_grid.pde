int MIDX = width / 2;
int MIDY = height / 2;
int FRAME_RATE = 60;
int STROKE_WEIGHT = 1;

boolean DEBUG = true;

color DEBUG_COLOR;
color BACKGROUND_COLOR;
color DRAW_COLOR;


float lastFrame;
float delta;

Spring[] springs;

int gridX = 1;
int gridY = 1;

float tension = 0.065f;
float dampening = 0.05f;
float spread = 0.45f;

float padding = .03f;
float canvasOffsetX;
float canvasOffsetY;
float canvasWidth;
float canvasHeight;

float attractRadius = 169;

void setup() {
  strokeWeight(STROKE_WEIGHT);
  frameRate(FRAME_RATE);
  size(600, 600); 
  // SET VARIABLES THAT DEPEND ON WIDTH AND HEIGHT   
  canvasOffsetX = width * padding;
  canvasOffsetY = height * padding;
  canvasWidth = width - canvasOffsetX * 2;
  canvasHeight = height - canvasOffsetY * 2;

  DEBUG_COLOR = color(#ba73a4);
  BACKGROUND_COLOR = color(#6189a5);
  DRAW_COLOR = color(#FFFFFF);

  springs = new Spring[gridX * gridY];


  int springCount = 0;
  float hAlpha;
  float vAlpha;

  float canvasDivW = canvasWidth / gridX;
  float canvasDivH = canvasHeight / gridY;
  for (int i = 0; i < gridX; i ++) {
    for (int j = 0; j < gridY; j ++) {
      Spring s = new Spring();
      hAlpha = i / (float) gridX;
      vAlpha = j / (float) gridY;
      s.x = canvasOffsetX + canvasDivW / 2 + hAlpha * canvasWidth;
      s.y = canvasOffsetY + canvasDivH / 2 + vAlpha * canvasHeight;
      springs[springCount] = s;
      springCount ++;
    }
  }
}

void draw() {
  delta = (millis() - lastFrame) / 1000f;
  lastFrame = millis();
  background(BACKGROUND_COLOR);

  noStroke();

  updateSimulation();

  noFill();
  stroke(DRAW_COLOR);
  strokeWeight(1);
  rect(canvasOffsetX, canvasOffsetY, canvasWidth, canvasHeight);

  int springIndex = 0;
  Spring s;
  float lastX = 0;
  float lastY = 0;
  for (int i = 0; i < gridX; i++) {
    for (int j = 0; j < gridY; j++) {
      s = springs[springIndex];
      s.render();
      // Draw Neighbors
      if (springIndex < springs.length - 1) {
        if (j != gridY - 1) {
          line(springs[springIndex + 1].x, springs[springIndex + 1].y, s.x, s.y);
        }

        if (springIndex + gridY < springs.length) {
          line(springs[springIndex + gridY].x, springs[springIndex + gridY].y, s.x, s.y);
        }
      }
      springIndex ++;
      lastX = s.oX;
      lastY = s.oY;
    }
  }

  if (mousePressed) {
    stroke(DRAW_COLOR);
  }

  ellipse(
    constrain(mouseX, canvasOffsetX, canvasOffsetX + canvasWidth), 
    constrain(mouseY, canvasOffsetY, canvasOffsetY + canvasHeight), 
    attractRadius, 
    attractRadius
    );
}


float getAngle(PVector vec) {
  return (float)Math.atan2(vec.y, vec.x);
}

void applyGravity(float x, float y) {
}

void updateSimulation() {
  for (int i = 0; i < springs.length; i++)
    springs[i].update(dampening, tension);

  float[] lDeltas = new float[springs.length];
  float[] rDeltas = new float[springs.length];

  // do some passes where springs pull on their neighbours
  for (int j = 0; j < 8; j++)
  {
    for (int i = 0; i < springs.length; i++)
    {
      if (i > 0)
      {
        lDeltas[i] = spread * (springs[i].currentLength - springs[i - 1].currentLength);
        springs[i - 1].speed += lDeltas[i];
      }
      if (i < springs.length - 1)
      {
        rDeltas[i] = spread * (springs[i].currentLength - springs[i + 1].currentLength);
        springs[i + 1].speed += rDeltas[i];
      }
    }

    for (int i = 0; i < springs.length; i++)
    {
      if (i > 0)
        springs[i - 1].currentLength += lDeltas[i];
      if (i < springs.length - 1)
        springs[i + 1].currentLength += rDeltas[i];
    }
  }
}

public float getRelativeRotationOfPoint(float originX, float originY, float ptX, float ptY) {
  float result = degrees(atan2(ptY - originY, ptX - originX));
  if (result < 0) {
    result += 360;
  }
  return result;
}

class Spring {
  float length = 1;
  float currentLength = 1;
  float x;
  float y;
  float speed;
  float oX;
  float oY;
  boolean inRange;

  void update(float dampening, float tension) {
    float diff = length - currentLength;
    speed += tension * diff - speed * dampening;
    currentLength += speed;

    oX = currentLength + x;
    oY = currentLength + y;
    inRange = false;
    if (mousePressed) {
      float xPos = constrain(mouseX, canvasOffsetX, canvasOffsetX + canvasWidth);
      float yPos = constrain(mouseY, canvasOffsetY, canvasOffsetY + canvasHeight);
      float distanceToPoint = sqrt(pow(x - xPos, 2) + pow(y - yPos, 2));
      float rotation = getRelativeRotationOfPoint(x, y, xPos, yPos);
      float alphaDistance = distanceToPoint / attractRadius;
      if (distanceToPoint < attractRadius / 2) {
        inRange = true;
        speed = (1 -alphaDistance) * attractRadius;
        oX = cos(radians(rotation)) * currentLength + x;
        oY = sin(radians(rotation)) * currentLength + y;
      }
    }
  }

  void render() {
    noFill();

    stroke(DRAW_COLOR);
    if (inRange) {
      stroke(255, 0, 0);
    }
    ellipse(x, y, 15, 15);
    stroke(DEBUG_COLOR);
    ellipse(oX, oY, 15, 15);
    line(x, y, oX, oY);
  }
}