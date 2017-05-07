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

    @Override
    protected void drawDebug() {
        super.drawDebug();
        drawWorldText("I'm a Sketch Specific Debug Line", 0, 0, 12);
    }

    @Override
    public void keyPressed() {
        super.keyPressed();
        if (key == 'a') {
        }

        if (key == CODED && keyCode == LEFT) {
        }
    }
}
