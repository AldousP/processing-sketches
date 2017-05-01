package util;

import processing.core.PVector;

import static processing.core.PApplet.atan2;
import static processing.core.PApplet.degrees;
import static processing.core.PApplet.sqrt;

public class SolMath {

    public static float clamp(float input, float low, float high) {
        if (input < low) {
            return low;
        } else if (input > high) {
            return high;
        } else {
            return input;
        }
    }

    public static boolean inRange(float val, float lower, float upper) {
        return val >= lower && val <= upper;
    }

    /**
     * Get relative rotation between two points In Degrees
     * @param originX
     * @param originY
     * @param ptX
     * @param ptY
     * @return
     */
    public static float getRelativeRotationOfPoint(float originX, float originY, float ptX, float ptY) {
        float result = degrees(atan2(ptY - originY, ptX - originX));
        if (result < 0) {
            result += 360;
        }
        return result;
    }

    public static float getRelativeRotationOfPoint(PVector origin, PVector pt) {
        return getRelativeRotationOfPoint(origin.x, origin.y, pt.x, pt.y);
    }

    public static float distance(PVector a, PVector b) {
        return sqrt((a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y));
    }

    public static PVector perpendicular(PVector axis) {
        return axis.copy().set(axis.y, -axis.x);
    }

    public static int wrapIndex(int index, int length) {
        if (index > length - 1) {
            index = wrapIndex(index - length, length);
        }
        return index;
    }

    public static boolean colliding(float a1, float a2, float b1, float b2) {
        float distA = Math.abs(a2 - a1) / 2;
        float distB = Math.abs(b2 - b1) / 2;
        float midA = (a1 + a2) / 2;
        float midB = (b1 + b2) / 2;

        if (Math.abs(midA - midB) < distA + distB) {
            return Math.sqrt((midB - midA) * (midB - midA)) < (distA + distB);
        } else {
            return false;
        }
    }

    public static PVector overlap(float a1, float a2, float b1, float b2) {
        if (colliding(a1, a2, b1, b2)) {
            return new PVector(Math.max(a1, b1), Math.min(a2, b2));
        } else {
            return new PVector(0 ,0);
        }
    }
}
