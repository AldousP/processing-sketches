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

float CANVAS_PERCENTAGE = .85;
float CANVAS_X;
float CANVAS_Y;
float CANVAS_WIDTH;
float CANVAS_HEIGHT;

// Portion of the canvas that nodes will occupy
float SPAWN_REGION_PERCENTAGE = 0.9;
float SPAWN_REGION_X;
float SPAWN_REGION_Y;
float SPAWN_REGION_WIDTH;
float SPAWN_REGION_HEIGHT;

int NODE_COUNT = 8;
float NODE_MIN_DIAMETER = 1;
float NODE_MAX_DIAMETER = 5;
float NODE_MIN_SPEED = 1;
float NODE_MAX_SPEED = 15;

float NODE_GOAL_RADIUS = 5;
float NODE_DECCELLERATION_RADIUS = 20;

Node[] nodes;

void setup() {
  strokeWeight(STROKE_WEIGHT);
  frameRate(FRAME_RATE);
  size(600, 600); 
  // SET VARIABLES THAT DEPEND ON WIDTH AND HEIGHT 
  DEBUG_COLOR = color(#FFFFFF);
  BACKGROUND_COLOR = color(#467796);
  DRAW_COLOR = color(#FFFFFF);
  CANVAS_WIDTH = width * CANVAS_PERCENTAGE;
  CANVAS_HEIGHT = height * CANVAS_PERCENTAGE;
  CANVAS_X =  width * (1 - CANVAS_PERCENTAGE) / 2;
  CANVAS_Y =  height * (1 - CANVAS_PERCENTAGE) / 2;
  SPAWN_REGION_WIDTH = CANVAS_WIDTH * SPAWN_REGION_PERCENTAGE;
  SPAWN_REGION_HEIGHT = CANVAS_HEIGHT * SPAWN_REGION_PERCENTAGE;
  SPAWN_REGION_X = CANVAS_X + CANVAS_WIDTH * (1 - SPAWN_REGION_PERCENTAGE) / 2;
  SPAWN_REGION_Y = CANVAS_Y + CANVAS_HEIGHT * (1 - SPAWN_REGION_PERCENTAGE) / 2;
  
  nodes = generateNodes();
}

void draw() {
  delta = (millis() - lastFrame) / 1000f;
  lastFrame = millis();
  background(BACKGROUND_COLOR);
  if (DEBUG) {
    noFill();
    stroke(DEBUG_COLOR);
    line(-1, height / 2, height + 1, height / 2);
    line(width / 2, -1, width / 2, height + 1);
  }
  //rect(CANVAS_X, CANVAS_Y, CANVAS_WIDTH, CANVAS_HEIGHT);
  for (Node n : nodes) {
    n.update(delta);
    fill(255, 255, 255);  
    //ellipse(.n.x, n.y, n.diameter, n.diameter);
    fill(255, 0, 255);
    for (Node neighbor : n.neighbors) {
      line(n.x, n.y, neighbor.x, neighbor.y);
    }  
  }
  noFill();
}

Node[] generateNodes() {
  Node[] newNodes = new Node[NODE_COUNT];

  float nodeX;
  float nodeY;
  float nodeDiameter;
  float nodeSpeed;
  Node newNode;
  for (int i = 0; i < newNodes.length; i++) {
    nodeX = random(SPAWN_REGION_X, SPAWN_REGION_X + SPAWN_REGION_WIDTH);
    nodeY = random(SPAWN_REGION_Y, SPAWN_REGION_Y + SPAWN_REGION_HEIGHT);
    nodeDiameter = random(NODE_MIN_DIAMETER, NODE_MAX_DIAMETER);
    nodeSpeed = random(NODE_MIN_SPEED, NODE_MAX_SPEED);
    newNode = new Node(nodeX, nodeY, nodeDiameter, nodeSpeed);
    newNode.setNeighbors(newNodes);
    newNodes[i] = newNode;
  }
  
  return newNodes;
}

class Node {
  float x;
  float y;
  float diameter;
  Node[] neighbors;
  float goalX;
  float goalY;
  float movementSpeed;
  float velocity;
  float lastX;
  float lastY;
  float distanceToGoal;

  Node(float x, float y, float diameter, float speed) {
    this.x = x;
    this.y = y;
    this.diameter = diameter;
    this.movementSpeed = speed;
    setNewGoal();
  }
  
  void setNeighbors(Node[] neighbors) {
    this.neighbors = neighbors;
  }
  
  void setNewGoal() {
    goalX = random(SPAWN_REGION_X, SPAWN_REGION_X + SPAWN_REGION_WIDTH);
    goalY = random(SPAWN_REGION_Y, SPAWN_REGION_Y + SPAWN_REGION_HEIGHT);
    lastX = this.x;
    lastY = this.y;
    distanceToGoal = sqrt(pow(goalX - x, 2) + pow(goalY - y, 2));
  }
  
  void update(float delta) {
    float dx = goalX - x;
    float dy = goalY - y;
    float angle = atan2(dy, dx);
    float distanceFromGoal = sqrt(pow(goalX - x, 2) + pow(goalY - y, 2));
    
    if (distanceFromGoal < NODE_DECCELLERATION_RADIUS) {
      float alpha 
    }
   
    if (distanceFromGoal < NODE_GOAL_RADIUS) {
      setNewGoal();
    }
  }
}