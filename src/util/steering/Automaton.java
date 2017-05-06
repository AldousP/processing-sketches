package util.steering;

import processing.core.PApplet;
import processing.core.PVector;
import sketches.Steering;

import java.util.ArrayList;

import static util.SolMath.distance;
import static util.SolMath.inRange;

public class Automaton {
    public Steering steering;
    public PVector position;
    public PVector velocity;
    ArrayList<Obstacle> obstacles;
    float wanderCircleDistance = .045f;
    float wanderCircleRadius = .1f;
    float speed = 0;
    float wanderAngle = 0;
    float ANGLE_CHANGE = 0.02f;
    float MAX_SPEED = .70f;
    float MAX_SEE_AHEAD = wanderCircleDistance * 2;
    float MAX_AVOID_FORCE = .15f;
    float GRID_WIDTH;
    float GRID_HEIGHT;

    public Automaton(PVector position, ArrayList<Obstacle> obstacles, float gridW, float gridH) {
        this.steering = steering;
        this.position = position;
        this.obstacles = obstacles;
        this.velocity = new PVector(speed, speed);
        this.GRID_WIDTH = gridW;
        this.GRID_HEIGHT = gridH;
    }

    public void update(float delta, float maxAvoidForce, boolean debug) {
        float rotation = PApplet.atan2(velocity.y, velocity.x);
        float circleX = PApplet.cos(rotation) * wanderCircleDistance;
        float circleY = PApplet.sin(rotation) * wanderCircleDistance;
        PVector circleCenter = new PVector(circleX, circleY);
        PVector displacement = new PVector(0, 0);
        PVector wanderForce = circleCenter.add(displacement);
        wanderForce.rotate(wanderAngle);

        float random = (float) (-ANGLE_CHANGE + (ANGLE_CHANGE * 2) * Math.random());
        wanderAngle += delta * random;
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
    }
}
