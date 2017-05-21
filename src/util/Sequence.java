package util;

public abstract class Sequence {
    float length = 0;
    float current = 0;
    public float alpha = 0;
    boolean pingPong = false;
    boolean reverse = false;

    public Sequence(float length, boolean pingPong) {
        this.length = length;
        this.pingPong = pingPong;
    }

    public void update(float delta) {
        current += delta;
        if (current > length) {
            event();
            current -= length;
            if (pingPong) {
                reverse = !reverse;
            }

            if (reverse) {
                current = 1 - current;
            }
        }
        alpha = current / length;
    }

    public abstract void event ();

}
