package sketches;

import processing.core.PVector;
import util.geometry.Polygon;

import java.util.ArrayList;

/**
 * BlankSlate.
 */
public class Geometry extends BaseSketch {
    ArrayList<Polygon> polygons = new ArrayList<>();

    public void setup() {
        super.setup();
        title = "Geometry";
        date = "04.26.17";

        for (int i = 0; i < 10; i++) {
            for (int j = 0; j < 10; j++) {
                polygons.add(
                    new Polygon(
                        new PVector(-.1f, -.1f),
                        new PVector(.1f, -.1f),
                        new PVector(.1f, .1f),
                        new PVector(-.1f, .1f)
                    )
                    .scale(.25f, .25f)
                    .position(GRID_LOWER_X + i * GRID_WIDTH / 9, GRID_LOWER_Y + j * GRID_HEIGHT / 9));
            }
        }
    }

    public void draw() {
        super.draw();
        stroke(DRAW_COLOR);
        strokeWeight(5);
        for (Polygon polygon : polygons) {
            drawShape(
                polygon.rotate(64 * delta));
        }
    }
}
