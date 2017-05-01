package sketches;

import processing.core.PConstants;
import processing.core.PVector;
import util.Segment;
import util.SolMath;
import util.geometry.Polygon;

import java.util.ArrayList;

public class Collision extends BaseSketch {
    ArrayList<Polygon> polygons = new ArrayList<>();
    PVector gravity = new PVector(0, -0.25f);

    public void setup() {
        super.setup();
        STROKE_WEIGHT = 1.5f;
        BACKGROUND_COLOR = color(40, 21, 71);
        DRAW_COLOR = color(255, 255, 255);
        title = "Collision";
        date = "04.30.17";
        DEBUG = false;
        polygons.add(Polygon.generate(0, -0.25f, 0.075f, 4).rotate(45).scale(2, 1));
        polygons.add(Polygon.generate(0, 0.5f, 0.075f, 4).rotate(45).tag("dynamic"));
    }

    public void draw() {
        super.draw();
        stroke(DRAW_COLOR);
        strokeWeight(5);
        textAlign(PConstants.CENTER, PConstants.CENTER);
        for (Polygon polygon : polygons) {
            if (polygon.hasTag("dynamic")) {
                polygon.position.add(gravity.copy().mult(delta));
            }

            stroke(DRAW_COLOR);
            drawShape(polygon);
            if (polygon.hasTag("dynamic")) {
                tmp1.set(screenToWorld(mouseX, height - mouseY));
                polygon.position.add(gravity.copy().mult(delta));

                for (Polygon collider : polygons) {
                    if (collider != polygon && collides(polygon, collider, tmp1)) {
                        drawWorldLine(polygon.position, tmp1.copy().add(polygon.position), STROKE_WEIGHT);
                        polygon.position.add(tmp1.mult(delta));
                    }
                }
            }
        }
        postDraw();
    }
}
