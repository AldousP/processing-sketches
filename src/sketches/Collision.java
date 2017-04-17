package sketches;

import processing.core.PVector;

public class Collision extends BaseSketch {
    float rectW = 0.1f;
    PVector tmp = new PVector();

    public void setup() {
        super.setup();
        title = "Collision";
        date = "04.17.2017";
        H_FRAGMENTS_PER_UNIT = CANVAS_WIDTH / GRID_WIDTH;
        V_FRAGMENTS_PER_UNIT = CANVAS_HEIGHT / GRID_HEIGHT;
    }

    public void draw() {
        super.draw();
        drawWorldRect(tmp.set(0, 0), rectW, rectW);
        drawWorldRect(tmp.set(.25f, .25f), rectW, rectW);
        drawWorldRect(tmp.set(-.13f, -.21f), rectW, rectW);
        drawWorldEllipse(tmp.set(-.13f, -.21f), rectW / 2);
    }
}
