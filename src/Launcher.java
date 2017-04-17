import java.io.File;
import java.util.regex.Pattern;

import javafx.application.Application;
import javafx.application.Platform;
import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.control.ListView;
import javafx.scene.control.ToolBar;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.layout.BorderPane;
import javafx.scene.layout.GridPane;
import javafx.scene.layout.HBox;
import javafx.stage.Stage;
import javafx.stage.StageStyle;

import javax.swing.GroupLayout.Alignment;

import jdk.nashorn.internal.runtime.regexp.joni.Regex;
import processing.core.PApplet;
import processing.core.PVector;

/**
 * Launcher.
 */
public class Launcher extends Application {

    private final int WIDTH = 1020;
    private final int HEIGHT = 720;
    private final boolean RESIZABLE = true;
    private final String TITLE = "Processing Sketches";
    private final String SKETCHES_SRC = "sketches.";
    private double xOffset;
    private double yOffset;

    /**
     * Constructor.
     */
    public Launcher() {
    }

    @Override
    public void start(Stage primaryStage) throws Exception {
        primaryStage.initStyle(StageStyle.UNDECORATED);
        BorderPane borderPane = new BorderPane();

        ToolBar toolBar = new ToolBar();
        toolBar.setOnMousePressed(event -> {
            xOffset = primaryStage.getX() - event.getScreenX();
            yOffset = primaryStage.getY() - event.getScreenY();
        });

        toolBar.setOnMouseDragged(event -> {
            primaryStage.setX(event.getScreenX() + xOffset);
            primaryStage.setY(event.getScreenY() + yOffset);
        });

        int height = 32;
        toolBar.setPrefHeight(height);
        toolBar.setMinHeight(height);
        toolBar.setMaxHeight(height);
        borderPane.setStyle("-fx-background: #fff;");
        toolBar.setStyle("-fx-background: #fff;");
        toolBar.getItems().add(new WindowButtons());
        borderPane.setTop(toolBar);
        GridPane grid = new GridPane();
        borderPane.setCenter(grid);
        borderPane.getCenter().setStyle("-fx-margin: 0;");
        grid.setAlignment(Pos.CENTER);
        grid.setPadding(new Insets(25, 25, 25, 25));
        grid.setStyle("-fx-background: #fff;");
        Scene scene = new Scene(borderPane, WIDTH, HEIGHT);
        primaryStage.setTitle(TITLE);
        primaryStage.setScene(scene);
        primaryStage.setResizable(RESIZABLE);
        primaryStage.getIcons().add(new Image("file:icon.png"));

        ImageView header = new ImageView();
        header.setImage(new Image("file:header.png"));
        header.setFitWidth(900);
        header.setPreserveRatio(true);
        header.setSmooth(true);
        header.setCache(true);
        grid.add(header, 0, 0, 4, 1);

        // Options List
        ListView<String> list = new ListView<String>();

        File folder = new File("src/sketches/");
        File[] listOfFiles = folder.listFiles();
        ObservableList<String> items = FXCollections.observableArrayList();
        String tmp;
        if (listOfFiles != null) {
            for (File file : listOfFiles) {
                tmp = file.getName();
                if (!tmp.equals("BaseSketch.java")) {
                    tmp = tmp.substring(0, tmp.lastIndexOf('.'));
                    tmp = tmp.replaceAll("(\\p{Ll})(\\p{Lu})", "$1 $2");
                    items.add(tmp);
                }
            }
        }

        list.setItems(items);
        list.setPrefWidth(300);
        list.setPrefHeight(400);
        grid.add(list, 0, 1, 2, 1);
        Button btn = new Button();
        btn.setStyle(
                "-fx-background-color:#306;"
                        + "-fx-text-fill: white;"
                        + "-fx-border-style: none;"
                        + "-fx-font-size: 14px;"
                        + "-fx-start-margin: 10px;"
                        + "-fx-: 14px;");
        btn.setText("Launch Sketch");
        btn.setPrefWidth(128);
        btn.setOnAction((javafx.event.ActionEvent event) -> {
            String fileName = list.getSelectionModel().getSelectedItem();
            PApplet.main(SKETCHES_SRC + (fileName.replaceAll("\\s+", "")), new String[]{});
        });
        grid.add(btn, 0, 2, 2, 1);
        primaryStage.show();

    }

    class WindowButtons extends HBox {
        public WindowButtons() {
            Button closeBtn = new Button("Exit");
            this.setAlignment(Pos.BOTTOM_RIGHT);
            closeBtn.setStyle(
                    "-fx-background-color:#306;"
                            + "-fx-text-fill: white;"
                            + "-fx-border-style: none;"
                            + "-fx-font-size: 14px;"
                            + "-fx-: 10px;");
            closeBtn.setOnAction(actionEvent -> Platform.exit());
            this.getChildren().add(closeBtn);
        }
    }


    public static void main(String[] args) {
        launch(args);
    }
}
