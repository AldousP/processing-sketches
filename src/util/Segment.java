package util;

import processing.core.PVector;

public class Segment {
    public PVector pointA;
    public PVector pointB;
    public PVector dir;

    public Segment(PVector pA, PVector pB) {
        pointA = pA;
        pointB = pB;
        dir = new PVector(pointB.x - pointA.x, pointB.y - pointA.y);
    }
}
