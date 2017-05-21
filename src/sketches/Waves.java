package sketches;

import processing.core.PVector;
import util.Sequence;
import util.SolColor;
import util.geometry.VelocityPoly;
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

    PVector springRange = new PVector(-.5f, .5f);
    int springCount = 32;

    PVector gravity = new PVector(0, -.1f);
    ArrayList<VelocityPoly> rainDrops = new ArrayList<>();
    ArrayList<VelocityPoly> buffer = new ArrayList<>();

    enum EditState {
        TENSION,
        DAMPENING
    }

    float colAlpha = 0;

    EditState editState = EditState.TENSION;

    public void setup() {
        super.setup();
        title = "Waves";
        date = "05.20.17";
        float range = springRange.y - springRange.x;
        float inc = range / springCount;
        for (int i = 0; i < springCount; i++) {
            springs.add(new Spring(new PVector(springRange.x + (springCount % 2 != 0 ? inc / 2 : 0) + inc * i, -.25f)).speed(0.05f));
            springs.get(i);
        }

        sequences.add(new Sequence(60f, true) {
            public void update(float delta) {
                super.update(delta);
                PVector lerped = SolColor.lerpSpectrum(this.alpha, 64);
                BACKGROUND_COLOR = color(lerped.x, lerped.y, lerped.z);
                fill(64);
                colAlpha = alpha;
            }

            @Override
            public void event() {

            }
        });

        sequences.add( new Sequence(.15f, false) {
            @Override
            public void event() {
                rainDrops.add(new VelocityPoly(
                        Polygon.generate(
                                random(springRange.x, springRange.y), .5f,
                                random(0.0035f, 0.0075f),
                                (int) random(3, 24)).rotate(random(0, 360)),
                        new PVector(0 ,-.05f)));
            }
        });
    }

    public void draw() {
        super.draw();
        noFill();
        stroke(255, 255, 255);
        Spring last = springs.get(1);

        for (VelocityPoly rainDrop : rainDrops) {
            rainDrop.update(delta, gravity);
            drawShape(rainDrop.polygon);
        }

        for (Spring spring : springs) {
            STROKE_WEIGHT = .75f;
            drawWorldEllipse(spring.worldSpace(), 0.005f, STROKE_WEIGHT);
            if (!paused) {
                spring.update(delta, tension, dampening);
            }
            if (DEBUG)  {
                drawWorldLine(spring.pos, spring.worldSpace(), STROKE_WEIGHT);
                fill(255);
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
                float attractRadius = last.worldSpace().dist(spring.worldSpace());
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
