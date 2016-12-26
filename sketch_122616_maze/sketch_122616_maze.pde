int MIDX = width / 2;
int MIDY = height / 2;
int FRAME_RATE = 60;
int STROKE_WEIGHT = 1;

boolean DEBUG = false;

color DEBUG_COLOR;
color BACKGROUND_COLOR;
color DRAW_COLOR;

float CANVAS_PERCENTAGE = 0.8f;
float CANVAS_X;
float CANVAS_Y;
float CANVAS_WIDTH;
float CANVAS_HEIGHT;

int lastFrame = 0;
float delta = 0;

boolean graph[][];

float TRAVEL_TIME = .08;
float travelDelta = 0;

int brushGraphX = 4;
int brushGraphY = 4;
int brushGoalX = 4;
int brushGoalY = 5;
float BRUSH_WIDTH;

float subDivisionX;
float subDivisionY;

boolean WARMED_UP = false;
boolean staleMate = false;

void setup()
{
  strokeWeight(STROKE_WEIGHT);
  frameRate(FRAME_RATE);
  size(720, 720); 
  // SET VARIABLES THAT DEPEND ON WIDTH AND HEIGHT 
  DEBUG_COLOR = color(#000000);
  BACKGROUND_COLOR = color(#FFFFFF);
  DRAW_COLOR = color(99, 173, 216);

  graph = new boolean[16][16];
  background(BACKGROUND_COLOR); 
  CANVAS_WIDTH = (float)width * (float)CANVAS_PERCENTAGE;
  CANVAS_HEIGHT = height * CANVAS_PERCENTAGE;
  BRUSH_WIDTH = CANVAS_WIDTH / graph.length / 2;
  CANVAS_X = (width - CANVAS_WIDTH) / 2;
  CANVAS_Y = (height - CANVAS_HEIGHT) / 2;
  subDivisionX = (CANVAS_WIDTH) / (float)(graph.length);
  subDivisionY = (CANVAS_HEIGHT) / (float) graph[0].length;

  if (DEBUG) {
    float nodeWidth = subDivisionX / 4; 
    for (int i = 0; i < graph.length; i ++) {
      for (int j = 0; j < graph[i].length; j ++) {
        ellipse(CANVAS_X + subDivisionX / 2 + subDivisionX * i, CANVAS_Y + subDivisionY / 2 + subDivisionY * j, nodeWidth, nodeWidth);
      }
    }
  }
}

void draw() {
  delta = (millis() - lastFrame) / 1000f;
  lastFrame = millis();
  //background(BACKGROUND_COLOR); 

  // There is an initial spike of .325 in the delta value that causes the brush math to go haywire. For some reason only on the first tick.
  if (!WARMED_UP) {
    WARMED_UP = true;
    return;
  }

  if (staleMate) {
    //println("STALE AF");
    return;
  }

  if (DEBUG) {
    noFill();
    stroke(DEBUG_COLOR);
    line(-1, height / 2, height + 1, height / 2);
    line(width / 2, -1, width / 2, height + 1);
    rect(CANVAS_X, CANVAS_Y, CANVAS_WIDTH, CANVAS_HEIGHT);
  }
  noFill();

  travelDelta += delta;
  float travelAlpha = clamp(travelDelta / TRAVEL_TIME, 0, 1);
  float brushX = CANVAS_X + subDivisionX * (brushGraphX + .5f);
  float brushY = CANVAS_Y + subDivisionY * (brushGraphY + .5f);
  float goalX = CANVAS_X + subDivisionX * (brushGoalX + .5f);
  float goalY = CANVAS_Y + subDivisionY * (brushGoalY + .5f);
  float newX = lerp(brushX, goalX, travelAlpha);
  float newY = lerp(brushY, goalY, travelAlpha);

  noStroke();
  fill(red(DRAW_COLOR), green(DRAW_COLOR), blue(DRAW_COLOR), random(50, 180));
  float brushSize = random(BRUSH_WIDTH / 4, BRUSH_WIDTH / 2);
  ellipse(newX, newY, brushSize, brushSize);

  //println("GOALX: " + brushGoalX + " | GOALY: " + brushGoalY);
  if (travelAlpha >= 1) {
    brushGraphX = brushGoalX;
    brushGraphY = brushGoalY;    
    graph[brushGraphX][brushGraphY] = true;
    travelDelta = 0;

    // Determine if there are any valid moves 
    boolean validMove = false;
    boolean validMoves[] = new boolean[4];

    // 0. (-1, 0) 
    if (brushGraphX != 0 && !graph[brushGraphX - 1][brushGraphY]) {  
      validMoves[0] = true;
      validMove = true;
    }

    // 1. (+1, 0)
    if (brushGraphX != graph.length - 1 && !graph[brushGraphX + 1][brushGraphY]) { 
      validMoves[1] = true;
      validMove = true;
    }

    // 2. (0, +1)
    if (brushGraphY != 0 && !graph[brushGraphX][brushGraphY - 1]) {    
      validMoves[2] = true;
      validMove = true;
    }

    // 3. (0, -1)
    if (brushGraphY != graph[0].length - 1 && !graph[brushGraphX][brushGraphY + 1]) { 
      validMoves[3] = true;
      validMove = true;
    }

    if (!validMove) {
      //staleMate = true;
      graph[brushGraphX][brushGraphY] = true;
      while (graph[brushGraphX][brushGraphY]) {
        brushGraphX = int(random(0, graph.length - 1));
        brushGraphY = int(random(0, graph[0].length - 1));
        if (brushGraphX != 0) {
          brushGoalX = brushGraphX - 1;
        } else {
          brushGoalX = brushGraphX + 1;
        }
        brushGoalY = brushGraphY;
      } 
    } else {
      int randInt = int(random(0, 4));
      while (!validMoves[randInt]) {
        randInt = int(random(0, 4));
      } 
      if (randInt == 0) {
        brushGoalX = brushGraphX - 1;
      } else if (randInt == 1) {
        brushGoalX = brushGraphX + 1;
      } else if (randInt == 2) {
        brushGoalY = brushGraphY - 1;
      } else if (randInt == 3) {
        brushGoalY = brushGraphY + 1;
      }
    }
  }
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