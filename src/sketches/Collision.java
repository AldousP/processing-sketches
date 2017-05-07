package sketches;

import processing.core.PConstants;
import processing.core.PVector;
import util.SolMath;
import util.geometry.Polygon;

import java.util.ArrayList;

public class Collision extends BaseSketch {
    ArrayList<Polygon> polygons = new ArrayList<>();
    PVector gravity = new PVector(0, -0.05f);

    public void setup() {
        super.setup();
        STROKE_WEIGHT = 1.5f;
        BACKGROUND_COLOR = color(40, 21, 71);
        DRAW_COLOR = color(255, 255, 255);
        title = "Collision";
        date = "04.30.17";
        DEBUG = true;
        polygons.add(Polygon.generate(0f , .35f, 0.075f, 8).rotate(45).tag("dynamic"));
        polygons.add(Polygon.generate(0, -.35f, 0.075f, 4).rotate(45).scale(3, 1));
    }

    @Override
    public void keyPressed() {
        super.keyPressed();
    }

    public void draw() {
        super.draw();
        strokeWeight(5);
        fill(DRAW_COLOR);
        stroke(color(0, 250, 100));
        if (!paused) {
            textAlign(PConstants.CENTER, PConstants.CENTER);
            for (Polygon polygon : polygons) {
                if (polygon.hasTag("cursor")) {
                    tmp1.set(screenToWorld(mouseX, height - mouseY));
                    polygon.position.set(tmp1);
                }
                stroke(DRAW_COLOR);
                STROKE_WEIGHT = 1;
                drawShape(polygon);
                ArrayList<PVector> polyAxes = new ArrayList<>();
                ArrayList<PVector> colliderAxes = new ArrayList<>();

                ArrayList<PVector> polyOverlaps = new ArrayList<>();

                for (int i = 0; i < polygon.vertices.size(); i++) {
                    PVector ptA = polygon.vertices.get(i);
                    PVector ptB = polygon.vertices.get(SolMath.wrapIndex(i + 1, polygon.vertices.size()));
                    PVector edge = ptA.copy().sub(ptB);
                    PVector normal = edge.copy();
                    normal.set(-normal.y, normal.x);
                    normal.normalize();
                    polyAxes.add(normal);
                }

                if (polygon.hasTag("dynamic")) {
                    polygon.position.add(gravity.copy().mult(delta));
                    for (Polygon collider : polygons) {
                        if (collider != polygon) {
                            for (int i = 0; i < collider.vertices.size(); i++) {
                                PVector ptA = collider.vertices.get(i);
                                PVector ptB = collider.vertices.get(SolMath.wrapIndex(i + 1, collider.vertices.size()));
                                PVector edge = ptA.copy().sub(ptB);
                                PVector normal = edge.copy();
                                normal.set(-normal.y, normal.x);
                                normal.normalize();
                                colliderAxes.add(normal);
                            }

                            for (PVector axe : polyAxes) {
                                tmp1.set(0, 0);
                                PVector proj1 = project(polygon, axe);
                                PVector proj2 = project(collider, axe);
                                PVector overlap = SolMath.overlap(proj1.x, proj1.y, proj2.x, proj2.y);
                                polyOverlaps.add(new PVector().set(axe).setMag(overlap.y - overlap.x));
                                if (DEBUG) {
                                    STROKE_WEIGHT = 0.05f;
                                    stroke(color(255, 255, 255));
                                    drawWorldLine(polygon.position, polygon.position.copy().add(axe), STROKE_WEIGHT);
                                    noFill();
                                    STROKE_WEIGHT *= 2f;
                                    stroke(color(100));
                                    drawWorldLine(
                                            axe.copy().setMag(proj1.x).add(polygon.position),
                                            axe.copy().setMag(proj1.y).add(polygon.position),
                                            2);
                                    stroke(color(200));
                                    drawWorldLine(
                                            axe.copy().setMag(proj2.x).add(polygon.position),
                                            axe.copy().setMag(proj2.y).add(polygon.position),
                                            2);
                                    stroke(color(255));
                                    STROKE_WEIGHT = 3;
                                    drawWorldLine(
                                            axe.copy().setMag(overlap.x).add(polygon.position),
                                            axe.copy().setMag(overlap.y).add(polygon.position), STROKE_WEIGHT);
                                }
                            }

                            for (PVector axe : colliderAxes) {
                                tmp1.set(0, 0);
                                PVector proj1 = project(polygon, axe);
                                PVector proj2 = project(collider, axe);
                                PVector overlap = SolMath.overlap(proj1.x, proj1.y, proj2.x, proj2.y);
                                polyOverlaps.add(new PVector().set(axe).setMag(overlap.y - overlap.x));
                                if (DEBUG) {
                                    stroke(color(255, 255, 255));
                                    STROKE_WEIGHT = 0.05f;
                                    drawWorldLine(collider.position, collider.position.copy().add(axe), STROKE_WEIGHT);
                                    noFill();
                                    STROKE_WEIGHT *= 2f;
                                    stroke(color(100));
                                    drawWorldLine(
                                            axe.copy().setMag(proj1.x).add(collider.position),
                                            axe.copy().setMag(proj1.y).add(collider.position),
                                            2);
                                    stroke(color(200));
                                    drawWorldLine(
                                            axe.copy().setMag(proj2.x).add(collider.position),
                                            axe.copy().setMag(proj2.y).add(collider.position),
                                            2);

                                    stroke(color(255));
                                    STROKE_WEIGHT = 3;
                                    drawWorldLine(
                                            axe.copy().setMag(overlap.x).add(collider.position),
                                            axe.copy().setMag(overlap.y).add(collider.position), STROKE_WEIGHT);
                                }
                            }
                        }
                        if (polyOverlaps.size() > 0) {
                            PVector shortest = polyOverlaps.get(0);
                            for (PVector polyOverlap : polyOverlaps) {
                                if (polyOverlap.mag() < shortest.mag()) {
                                    shortest = polyOverlap;
                                }
                            }
                            polygon.position.add(shortest.mult(-1));
                        }
                    }
                }
            }
        }
        postDraw();
    }
}
