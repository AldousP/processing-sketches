package sketches;

/**
 * BlankSlate.
 */
public class BlankSlate extends BaseSketch {

    public void setup() {
        super.setup();
        title = "Blank Slate";
        date = "00.00.00";
    }

    public void draw() {
        super.draw();
        postDraw();
    }
}
