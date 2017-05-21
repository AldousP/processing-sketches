package util.geometry;

import processing.core.PVector;

import static processing.core.PApplet.radians;

public class Spring {
    public PVector pos;
    public PVector displace;
    public float speed;
    float tension = 0.015f;
    float dampening = 0.015f;
    float rotation = 90;
    public float length = 0.1f;
    public float maxLength = .5f;

    public Spring(PVector pos) {
        this.pos = pos;
        this.displace = new PVector();
    }

    public Spring tension(float tension) {
        this.tension = tension;
        return this;
    }

    public Spring dampening(float dampening) {
        this.dampening = dampening;
        return this;
    }

    public Spring rotation(float rotation) {
        this.rotation = rotation;
        return this;
    }

    public Spring speed(float speed) {
        this.speed = speed;
        return this;
    }

    public void update(float delta, float tension, float dampening) {
        float diff = length - displace.mag();
        speed += tension * diff - speed * dampening;
        displace.add(0, speed * delta);
        float oX = (float) (Math.cos(radians(rotation)) * displace.mag());
        float oY = (float) (Math.sin(radians(rotation)) * displace.mag());
        displace.set(oX, oY);
        if (displace.mag() > maxLength) {
            displace.setMag(maxLength);
        }
    }

    public PVector worldSpace() {
        return pos.copy().add(displace);
    }
}
