package util.geometry;

import processing.core.PVector;

import java.lang.reflect.Array;
import java.util.ArrayList;
import java.util.Arrays;

public class Polygon {
    public ArrayList<PVector> vertices;
    public PVector position = new PVector();
    public float width;
    public float height;
    private PVector midPoint = new PVector();
    private PVector tmp = new PVector();

    public Polygon(PVector... vertices) {
        this.vertices = new ArrayList<>();
        this.vertices.addAll(Arrays.asList(vertices));
    }

    public PVector midPoint() {
        vertices.forEach(vert -> midPoint.add(vert));
        midPoint.div(vertices.size() + 1);
        return midPoint;
    }

    public Polygon translate(float x, float y) {
       position.add(x, y);
        return this;
    }

    public Polygon rotate(float degrees) {
        double angleRad = (degrees / 180) * Math.PI;
        for (PVector vertex : vertices) {
            vertex.rotate((float) angleRad);
        }
        return this;
    }

    public Polygon scale(float x, float y) {
        tmp.set(x, y);
        for (PVector vertex : vertices) {
            vertex.set(vertex.x * tmp.x, vertex.y * tmp.y);
        }
        midPoint();
        return this;
    }

    public Polygon scale(PVector scaling) {
        return scale(scaling.x, scaling.y);
    }

    public Polygon position(float x, float y) {
        position.set(x, y);
        return this;
    }
}
