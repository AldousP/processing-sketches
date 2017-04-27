package sketches;

import processing.core.PVector;
import util.Segment;
import util.SolMath;

/**
 * BlankSlate.
 */
public class Lighting extends BaseSketch {

    PVector lightPos = new PVector();
    PVector gravity = new PVector(.05f, 0);
    Entity box = new Entity(new PVector(), .045f, .045f);
    float lightRadius = .025f;
    Segment wall = new Segment(new PVector(-0.25f, .45f), new PVector(0.25f, .45f));

    public void setup() {
        super.setup();
        title = "Lighting";
        date = "04.23.17";
    }

    public void draw() {
        super.draw();
        noStroke();
        fill(color(255, 255, 255));
        drawWorldEllipse(lightPos, lightRadius, STROKE_WEIGHT);
        drawWorldRect(box.pos, box.w, box.h, STROKE_WEIGHT);
        stroke(color(255, 255, 255));
//        drawWorldLine(wall.pointA, wall.pointB, 10);

        PVector proj = project(box, SolMath.perpendicular(wall.dir));
        stroke(255, 255, 0);
        drawWorldLine(wall.pointA.copy().normalize().setMag(proj.x), wall.pointB.copy().normalize().setMag(proj.y), STROKE_WEIGHT * 10);
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
}
