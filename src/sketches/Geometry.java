package sketches;

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
        polygons.add(Polygon.generate(tmp1.set(0, 0), 0.075f, 3));
        polygons.add(Polygon.generate(tmp1.set(0, 0), 0.075f, 8).tag("cursor"));
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

}
