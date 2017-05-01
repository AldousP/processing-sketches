package sketches;

import processing.core.PConstants;
import util.geometry.Polygon;

import java.util.ArrayList;

public class Spiral extends BaseSketch {
    ArrayList<Polygon> polygons = new ArrayList<>();

    float alpha = 0;
    float alphaInc = 0.01f;

    public void setup() {
        super.setup();
        STROKE_WEIGHT = 0.15f;
        BACKGROUND_COLOR = color(70, 23, 32);
        DRAW_COLOR = color(230, 230, 230);
        title = "Spiral";
        date = "04.29.17";
        DEBUG = false;
        for (int i = 0; i < 10; i++) {
            polygons.add(Polygon
                    .generate(0, 0, (float) Math.pow(.1f * i, 2), 12)
                    .scale(0.1f * i)
                    .rotate(90 * i));
        }
    }

    public void draw() {
        super.draw();
        alpha += alphaInc;
        if (alpha > 1) {
            alpha -= 1;
        }
        stroke(DRAW_COLOR);
        strokeWeight(5);
        textAlign(PConstants.CENTER, PConstants.CENTER);
        Polygon last = polygons.get(0);
        int i = 1;
        for (Polygon polygon : polygons) {
            drawShape(polygon);
            polygon.rotate(100 / i * delta);
            drawVolume(last, polygon);
            last = polygon;
            i++;
        }
        postDraw();
    }
}
