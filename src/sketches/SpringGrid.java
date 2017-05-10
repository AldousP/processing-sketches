package sketches;

import static util.SolMath.getRelativeRotationOfPoint;

/**
 * Spring Grid
 */
public class SpringGrid extends BaseSketch {
    Spring[] springs;
    int gridX = 20;
    int gridY = 20;
    float tension = 0.065f;
    float dampening = 0.05f;
    float padding = .15f;
    float canvasOffsetX;
    float canvasOffsetY;
    float canvasWidth;
    float canvasHeight;
    float attractRadius = 105;

    public void settings() {
        size(700, 700);
    }

    public void setup() {
        super.setup();
        title = "Spring Grid";
        date = "10.18.16";
        DEBUG_COLOR = color(255, 255, 255);
        DRAW_COLOR = color(255, 255, 255);
        BACKGROUND_COLOR = color(0xFF6189a5);
        STROKE_WEIGHT = 1;
        strokeWeight(STROKE_WEIGHT);
        frameRate(FRAME_RATE);
        canvasOffsetX = width * padding;
        canvasOffsetY = height * padding;
        canvasWidth = width - canvasOffsetX * 2;
        canvasHeight = height - canvasOffsetY * 2;
        DEBUG = false;
        springs = new Spring[gridX * gridY];

        int springCount = 0;
        float hAlpha;
        float vAlpha;
        float canvasDivW = canvasWidth / gridX;
        float canvasDivH = canvasHeight / gridY;
        for (int i = 0; i < gridX; i ++) {
            for (int j = 0; j < gridY; j ++) {
                Spring s = new Spring();
                hAlpha = (float) i / (float) gridX;
                vAlpha = (float) j / (float) gridY;
                s.x = canvasOffsetX + canvasDivW / 2 + hAlpha * canvasWidth;
                s.y = canvasOffsetY + canvasDivH / 2 + vAlpha * canvasHeight;
                springs[springCount] = s;
                springCount ++;
            }
        }
    }

    public void draw() {
        super.draw();
        updateSimulation();
        stroke(DRAW_COLOR);
        fill(DRAW_COLOR);
        strokeWeight(STROKE_WEIGHT);
        int springIndex = 0;
        Spring s;
        for (int i = 0; i < gridX; i++) {
            for (int j = 0; j < gridY; j++) {
                s = springs[springIndex];
                s.render();
                // Draw Neighbors
                if (springIndex < springs.length - 1) {
                    if (j != gridY - 1) {
                        line(springs[springIndex + 1].oX, springs[springIndex + 1].oY, s.oX, s.oY);
                    }

                    if (springIndex + gridY < springs.length) {
                        line(springs[springIndex + gridY].oX, springs[springIndex + gridY].oY, s.oX, s.oY);
                    }
                }
                springIndex ++;
            }
        }

        if (mousePressed) {
            stroke(DRAW_COLOR);
        }

        noFill();
        ellipse(
                constrain(mouseX, canvasOffsetX, canvasOffsetX + canvasWidth),
                constrain(mouseY, canvasOffsetY, canvasOffsetY + canvasHeight),
                attractRadius * 2,
                attractRadius * 2
        );
        postDraw();
    }

    void updateSimulation() {
        for (Spring spring : springs) {
            spring.update(dampening, tension);
        }
    }

    protected class Spring {
        float length = 1;
        float currentLength = 1;
        float x;
        float y;
        float speed;
        float oX;
        float oY;
        boolean inRange;
        float rotation;
        float distance;
        float size = (canvasWidth / gridX / 2);

        void update(float dampening, float tension) {
            float diff = length - currentLength;
            speed += tension * diff - speed * dampening;
            currentLength += speed;
            inRange = false;
            if (mousePressed) {
                float xPos = constrain(mouseX, canvasOffsetX, canvasOffsetX + canvasWidth);
                float yPos = constrain(mouseY, canvasOffsetY, canvasOffsetY + canvasHeight);
                float distanceToPoint = sqrt(pow(x - xPos, 2) + pow(y - yPos, 2));
                distance = distanceToPoint;
                float alphaDistance = distanceToPoint / attractRadius;
                if (distanceToPoint < attractRadius) {
                    rotation = getRelativeRotationOfPoint(x, y, xPos, yPos);
                    inRange = true;
                    speed = (alphaDistance) * 1;
                }
            }

            oX = cos(radians(rotation)) * currentLength + x;
            oY = sin(radians(rotation)) * currentLength + y;
        }

        void render() {
            noFill();
            stroke(DRAW_COLOR);
            fill(DRAW_COLOR);
            ellipse(oX, oY, size, size);
        }
    }
}
