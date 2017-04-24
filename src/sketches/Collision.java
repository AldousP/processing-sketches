package sketches;

import processing.core.PVector;
import util.Segment;

import java.util.ArrayList;

import static util.SolArray.wrapIndex;
import static util.SolMath.inRange;

public class Collision extends BaseSketch {
    float rectW = 0.1f;
    PVector tmp = new PVector();
    ArrayList<Entity> entities = new ArrayList<>();
    PVector gravity = new PVector(.05f, 0);
    PVector center = new PVector(0, 0);
    PVector sampleVector = new PVector(.35f, .35f);

    public void setup() {
        super.setup();
        title = "Collision";
        date = "04.17.2017";
        H_FRAGMENTS_PER_UNIT = CANVAS_WIDTH / GRID_WIDTH;
        V_FRAGMENTS_PER_UNIT = CANVAS_HEIGHT / GRID_HEIGHT;
        entities.add(new Entity(new PVector(0f, .25f), .045f, .045f, false));
        entities.add(new Entity(new PVector(-.25f, .25f), .045f, .045f, true));
        STROKE_WEIGHT = 1.5f;
    }

    public void draw() {
        super.draw();
        for (Entity entity : entities) {
            entity.update(delta);
        }
        // Check collisions (Always after updating)
        for (Entity entity : entities) {
            for (Entity collider : entities) {
                if (entity != collider) {
                    boolean colliding = colliding(entity, collider);
                    entity.colliding = colliding;
                    collider.colliding = true;

                }
            }
        }

        for (Entity entity : entities) {
            noFill();
            stroke(color(255, 255, 255));
            if (entity.colliding) {
                stroke(color(255, 64, 64));
            }
            drawWorldRect(entity.pos, entity.w, entity.h, STROKE_WEIGHT);
        }
    }

    PVector project(Entity entity, PVector axis) {
        PVector axisNorm = axis.copy().normalize();
        float min = entity.getCorner(1).dot(axisNorm);
        float max = min;
        for (int i = 0; i < 4; i++) {
            float proj = entity.getCorner(i).dot(axisNorm);
            if (proj < min) {
                min = proj;
            }

            if (proj > max) {
                max = proj;
            }
        }

        return new PVector(min, max);
    }

    PVector perpendicular(PVector axis) {
        return axis.copy().set(axis.y, -axis.x);
    }

    boolean colliding(Entity a, Entity b) {
        Segment seg;
        PVector axis;
        PVector projA;
        PVector projB;
        for (int i = 1; i <= 4; i++) {
            seg = new Segment(a.getCorner(i), a.getCorner(wrapIndex(i + 1, 4)));
            axis = seg.dir;
            axis = perpendicular(axis);
            projA = project(a, axis);
            projB = project(b, axis);
            drawWorldLine(seg.pointA, seg.pointB, STROKE_WEIGHT);
            if (
                inRange(projA.x, projB.x, projB.y)
                || inRange(projA.y, projB.x, projB.y)
                || inRange(projB.y, projA.x, projB.y)
                || inRange(projB.y, projA.x, projB.y)
            ) {
                return true;
            }
        }

        for (int i = 1; i <= 4; i++) {
            seg = new Segment(b.getCorner(i), b.getCorner(wrapIndex(i + 1, 4)));
            axis = seg.dir;
            axis = perpendicular(axis);
            projA = project(a, axis);
            projB = project(b, axis);
            if (
                    inRange(projA.x, projB.x, projB.y)
                            || inRange(projA.y, projB.x, projB.y)
                            || inRange(projB.y, projA.x, projB.y)
                            || inRange(projB.y, projA.x, projB.y)
                    ) {
                return true;
            }
        }
        return false;
    }

    public void keyPressed() {
        super.keyPressed();
        if (CONTROLS_LOCKED) return;
        if (key == '[') {
            sampleVector.rotate(1.5f * delta);
        }

        if (key == ']') {
            sampleVector.rotate(-1.5f * delta);
        }

        if (key == 'n') {
            sampleVector = sampleVector.normalize();
        }

        if (key == 'j') {
            sampleVector.setMag(sampleVector.mag() - .1f * delta);
        }

        if (key == 'k') {
            sampleVector.setMag(sampleVector.mag() + .1f * delta);
        }
    }


    class Entity {
        PVector pos;
        PVector velocity = new PVector(0, 0);
        float maxVel;
        float w;
        float h;
        boolean dynamic = false;
        boolean colliding = false;

        public Entity(PVector pos, float w, float h) {
            this.pos = pos;
            this.w = w;
            this.h = h;
        }

        public Entity(PVector pos, float w, float h, boolean dynamic) {
            this(pos, w, h);
            this.dynamic = dynamic;
        }

        public void update(float delta) {
            colliding = false;
            if (dynamic) {
                velocity.add(gravity.x * delta, gravity.y * delta);
                pos.add(velocity.x * delta, velocity.y * delta);
            }
        }

        /**
         * Returns a corner on the bounding box of the object. 1-4 clockwise.
         */
        public PVector getCorner(int corner) {
            float hW = w / 2;
            float hH = h / 2;
            switch (corner) {
                case 1:
                    return new PVector(pos.x + hW, pos.y + hH);
                case 2:
                    return new PVector(pos.x + hW, pos.y - hH);
                case 3:
                    return new PVector(pos.x - hW, pos.y - hH);
                case 4:
                    return new PVector(pos.x - hW, pos.y + hH);
                default:
                    return new PVector(pos.x + hW, pos.y + hH);
            }
        }
    }
}
