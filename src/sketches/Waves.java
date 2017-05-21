package sketches;

import processing.core.PVector;
import util.Sequence;
import util.VelocityPoly;
import util.geometry.Polygon;
import util.geometry.Spring;

import java.util.ArrayList;
import java.util.Iterator;

/**
 * BlankSlate.
 */
public class Waves extends BaseSketch {

    ArrayList<Spring> springs = new ArrayList<>();
    private float tension = .08f;
    private float dampening = .03f;
    private float spread = 0.25f;
    private int passCount = 8;

    PVector springRange = new PVector(-.25f, .25f);
    int springCount = 32;

    PVector gravity = new PVector(0, -.2f);
    ArrayList<VelocityPoly> rainDrops = new ArrayList<>();
    ArrayList<VelocityPoly> buffer = new ArrayList<>();

    int startColor = color(145, 36, 36);
    int endColor = color(36, 145, 145);

    enum EditState {
        TENSION,
        DAMPENING
    }

    EditState editState = EditState.TENSION;

    public void setup() {
        super.setup();
        title = "Waves";
        date = "05.20.17";
        float range = springRange.y - springRange.x;
        float inc = range / springCount;
        for (int i = 0; i < springCount; i++) {
            springs.add(new Spring(new PVector(springRange.x + (springCount % 2 != 0 ? inc / 2 : 0) + inc * i, 0)).speed(0.05f));
            springs.get(i);
        }

        sequences.add(new Sequence(3f, true) {
            public void update(float delta) {
                super.update(delta);
                BACKGROUND_COLOR = lerpColor(startColor, endColor, this.alpha);
            }

            @Override
            public void event() {
                rainDrops.add(new VelocityPoly(
                        Polygon.generate(random(-.25f, .25f), .5f, random(0.0075f, 0.015f), (int) random(3, 24)),
                        new PVector(0 ,0)));
            }
        });

        sequences.add( new Sequence(5f, false) {
            @Override
            public void event() {
                rainDrops.add(new VelocityPoly(
                        Polygon.generate(random(-.25f, .25f), .5f, random(0.0075f, 0.015f), (int) random(3, 24)),
                        new PVector(0 ,0)));
            }
        });
    }

    public void draw() {
        super.draw();
        noFill();
        stroke(255, 255, 255);
        Spring last = null;

        for (VelocityPoly rainDrop : rainDrops) {
            rainDrop.update(delta, gravity);
            drawShape(rainDrop.polygon);
        }

        for (Spring spring : springs) {
            drawWorldEllipse(spring.worldSpace(), 0.005f, STROKE_WEIGHT);
            STROKE_WEIGHT = 1.5f;
            if (!paused) {
                spring.update(delta, tension, dampening);
            }
            if (DEBUG)  {
                drawWorldLine(spring.pos, spring.worldSpace(), STROKE_WEIGHT);
                stroke(color(0, 128, 255));
                STROKE_WEIGHT = 3;
                drawWorldText(decimal.format(spring.speed), spring.pos, 12);
            }

            if (last != null) {
                drawWorldLine(last.pos.copy().add(last.displace), spring.pos.copy().add(spring.displace), STROKE_WEIGHT);
            }

            // Listen for impacts
            Iterator<VelocityPoly> iterator = rainDrops.iterator();
            while (iterator.hasNext()) {
                VelocityPoly drop = iterator.next();
                float dist = drop.polygon.position.dist(spring.worldSpace());
                float attractRadius = 0.05f;
                if (dist < attractRadius && abs(spring.worldSpace().y - drop.polygon.position.y) < 0.01f) {
                    stroke(255);
                    iterator.remove();
                    spring.speed += drop.velocity.y;
                }
            }
            rainDrops.addAll(buffer);
            buffer.clear();
            last = spring;
        }


        for (int i = 0; i < passCount; i++) {
//            springs.

        }

        postDraw();
    }

    @Override
    public void keyPressed() {
        super.keyPressed();
        if (key == 'h') {
            springs.get(0).speed(springs.get(0).speed +  5f * delta);
        }

        if (key == CODED && keyCode == LEFT) {
        }
        
        if (key == '4') {
            editState = EditState.TENSION;
        }

        if (key == '5') {
            editState = EditState.DAMPENING;
        }

        if (key == CODED && keyCode == UP) {
            switch (editState) {
                case TENSION:
                    tension += 1 * delta;
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
                case DAMPENING:
                    dampening -= 1 * delta;
                    break;
            }
        }
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
            case DAMPENING:
                val = decimal.format(dampening);
                break;
        }
        fill(color(255, 255, 255));
        text(val, tmp1.x, tmp1.y);
    }
}
