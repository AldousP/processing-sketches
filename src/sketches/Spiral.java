package sketches;

import processing.core.PConstants;
import processing.core.PVector;
import util.geometry.Polygon;

import java.util.ArrayList;

public class Spiral extends BaseSketch {
    ArrayList<Polygon> polygons = new ArrayList<>();

    float alpha = 0;
    float alphaInc = 0.0001f;

    PVector rRange = new PVector(10, 100);
    PVector gRange = new PVector(10, 100);
    PVector bRange = new PVector(10, 100);
    PVector camRange = new PVector(0.5f, 5);

    float r = rRange.x;
    float g = gRange.y;
    float b = bRange.x + (bRange.y - bRange.x) / 2;

    float rInc = -10;
    float gInc = 10;
    float bInc = -10;

    public void settings() {size(700, 700);
    }

    public void setup() {
        super.setup();
        STROKE_WEIGHT = 0.5f;
        BACKGROUND_COLOR = color(70, 23, 32);
        DRAW_COLOR = color(230, 230, 230);
        title = "Spiral";
        date = "04.29.17";
        DEBUG = false;
        for (int i = 1; i < 10; i++) {
            polygons.add(Polygon
                    .generate(0, 0, (float) Math.pow(.1f * i, 2), 12)
                    .scale(0.5f * i)
                    .rotate(10 * i));
        }
        zoom = 5;
    }

    public void draw() {
        super.draw();
        BACKGROUND_COLOR = color(r, g, b);
        alpha += alphaInc;

        if (alpha > 1) {
            alpha = 1;
            alphaInc *= -1;
        }

        if (alpha < 0) {
            alpha = 0;
            alphaInc *= -1;
        }


        float rand = random(0 ,1);
        if (rand < .33f) {
            r += rInc * delta;
            if (r > rRange.y) {
                r = rRange.y;
                rInc *= -1;
            }

            if (r < rRange.x) {
                r = rRange.x;
                rInc *= -1;
            }
        }

        if (rand > .33f && rand < .66f) {
            g += gInc * delta;
            if (g > gRange.y) {
                g = gRange.y;
                gInc *= -1;
            }

            if (g < gRange.x) {
                g = gRange.x;
                gInc *= -1;
            }
        }

        if (rand > .66f) {
            b += bInc * delta;
            if (b > bRange.y) {
                b = bRange.y;
                bInc *= -1;
            }

            if (b < bRange.x) {
                b = bRange.x;
                bInc *= -1;
            }
        }
        zoom = (camRange.x + (alpha * (camRange.y - camRange.x)));
        stroke(DRAW_COLOR);
        strokeWeight(5);
        textAlign(PConstants.CENTER, PConstants.CENTER);
        Polygon last = polygons.get(0);
        int i = 1;
        for (Polygon polygon : polygons) {
            drawShape(polygon);
            polygon.rotate(5 * i * delta);
            drawVolume(last, polygon);
            last = polygon;
            i++;
        }
        postDraw();
    }
}
