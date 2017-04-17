int MIDX = width / 2;
int MIDY = height / 2;
int FRAME_RATE = 60;
int STROKE_WEIGHT = 1;

boolean DEBUG = true;

color DEBUG_COLOR;
color BACKGROUND_COLOR;
color DRAW_COLOR;

float E = (float) Math.E;

int lastFrame;
float delta;

WaterColumn[] columns;
ArrayList<RainDrop> rain = new ArrayList<RainDrop>();
ArrayList<RainDrop> garbage = new ArrayList<RainDrop>();

float rainTimer;
float rainInterval = 5;

float tension = 0.00045f;
float dampening = 0.0005f;
float spread = 0.25f;

float waterLine;

void setup() {
  strokeWeight(STROKE_WEIGHT);
  frameRate(FRAME_RATE);
  size(600, 600); 
  // SET VARIABLES THAT DEPEND ON WIDTH AND HEIGHT   
  waterLine =  height - height / 3;
  DEBUG_COLOR = color(#FFFFFF);
  BACKGROUND_COLOR = color(#d64524);
  DRAW_COLOR = color(#FFFFFF);

  columns = new WaterColumn[200];

  for (int i = 0; i < columns.length; i++)
  {
    columns[i] = new WaterColumn();
    columns[i].targetHeight = waterLine;
    columns[i].colHeight = waterLine;
    columns[i].speed = 0;
  }
}

void draw() {
  delta = (millis() - lastFrame) / 1000f;
  lastFrame = millis();
  background(BACKGROUND_COLOR);

  rainTimer += delta;
  
  rainInterval -= delta * 1;
  
  rainInterval = max(.00001, rainInterval);

  if (rainTimer > rainInterval) {
    rain.add(new RainDrop(random(0, width - 1), - height / 2));
    rainTimer -= rainInterval;
  }

  for (RainDrop drop : rain) {
    drop.draw(delta); 
    int index = (int) ( (float)(drop.x / (float)width) * (float)columns.length);
    if (drop.y > columns[index].colHeight) {
      garbage.add(drop); 
      splash(index, drop.velocity);
    }
  }
  
  for (RainDrop garbage : garbage) {
    rain.remove(garbage);
  }  
  garbage.clear();
  noStroke();
  fill(DRAW_COLOR);
  updateSimulation();

  for (int i = 0; i < columns.length; i ++) {
    float alpha = (float) i / (float)columns.length;
    WaterColumn col = columns[i];
    ellipse(alpha * width, col.colHeight, 15, 15);
    rect(alpha * width, col.colHeight, 15, height - col.colHeight);
  }
}

void keyPressed() {
  if (key == '1') {
    splash(0, 50);
  }

  if (key == '2') {
    splash(32, 50);
  }

  if (key == '3') {
    splash(64, 50);
  }

  if (key == '4') {
    splash(96, 50);
  }

  if (key == '5') {
    splash(128, 50);
  }
}

float alphaSmooth(float alpha) {
  return alpha * alpha * alpha * (alpha * (alpha * 6 - 15) + 10);
}

float getAngle(PVector vec) {
  return (float)Math.atan2(vec.y, vec.x);
}

void updateSimulation() {
  for (int i = 0; i < columns.length; i++)
    columns[i].update(dampening, tension);

  float[] lDeltas = new float[columns.length];
  float[] rDeltas = new float[columns.length];

  // do some passes where columns pull on their neighbours
  for (int j = 0; j < 8; j++)
  {
    for (int i = 0; i < columns.length; i++)
    {
      if (i > 0)
      {
        lDeltas[i] = spread * (columns[i].colHeight - columns[i - 1].colHeight);
        columns[i - 1].speed += lDeltas[i];
      }
      if (i < columns.length - 1)
      {
        rDeltas[i] = spread * (columns[i].colHeight - columns[i + 1].colHeight);
        columns[i + 1].speed += rDeltas[i];
      }
    }

    for (int i = 0; i < columns.length; i++)
    {
      if (i > 0)
        columns[i - 1].colHeight += lDeltas[i];
      if (i < columns.length - 1)
        columns[i + 1].colHeight += rDeltas[i];
    }
  }
}

void splash(int index, float speed) { 
  for (int i = max(0, index - 0); i < min(columns.length - 1, index + 1); i++)
    columns[index].speed = speed;
}

class WaterColumn {
  public float targetHeight;
  public float colHeight;
  public float speed;

  void update(float dampening, float tension) {
    float x = targetHeight - colHeight;
    speed += tension * x - speed * dampening;
    colHeight += speed;
  }
}

class RainDrop {
  float size = 5;
  float x;
  float y;
  float velocity;

  RainDrop(float x, float y) {
    this.x = x;
    this.y = y;
    size = random(1, 6);
    velocity = size;
  }

  void draw(float delta) {
    y += velocity;
    velocity += size * delta;
    noFill();
    strokeWeight(size);
    fill(DRAW_COLOR);
    ellipse(x, y, size, size);
  }
}