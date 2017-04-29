package util.geometry;

import processing.core.PVector;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;

public class Polygon {
    public ArrayList<PVector> vertices;
    public PVector position = new PVector();
    private PVector midPoint = new PVector();
    private PVector tmp = new PVector();
    private PVector lastPt = new PVector();
    private int color;
    private ArrayList<String> tags = new ArrayList<>();

    public Polygon(PVector... vertices) {
        this.vertices = new ArrayList<>();
        this.vertices.addAll(Arrays.asList(vertices));
    }

    public Polygon (ArrayList<PVector> vertices) {
        this.vertices = new ArrayList<>();
        this.vertices.addAll(vertices);
    }

    public PVector midPoint() {
        vertices.forEach(vert -> midPoint.add(vert));
        midPoint.div(vertices.size() + 1);
        return midPoint;
    }

    public Polygon translate(float x, float y) {
        lastPt.set(position);
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

    public Polygon scale(float scale) {
        return scale(scale, scale);
    }

    public Polygon color(int color) {
        this.color = color;
        return this;
    }

    public Polygon tag(String... tags) {
        Collections.addAll(this.tags, tags);
        return this;
    }

    public boolean hasTag(String tag) {
        for (String s : tags) {
            if (s.equals(tag)) {
                return true;
            }
        }
        return false;
    }

    public int getColor() {
        return color;
    }

    public Polygon scale(PVector scaling) {
        return scale(scaling.x, scaling.y);
    }

    public Polygon position(float x, float y) {
        lastPt.set(position);
        position.set(x, y);
        return this;
    }

    static public boolean overlaps(Polygon a, Polygon b) {

     return true;
    }

    public static Polygon generate(PVector position, float radius, int segments) {
        float inc = (float) (2f * Math.PI) / segments;
        float startingPos = (float) (Math.PI / 2f);
        float currPos = 0f;
        ArrayList<PVector> pts = new ArrayList<>();
        while (currPos < 2 * Math.PI) {
            currPos += inc;
            float x = (float) Math.cos(startingPos + currPos) * radius;
            float y = (float) Math.sin(startingPos + currPos) * radius;
            pts.add(new PVector(x, y));
        }
        return new Polygon(pts).position(position.x, position.y);
    }
}
