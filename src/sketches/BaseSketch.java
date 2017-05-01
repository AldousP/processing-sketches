package sketches;

import java.text.DecimalFormat;
import java.util.*;

import processing.core.PApplet;
import processing.core.PConstants;
import processing.core.PVector;
import processing.event.KeyEvent;
import util.Segment;
import util.SolMath;
import util.geometry.Polygon;

import static util.SolMath.clamp;

abstract class BaseSketch extends PApplet {

    protected float runTime = 0;
    protected int FRAME_RATE = 60;
    protected float STROKE_WEIGHT = .01f;
    protected boolean DEBUG = true;
    protected String title = "base_sketch";
    protected String date = "00.00.00";
    protected float sketchOpacity = 1;
    protected int DEBUG_COLOR;
    protected int BACKGROUND_COLOR;
    protected int DRAW_COLOR;
    protected int FPS_GRAPH_LOW_Y = 0;
    protected int FPS_GRAPH_HIGH_Y = 120;
    protected float spinnerRotation = 0;
    protected int spinnerOrbs = 20;
    protected boolean spinnerAccelerating = true;
    protected float spinnerRotationSpeed = 100;
    protected float spinnerAcceleration = 50;
    protected float spinnerAccelerationInterval = 1080;
    protected float spinnerDecay = 25;
    protected float SPINNER_HEIGHT;
    protected float SPINNER_WIDTH;
    protected float CANVAS_PERCENTAGE = 0.85f;                   // Amount of the frame that the canvas will occupy.
    protected float CANVAS_X;
    protected float CANVAS_Y;
    protected float CANVAS_WIDTH;
    protected float CANVAS_HEIGHT;
    protected float PALETTE_X;
    protected float PALETTE_Y;
    protected float PALETTE_HEIGHT;
    protected float PALETTE_WIDTH;
    protected float PALETTE_PERCENTAGE = 0.25f;                   // Amount of space between bottom of the bottom of the canvas to the bottom of the page that the palette will fill
    protected int lastFrame;
    protected float delta;
    protected ArrayList<Integer> palette = new ArrayList();
    protected boolean paletteLogging = true;

    // Projection Variables.
    protected float GRID_WIDTH = 1;
    protected float GRID_HEIGHT = 1;
    protected float GRID_MID_X = 0;
    protected float GRID_MIX_Y = 0;
    protected float GRID_LOWER_X = GRID_MID_X - GRID_WIDTH / 2;
    protected float GRID_UPPER_X = GRID_MID_X + GRID_WIDTH / 2;
    protected float GRID_LOWER_Y = GRID_MIX_Y - GRID_HEIGHT / 2;
    protected float GRID_UPPER_Y = GRID_MIX_Y + GRID_HEIGHT / 2;
    protected int GRID_COLOR;

    protected float zoom = 1;
    float H_FRAGMENTS_PER_UNIT;
    float V_FRAGMENTS_PER_UNIT;
    private int FRAMETIME_QUEUE_SIZE = 100;
    private int FRAMERATE_QUEUE_SIZE = 100;
    private Queue<Float> FRAMETIMES;
    private Queue<Float> FRAMERATES;
    PVector tmp1 = new PVector();

    protected DecimalFormat decimal = new DecimalFormat("#.##");

    public void settings() {
        size(700, 700);
    }

    public void setup() {
        strokeWeight(STROKE_WEIGHT);
        frameRate(FRAME_RATE);
        FRAMETIMES = new ArrayDeque<>();
        FRAMERATES = new ArrayDeque<>();
        DEBUG_COLOR = color(0xFFFFFFFF);
        BACKGROUND_COLOR = color(0xFF2d3138);
        DRAW_COLOR = color(0xFFFFFFFF);
        GRID_COLOR = color(0xFFf46842);
        CANVAS_WIDTH = (float) width * CANVAS_PERCENTAGE;
        CANVAS_HEIGHT = height * CANVAS_PERCENTAGE;
        CANVAS_X = (width - CANVAS_WIDTH) / 2;
        CANVAS_Y = (height - CANVAS_HEIGHT) / 2;
        SPINNER_WIDTH = (width - CANVAS_WIDTH) / 2;
        SPINNER_HEIGHT = (height - CANVAS_HEIGHT) / 2;
        PALETTE_HEIGHT = CANVAS_Y * PALETTE_PERCENTAGE;
        PALETTE_WIDTH = CANVAS_WIDTH * PALETTE_PERCENTAGE;
        PALETTE_Y = CANVAS_Y + CANVAS_HEIGHT;
        PALETTE_X = CANVAS_X;
        H_FRAGMENTS_PER_UNIT = CANVAS_WIDTH / GRID_WIDTH;
        V_FRAGMENTS_PER_UNIT = CANVAS_HEIGHT / GRID_HEIGHT;
    }

    @Override
    protected void handleKeyEvent(KeyEvent event) {
        if (event.getKey() != ESC) {
            super.handleKeyEvent(event);
        }
    }

    @Override
    public void exit() {
        dispose();
    }

    public void draw() {
        delta = (millis() - lastFrame) / 1000f;
        FRAMETIMES.add(delta);
        if (FRAMETIMES.size() > FRAMETIME_QUEUE_SIZE) {
            FRAMETIMES.poll();
        }
        runTime += delta;
        lastFrame = millis();
        background(BACKGROUND_COLOR);
        if (DEBUG) {
            drawGridLines();
        }

    }

    public void postDraw() {
        // Hacky clip!
        drawGutterMask();
        if (DEBUG) {
            togglePaletteLogging();
            drawDebug();
            drawSpinner();
            drawPalette();
            drawTime();
            drawFPS();
            togglePaletteLogging();
        }
        fill(color(255, 255, 255));
    }

    private void drawGutterMask() {
        noStroke();
        fill(BACKGROUND_COLOR);
        rectMode(PConstants.CORNER);
        rect(0, 0, width, (height - CANVAS_HEIGHT) / 2);
        rect(0, height - (height - CANVAS_HEIGHT) / 2, width, (height - CANVAS_HEIGHT) / 2);
        rect(0, 0, (width - CANVAS_WIDTH) / 2, height);
        rect(width - (width - CANVAS_WIDTH) / 2, 0, (width - CANVAS_WIDTH) / 2, height);
    }

    private void drawGridLines() {
        if (GRID_LOWER_X < 0 && GRID_UPPER_X > 0) {
            float diff = PApplet.abs(0 - GRID_LOWER_X);
            float alpha = clamp(diff / (GRID_WIDTH), 0, 1);
            float canvasX = (alpha * CANVAS_WIDTH) + CANVAS_X;
            strokeWeight(STROKE_WEIGHT);
            stroke(color(GRID_COLOR));
            line(canvasX, CANVAS_Y, canvasX, CANVAS_Y + CANVAS_HEIGHT);
        }

        if (GRID_LOWER_Y < 0 && GRID_UPPER_Y > 0) {
            float diff = PApplet.abs(0 - GRID_LOWER_Y);
            float alpha = clamp(diff / (GRID_HEIGHT), 0, 1);
            float canvasY = CANVAS_Y + ((1 - alpha) * CANVAS_HEIGHT);
            strokeWeight(STROKE_WEIGHT);
            stroke(color(GRID_COLOR));
            line(CANVAS_X, canvasY, CANVAS_X + CANVAS_WIDTH, canvasY);
        }
    }

    protected void drawDebug() {
        if (DEBUG) {
            fill(0xFFFFFF);
            noFill();
            strokeWeight(STROKE_WEIGHT);
            stroke(DEBUG_COLOR);
            // Render format
            rect(CANVAS_X, CANVAS_Y, CANVAS_WIDTH, CANVAS_HEIGHT);
            noStroke();
            float shortest = (SPINNER_HEIGHT < SPINNER_WIDTH ? SPINNER_HEIGHT : SPINNER_WIDTH);
            // Render sketch info
            textAlign(PConstants.RIGHT, PConstants.CENTER);
            float textSize = shortest / 4;
            textSize(textSize);
            fill(DEBUG_COLOR);
            text(date, CANVAS_X + CANVAS_WIDTH, CANVAS_Y - textSize);
            text(title, CANVAS_X + CANVAS_WIDTH, CANVAS_Y - textSize * 2);
            text("Zoom: " + zoom, CANVAS_X + CANVAS_WIDTH, CANVAS_Y - textSize * 3);
        }
    }

    // Projection methods
    PVector worldToScreen(PVector pt) {
        return worldToScreen(pt.x, pt.y);
    }

    protected PVector worldToScreen(float x, float y) {
        float hAlpha = (x - GRID_LOWER_X) / (GRID_UPPER_X - GRID_LOWER_X);
        float vAlpha = (y - GRID_LOWER_Y) / (GRID_UPPER_Y - GRID_LOWER_Y);
        float canvasX = CANVAS_X + CANVAS_WIDTH * hAlpha;
        float canvasY = CANVAS_Y + CANVAS_HEIGHT - (CANVAS_HEIGHT * vAlpha);
        return new PVector(canvasX, canvasY);
    }

    protected PVector screenToWorld(float x, float y) {
        if (y < CANVAS_Y) {
            y = CANVAS_Y;
        } else if (y > CANVAS_Y + CANVAS_HEIGHT) {
            y = CANVAS_Y + CANVAS_HEIGHT;
        }

        if (x < CANVAS_X) {
            x = CANVAS_X;
        } else if (x > CANVAS_X + CANVAS_WIDTH) {
            x = CANVAS_X + CANVAS_WIDTH;
        }

        float hAlpha = (x - CANVAS_X) / CANVAS_WIDTH;
        float vAlpha = (y - CANVAS_Y) / CANVAS_HEIGHT;
        float worldX = GRID_LOWER_X * zoom + GRID_WIDTH * zoom * hAlpha;
        float worldY = GRID_LOWER_Y * zoom + GRID_HEIGHT * zoom * vAlpha;
        return new PVector(worldX, worldY);
    }

    // Control the loading spinner
    private void drawSpinner() {
        spinnerRotationSpeed -= spinnerDecay * delta;
        if (spinnerAccelerating) {
            spinnerRotationSpeed += spinnerAcceleration * delta;
        }
        if (spinnerRotation > spinnerAccelerationInterval) {
            spinnerAccelerating = !spinnerAccelerating;
            spinnerRotation -= spinnerAccelerationInterval;
        }
        spinnerRotation += clamp(spinnerRotationSpeed, 0, 1000) * delta;
        float shortest = (SPINNER_HEIGHT < SPINNER_WIDTH ? SPINNER_HEIGHT : SPINNER_WIDTH);
        float radius = shortest / 6;
        for (int i = 0; i < spinnerOrbs; i++) {
            float alpha = i / (float) spinnerOrbs;
            fill(color(255, 255, 255, 255 * alpha));
            float currentDegree = (360 / spinnerOrbs) * i + spinnerRotation;
            float orbX = SPINNER_WIDTH / 2 + PApplet.cos(PApplet.radians(currentDegree)) * radius;
            float orbY = SPINNER_HEIGHT / 2 + PApplet.sin(PApplet.radians(currentDegree)) * radius;
            ellipse(orbX, orbY, radius, radius);
        }
    }

    private void drawPalette() {
        noFill();
        stroke(0xFFFFFF);
        strokeWeight(STROKE_WEIGHT);
        rect(PALETTE_X, PALETTE_Y, PALETTE_WIDTH, PALETTE_HEIGHT);
        noStroke();
        float chipWidth = PALETTE_WIDTH / palette.size();
        float chipHeight = PALETTE_HEIGHT;
        for (int i = 0; i < palette.size(); i++) {
            fill(palette.get(i));
            rect(PALETTE_X + chipWidth * i, PALETTE_Y, chipWidth, chipHeight);
        }
    }

    private void drawFPS() {
        float frameTime = 0;
        Iterator<Float> iterator = FRAMETIMES.iterator();
        while (iterator.hasNext()) {
            frameTime += iterator.next();
        }
        frameTime /= FRAMETIMES.size();
        frameTime = 1000 / frameTime;
        frameTime /= 1000;
        FRAMERATES.add(frameTime);
        if (FRAMERATES.size() > FRAMERATE_QUEUE_SIZE) {
            FRAMERATES.poll();
        }
        float FRAME_SIZE = CANVAS_WIDTH / 24;
        float FRAME_X = PALETTE_X + (CANVAS_WIDTH / 2) - FRAME_SIZE;
        float FRAME_Y = CANVAS_Y + CANVAS_HEIGHT + 16;
        fill(BACKGROUND_COLOR);
        stroke(DEBUG_COLOR);
        float FRAME_INCREMENT = FRAME_SIZE * 2/ FRAMERATES.size();
        rect(FRAME_X, FRAME_Y, FRAME_SIZE * 2, FRAME_SIZE);

        PVector drawPoint = new PVector();
        PVector lastDrawPoint = new PVector(FRAME_X, FRAME_Y + FRAME_SIZE / 2);
        iterator = FRAMERATES.iterator();
        int i = 0;
        float BASE_X = FRAME_X;
        float BASE_Y = FRAME_Y + FRAME_SIZE;
        while (iterator.hasNext()) {
            float fps = iterator.next();
            float alpha = fps / FPS_GRAPH_HIGH_Y - FPS_GRAPH_LOW_Y;
            drawPoint.set(BASE_X + i * FRAME_INCREMENT, BASE_Y - FRAME_SIZE * (alpha));
            stroke(color(0, 255, 255));
            line(lastDrawPoint, drawPoint);
            i++;
            lastDrawPoint.set(drawPoint);
        }

        fill(BACKGROUND_COLOR);
        stroke(DEBUG_COLOR);
        rect(FRAME_X - 5, FRAME_Y - 5,  12, 12);

        if (frameTime < 60) {
            fill(lerpColor(
                    color(200, 100, 100),
                    DEBUG_COLOR, frameTime / 60));
        } else {
            fill(DEBUG_COLOR);
        }
        noStroke();
        textAlign(PConstants.CENTER, PConstants.CENTER);
        textSize(8);
        text(round(frameTime), FRAME_X, FRAME_Y);
    }

    private void drawTime() {
        fill(color(DEBUG_COLOR, 128));
        textAlign(PConstants.RIGHT, PConstants.CENTER);
        textSize(24);
        int millis = (int) ((runTime - (PApplet.floor(runTime))) * 1000);
        int seconds = (int) (runTime - (millis / 1000)) % 60;
        int minutes = PApplet.floor(runTime / (60)) % 60;
        int hours = (PApplet.floor(runTime / (60)) / 60) % 24;
        String timeFormat = String.format("%s:%s:%s:%03dms", hours, minutes, seconds, millis);
        text(timeFormat, PALETTE_X + CANVAS_WIDTH, PALETTE_Y + 24);
    }

    @Override
    public void keyPressed() {
        if (key == 'w') {
            translateViewport(0, GRID_HEIGHT / 64);
            System.out.print("W");
        }

        if (key == 'a') {
            translateViewport(-GRID_WIDTH / 64, 0);
        }

        if (key == 's') {
            translateViewport(0, -GRID_HEIGHT / 64);
        }

        if (key == 'd') {
            translateViewport(GRID_WIDTH / 64, 0);
        }

        if (key == '1') {
            sketchOpacity = 0;
        }

        if (key == '2') {
            sketchOpacity = .5f;
        }

        if (key == '3') {
            sketchOpacity = 1;
        }

        if (key == '+') {
            zoom -= 0.1;
        }

        if (key == '-') {
            zoom += 0.01;
        }

        if (key == 't') {
            DEBUG = !DEBUG;
        }

        if (zoom < .1f ) {
            zoom = .01f;
        }
    }

    // Shape Overrides (For using vectors rather than points)
    void ellipse(PVector p, float r) {
        ellipse(p.x, p.y, r, r);
    }

    void rect(PVector p, float w, float h) {
        rectMode(PConstants.CENTER);
        rect(p.x, p.y, clamp(w, 0, CANVAS_WIDTH), clamp(h, 0, CANVAS_HEIGHT));
        rectMode(PConstants.CORNER);
    }

    void triangle(PVector a, PVector b, PVector c) {
        triangle(a.x, a.y, b.x, b.y, c.x, c.y);
    }

    void line(PVector a, PVector b) {
        line(a.x, a.y, b.x, b.y);
    }

    void translateViewport(float x, float y) {
        GRID_LOWER_X += x;
        GRID_UPPER_X += x;
        GRID_UPPER_Y += y;
        GRID_LOWER_Y += y;
    }

    // Methods for drawing shapes within the projection context.
    void drawWorldRect(PVector pos, float w, float h, float strokeWeight) {
        strokeWeight(strokeWeight / zoom);
        rect(worldToScreen(pos.copy().set(pos.x / zoom, pos.y / zoom)),
                w * V_FRAGMENTS_PER_UNIT / zoom, h * H_FRAGMENTS_PER_UNIT / zoom);
    }

    void drawWorldEllipse(PVector pos, float r, float strokeWeight) {
        strokeWeight(strokeWeight / zoom);
        ellipse(worldToScreen(pos.copy().div(zoom)), r * H_FRAGMENTS_PER_UNIT / zoom);
    }

    void drawWorldEllipse(float x, float y, float r, float strokeWeight) {
        drawWorldEllipse(tmp1.set(x, y), r, strokeWeight);
    }

    void drawWorldLine(PVector pt1, PVector pt2, float strokeWeight) {
        strokeWeight(strokeWeight / zoom);
        line(worldToScreen(pt1.copy().div(zoom)), worldToScreen(pt2.copy().div(zoom)));
    }

    void drawWorldLine(Segment segment, float strokeWeight) {
        drawWorldLine(segment.pointA, segment.pointB, strokeWeight);
    }

    void drawWorldText(String text, PVector pos, float fontSize) {
        textSize(fontSize / zoom);
        tmp1 = worldToScreen(pos.x / zoom, pos.y / zoom);
        text(text, tmp1.x, tmp1.y);
    }

    void drawWorldText(String text, float x, float y, float fontSize) {
        drawWorldText(text, tmp1.set(x, y), fontSize);
    }

    // Color
    @Override
    public void fill(int c) {
        if (paletteLogging && !palette.contains(c)) {
            palette.add(c);
        }
        float opacity = (alpha(c) * sketchOpacity) / 255;
        super.fill(opacityAdj(c, opacity));
    }

    @Override
    public void stroke(int c) {
        if (paletteLogging && !palette.contains(c)) {
            palette.add(c);
        }
        float opacity = (alpha(c) * sketchOpacity) / 255;
        super.stroke(opacityAdj(c, opacity));
    }

    int opacityAdj(int colorIn, float opacity) {
        return color(red(colorIn), green(colorIn), blue(colorIn), 255 * opacity);
    }

    boolean togglePaletteLogging() {
        return paletteLogging = !paletteLogging;
    }

    void log(String cat, String message, boolean timeStamp) {
        String time = timeStamp ? "[" + PApplet.hour() + ":" + PApplet.minute() + ":" + PApplet.second() + ":" + millis() + "]" : "";
        cat = "[" + cat + "]: ";
        PApplet.println(time + cat + message);
    }

    /**
     * Geometry rendering.
     */
    protected void drawShape (Polygon shape) {
        PVector lastPt = shape.vertices.get(shape.vertices.size() - 1).copy().add(shape.position);
        for (PVector current : shape.vertices) {
            tmp1.set(current).add(shape.position);
            drawWorldLine(lastPt, tmp1, STROKE_WEIGHT);
            lastPt.set(tmp1);
        }
    }

    protected void drawVolume(Polygon... shape) {
        List<Polygon> polygons = Arrays.asList(shape);
        Polygon last = polygons.get(polygons.size() - 1);
        for (Polygon polygon : polygons) {
            int size = last.vertices.size() > polygon.vertices.size()
                    ? polygon.vertices.size() : last.vertices.size();
            for (int i = 0; i < size; i++) {
                drawWorldLine(polygon.vertices.get(i).copy().add(polygon.position), last.vertices.get(i).copy().add(last.position), STROKE_WEIGHT);
            }
        }

    }

    /**
     * Used to scale scaling values for polygons by the delta time.
     * @param scaling
     * @param delta
     * @return
     */
    protected PVector getScalingForDelta(PVector scaling, float delta) {
        float adjX;
        float adjY;
        if (scaling.x >= 1) {
            adjX = (scaling.x - 1) * delta + 1;
        } else {
            adjX = scaling.x * delta;
        }

        if (scaling.y >= 1) {
            adjY = (scaling.y - 1) * delta + 1;
        } else {
            adjY = scaling.y * delta;
        }
        return scaling.set(adjX, adjY);
    }

    protected PVector getScalingForDelta(float x, float y, float delta) {
        return getScalingForDelta(tmp1.set(x, y), delta);
    }

    protected boolean overlaps(float a1, float a2, float b1, float b2) {
        float dstA = a2 - a1;
        float dstB = b2 - b1;
        float dstAvg = (dstA + dstB) / 2;
        float midA = a1 + (a2 - a1) / 2;
        float midB = b1 + (b2 - b1) / 2;
        float midDst = abs(midB - midA);
        return midDst < dstAvg;
    }

    @SuppressWarnings("SuspiciousNameCombination")
    protected boolean collides(Polygon polyA, Polygon polyB, PVector penA) {
        penA = new PVector(0, 0);
        boolean collides = true;
        for (int t = 0; t < 2; t++) {
            Polygon target = t == 0 ? polyA : polyB;
            for (int i = 0; i < target.vertices.size(); i++) {
                PVector ptA = target.vertices.get(i);
                PVector ptB = target.vertices.get(SolMath.wrapIndex(i + 1, target.vertices.size()));
                PVector diff = ptA.copy().sub(ptB);
                PVector perp = diff.set(diff.y, -diff.x);
                PVector projA = project(polyA, perp);
                PVector projB = project(polyB, perp);
                PVector overlap = SolMath.overlap(projA.x, projA.y, projB.x, projB.y);
                if (overlap.x == 0 && overlap.y == 0) {
                    collides = false;
                } else {
                    PVector newPen = perp.copy().normalize().setMag(overlap.y - overlap.x);
                    PVector penTarget = penA;

                    if (newPen.mag() < penTarget.mag()) {
                        penTarget.set(newPen);
                    }
                }
            }
        }
        return collides;
    }

    protected PVector project(Polygon entity, PVector axis) {
        PVector axisNorm = axis.copy().normalize();
        float min = entity.vertices.get(0).copy().add(entity.position).dot(axisNorm);
        float max = min;
        for (int i = 0; i < entity.vertices.size(); i++) {
            float proj = entity.vertices.get(i).copy().add(entity.position).dot(axisNorm);
            if (proj < min) {
                min = proj;
            }

            if (proj > max) {
                max = proj;
            }
        }
        return new PVector(min, max);
    }
}
