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
}
