package sketches;

import processing.core.PVector;
import util.Segment;
import util.geometry.Polygon;

import java.awt.*;
import java.util.ArrayList;

import static util.SolArray.wrapIndex;
import static util.SolMath.inRange;

/**
 * BlankSlate.
 */
public class Geometry extends BaseSketch {
    ArrayList<Polygon> polygons = new ArrayList<>();
    public int debugVertice = 0;

    public void setup() {
        super.setup();
        title = "Geometry";
        date = "04.26.17";
        polygons.add(new Polygon(
                new PVector(.25f, .25f),
                new PVector(.25f, -.25f),
                new PVector(-.25f, -.25f),
                new PVector(-.25f, .25f)
        ).scale(.35f).rotate(49));
    }

    public void draw() {
        super.draw();
        stroke(DRAW_COLOR);
        strokeWeight(5);

        for (Polygon polygon : polygons) {
            drawShape(polygon);
            if (debugVertice > polygon.vertices.size() - 1) {
                return;
            }
            PVector a = polygon.vertices.get(debugVertice);
            PVector b = polygon.vertices.get(wrapIndex(debugVertice + 1, polygon.vertices.size()));
            drawWorldLine(a.add(polygon.position), b.add(polygon.position), 3);

            PVector midPoint = b.copy().add(a).mult(0.5f);
            drawWorldEllipse(midPoint, .015f, STROKE_WEIGHT);
        }
    }

    public void drawDebug() {
        super.drawDebug();
        textSize(24);
        textAlign(1);
        text("EDGE: " + debugVertice, CANVAS_X, CANVAS_Y - 24);
    }

    @Override
    public void keyPressed() {
        super.keyPressed();
        if (key == 'y') {
            debugVertice --;
        }

        if (key == 'u') {
            debugVertice ++;
        }

        if (debugVertice < 0) {
            debugVertice = 0;
        }
    }

    PVector project(Polygon entity, PVector axis) {
        PVector axisNorm = axis.copy().normalize();
        float min = entity.vertices.get(0).dot(axisNorm);
        float max = min;
        for (int i = 0; i < entity.vertices.size(); i++) {
            float proj = entity.vertices.get(i).dot(axisNorm);
            if (proj < min) {
                min = proj;
            }

            if (proj > max) {
                max = proj;
            }
        }
        return new PVector(min, max);
    }

    PVector perpendicular(PVector axis) {
        return axis.copy().set(-axis.x, -axis.y);
    }
}
