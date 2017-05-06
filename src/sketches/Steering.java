package sketches;

import processing.core.PVector;
import util.steering.Automaton;
import util.steering.Obstacle;

import java.util.ArrayList;

public class Steering extends BaseSketch {
    protected ArrayList<Automaton> automatons;
    protected ArrayList<Obstacle> obstacles;
    protected float automatonRadius = .0075f;
    protected float obstacleRadius = .015f;
    int obstacleCount = 300;
    int automatonCount = 1;
    int OBSTACLE_COLOR;
    float maxAvoidForce = .18f;
    int GRID_X = 16;
    int GRID_Y = 16;

    public void setup() {
        super.setup();
        title = "Steering";
        date = "04.15.17";
        automatons = new ArrayList<>();
        obstacles = new ArrayList<>();
        BACKGROUND_COLOR = color(0xd3dae5);
        DRAW_COLOR = color(0xFF43474f);
        DEBUG_COLOR = color(0xFF43474f);
        DEBUG = false;
        GRID_COLOR = color(0xFF43474f);
        OBSTACLE_COLOR = color(0xFFD68A51);

        PVector tmp;
        for (int i = 0; i < obstacleCount; i++) {
            tmp = new PVector(random(-0.5f, 0.5f), random(-0.5f, 0.5f));
            obstacles.add(new Obstacle(tmp, random(obstacleRadius / 2, obstacleRadius * 2)));
        }

        for (int i = 0; i < automatonCount; i++) {
            tmp = new PVector(random(-0.5f, 0.5f), random(-0.5f, 0.5f));
            automatons.add(new Automaton(tmp, obstacles, GRID_X, GRID_Y));
        }
    }

    public void draw() {
        super.draw();
        for (Automaton automaton : automatons) {
            automaton.update(delta, maxAvoidForce, DEBUG);
        }
        PVector pos;
        for (Obstacle obstacle : obstacles) {
            fill(OBSTACLE_COLOR);
            stroke(OBSTACLE_COLOR);
            ellipse(worldToScreen(obstacle.position), CANVAS_WIDTH * obstacle.radius);
        }

        for (Automaton automaton : automatons) {
            pos = automaton.position;
            noStroke();
            fill(DRAW_COLOR);
            ellipse(worldToScreen(pos), CANVAS_WIDTH * (automatonRadius * 2));
            textSize(10);
            PVector text = worldToScreen(pos);
            text("Avoid Force " + maxAvoidForce, CANVAS_X, CANVAS_Y);
        }
        postDraw();
    }

}


