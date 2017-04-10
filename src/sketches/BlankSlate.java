package sketches;

import java.text.DecimalFormat;
import java.util.ArrayList;

import processing.core.PApplet;
import processing.core.PConstants;
import processing.core.PVector;

/**
 * BlankSlate.
 */
public class BlankSlate extends ProcessingApp {
    float runTime = 0;
    int FRAME_RATE = 60;
    float STROKE_WEIGHT = .01f;

    boolean DEBUG = true;
    String title = "blank_slate";
    String date = "00.00.00";
    float sketchOpacity = 1;

    int NML_L = -999;
    int NML_U = 999;

    int DEBUG_COLOR;
    int BACKGROUND_COLOR;
    int DRAW_COLOR;
    float spinnerRotation = 0;
    int spinnerOrbs = 20;
    boolean spinnerAccelerating = true;
    float spinnerRotationSpeed = 100;
    float spinnerAcceleration = 50;
    float spinnerAccelerationInterval = 1080;
    float spinnerDecay = 25;
    float SPINNER_HEIGHT;
    float SPINNER_WIDTH;

    float CANVAS_PERCENTAGE = 0.85f;                   // Amount of the frame that the canvas will occupy.
    float CANVAS_X;
    float CANVAS_Y;
    float CANVAS_WIDTH;
    float CANVAS_HEIGHT;
    float PALETTE_X;
    float PALETTE_Y;
    float PALETTE_HEIGHT;
    float PALETTE_WIDTH;
    float PALETTE_PERCENTAGE = 0.45f;                   // Amount of space between bottom of the bottom of the canvas to the bottom of the page that the palette will fill

    int lastFrame;
    float delta;
    ArrayList<Integer> palette = new ArrayList();
    DecimalFormat df = new DecimalFormat(".#");
    float colorDelta = 0;

    // There's some simple projection going on here. No scaling.
    float GRID_WIDTH = 1;
    float GRID_HEIGHT = 1;
    float CANVAS_MID_X = 0;
    float CANVAS_MID_Y = 0;
    float CANVAS_LOWER_X = CANVAS_MID_X - GRID_WIDTH / 2;
    float CANVAS_UPPER_X  =  CANVAS_MID_X + GRID_WIDTH / 2;
    float CANVAS_LOWER_Y = CANVAS_MID_Y - GRID_HEIGHT / 2;
    float CANVAS_UPPER_Y = CANVAS_MID_Y + GRID_HEIGHT / 2;

    int GRID_COLOR;
    float zoomLevel = 1;
    float rotation;

    public void settings() {
        size(700, 700);
    }

    public void setup() {
        strokeWeight(STROKE_WEIGHT);
        frameRate(FRAME_RATE);
        // Init variables
        DEBUG_COLOR = color(0xFFFFFFFF);
        BACKGROUND_COLOR = color(0xFF2d3138);
        DRAW_COLOR = color(0xFFFFFFFF);
        GRID_COLOR = color(0xFFf46842);
        CANVAS_WIDTH = (float) width * (float) CANVAS_PERCENTAGE;
        CANVAS_HEIGHT = height * CANVAS_PERCENTAGE;
        CANVAS_X = (width - CANVAS_WIDTH) / 2;
        CANVAS_Y = (height - CANVAS_HEIGHT) / 2;
        SPINNER_WIDTH = (width - CANVAS_WIDTH) / 2;
        SPINNER_HEIGHT = (height - CANVAS_HEIGHT) / 2;

        PALETTE_HEIGHT = CANVAS_Y * PALETTE_PERCENTAGE;
        PALETTE_WIDTH = CANVAS_WIDTH * PALETTE_PERCENTAGE;
        PALETTE_Y = CANVAS_Y + CANVAS_HEIGHT;
        PALETTE_X = CANVAS_X;
        log("Sketch", "Beginning sketch " + title + "!", true);
    }

    public void draw() {
        rotation += 10 * delta;
        delta = (millis() - lastFrame) / 1000f;
        runTime += delta;
        lastFrame = millis();
        background(BACKGROUND_COLOR);
        drawDebug();
        drawGridLines();
        // Draw shapes
        // Hacky clip!
        drawGutterMask();
        drawSpinner();
        drawPalette();
        drawTime();
        fill(255, 255, 255, 255);
        rect(graphToCanvas(0, 0), 75, 75);
    }

    private void drawGutterMask() {
        noStroke();
        fill(BACKGROUND_COLOR);
        rectMode(PConstants.CORNER);
        rect(0, 0, width, (height - CANVAS_HEIGHT) / 2);
        rect(0, height - (height - CANVAS_HEIGHT) / 2, width, (height - CANVAS_HEIGHT) / 2);
        rect(0, 0, (width - CANVAS_WIDTH) / 2 , height);
        rect(width - (width - CANVAS_WIDTH) / 2, 0, (width - CANVAS_WIDTH) / 2 , height);
    }

    private void drawGridLines() {
        if (CANVAS_LOWER_X < 0 && CANVAS_UPPER_X > 0) {
            float diff = PApplet.abs(0 - CANVAS_LOWER_X);
            float alpha = clamp(diff / (GRID_WIDTH), 0, 1);
            float canvasX = (alpha * CANVAS_WIDTH) + CANVAS_X;
            stroke(color(GRID_COLOR), "o");
            line(canvasX, CANVAS_Y, canvasX, CANVAS_Y + CANVAS_HEIGHT);
        }

        if (CANVAS_LOWER_Y < 0 && CANVAS_UPPER_Y > 0) {
            float diff = PApplet.abs(0 - CANVAS_LOWER_Y);
            float alpha = clamp(diff / (GRID_HEIGHT), 0, 1);
            float canvasY = CANVAS_Y + ((1 - alpha) * CANVAS_HEIGHT);
            stroke(color(GRID_COLOR), "o");
            line(CANVAS_X, canvasY, CANVAS_X + CANVAS_WIDTH, canvasY);
        }
    }

    private void drawDebug() {
        if (DEBUG) {
            fill(0xFFFFFF, "o");
            noFill();
            strokeWeight(STROKE_WEIGHT);
            stroke(DEBUG_COLOR, "overridden");
            // Render format
            rect(CANVAS_X, CANVAS_Y, CANVAS_WIDTH, CANVAS_HEIGHT);
            noStroke();
            float shortest = (SPINNER_HEIGHT < SPINNER_WIDTH ? SPINNER_HEIGHT : SPINNER_WIDTH);
            // Render sketch info
            textAlign(PConstants.RIGHT, PConstants.CENTER);
            float textSize = shortest / 4;
            textSize(textSize);
            text(date, CANVAS_X + CANVAS_WIDTH, CANVAS_Y - textSize);
            text(title, CANVAS_X + CANVAS_WIDTH, CANVAS_Y - textSize * 2);
        }
    }

    // Projection methods
    PVector graphToCanvas(PVector pt) {
        return graphToCanvas(pt.x, pt.y);
    }

    private PVector graphToCanvas(float x, float y) {
        float hAlpha = (x - CANVAS_LOWER_X) / (CANVAS_UPPER_X - CANVAS_LOWER_X);
        float vAlpha = (y - CANVAS_LOWER_Y) / (CANVAS_UPPER_Y - CANVAS_LOWER_Y);
        float canvasX = CANVAS_X + CANVAS_WIDTH * hAlpha;
        float canvasY = CANVAS_Y + CANVAS_HEIGHT - (CANVAS_HEIGHT * vAlpha);

        if (!inRange(hAlpha, 0, 1)) {
            if (hAlpha < 0) {
                canvasX = NML_L;
            } else {
                canvasX = NML_U;
            }
        }

        if (!inRange(vAlpha, 0, 1)) {
            if (vAlpha < 0) {
                canvasY = NML_U;
            } else {
                canvasY = NML_L;
            }
        }
        return new PVector(canvasX, canvasY);
    }

    // Boilerplate Methods
    private void drawSpinner() {
        // Control the loading spinner
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
        for (int i = 0; i < spinnerOrbs; i ++) {
            float alpha = i / (float)spinnerOrbs;
            fill(color(255, 255, 255, 255 * alpha), "overridden");
            float currentDegree = (360 / spinnerOrbs) * i + spinnerRotation;
            float orbX = SPINNER_WIDTH / 2 + PApplet.cos(PApplet.radians(currentDegree)) * radius;
            float orbY = SPINNER_HEIGHT / 2 + PApplet.sin(PApplet.radians(currentDegree)) * radius;
            ellipse(orbX, orbY, radius, radius);
        }
    }

    private void drawPalette() {
        noFill();
        stroke(0xFFFFFF, "o");
        strokeWeight(STROKE_WEIGHT);
        rect(PALETTE_X, PALETTE_Y, PALETTE_WIDTH, PALETTE_HEIGHT);
        noStroke();
        float chipWidth = PALETTE_WIDTH / palette.size();
        float chipHeight = PALETTE_HEIGHT;
        for (int i = 0; i < palette.size(); i++) {
            fill(palette.get(i), "o");
            rect(PALETTE_X + chipWidth * i, PALETTE_Y, chipWidth, chipHeight);
        }
    }

    private void drawTime() {
        fill(color(255, 255, 255, 128), "overridden");
        textAlign(PConstants.RIGHT, PConstants.CENTER);
        textSize(24);
        int millis = (int)((runTime - (PApplet.floor(runTime))) * 1000);
        int seconds = (int)(runTime - (millis / 1000)) % 60;
        int minutes = PApplet.floor(runTime / (60)) % 60;
        int hours = (PApplet.floor(runTime / (60)) / 60) % 24;
        String timeFormat = String.format("%s:%s:%s:%03dms", hours, minutes, seconds, millis);
        text(timeFormat, PALETTE_X + CANVAS_WIDTH, PALETTE_Y + 24);
    }

    public void keyPressed() {
        if (key == '+') {
            zoomIn(0.5f);
        }

        if (key == '-') {
            zoomOut(0.5f);
        }

        if (key == 'w') {
            translateViewport(0, GRID_HEIGHT / 8);
        }

        if (key == 'a') {
            translateViewport(-GRID_WIDTH / 8, 0);
        }

        if (key == 's') {
            translateViewport(0, -GRID_HEIGHT / 8);
        }

        if (key == 'd') {
            translateViewport(GRID_WIDTH / 8, 0);
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
    }

    // Shape overrides
    void ellipse(PVector p, float r) {
        ellipse(p.x, p.y, r * (1 - zoomLevel), r * (1 - zoomLevel));
    }

    void rect(PVector p, float w, float h) {
        rectMode(PConstants.CENTER);
        rect(p.x, p.y, clamp(w / zoomLevel, 0, CANVAS_WIDTH), clamp(h / zoomLevel, 0, CANVAS_HEIGHT));
        rectMode(PConstants.CORNER);
    }

    void zoomIn(float zoom) {
        zoomLevel -= clamp(zoom, 0, 1);
        zoomLevel = clamp(zoomLevel, 0, 100);
    }

    void zoomOut(float zoom) {
        zoomLevel += clamp(zoom, 0, 1);
        zoomLevel = clamp(zoomLevel, 0, 100);
    }

    void translateViewport(float x, float y) {
        CANVAS_LOWER_X += x;
        CANVAS_UPPER_X += x;
        CANVAS_UPPER_Y += y;
        CANVAS_LOWER_Y += y;
    }

    // Util Methods
    float clamp(float input, float low, float high) {
        if (input < low) {
            return low;
        } else if (input > high) {
            return high;
        } else {
            return input;
        }
    }

    boolean inRange(float val, float lower, float upper) {
        return val >= lower && val <= upper;
    }

    void fill(int c, String s) {
        if (!palette.contains(c)) {
            palette.add(c);
        }
        float opacity = (alpha(c) * sketchOpacity) / 255;
        fill(opacityAdj(c, opacity));
    }

    void stroke(int c, String s) {
        if (!palette.contains(c)) {
            palette.add(c);
        }
        float opacity = (alpha(c) * sketchOpacity) / 255;
        stroke(opacityAdj(c, opacity));
    }

    // [0-1] Opacity
    int opacityAdj(int colorIn, float opacity) {
        return color(red(colorIn), green(colorIn), blue(colorIn), 255 * opacity);
    }

    void log(String cat, String message, boolean timeStamp) {
        String time = timeStamp ? "[" + PApplet.hour() + ":" + PApplet.minute() + ":" + PApplet.second() + ":" + millis() +  "]" : "";
        cat = "[" + cat + "]: ";
        PApplet.println(time + cat + message);
    }
}
