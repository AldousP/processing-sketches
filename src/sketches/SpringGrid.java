package sketches;

import processing.core.PConstants;
import processing.core.PVector;
import util.SolMath;
import util.geometry.Polygon;
import util.steering.Automaton;
import util.steering.Obstacle;

import java.util.ArrayList;

/**
 * Spring Grid
 */
public class SpringGrid extends BaseSketch {
    Spring[] springs;
    int gridX = 19;
    int gridY = 19 ;
    float tension = 0.035f;
    float dampening = 0.03f;
    float topSpeed = 0.025f;
    boolean spacePressed = false;
    float averageSpeed = 0;

    protected ArrayList<Automaton> automatons;
    protected ArrayList<Obstacle> obstacles;
    protected float automatonRadius = .0075f;
    protected float obstacleRadius = .075f;
    int obstacleCount = 30;
    int automatonCount = 1;
    int OBSTACLE_COLOR;
    float maxAvoidForce = .18f;
    Polygon obstacleShape = Polygon.generate(0, 0, obstacleRadius, 36);
    Polygon automatonShape = Polygon.generate(0, 0, automatonRadius, 36);

    enum EditState {
        TENSION,
        DAMPENING,
        TOPSPEED
    }

    EditState editState = EditState.TENSION;

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
        zoomInc = 0.01f;
        zoom = 1.98f;
        iHat.set(-0.51f, -0.47f);
        jHat.set(-1.18f, 0.13f);
        GRID_LOWER_X = -0.5f;
        GRID_UPPER_X = 0.5f;
        GRID_LOWER_Y = -0.31f;
        GRID_UPPER_Y = 0.69f;

        OBSTACLE_COLOR = color(0xFFD68A51);

        obstacles = new ArrayList<Obstacle>();
        automatons = new ArrayList<Automaton>();
        PVector tmp;
        for (int i = 0; i < obstacleCount; i++) {
            tmp = new PVector(random(-0.5f, 0.5f), random(-0.5f, 0.5f));
            obstacles.add(new Obstacle(tmp, random(obstacleRadius / 2, obstacleRadius * 2)));
        }

        for (int i = 0; i < automatonCount; i++) {
            tmp = new PVector(random(-0.5f, 0.5f), random(-0.5f, 0.5f));
            automatons.add(new Automaton(tmp, obstacles, 1, 1));
        }

        int springCount = 0;
        float springArea = 1;
        float hInc = springArea / gridX;
        float vInc = springArea / gridY;
        float originX = -.5f;
        float originY = -.5f;
        for (int i = 0; i < gridX; i ++) {
            for (int j = 0; j < gridY; j ++) {
                Spring s = new Spring();
                s.position = new PVector(i * hInc + originX, j * vInc + originY);
                s.length = 0;
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
        strokeWeight(STROKE_WEIGHT);
        tension = SolMath.clamp(tension, 0, 5);
        dampening = SolMath.clamp(dampening, 0, 5);
        topSpeed = SolMath.clamp(topSpeed, 0, 5);
        float alpha = averageSpeed / topSpeed;

        textAlign(PConstants.CENTER, PConstants.CENTER);
        int springIndex = 0;
        STROKE_WEIGHT = 0.75f;
        Spring s;
        for (int i = 0; i < gridX; i++) {
            for (int j = 0; j < gridY; j++) {
                s = springs[springIndex];
//                drawMultipleEllipse(s.position.copy().add(s.spring), s.size, STROKE_WEIGHT, s.height / 4);
                // Draw Neighbors
                if (springIndex < springs.length - 1) {
                    if (j != gridY - 1) {
                        Spring spring = springs[springIndex + 1];
                        drawMultipleWorldLine(
                                spring.position.copy().add(spring.spring),
                                s.position.copy().add(s.spring),
                                STROKE_WEIGHT,
                                s.height / 4);
                    }

                    if (springIndex + gridY < springs.length) {
                        Spring spring = springs[springIndex + gridY];
                        drawMultipleWorldLine(
                                spring.position.copy().add(spring.spring),
                                s.position.copy().add(s.spring),
                                STROKE_WEIGHT,
                                s.height / 4);
                    }
                }
                springIndex ++;
            }
        }


        if (DEBUG) {
            for (Obstacle obstacle : obstacles) {
                stroke(color(10, 120, 180));
                obstacleShape.position.set(obstacle.position);
                STROKE_WEIGHT = 2;
                drawShape(obstacleShape);
            }
        }

        for (Automaton automaton : automatons) {
            automaton.update(delta, maxAvoidForce, DEBUG);
            if (DEBUG) {
                stroke(color(200, 60, 60));
                automatonShape.position.set(automaton.position);
                STROKE_WEIGHT = 2;
                drawShape(automatonShape);
            }
        }

        postDraw();
        BACKGROUND_COLOR = color(alpha / 40);
        spacePressed = false;
    }

    @Override
    protected void drawDebug() {
        super.drawDebug();
        textAlign(CENTER, CENTER);
        fill(BACKGROUND_COLOR);
        stroke(color(255, 255, 255));
        rect(tmp1.set(CANVAS_X + CANVAS_WIDTH / 2, CANVAS_Y), CANVAS_WIDTH / 6, CANVAS_HEIGHT / 16);
        textSize(12);
        fill(color(255, 255, 255));
        text(editState + " ", tmp1.x, tmp1.y);
        tmp1.y += CANVAS_HEIGHT / 16;
        fill(BACKGROUND_COLOR);
        rect(tmp1, CANVAS_WIDTH / 16, CANVAS_HEIGHT / 16);
        String val = "";
        switch (editState) {
            case TENSION:
                val = decimal.format(tension);
                break;
            case TOPSPEED:
                val = decimal.format(topSpeed);
                break;
            case DAMPENING:
                val = decimal.format(dampening);
                break;
        }
        fill(color(255, 255, 255));
        text(val, tmp1.x, tmp1.y);
    }

    @Override
    public void keyPressed() {
        super.keyPressed();
        if (key == ' ') {
            spacePressed = true;
        }

        if (key == '4') {
            editState = EditState.TENSION;
        }

        if (key == '5') {
            editState = EditState.DAMPENING;
        }

        if (key == '6') {
            editState = EditState.TOPSPEED;
        }

        if (key == CODED && keyCode == UP) {
            switch (editState) {
                case TENSION:
                    tension += 1 * delta;
                    break;
                case TOPSPEED:
                    topSpeed += 1 * delta;
                    break;
                case DAMPENING:
                    dampening += 1 * delta;
                    break;
            }
        }

        if (key == CODED && keyCode == DOWN) {
            switch (editState) {
                case TENSION:
                    tension -= 1 * delta;
                    break;
                case TOPSPEED:
                    topSpeed -= 1 * delta;
                    break;
                case DAMPENING:
                    dampening -= 1 * delta;
                    break;
            }
        }
    }

    void updateSimulation() {
        averageSpeed = 0;
        for (Spring spring : springs) {
            spring.update(dampening, tension, topSpeed);
            averageSpeed += spring.currentLength;
        }
        averageSpeed /= 1;

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
        float height = 0;
        float attractRadius = 0.25f;

        void update(float dampening, float tension, float topSpeed) {
            float diff = length - currentLength;
            speed += tension * diff - speed * dampening;
            currentLength += speed;
            inRange = false;
            spring.set(cos(radians(rotation)) * currentLength, sin(radians(rotation)) * currentLength);
            if (spacePressed) {
                rotation = rotation + random(-360, 360);
                speed += 0.5 * delta;
            }

            Automaton a = automatons.get(0);
            float dst = abs(a.position.dist(position));
            if (dst < attractRadius) {
                height = ((dst) / attractRadius);
            }
            height -= 5 * delta;
            if (height < 0) {
                height = 0;
            }

            if (speed > topSpeed) {
                speed = topSpeed;
            }
        }
    }
}
