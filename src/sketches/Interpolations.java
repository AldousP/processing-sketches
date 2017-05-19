package sketches;

import processing.core.PVector;
import util.geometry.Polygon;

/**
 * BlankSlate.
 */
public class Interpolations extends BaseSketch {
    PVector vRange = new PVector(0.25f, -0.25f);
    PVector hRange = new PVector(-0.25f, 0.25f);
    Polygon circle = Polygon.generate(0, 0, .025f / 3f, 36);
    float sequenceLength = 3f;
    float sequenceDelta = 0f;
    int orbCount = 16;
    int startColor = color(128, 64, 255);
    int endColor = color(0, 255, 128);
    boolean inv = false;

    public void setup() {
        super.setup();
        title = "Interpolations";
        date = "05.12.17";
    }

    public void draw() {
        super.draw();
        STROKE_WEIGHT = 0.5f;

        sequenceDelta += delta;
        if (sequenceDelta > sequenceLength) {
            sequenceDelta -= sequenceLength;
            inv = !inv;
        }

        float vAlpha;
        float vDiff = vRange.y - vRange.x;
        float hDiff = hRange.y - hRange.x;
        float hAlpha = sequenceDelta / sequenceLength;
        float modAlpha;

        for (int i = 0; i < orbCount; i++) {
            vAlpha = i / (float) orbCount;
            modAlpha = (float) Math.pow(hAlpha, i + 1);
            circle.position(
                    inv ? hRange.y - modAlpha * hDiff : hRange.x + modAlpha * hDiff,
                    vRange.x + vDiff * vAlpha);
            stroke(color(lerpColor(startColor, endColor, vAlpha)));
            drawShape(circle);
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
