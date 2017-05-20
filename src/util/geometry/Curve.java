package util.geometry;

import processing.core.PVector;

public class Curve {
    public PVector pt1;
    public PVector pt2;
    public PVector cp1;
    public PVector cp2;

    public Curve(PVector pt1, PVector pt2, PVector cp1, PVector cp2) {
        this.pt1 = pt1;
        this.pt2 = pt2;
        this.cp1 = cp1;
        this.cp2 = cp2;
    }

    public Curve scale(float factor) {
        pt1.div(factor);
        pt2.div(factor);
        cp1.div(factor);
        cp2.div(factor);
        return this;
    }
}
