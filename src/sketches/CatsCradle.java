package sketches;

import java.util.ArrayList;

public class CatsCradle extends BaseSketch {
    // Portion of the canvas that nodes will spawn within
    float SPAWN_REGION_PERCENTAGE = 0.95f;
    float SPAWN_REGION_X;
    float SPAWN_REGION_Y;
    float SPAWN_REGION_WIDTH;
    float SPAWN_REGION_HEIGHT;

    int NODE_COUNT = 7;
    float NODE_MIN_DIAMETER = 0.035f;
    float NODE_MAX_DIAMETER = 2.75f;
    float NODE_MIN_SPEED = 45;
    float NODE_MAX_SPEED = 350;

    float MIN_PPS = 50;
    float MAX_PPS = 150;

    float NODE_GOAL_RADIUS = 5;
    float NODE_DECCELLERATION_RADIUS = 150;
    float speedCoeff = .15f;

    Node[] nodes;

    public void setup() {
        super.setup();
        title = "Cat's Cradle";
        date = "12.23.16";
        DEBUG = false;
        BACKGROUND_COLOR = color(0xFFFFFF);
        DRAW_COLOR = color(0xC2F5E);
        SPAWN_REGION_WIDTH = CANVAS_WIDTH * SPAWN_REGION_PERCENTAGE;
        SPAWN_REGION_HEIGHT = CANVAS_HEIGHT * SPAWN_REGION_PERCENTAGE;
        SPAWN_REGION_X = CANVAS_X + CANVAS_WIDTH * (1 - SPAWN_REGION_PERCENTAGE) / 2;
        SPAWN_REGION_Y = CANVAS_Y + CANVAS_HEIGHT * (1 - SPAWN_REGION_PERCENTAGE) / 2;
        nodes = generateNodes();
    }

    public void draw() {
        super.draw();
        // Render Particles
        for (Node n : nodes) {
            n.renderParticles(delta);
        }

        // Draw Fills
        int from = color(134, 45, 99, 50);
        int to = color(46, 65, 114, 0);
        int lerped;
        for (int i = 0; i < nodes.length; i++) {
            float x1, y1, x2, y2, x3, y3;
            int len = nodes.length;
            x1 = nodes[i].x;
            y1 = nodes[i].y;
            x2 = nodes[wrapIndex(i + 2, len)].x;
            y2 = nodes[wrapIndex(i + 2, len)].y;
            x3 = nodes[wrapIndex(i + 4, len)].x;
            y3 = nodes[wrapIndex(i + 4, len)].y;

            lerped = lerpColor(from, to, (float) i / len);
            fill(lerped, "");
            triangle(x1, y1, x2, y2, x3, y3);
        }

        // Draw connectors
        for (Node n : nodes) {
            n.update(delta);
            fill(color(140, 47, 94), "");
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
                noFill();
                stroke(0, 255, 0);
                ellipse(n.x, n.y, NODE_DECCELLERATION_RADIUS, NODE_DECCELLERATION_RADIUS);
                line(n.x, n.y, n.goalX, n.goalY);
            }

            ellipse(n.x, n.y, n.currentDiameter, n.currentDiameter);
        }

        if (DEBUG) {
            textSize(50);
            fill(color(255, 0, 0), "");
            fill(color(100, 240, 0), "");
        }
    }

    // Classes
    class Node {
        Node[] neighbors;
        Emitter emitter;
        float x;
        float y;
        // Points at the end of the line perpendicular to the diameter
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
            float dx = goalX - x;
            float dy = goalY - y;
            angleOfMovement = atan2(dy, dx);
            float distanceFromGoal = sqrt(pow(goalX - x, 2) + pow(goalY - y, 2));
            float currentSpeed = NODE_MIN_SPEED + (NODE_MAX_SPEED - NODE_MIN_SPEED) * speedCoeff;
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

        // Each node manages an Emitter which manages its own particle system. Inefficient, but, whatever.
        void renderParticles(float deltaTime) {
            emitter.update(deltaTime, x, y);
            emitter.draw();
        }
    }

    class Emitter {
        ArrayList<Particle> particles;
        ArrayList<Particle> garbage;
        float x, y;
        float squareSize;

        Emitter() {
            particles = new ArrayList<Particle>();
            garbage = new ArrayList<Particle>();
        }


        void update(float delta, float x, float y) {
            this.x = x;
            this.y = y;

            int pps = (int) random(MIN_PPS, MIN_PPS + ((MAX_PPS - MIN_PPS) * speedCoeff));

            //println("[EMITTER] PPS: " + pps + " EMISSIONS THIS TICK: " + (int)(pps * delta));
            emit((int) (pps * delta));

            for (Particle p : particles) {
                p.update(delta);
            }

            for (Particle g : garbage) {
                particles.remove(g);
            }
            garbage.clear();
        }

        void draw() {
            noStroke();
            for (Particle p : particles) {
                fill(p.fill, "");
                float x1, y1, x2, y2, x3, y3, x4, y4;
                float radian = p.diameter;

                // Top Right
                x1 = x + p.x + cos(radians(45 + (p.rotation - 45))) * radian;
                y1 = y + p.y + sin(radians(45 + (p.rotation - 45))) * radian;

                // Top Left
                x2 = x + p.x + cos(radians(135 + (p.rotation - 45))) * radian;
                y2 = y + p.y + sin(radians(135 + (p.rotation - 45))) * radian;

                // Bottom Left
                x3 = x + p.x + cos(radians(225 + (p.rotation - 45))) * radian;
                y3 = y + p.y + sin(radians(225 + (p.rotation - 45))) * radian;

                // Bottom Right
                x4 = x + p.x + cos(radians(315 + (p.rotation - 45))) * radian;
                y4 = y + p.y + sin(radians(315 + (p.rotation - 45))) * radian;

                quad(x1, y1, x2, y2, x3, y3, x4, y4);
            }
        }

        void emit(int particleCount) {
            Particle newPart;
            float particleDegreeInc = 360.0f / (float) particleCount;
            for (int i = 0; i < particleCount; i++) {
                newPart = new Particle(random(0, 360) + (i * particleDegreeInc),
                        random(5, 100 * speedCoeff), // SPEED
                        random(0, 700 * speedCoeff), // OFFSET
                        random(0, 5 * speedCoeff), // FADETIME
                        garbage);
                particles.add(newPart);
            }
        }

        class Particle {
            float x;
            float y;
            float diameter = random(0.01f, 2);
            float speed;
            float timeAlive;
            float lifeSpan;
            float targetOpacity = 200;
            float currentOpacity = 0;
            float rotation;
            float fadeLength;
            float lifeDelta;
            int fill = color(140, 47, random(70, 100), 0);
            ArrayList<Particle> garbage;

            // offset is from the spawn point
            Particle(float rotation, float speed, float offset, float fadeTime, ArrayList<Particle> garbage) {
                this.rotation = random(0, 360);
                this.speed = speed;
                this.x = cos(radians(rotation)) * offset;
                this.y = sin(radians(rotation)) * offset;
                this.fadeLength = fadeTime;
                this.garbage = garbage;
                this.lifeSpan = fadeLength * random(3, 5);
            }

            void update(float delta) {
                this.lifeDelta += delta;
                if (lifeDelta < fadeLength) {
                    float alpha = lifeDelta / fadeLength;
                    currentOpacity = max(1.1f, targetOpacity * alpha);
                    fill = color(red(fill), green(fill), blue(fill), currentOpacity);
                }

                if (lifeDelta > lifeSpan) {
                    float alpha = 1 - (lifeDelta - lifeSpan) / fadeLength;
                    currentOpacity = max(targetOpacity * alpha, 1);
                    fill = color(red(fill), green(fill), blue(fill), currentOpacity);
                    if (lifeDelta > lifeSpan + fadeLength) {
                        garbage.add(this);
                    }
                }

                //println(speed * delta);
                x += cos((rotation)) * (speed * delta);
                y += sin((rotation)) * (speed * delta);
            }
        }
    }

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
}

