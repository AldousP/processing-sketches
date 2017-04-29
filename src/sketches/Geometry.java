package sketches;

import processing.core.PVector;
import util.SolArray;
import util.geometry.Polygon;

import java.util.ArrayList;

/**
 * BlankSlate.
 */
public class Geometry extends BaseSketch {
    ArrayList<Polygon> polygons = new ArrayList<>();

    public void setup() {
        super.setup();
        STROKE_WEIGHT = 1.5f;
        title = "Geometry";
        date = "04.26.17";
        polygons.add(Polygon.triangle(tmp1.set(0, 0), 0.15f));
        polygons.add(Polygon.triangle(tmp1.set(0, 0), 0.15f).tag("cursor"));
    }

    public void draw() {
        super.draw();
        stroke(DRAW_COLOR);
        strokeWeight(5);

        for (Polygon polygon : polygons) {
            stroke(polygon.getColor());
            drawShape(polygon);
            for (Polygon collider : polygons) {
                if (collider != polygon && collides(polygon, collider)) {
                    polygon.color(color(0, 255, 0));
                    collider.color(color(0, 255, 0));
                } else {
                    polygon.color(color(255, 255, 255));
                    collider.color(color(255, 255, 255));
                }
            }
            if (polygon.hasTag("cursor")) {
                tmp1.set(screenToWorld(mouseX, height - mouseY));
                polygon.position(tmp1.x, tmp1.y);
            }
        }
    }

    public boolean overlaps(float a1, float a2, float b1, float b2) {
        float dstA = a2 - a1;
        float dstB = b2 - b1;
        float dstAvg = (dstA + dstB) / 2;
        float midA = a1 + (a2 - a1) / 2;
        float midB = b1 + (b2 - b1) / 2;
        float midDst = abs(midB - midA);
        return midDst < dstAvg;
    }

    public boolean collides(Polygon polyA, Polygon polyB) {
        boolean collides = true;

        for (int i = 0; i < polyA.vertices.size(); i++) {
            PVector ptA = polyA.vertices.get(i);
            PVector ptB = polyA.vertices.get(SolArray.wrapIndex(i + 1, polyA.vertices.size()));
            PVector midPoint = ptB.copy().add(ptA).mult(0.5f);
            PVector diff = ptA.copy().sub(ptB);
            PVector perp = diff.set(diff.y, -diff.x);
            PVector projA = project(polyA, perp);
            PVector projB = project(polyB, perp);

            if (!overlaps(projA.x, projA.y, projB.x, projB.y)) {
                collides = false;
            }
        }

        for (int i = 0; i < polyB.vertices.size(); i++) {
            PVector ptA = polyB.vertices.get(i);
            PVector ptB = polyB.vertices.get(SolArray.wrapIndex(i + 1, polyB.vertices.size()));
            PVector midPoint = ptB.copy().add(ptA).mult(0.5f);
            PVector diff = ptA.copy().sub(ptB);
            PVector perp = diff.set(diff.y, -diff.x);
            PVector projA = project(polyA, perp);
            PVector projB = project(polyB, perp);

            if (!overlaps(projA.x, projA.y, projB.x, projB.y)) {
                collides = false;
            }
        }
        return collides;
    }

    PVector project(Polygon entity, PVector axis) {
        PVector axisNorm = axis.copy().normalize();
        float min = entity.vertices.get(0).copy().add(entity.position).dot(axisNorm);
        float max = min;
        for (int i = 0; i < entity.vertices.size(); i++) {
            float proj = entity.vertices.get(i).copy().add(entity.position).dot(axisNorm);
            if (proj < min) {
                min = proj;
            }

            if (proj > max) {
                max = proj;
            }
        }
        return new PVector(min, max);
    }
}
