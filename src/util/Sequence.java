package util;

public abstract class Sequence {
    float length = 0;
    float current = 0;
//    boolean pingPong = false;

    public Sequence(float length, boolean pingPong) {
        this.length = length;
//        this.pingPong = pingPong;
    }

    public float update(float delta) {
        current += delta;
        if (current > length) {
            event();
            current -= length;
//            if (pingPong) {
//                current = 1 - current;
//            }
        }
        return current / length;
    }

    public abstract void event ();

}
