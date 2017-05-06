package util.steering;

import processing.core.PVector;

import static util.SolMath.distance;

public class Obstacle {
    public PVector position;
    public float radius;

    public Obstacle(PVector position, float radius) {
        this.position = position;
        this.radius = radius;
    }

    public boolean intersects(PVector pt) {
        return distance(position, pt) < radius;
    }
}
