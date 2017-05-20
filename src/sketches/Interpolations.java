package sketches;

import processing.core.PVector;
import util.geometry.Polygon;

import java.util.ArrayList;
import java.util.HashMap;

/**
 * BlankSlate.
 */
public class Interpolations extends BaseSketch {
    PVector vRange = new PVector(0f, -0.25f);
    PVector hRange = new PVector(-0.25f, 0.25f);
    float sequenceLength = 3f;
    float sequenceDelta = 0f;
    int orbCount = 0;
    int startColor = color(128, 64, 255);
    int endColor = color(0, 255, 128);
    float orbSize = 0.045f;
    boolean inv = false;
    EasingFilter tween = new EasingFilter();
    Polygon circle = Polygon.generate(0, 0, orbSize, 36);
    Polygon box = Polygon.generate(0, 0, .5f, 4).rotate(45);

    PVector cp1 = new PVector(-.25f, .25f);
    PVector cp2 = new PVector(.25f, -.25f);
    PVector bez1 = new PVector(-.25f, -.25f);
    PVector bez2 = new PVector(.25f, .25f);

    ArrayList<PVector> bezPts = new ArrayList<>();
    HashMap<String, Boolean> buttons = new HashMap<>();

    public void setup() {
        super.setup();
        title = "Interpolations";
        date = "05.12.17";
        bezPts.add(cp1);
        bezPts.add(cp2);
        bezPts.add(bez1);
        bezPts.add(bez2);
        buttons.put("mouse_down", false);
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
            modAlpha = tween.filter(hAlpha);
            circle.position(
                    inv ? hRange.y - modAlpha * hDiff : hRange.x + modAlpha * hDiff,
                    vRange.x + vDiff * vAlpha);
            stroke(color(lerpColor(startColor, endColor, vAlpha)));
            drawShape(circle);
        }

        noFill();
        stroke(255, 255, 255);
        strokeWeight(STROKE_WEIGHT);
        drawShape(box);
        drawWorldCurve(bez1, cp1, bez2, cp2);
        drawWorldLine(bez1, cp1, STROKE_WEIGHT);
        drawWorldLine(bez2, cp2, STROKE_WEIGHT);
        int i = 0;
        for (PVector bezPt : bezPts) {
            drawWorldEllipse(bezPt, orbSize, STROKE_WEIGHT);
            if (mousePressed && bezPt.dist(screenToWorld(mouseX, height - mouseY)) < orbSize * 1.5f) {
                bezPt.set(screenToWorld(mouseX, height - mouseY));
            }
            i ++;
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

    class EasingFilter {
        float filter(float val) {
            return val;
        }
    }
}
