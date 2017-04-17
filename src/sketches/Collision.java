package sketches;

import processing.core.PVector;

import java.util.ArrayList;

public class Collision extends BaseSketch {
    float rectW = 0.1f;
    PVector tmp = new PVector();
    ArrayList<Entity> entities = new ArrayList<>();
    PVector gravity = new PVector(.015f, 0);

    public void setup() {
        super.setup();
        title = "Collision";
        date = "04.17.2017";
        H_FRAGMENTS_PER_UNIT = CANVAS_WIDTH / GRID_WIDTH;
        V_FRAGMENTS_PER_UNIT = CANVAS_HEIGHT / GRID_HEIGHT;
        entities.add(new Entity(new PVector(0, .25f), .025f, .025f, true));
        entities.add(new Entity(new PVector(.25f, .25f), .025f, .025f, false));
//        entities.add(new Entity(new PVector(0, -.25f),1f, .025f, false));
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
                    float gap = entity.pos.dist(collider.pos);
                    float rotation = getRelativeRotationOfPoint(entity.pos, collider.pos);
                    fill(255, 255, 255);
                    stroke(255, 255, 255);
                    drawWorldText("" + rotation, entity.pos, 14);
                }
            }
        }

        for (Entity entity : entities) {
            noFill();
            stroke(color(255, 255, 255));
            if (entity.colliding) {
                stroke(color(255, 64, 64));
            }
            strokeWeight(3);
            drawWorldRect(entity.pos, entity.w, entity.h);
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
            float hW = width / 2;
            float hH = height / 2;
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
