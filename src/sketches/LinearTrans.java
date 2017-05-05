package sketches;

import processing.core.PVector;

import java.util.ArrayList;

/**
 * BlankSlate.
 */
public class LinearTrans extends BaseSketch {
    ArrayList<PVector> pts =  new ArrayList<>();
    int gridDensity = 25;


    float alpha = 0;
    float alphaInc = 0.0001f;

    public void setup() {
        super.setup();
        title = "Linear Trans";
        date = "05.04.17";
        zoom = 3;
        BACKGROUND_COLOR = color(23, 66, 59);

        float inc = 2f / gridDensity;
        for (int i = 0; i < gridDensity; i++) {
            for (int i1 = 0; i1 < gridDensity; i1++) {
                pts.add(new PVector(i * inc - 1f + inc / 2, i1 * inc - 1 + inc / 2));
            }
        }
    }

    @Override
    public void keyPressed() {
        super.keyPressed();
        if (key == ']') {
            jHat.x += 0.5 * delta;
        }

        if (key == '[') {
            jHat.x -= 0.5 * delta;
        }

        if (key == '}') {
            iHat.y += 0.5 * delta;
        }

        if (key == '{') {
            iHat.y -= 0.5 * delta;
        }

        if (key == 'n') {
            iHat.rotate(radians(-60 * delta));
            jHat.rotate(radians(-60 * delta));
        }

        if (key == 'm') {
            iHat.rotate(radians(60 * delta));
            jHat.rotate(radians(60 * delta));
        }
    }

    public void draw() {
        super.draw();
        alpha += alphaInc;
        if (alpha > 1) {
            alpha = 1;
            alphaInc *= -1;
        }

        if (alpha < 0) {
            alpha = 0;
            alphaInc *= -1;
        }

        stroke(color(255, 0, 0));
        drawWorldLine(tmp1.set(0, 0), iHat, 5);
        stroke(color(0, 255, 0));
        drawWorldLine(tmp1.set(0, 0), jHat, 5);
        fill(color(255, 255, 255));
        stroke(color(255, 255, 255));
        for (PVector pt : pts) {
            drawWorldEllipse(pt, 0.005f, 0.005f);
        }

        drawWorldText("Rotate  with M & N", 0, -.25f, 36);
        drawWorldText("Shift jHat with [ & ]", 0, -.35f, 36);
        drawWorldText("Shift iHat with { & }", 0, -.45f, 36);
        postDraw();
    }
}
