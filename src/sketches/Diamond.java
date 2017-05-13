package sketches;

public class Diamond extends BaseSketch {
    protected int DIAMOND_VERTICES = 9;
    protected float DIAMOND_HEIGHT;
    protected float MAX_RADIUS;
    protected float SUBDIVISION = 360 / DIAMOND_VERTICES;
    protected float DEGREES_PER_SECOND = 45;
    protected float V_SCALING_FACTOR = 0.25f;
    protected float MIN_RADIUS = 0;
    protected float RADIUS_INCREMENT = .015f;
    protected float baseDegree = 0;
    protected float tempDegree;
    protected float x = 0;
    protected float y = 0;
    protected float lastX1;
    protected float lastY1;
    protected float lastX2;
    protected float lastY2;
    protected float radius = 0;
    protected int MIDX;
    protected int MIDY;

    public void setup() {
        super.setup();
        title = "Diamond";
        date = "06.19.16";
        STROKE_WEIGHT = 2.35f;
        DEBUG = false;
        DIAMOND_HEIGHT = .35f;
        MAX_RADIUS = .2f;
        zoomInc = 0.05f;
        zoom = 0.5f;
        MIDX = 0;
        MIDY = 0;
        paused = true;
        BACKGROUND_COLOR = color(19, 19, 60);
        GRID_COLOR = color(0xFFFFFFFF);
        DRAW_COLOR = color(0xFF4ECDC4);
        FRAME_RATE = 30;
        strokeWeight(STROKE_WEIGHT);
        fill(DRAW_COLOR);
    }

    public void draw() {
        super.draw();
        stroke(DRAW_COLOR);
        STROKE_WEIGHT = random(1.9f, 2.5f);
        radius += RADIUS_INCREMENT * delta;
        if ( ((RADIUS_INCREMENT < 0) && radius < MIN_RADIUS) || ((RADIUS_INCREMENT > 0) && radius > MAX_RADIUS)) {
            RADIUS_INCREMENT *= -1;
        }
        baseDegree +=  DEGREES_PER_SECOND * delta;
        baseDegree = baseDegree % 360;
        for (int i = 0; i < DIAMOND_VERTICES; i++) {
            tempDegree = baseDegree + SUBDIVISION * i;
            tempDegree = tempDegree % 360;
            x = (sin(radians(tempDegree)) * radius) + MIDX;
            y = (cos(radians(tempDegree)) * radius * V_SCALING_FACTOR) + MIDY;
            drawWorldLine(tmp1.set(x, y), tmp2.set(MIDX, MIDY + DIAMOND_HEIGHT / 2), STROKE_WEIGHT);
            drawWorldLine(tmp1.set(x, y), tmp2.set(MIDX, MIDY - DIAMOND_HEIGHT / 2), STROKE_WEIGHT);
            drawWorldLine(tmp1.set(x, y), tmp2.set(lastX1, lastY1), STROKE_WEIGHT);
            lastX1 = x;
            lastY1 = y;

            x = (sin(radians(tempDegree)) * radius / 2) + MIDX;
            y = (cos(radians(tempDegree)) * radius / 2 * V_SCALING_FACTOR) + MIDY;
            drawWorldLine(tmp1.set(x, y), tmp2.set(MIDX, MIDY + DIAMOND_HEIGHT / 2), STROKE_WEIGHT);
            drawWorldLine(tmp1.set(x, y), tmp2.set(MIDX, MIDY - DIAMOND_HEIGHT / 2), STROKE_WEIGHT);
            drawWorldLine(tmp1.set(x, y), tmp2.set(lastX2, lastY2), STROKE_WEIGHT);
            lastX2 = x;
            lastY2 = y;
        }
        postDraw();
    }
}
