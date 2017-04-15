package sketches;

import processing.core.PVector;

import java.util.ArrayList;

/**
 * BlankSlate.
 */
public class Steering extends BaseSketch {
    protected ArrayList<Automaton> automatons;
    protected ArrayList<Obstacle> obstacles;
    protected float automatonRadius = .025f;
    protected float obstacleRadius = .025f;
    int obstacleCount = 10;
    int OBSTACLE_COLOR;

    public void setup() {
        super.setup();
        title = "Steering";
        date = "04.15.17";
        automatons = new ArrayList<>();
        obstacles = new ArrayList<>();
        automatons.add(new Automaton(new PVector(0, 0), 100, 100));
        BACKGROUND_COLOR = color(0xd3dae5);
        DRAW_COLOR = color(0xFF43474f);
        DEBUG_COLOR = color(0xFF43474f);
        GRID_COLOR = color(0xFF43474f);
        OBSTACLE_COLOR = color(0xFFD68A51);

        PVector tmp = new PVector();
        boolean valid;
        for (int i = 0; i < obstacleCount; i++) {
            valid = false;
            while (!valid) {
                tmp = new PVector(
                        random(-0.5f, 0.5f),
                        random(-0.5f, 0.5f)
                );
                for (Automaton automaton : automatons) {
                    if (abs(automaton.position.dist(tmp)) > .1) {
                        valid = true;
                    }
                }
            }
            obstacles.add(new Obstacle(tmp, obstacleRadius));
        }
    }

    public void draw() {
        super.draw();
        for (Automaton automaton : automatons) {
            automaton.update(delta);
        }

        PVector pos;
        PVector vel;
        PVector pointerPos = new PVector();

        for (Automaton automaton : automatons) {
            vel = automaton.velocity;
            pos = automaton.position;
            fill(DRAW_COLOR, "");
            ellipse(graphToCanvas(pos), CANVAS_WIDTH * (automatonRadius * 2));
            float rotation = vel.mag() > 0 ? (float) Math.atan2(vel.y, vel.x) : 0;
            pointerPos.set(
                    (float) Math.cos(rotation) * automatonRadius,
                    (float) Math.sin(rotation) * automatonRadius
            );
            strokeWeight(5);
            stroke(DEBUG_COLOR, "");
            line(graphToCanvas(pointerPos.add(pos)), graphToCanvas(pos));
        }

        for (Obstacle obstacle : obstacles) {
            fill(OBSTACLE_COLOR, "");
            stroke(OBSTACLE_COLOR, "");
            ellipse(graphToCanvas(obstacle.position), CANVAS_WIDTH * obstacleRadius);
        }
    }

    class Automaton {
        PVector position;
        PVector velocity;

        Automaton(PVector position, float width, float height) {
            this.position = position;
            this.velocity = new PVector(0, 0);
        }

        void update(float delta) {
            position.add(velocity.x * delta, velocity.y * delta);
        }
    }

    class Obstacle {
        PVector position;

        public Obstacle(PVector position, float radius) {
            this.position = position;
        }
    }
}
