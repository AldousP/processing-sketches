package util.geometry;

import processing.core.PVector;
import util.geometry.Polygon;

public class VelocityPoly {
    public Polygon polygon;
    public PVector velocity;

    public VelocityPoly(Polygon polygon, PVector velocity) {
        this.polygon = polygon;
        this.velocity = velocity;
    }

    public void update(float delta, PVector gravity) {
        polygon.position.add(velocity.copy().mult(delta));
        velocity.add(gravity.copy().mult(delta));
    }
}
