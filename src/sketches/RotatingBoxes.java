package sketches;

public class RotatingBoxes extends BaseSketch {
    protected float rectW;
    protected float rectH;
    protected int RECT_DIV = 32;
    protected int gridX = 8;
    protected int gridY = 8;
    protected float gridSubdivisionX;
    protected float gridSubdivisionY;
    protected float drawPosX = 0;
    protected float drawPosY = 0;
    protected float linePos = 0;
    protected float lineSpeed = 400;
    protected float accelerationRange = .05f;
    protected int LINE_COLOR;
    protected float[][] currentRotation;
    protected float[][] rotationSpeed;
    protected float maxRotationSpeed = 300;
    protected float decayRate = 15;

    public void setup() {
        super.setup();
        title = "Rotating Boxes";
        date = "10.10.16";
        STROKE_WEIGHT = 3;
        rectW = width / RECT_DIV;
        rectH = rectW;
        gridSubdivisionX = width / gridX;
        gridSubdivisionY = height / gridY;

        LINE_COLOR = color(0xFFf44283);
        BACKGROUND_COLOR = color(0xFF33a4aa);
        DRAW_COLOR = color(0xFFf9fbfc);
        DEBUG = false;

        currentRotation = new float[gridX][gridY];
        rotationSpeed = new float[gridX][gridY];
    }

    public void draw() {
        super.draw();
        // RESET THE CAMERA
        translate(width/2, height/2);
        linePos += lineSpeed * delta;

        if (linePos > width)
            linePos = linePos - width;

        if (DEBUG) {
            stroke(LINE_COLOR);
            line(linePos - (width / 2) , (height / 2 + 1), linePos - (width / 2) , - (width / 2));
            line((linePos - width * accelerationRange) - (width / 2) , (height / 2 + 1), (linePos - width * accelerationRange) - (width / 2) , - (width / 2));
            line((linePos + width * accelerationRange) - (width / 2) , (height / 2 + 1), (linePos + width * accelerationRange) - (width / 2) , - (width / 2));
            fill(LINE_COLOR);
            textSize(36);
            text((linePos / width), linePos - (width / 2), (height/2 + 1));
        }

        drawPosX = (gridSubdivisionX / 2 + -1 * (width / 2));
        drawPosY = (gridSubdivisionY / 2 + -1 * (height / 2));
        int progress = 0;
        for (int i = 0; i < gridX; i++) {
            for (int j = 0; j < gridY; j++) {
                float currRotation = currentRotation[i][j];
                float currentPosition = (float)progress / (float) (gridX);
                currentPosition += ((float)1 / (float)(gridX) / 2);
                float distanceFromLine = shortestDistance(currentPosition, (linePos / width), 0, 1);

                if (Math.abs(distanceFromLine) < accelerationRange) {
                    rotationSpeed[i][j] += (maxRotationSpeed * (1 - Math.abs(distanceFromLine)) * delta);
                }
                currentRotation[i][j] += rotationSpeed[i][j] * delta;

                translate(drawPosX, drawPosY);
                rotate(radians(currRotation));
                stroke(0x9e9e9e);
                //line(0, 99900, 0, -99999);
                //line(99999, 0, -99999, 0);
                noStroke();
                fill(DRAW_COLOR);
                rect(0, 0, rectW, rectH);
                // DRAW SPEED
                fill(0xAAAAAA);
                rotate(-radians(currRotation));
                translate(-drawPosX, -drawPosY);
                drawPosY += gridSubdivisionY;

                rotationSpeed[i][j] -= (decayRate * delta);
                if (rotationSpeed[i][j] < 0) {
                    rotationSpeed[i][j] = 0;
                }
            }
            progress ++;

            drawPosX += gridSubdivisionX;
            drawPosY = (gridSubdivisionY / 2 + -1 * (height / 2));
        }
    }

    float shortestDistance(float pt1, float pt2, float floor, float ceil) {
        if (floor > ceil || pt1 < floor || pt1 > ceil || pt2 < floor || pt2 > ceil) {
            println("[WARN]: A provided value exceeds bounds.");
            return 0; //Numbers are outside of range
        }
        float distance = pt2 - pt1;
        float midPoint = (ceil - floor) / 2;
        if (Math.abs(distance) > midPoint) {
            if (pt1 > pt2) {
                distance = (ceil - pt1) + (pt2 - floor);
            } else {
                distance = -1 * ((pt1 - floor) + (ceil - pt2));
            }
        }
        return distance;
    }
}
