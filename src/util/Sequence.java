package util;

public abstract class Sequence {
    float length = 0;
    float current = 0;
    public float alpha = 0;

    public Sequence(float length, boolean pingPong) {
        this.length = length;
    }

    public void update(float delta) {
        current += delta;
        if (current > length) {
            event();
            current -= length;
        }
        alpha = current / length;
    }

    public abstract void event ();

}
