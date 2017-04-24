package util;

public class SolArray {

    public static int wrapIndex(int index, int length) {
        if (index > length - 1) {
            index = wrapIndex(index - length, length);
        }
        return index;
    }
}
