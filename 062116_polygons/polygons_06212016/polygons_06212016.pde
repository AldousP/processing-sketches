int WIDTH = 600;
int HEIGHT = WIDTH;
int MIDX = WIDTH / 2;
int MIDY = HEIGHT / 2;
int PADDING = WIDTH / 8;
int POINTS = 45;
int POINT_PADDING = 60;
int FRAME_RATE = 60;
color BACKGROUND_COLOR;
color DRAW_COLOR;

int lastFrame;
float delta;
ArrayList<PVector> points;

void setup()
{
  BACKGROUND_COLOR = color(#5D737E);
  DRAW_COLOR = color(#C0FDFB);
  frameRate(FRAME_RATE);
  size(1, 1); //Work around for Processing 3.
  surface.setSize(WIDTH, HEIGHT);  
  points = new ArrayList();
  PVector temp;
  PVector v;
  for (int i = 0; i < POINTS; i ++) {
    temp = new PVector(random(0 + PADDING, WIDTH - PADDING), random(0 + PADDING, HEIGHT - PADDING));
    for (int j = 0; j < points.size(); j ++) {
      v = points.get(j);
      if (sqrt(sq(v.x - temp.x) + sq(v.y - temp.y)) < POINT_PADDING) {
        temp.set(random(0 + PADDING, WIDTH - PADDING), random(0 + PADDING, HEIGHT - PADDING));
        j = 0;
      }
    } 
    points.add(temp);
  }
}

void draw() {
  delta = (millis() - lastFrame) / 1000f;
  background(BACKGROUND_COLOR);
  fill(DRAW_COLOR);
  stroke(0, 0, 0, 0);
  for (PVector v : points) {
    ellipse(v.x, v.y, POINT_PADDING / 2, POINT_PADDING / 2);
    
  }
  
 
  lastFrame = millis();
}