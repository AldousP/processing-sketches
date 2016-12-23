import ddf.minim.*;
import ddf.minim.ugens.*;

int MIDX = width / 2;
int MIDY = height / 2;
int FRAME_RATE = 60;
float STROKE_WEIGHT = .25;

boolean DEBUG = false;

color DEBUG_COLOR;
color BACKGROUND_COLOR;
color DRAW_COLOR;

int lastFrame;
float delta;

float CANVAS_PERCENTAGE = .6;
float CANVAS_X;
float CANVAS_Y;
float CANVAS_WIDTH;
float CANVAS_HEIGHT;

// Portion of the canvas that nodes will occupy
float SPAWN_REGION_PERCENTAGE = 0.95;
float SPAWN_REGION_X;
float SPAWN_REGION_Y;
float SPAWN_REGION_WIDTH;
float SPAWN_REGION_HEIGHT;

int NODE_COUNT = 12;
float NODE_MIN_DIAMETER = 1;
float NODE_MAX_DIAMETER = 4;
float NODE_MIN_SPEED = 50;
float NODE_MAX_SPEED = 150;

float NODE_GOAL_RADIUS = 5;
float NODE_DECCELLERATION_RADIUS = 150;
float lastSoundLevel = 0;
float currentSoundLevel = 0;
float normSoundLevel = 0;

Minim minim;
AudioInput in;

Node[] nodes;

void setup() {
  strokeWeight(STROKE_WEIGHT);
  frameRate(FRAME_RATE);
  size(800, 800); 
  // SET VARIABLES THAT DEPEND ON WIDTH AND HEIGHT 
  DEBUG_COLOR = color(#FFFFFF);
  BACKGROUND_COLOR = color(#FFFFFF);
  DRAW_COLOR = color(#000000);
  CANVAS_WIDTH = width * CANVAS_PERCENTAGE;
  CANVAS_HEIGHT = height * CANVAS_PERCENTAGE;
  CANVAS_X =  width * (1 - CANVAS_PERCENTAGE) / 2;
  CANVAS_Y =  height * (1 - CANVAS_PERCENTAGE) / 2;
  SPAWN_REGION_WIDTH = CANVAS_WIDTH * SPAWN_REGION_PERCENTAGE;
  SPAWN_REGION_HEIGHT = CANVAS_HEIGHT * SPAWN_REGION_PERCENTAGE;
  SPAWN_REGION_X = CANVAS_X + CANVAS_WIDTH * (1 - SPAWN_REGION_PERCENTAGE) / 2;
  SPAWN_REGION_Y = CANVAS_Y + CANVAS_HEIGHT * (1 - SPAWN_REGION_PERCENTAGE) / 2;

  nodes = generateNodes();

  // Create the Input stream
  minim = new Minim(this);
  if (DEBUG) {
    minim.debugOn();
  }
  in = minim.getLineIn(Minim.STEREO, 512);
}

void draw() {
  delta = (millis() - lastFrame) / 1000f;
  lastFrame = millis();
  lastSoundLevel = currentSoundLevel;
  currentSoundLevel = in.mix.level() * 3;
  normSoundLevel = lerp(lastSoundLevel, currentSoundLevel, 0.5);
  background(BACKGROUND_COLOR);
  if (DEBUG) {
    noFill();
    stroke(DEBUG_COLOR);
    line(-1, height / 2, height + 1, height / 2);
    line(width / 2, -1, width / 2, height + 1);
  }

  // Draw Fills
  color from = color(255, 255, 255, 10);
  color to = color(200, 200, 200, 10);
  color lerped;
  for (int i = 0; i < nodes.length; i++) { 
    float x1, y1, x2, y2, x3, y3;
    int len = nodes.length;
    x1 = nodes[i].x;
    y1 = nodes[i].y;
    x2 = nodes[wrapIndex(i + 2, len)].x;
    y2 = nodes[wrapIndex(i + 2, len)].y;
    x3 = nodes[wrapIndex(i + 4, len)].x;
    y3 = nodes[wrapIndex(i + 4, len)].y;

    lerped = lerpColor(from, to, (float)i / len);
    fill(lerped);
    triangle(x1, y1, x2, y2, x3, y3);
  }

  for (Node n : nodes) {
    n.renderParticles(delta);
  }

  // Draw connectors
  for (Node n : nodes) {
    n.update(delta);
    fill(200, 200, 200);  
    float x1, y1, x2, y2;
    for (Node neighbor : n.neighbors) {
      if (neighbor != n) {
        // Get the stroke anchors for the current node...
        float radius = (n.currentDiameter) / 2;
        float angle = atan2(n.y - neighbor.y, n.x - neighbor.x);
        float pt1Angle = angle - radians(90);
        float pt2Angle = pt1Angle + radians(180);
        x1 = n.x + cos(pt1Angle) * radius;
        y1 = n.y + sin(pt1Angle) * radius;
        x2 = n.x + cos(pt2Angle) * radius;
        y2 = n.y + sin(pt2Angle) * radius;
        noStroke();

        if (DEBUG) {
          strokeWeight(2);
          stroke(0, 255, 0);
          ellipse(x1, y1, 3, 3);
          ellipse(x2, y2, 3, 3);
          line(x1, y1, x2, y2);
        }
        triangle(x1, y1, x2, y2, neighbor.x, neighbor.y);
      }
    }

    if (DEBUG) {
      ellipse(n.x, n.y, n.currentDiameter, n.currentDiameter);
    }
  }

  if (DEBUG) {
    textSize(50);
    fill(255, 0, 0);
    text(normSoundLevel, 25, 25 );
  }
}

// Classes
class Node {
  Node[] neighbors;
  Emitter emitter;
  float x;
  float y;
  // Points at the end of the line perpindicular to the diameter
  float currentDiameter;
  float nextDiameter;
  float lastDiameter;
  float goalX;
  float goalY;
  float movementSpeed;
  float lastX;
  float lastY;
  float distanceToGoal;
  float currentPathLength;
  float angleOfMovement;

  float emitInterval = 3;
  float emitIntervalCounter = 0;

  Node(float x, float y, float speed) {
    this.x = x;
    this.y = y;
    this.movementSpeed = speed;
    emitter = new Emitter();
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
    currentPathLength = distanceToGoal;
    lastDiameter = currentDiameter;
    nextDiameter = random(NODE_MIN_DIAMETER, NODE_MAX_DIAMETER);
  }

  void moveBy(float x, float y) {
    this.x += x;
    this.y += y;
  }

  void update(float delta) {
    emitIntervalCounter += delta;

    //println(emitIntervalCounter);
    if (emitIntervalCounter > emitInterval) {
      emitter.emit((int)random(3, 20), random(1, 20));
      emitIntervalCounter -= emitInterval;
      println("emit!");
    }

    float dx = goalX - x;
    float dy = goalY - y;
    angleOfMovement = atan2(dy, dx);
    float distanceFromGoal = sqrt(pow(goalX - x, 2) + pow(goalY - y, 2));
    float currentSpeed = NODE_MIN_SPEED + (movementSpeed * (100 * normSoundLevel));
    if (distanceFromGoal < NODE_DECCELLERATION_RADIUS) {
      float alpha = distanceFromGoal / NODE_DECCELLERATION_RADIUS;
      currentSpeed = currentSpeed * alpha;
    }
    float xIncrement = currentSpeed * cos(angleOfMovement);
    float yIncrement = currentSpeed * sin(angleOfMovement);
    moveBy(xIncrement * delta, yIncrement * delta);
    distanceFromGoal = sqrt(pow(goalX - x, 2) + pow(goalY - y, 2));
    currentDiameter = lerp(lastDiameter, nextDiameter, (currentPathLength - distanceFromGoal) / currentPathLength);   
    if (distanceFromGoal < NODE_GOAL_RADIUS) {
      setNewGoal();
    }
  }

  // There is no global particle system. 
  // Each node manages an Emitter which manages its own particle system. Inefficient, but, whatever. 
  void renderParticles(float deltaTime) {
    emitter.update(deltaTime, x, y);
    emitter.draw();
  }
}

class Emitter {
  ArrayList<Particle> particles;
  float x, y;

  Emitter() {
    particles = new ArrayList<Particle>();
  }

  void update(float delta, float x, float y) {
    this.x = x;
    this.y = y;
    for (Particle p : particles) {
      p.update(delta);
    }
  }

  void draw() {
    for (Particle p : particles) {
      fill(p.fill);
      rect(x + p.x, y + p.y, p.diameter, p.diameter);
    }
  }

  void emit(int particleCount, float particleSpeed) {
    Particle newPart;
    float particleDegreeInc = 360.0 / (float) particleCount;
    for (int i = 0; i < particleCount; i++) {
      newPart = new Particle(i * particleDegreeInc, particleSpeed);
      particles.add(newPart);
    }
  }

  class Particle {
    float x; 
    float y; 
    float diameter = 5;
    float speed;
    float timeAlive;
    float lifeSpan;
    color fill = color(200, 200, 200, random(100, 255));
    float rotation;

    Particle(float rotation, float speed) {
      this.rotation = rotation;
      this.speed = speed;
    }

    void update(float delta) {
      x += cos(radians(rotation)) + speed * delta;
      y += sin(radians(rotation)) + speed * delta;
    }
  }
}

// Utils
float alphaSmooth(float alpha) {
  return alpha * alpha * alpha * (alpha * (alpha * 6 - 15) + 10);
}

int wrapIndex(int index, int length) {
  if (index > length - 1) {
    index = wrapIndex(index - length, length);
  } 
  return index;
};

Node[] generateNodes() {
  Node[] newNodes = new Node[NODE_COUNT];
  float nodeX;
  float nodeY;  
  float nodeSpeed;
  Node newNode;

  for (int i = 0; i < newNodes.length; i++) {
    nodeX = random(SPAWN_REGION_X, SPAWN_REGION_X + SPAWN_REGION_WIDTH);
    nodeY = random(SPAWN_REGION_Y, SPAWN_REGION_Y + SPAWN_REGION_HEIGHT);
    nodeSpeed = random(NODE_MIN_SPEED, NODE_MAX_SPEED);
    newNode = new Node(nodeX, nodeY, nodeSpeed);
    newNode.setNeighbors(newNodes);
    newNodes[i] = newNode;
  }
  return newNodes;
}