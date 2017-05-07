package sketches;

import processing.core.PConstants;
import util.geometry.Polygon;

import java.util.ArrayList;

public class Geometry extends BaseSketch {
    ArrayList<Polygon> polygons = new ArrayList<>();

    public void setup() {
        super.setup();
        STROKE_WEIGHT = 1.5f;
        BACKGROUND_COLOR = color(57, 95, 155);
        DRAW_COLOR = color(255, 255, 255);
        title = "Geometry";
        date = "04.26.17";
        DEBUG = false;
        polygons.add(Polygon.generate(0, 0, 0.075f, 3));
        polygons.add(Polygon.generate(0, 0, 0.075f, 8)
                .tag("cursor")
                .scale(1, 2f));

        polygons.add(Polygon
                .generate(0, 0, 0.075f, 8)
                .tag("cursor")
                .scale(1, 2)
                .rotate(90));
    }

    public void draw() {
        super.draw();
        stroke(DRAW_COLOR);
        strokeWeight(5);
        textAlign(PConstants.CENTER, PConstants.CENTER);

        for (Polygon polygon : polygons) {
            for (Polygon collider : polygons) {
                if (collider != polygon && collides(polygon, collider, tmp1)) {
                    fill(color(255, 255, 255));
                    drawWorldText("I'm colliding", polygon.position, 12);
                }
            }

            if (polygon.hasTag("cursor")) {
                tmp1.set(screenToWorld(mouseX, height - mouseY));
                polygon.position(tmp1.x, tmp1.y).rotate(180 * delta);
            }
            drawShape(polygon);
        }

        drawWorldText("Move the cursor with the mouse.", 0, -.25f, 12);
        drawWorldText("Move the camera with WASD.", 0, -.35f, 12);
        drawWorldText("Zoom with +/-.", 0, -.45f, 12);
        postDraw();
    }

}
