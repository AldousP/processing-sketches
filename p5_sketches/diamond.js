var WIDTH = 600;
var HEIGHT = WIDTH;
var MIDX = WIDTH / 2;
var MIDY = HEIGHT / 2;
var FRAME_RATE = 60;
var STROKE_WEIGHT = 2;
var DIAMOND_VERTICES = 6;
var SUBDIVISION = 360 / DIAMOND_VERTICES;
var DIAMOND_HEIGHT = HEIGHT * 0.75;
var DEGREES_PER_SECOND = 180;
var V_SCALING_FACTOR = 0.4;
var MAX_RADIUS = WIDTH / 4;
var MIN_RADIUS = 0;
var RADIUS_INCREMENT = 25;

var BACKGROUND_COLOR;
var DRAW_COLOR;

var lastFrame = 0;
var delta;
var baseDegree = 0;
var tempDegree;
var x = 0;
var y;
var lastX1;
var lastY1;
var lastX2;
var lastY2;
var radius = 0;

function setup(){
    BACKGROUND_COLOR = color('#FF6B6B');
    DRAW_COLOR = color('#4ECDC4');
    strokeWeight(STROKE_WEIGHT);
    frameRate(FRAME_RATE);
    createCanvas(WIDTH, HEIGHT);
    fill(DRAW_COLOR);
    stroke(DRAW_COLOR);
}

function draw() {
    delta = (millis() - lastFrame) / 1000;
    background(BACKGROUND_COLOR);
    radius += RADIUS_INCREMENT * delta;

    if ( ((RADIUS_INCREMENT < 0) && radius < MIN_RADIUS) || ((RADIUS_INCREMENT > 0) && radius > MAX_RADIUS)) {
        RADIUS_INCREMENT *= -1;
    }

    baseDegree +=  DEGREES_PER_SECOND * delta;
    baseDegree = baseDegree % 360;
    for (var i = 0; i < DIAMOND_VERTICES; i++) {
        tempDegree = baseDegree + SUBDIVISION * i;
        tempDegree = tempDegree % 360;
        x = (sin(radians(tempDegree)) * radius) + MIDX;
        y = (cos(radians(tempDegree)) * radius * V_SCALING_FACTOR) + MIDY;
        line(x, y, MIDX, MIDY + DIAMOND_HEIGHT / 2);
        line(x, y, MIDX, MIDY - DIAMOND_HEIGHT / 2);
        line(x, y, lastX1, lastY1);
        lastX1 = x;
        lastY1 = y;

        x = (sin(radians(tempDegree)) * radius / 2) + MIDX;
        y = (cos(radians(tempDegree)) * radius / 2 * V_SCALING_FACTOR) + MIDY;


        line(x, y, MIDX, MIDY + DIAMOND_HEIGHT / 2);
        line(x, y, MIDX, MIDY - DIAMOND_HEIGHT / 2);
        line(x, y, lastX2, lastY2);
        lastX2 = x;
        lastY2 = y;
    }
    lastFrame = millis();
}