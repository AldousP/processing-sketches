package util.geometry;

import processing.core.PVector;

import static processing.core.PApplet.radians;

public class Spring {
    public PVector pos;
    public PVector displace;
    public float speed;
    float tension = 0.0f;
    float dampening = 0.0f;
    float rotation = 90;
    public float maxLength = 0.05f;

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
        float diff = maxLength - displace.mag();
        speed += tension * diff - speed * dampening;
        displace.add(0, speed * delta);
        float oX = (float) (Math.cos(radians(rotation)) * displace.mag());
        float oY = (float) (Math.sin(radians(rotation)) * displace.mag());
        displace.set(oX, oY);
    }

    public PVector worldSpace() {
        return pos.copy().add(displace);
    }
}
