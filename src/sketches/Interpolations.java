package sketches;

import processing.core.PVector;
import util.geometry.Polygon;

import java.util.ArrayList;
import java.util.HashMap;

/**
 * BlankSlate.
 */
public class Interpolations extends BaseSketch {
    float sequenceLength = 3f;
    float sequenceDelta = 0f;
    float sequenceAlpha = 0;
    int startColor = color(128, 64, 255);
    int endColor = color(0, 255, 128);
    float orbSize = 0.045f;
    boolean inv = false;
    Polygon box = Polygon.generate(0, 0, .5f, 4).rotate(45);
    PVector cp1 = new PVector(-.25f, .25f);
    PVector cp2 = new PVector(.25f, -.25f);
    PVector bez1 = new PVector(-.25f, -.25f);
    PVector bez2 = new PVector(.25f, .25f);

    ArrayList<PVector> bezPts = new ArrayList<>();
    HashMap<String, Boolean> buttons = new HashMap<>();
    PVector[] pts = new PVector[] {
            bez1,
            cp1,
            cp2,
            bez2
    };

    public void setup() {
        super.setup();
        title = "Interpolations";
        date = "05.12.17";
        bezPts.add(bez1);
        bezPts.add(cp1);
        bezPts.add(cp2);
        bezPts.add(bez2);
        buttons.put("mouse_down", false);

        BACKGROUND_COLOR = color(10);
    }

    public void draw() {
        super.draw();
        STROKE_WEIGHT = 0.5f;
        sequenceDelta += delta;
        if (sequenceDelta > sequenceLength) {
            sequenceDelta -= sequenceLength;
            inv = !inv;
        }

        noFill();
        stroke(255, 255, 255, 64);
        strokeWeight(STROKE_WEIGHT);
        drawShape(box);
        drawWorldCurve(bez1, cp1, bez2, cp2);
        drawWorldLine(bez1, cp1, STROKE_WEIGHT);
        drawWorldLine(bez2, cp2, STROKE_WEIGHT);
        drawWorldLine(cp1, cp2, STROKE_WEIGHT);

        for (PVector bezPt : bezPts) {
            fill(255, 255, 255,54);
            noStroke();
            drawWorldEllipse(bezPt, orbSize / 2, STROKE_WEIGHT);
            if (mousePressed && bezPt.dist(screenToWorld(mouseX, height - mouseY)) < orbSize * 1.5f) {
                bezPt.set(screenToWorld(mouseX, height - mouseY));
            }
        }

        sequenceAlpha = sequenceDelta / sequenceLength;
        if (inv) {
            sequenceAlpha = 1 - sequenceAlpha;
        }

        pts = new PVector[] {
                bez1,
                cp1,
                cp2,
                bez2
        };

        float val = bezierNIH(pts, sequenceAlpha);
        fill(lerpColor(startColor, endColor, sequenceAlpha));
        drawWorldEllipse(tmp1.set(val, 0), orbSize, STROKE_WEIGHT);
        fill(255, 255, 255);
        drawWorldText(decimal.format(val), 0, .35f, 14);
        drawWorldText("pt1 " + decimal.format(bez1.x) + ", " + decimal.format(bez1.y), 0, -.15f, 12);
        drawWorldText("pt2 " + decimal.format(bez2.x) + ", " + decimal.format(bez2.y), 0, -.175f, 12);
        drawWorldText("cp1 " + decimal.format(cp1.x) + ", " + decimal.format(cp1.y), 0, -.2f, 12);
        drawWorldText("cp2 " + decimal.format(cp2.x) + ", " + decimal.format(cp2.y), 0, -.225f, 12);
        postDraw();
    }

    protected float bezierNIH (PVector[] points, float t) {
        PVector[] newpoints;
        if (points.length == 1 ) {
            return points[0].y;
        } else {
            newpoints = new PVector[points.length - 1];
            for(int i = 0; i < newpoints.length; i++) {
                PVector tmpVec = new PVector();
                tmpVec.set(points[i].copy().mult(1 - t).add(points[i + 1].copy().mult(t)));
                newpoints[i] = tmpVec;
            }
            return bezierNIH(newpoints, t);
        }
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
