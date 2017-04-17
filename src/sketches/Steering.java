package sketches;

import processing.core.PVector;

import java.util.ArrayList;

public class Steering extends BaseSketch {
    protected ArrayList<Automaton> automatons;
    protected ArrayList<Obstacle> obstacles;
    protected float automatonRadius = .0075f;
    protected float obstacleRadius = .015f;
    int obstacleCount = 300;
    int automatonCount = 1;
    int OBSTACLE_COLOR;
    float maxAvoidForce = .18f;

    public void setup() {
        super.setup();
        title = "Steering";
        date = "04.15.17";
        automatons = new ArrayList<>();
        obstacles = new ArrayList<>();
        BACKGROUND_COLOR = color(0xd3dae5);
        DRAW_COLOR = color(0xFF43474f);
        DEBUG_COLOR = color(0xFF43474f);
        DEBUG = false;
        GRID_COLOR = color(0xFF43474f);
        OBSTACLE_COLOR = color(0xFFD68A51);

        PVector tmp;
        for (int i = 0; i < obstacleCount; i++) {
            tmp = new PVector(random(-0.5f, 0.5f), random(-0.5f, 0.5f));
            obstacles.add(new Obstacle(tmp, random(obstacleRadius / 2, obstacleRadius * 2)));
        }

        for (int i = 0; i < automatonCount; i++) {
            tmp = new PVector(random(-0.5f, 0.5f), random(-0.5f, 0.5f));
            automatons.add(new Automaton(tmp, obstacles));
        }
    }

    public void draw() {
        super.draw();
        for (Automaton automaton : automatons) {
            automaton.update(delta);
        }
        PVector pos;
        for (Obstacle obstacle : obstacles) {
            fill(OBSTACLE_COLOR);
            stroke(OBSTACLE_COLOR);
            ellipse(graphToCanvas(obstacle.position), CANVAS_WIDTH * obstacle.radius);
        }

        for (Automaton automaton : automatons) {
            pos = automaton.position;
            noStroke();
            fill(DRAW_COLOR);
            ellipse(graphToCanvas(pos), CANVAS_WIDTH * (automatonRadius * 2));
            textSize(10);
            PVector text = graphToCanvas(pos);
            text("Avoid Force " + maxAvoidForce, CANVAS_X, CANVAS_Y);
        }
    }

    class Automaton {
        PVector position;
        PVector velocity;
        ArrayList<Obstacle> obstacles;
        float wanderCircleDistance = .045f;
        float wanderCircleRadius = .1f;
        float speed = 0;
        float wanderAngle = 0;
        float ANGLE_CHANGE = 0.02f;
        float MAX_SPEED = .20f;
        float MAX_SEE_AHEAD = wanderCircleDistance * 2;
        float MAX_AVOID_FORCE = .15f;

        Automaton(PVector position, ArrayList<Obstacle> obstacles) {
            this.position = position;
            this.obstacles = obstacles;
            this.velocity = new PVector(speed, speed);
        }

        void update(float delta) {
            float rotation = atan2(velocity.y, velocity.x);
            float circleX = cos(rotation) * wanderCircleDistance;
            float circleY = sin(rotation) * wanderCircleDistance;
            PVector circleCenter = new PVector(circleX, circleY);
            PVector displacement = new PVector(0, 0);

            PVector wanderForce = circleCenter.add(displacement);

            wanderForce.rotate(wanderAngle);
            wanderAngle += delta * random(-ANGLE_CHANGE, ANGLE_CHANGE);
            velocity.add(wanderForce);

            PVector ahead = position.copy().add(velocity.copy().normalize().setMag(MAX_SEE_AHEAD));
            PVector ahead2 = position.copy().add(velocity.copy().normalize().setMag(MAX_SEE_AHEAD * 0.5f));
            Obstacle closest = null;
            for (Obstacle obstacle : obstacles) {
                if (obstacle.intersects(ahead) || obstacle.intersects(ahead2)) {
                    if (closest == null || distance(position, obstacle.position) < distance(position, obstacle.position)) {
                        closest = obstacle;
                    }
                }
            }
            if (closest != null) {
                PVector avoidForce = ahead.copy().sub(closest.position);
                avoidForce = avoidForce.normalize().setMag(maxAvoidForce);
                velocity.add(avoidForce);
            }

            if (velocity.mag() > MAX_SPEED) {
                velocity.setMag(MAX_SPEED);
            }
            position.add(velocity.x * delta, velocity.y * delta);

            // Wrap Arounds
            if (position.x > GRID_WIDTH / 2) {
                position.x = position.x - GRID_WIDTH;
            }

            if (position.x < -GRID_WIDTH / 2) {
                position.x = position.x + GRID_WIDTH;
            }

            if (position.y > GRID_HEIGHT / 2) {
                position.y = position.y - GRID_HEIGHT;
            }

            if (position.y < -GRID_HEIGHT / 2) {
                position.y = position.y + GRID_HEIGHT;
            }

            if (DEBUG) {
                noFill();
                stroke(0, 128, 64);
                strokeWeight(1);
                if (closest != null) {
                    stroke(128, 0, 0);
                }
                ellipse(graphToCanvas(circleX + position.x, circleY + position.y), wanderCircleRadius * 200);
            }
        }
    }

    class Obstacle {
        PVector position;
        float radius;

        public Obstacle(PVector position, float radius) {
            this.position = position;
            this.radius = radius;
        }

        public boolean intersects(PVector pt) {
            return distance(position, pt) < radius;
        }
    }
}


