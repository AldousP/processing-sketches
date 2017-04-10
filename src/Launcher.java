import java.io.File;

import javafx.application.Application;
import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.control.ListView;
import javafx.scene.layout.GridPane;
import javafx.scene.text.Font;
import javafx.scene.text.FontWeight;
import javafx.scene.text.Text;
import javafx.stage.Stage;
import processing.core.PApplet;

/**
 * Launcher.
 */
public class Launcher extends Application {

    private final int WIDTH = 1280;
    private final int HEIGHT = 720;
    private final boolean RESIZABLE = false;
    private final String TITLE = "Processing Sketches";
    private final String SKETCHES_SRC = "sketches.";

    /**
     * Constructor.
     */
    public Launcher() {
    }

    @Override
    public void start(Stage primaryStage) throws Exception {
        GridPane grid = new GridPane();
        grid.setAlignment(Pos.CENTER);
        grid.setHgap(10);
        grid.setVgap(10);
        grid.setPadding(new Insets(25, 25, 25, 25));

        Text scenetitle = new Text("Welcome");
        scenetitle.setFont(Font.font("Tahoma", FontWeight.NORMAL, 20));
        grid.add(scenetitle, 0, 0, 2, 1);

        // Options List
        ListView<String> list = new ListView<String>();

        File folder = new File("src/sketches/");
        File[] listOfFiles = folder.listFiles();
        ObservableList<String> items = FXCollections.observableArrayList();

        String tmp;
        if (listOfFiles != null) {
            for (File file : listOfFiles) {
                tmp = file.getName();
                items.add(tmp.substring(0, tmp.lastIndexOf('.')));
            }
        }

        list.setItems(items);
        list.setPrefWidth(300);
        list.setPrefHeight(400);
        grid.add(list, 0, 1, 2, 1);

        Button btn = new Button();
        btn.setText("Launch Sketch");
        btn.setOnAction(event -> {
            PApplet.main(SKETCHES_SRC + list.getSelectionModel().getSelectedItem(), new String[]{});
        }
        );
        grid.getChildren().add(btn);

        Scene scene = new Scene(grid, WIDTH, HEIGHT);
        primaryStage.setTitle(TITLE);
        primaryStage.setScene(scene);
        primaryStage.setResizable(RESIZABLE);
        primaryStage.show();
    }

    public static void main(String[] args) {
        launch(args);
    }
}
