package sketches;

import processing.core.PVector;
import util.geometry.Polygon;

import java.util.ArrayList;

/**
 * BlankSlate.
 */
public class Orb extends BaseSketch {

    ArrayList<PVector> points = new ArrayList<>();
    float rotationSpeed = 1;

    public void setup() {
        super.setup();
        frameRate(30);
        title = "Orb";
        date = "05.07.17";
        zoom = .008f;
        DEBUG = false;
        zoomInc = .05f;
        iHat.set(-0.51f, -0.47f);
        jHat.set(-1.18f, 0.13f);
        GRID_LOWER_X = -0.5f;
        GRID_UPPER_X = 0.5f;
        GRID_LOWER_Y = -0.31f;
        GRID_UPPER_Y = 0.69f;
        BACKGROUND_COLOR = color(25, 25, 25);
        for (int i = 0; i < 45; i++) {
            points.add(new PVector(
                    (float) Math.cos(radians(i * 8)) *  0.25f,
                    (float)Math.sin(radians(i * 8)) * 0.25f));
        }

    }

    public void draw() {
        super.draw();
        zoom += zoomInc * delta;
        rotationSpeed += .001f * delta;
//        iHat.rotate(radians(5 * delta));
//        jHat.rotate(radians(5 * delta));
        for (PVector point : points) {
            point.rotate(rotationSpeed * delta);
        }

        for (int i = 1; i < 6; i++) {
            int j = 1;
            for (PVector point : points) {
//                stroke(DRAW_COLOR);
                noFill();
                if (i % 2 == 0) {
                    stroke(color(0, 200 + 50f / j,  250 - 50f / j, 255 - 255f / j));
                } else {
                    stroke(color(45, 200 - 100f / j, 100 + 150f / j, 255f / j));
                }
                drawMultipleEllipse(point.copy().rotate(i * 10).mult(i), i / 10f, i, i * 300);
                j ++;
            }
        }
        postDraw();
    }

    @Override
    protected void drawDebug() {
        super.drawDebug();
        textAlign(CENTER);
    }

    @Override
    public void keyPressed() {
        super.keyPressed();
        if (key == 'a') {
        }

        if (key == CODED && keyCode == LEFT) {
        }
    }
}
