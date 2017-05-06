package sketches;

import processing.core.PConstants;
import processing.core.PVector;

/**
 * Spring Grid
 */
public class SpringGrid extends BaseSketch {
    Spring[] springs;
    int gridX = 20;
    int gridY = 20;
    float tension = 0.065f;
    float dampening = 0.05f;

    public void settings() {
        size(700, 700);
    }

    public void setup() {
        super.setup();
        title = "Spring Grid";
        date = "10.18.16";
        DEBUG_COLOR = color(255, 255, 255);
        DRAW_COLOR = color(255, 255, 255);
        BACKGROUND_COLOR = color(25, 25, 25);
        STROKE_WEIGHT = 1;
        strokeWeight(STROKE_WEIGHT);
        frameRate(30);
        DEBUG = false;
        springs = new Spring[gridX * gridY];
        zoom = 1.5f;

        int springCount = 0;
        float hAlpha;
        float vAlpha;
        for (int i = 0; i < gridX; i ++) {
            for (int j = 0; j < gridY; j ++) {
                Spring s = new Spring();
                hAlpha = (float) i / (float) gridX;
                vAlpha = (float) j / (float) gridY;
                s.position = new PVector(hAlpha + -.5f, vAlpha + -.5f);
                s.length = 0;
                s.currentLength = random(0, 0.025f);
                s.rotation = random(0, 360);
                springs[springCount] = s;
                springCount ++;
            }
        }
    }

    public void draw() {
        super.draw();
        updateSimulation();
        stroke(color(255, 255, 255));
        fill(DRAW_COLOR);
        STROKE_WEIGHT = 2;
        strokeWeight(STROKE_WEIGHT);

        textAlign(PConstants.CENTER, PConstants.CENTER);
        if (DEBUG) {
            noFill();
            stroke(GRID_COLOR);
            drawWorldText("THERE ARE " + springs.length + " SPRINGS", 0, 0, 24);
        }
        int springIndex = 0;
        Spring s;
        for (int i = 0; i < gridX; i++) {
            for (int j = 0; j < gridY; j++) {
                s = springs[springIndex];
                drawWorldEllipse(s.position.copy().add(s.spring), s.size, STROKE_WEIGHT);
                drawWorldLine(s.position, s.position.copy().add(s.spring), STROKE_WEIGHT);
                // Draw Neighbors
                if (springIndex < springs.length - 1) {
                    if (j != gridY - 1) {
                        Spring spring = springs[springIndex + 1];
                        drawWorldLine(spring.position.copy().add(spring.spring), s.position.copy().add(s.spring), STROKE_WEIGHT);
                    }

                    if (springIndex + gridY < springs.length) {
                        Spring spring = springs[springIndex + gridY];
                        drawWorldLine(spring.position.copy().add(spring.spring), s.position.copy().add(s.spring), STROKE_WEIGHT);
                    }
                }
                springIndex ++;
            }
        }
        postDraw();
    }

    void updateSimulation() {
        for (Spring spring : springs) {
            spring.update(dampening, tension);
        }
    }

    protected class Spring {
        float length = 1;
        float currentLength = 0;
        PVector position;
        PVector spring = new PVector();
        float speed;
        boolean inRange;
        float rotation;
        float size = 0.005f;

        void update(float dampening, float tension) {
            float diff = length - currentLength;
            speed += tension * diff - speed * dampening;
            currentLength += speed;
            inRange = false;
            spring.set(cos(radians(rotation)) * currentLength, sin(radians(rotation)) * currentLength);
            if (speed < 0.0000025f) {
                speed = random(0.00025f, 0.0005f);
                rotation = random(0, 360);
            }
        }
    }
}
