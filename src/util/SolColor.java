package util;


import processing.core.PVector;

public class SolColor {
    static PVector lerped = new PVector(0, 0, 0);

    public static PVector lerpSpectrum(float alpha, int ceiling) {
        int r = 0, g = 0, b = 0;
        float sixth = 0.166f;
        if (alpha < sixth) {
            r = ceiling;
            g = (int) (alpha / sixth * ceiling);
            b = 0;
        } else if (alpha < sixth * 2) {
            r = ceiling - (int) ((alpha - sixth) / sixth * ceiling);
            g = ceiling;
            b = 0;
        } else if (alpha < sixth * 3) {
            r = 0;
            g = ceiling;
            b = (int) ((alpha - sixth * 2) / sixth * ceiling);
        }  else if (alpha < sixth * 4) {
            r = 0;
            g = ceiling - (int) ((alpha - sixth * 3) / sixth * ceiling);
            b = ceiling;
        } else if (alpha < sixth * 5) {
            r = (int) ((alpha - sixth * 4) / sixth * ceiling);;
            g = 0;
            b = ceiling;
        } else if (alpha < sixth * 6) {
            r = ceiling;
            g = 0;
            b = ceiling - (int) ((alpha - sixth * 5) / sixth * ceiling);
        }
        lerped.set(r, g, b);
        if (lerped.mag() == 0) {
            lerped.set(ceiling, 0, 0);
        }
        return lerped;
    }
}
