package ru.kiridmit;

import javafx.application.Application;
import javafx.scene.Scene;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.layout.StackPane;
import javafx.stage.Stage;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

/**
 * Класс графического варианта управления и отображения игры
 */
public class GraphicViewController extends Application {
    StackPane root;
    Scene scene;
    ArrayList<ImageView> imageViews = new ArrayList<>();
    Map<String,Image> buttonImages = new HashMap<String,Image>();
    Map<String,ImageView> buttonImageViews = new HashMap<String,ImageView>();
    Game game;
    boolean[] playerIsHuman = {true, false};
    // Начало игры
    void run() {
        game = new Game();
        updateInterface();
    }
    // Обновление всего состояния интерфейса
    void updateInterface() {
        // Обновляем поле
        for (int i = 0; i < 9; i++) {
            int cell = game.field[i];
            Image image;
            switch (game.field[i]) {
                case 0:
                    image = buttonImages.get("imageX");
                    break;
                case 1:
                    image = buttonImages.get("imageO");
                    break;
                default:
                    image = buttonImages.get("imageN");
            }
            imageViews.get(i).setImage(image);
            // Обновление кнопки хода компьютера и отображения хода человека
            boolean isHuman = playerIsHuman[game.getCurrentPlayer()];
            buttonImageViews.get("computerTurn").setVisible(!isHuman);
            buttonImageViews.get("humanTurn").setVisible(isHuman);
            buttonImageViews.get("win").setVisible(game.isWin());
            buttonImageViews.get("draw").setVisible(game.isDraw());
            Image turnImage =  buttonImages.get(game.getCurrentPlayer() == 0 ? "imageX" : "imageO");
            buttonImageViews.get("turn").setImage(turnImage);
            Image playerXImage =  buttonImages.get(playerIsHuman[0] ? "playerX" : "playerO");
            Image playerOImage =  buttonImages.get(playerIsHuman[1] ? "playerX" : "playerO");
            buttonImageViews.get("playerX").setImage(playerXImage);
            buttonImageViews.get("playerO").setImage(playerOImage);
        }
    }
    // Сoздание графики поля 3x3
    void createField() {
        for (int i = 0; i < 3; i++) {
            for (int j = 0; j < 3; j++) {
                int n = j+i*3;
                ImageView imageView = new ImageView(buttonImages.get("imageN"));
                imageView.setTranslateX(50*j-50);
                imageView.setTranslateY(50*i-50);
                imageView.setOnMouseClicked(t -> fieldPress(n));
                root.getChildren().add(imageView);
                imageViews.add(imageView);
            }
        }
    }
    // Переключение типа игроков
    void changePlayerPress(int player) {
        playerIsHuman[player] = !playerIsHuman[player];
        game.newGame();
        updateInterface();
    }
    // Сброс игры
    void newGamePress() {
        game.newGame();
        updateInterface();
    }
    // Сброс игры
    void fieldPress(int turn) {
        if (game.isPlay() && playerIsHuman[game.getCurrentPlayer()]) {
            game.step(turn);
            updateInterface();
        }
    }
    // Ход компьютера
    void computerTurnPress() {
        if (game.isPlay() && !playerIsHuman[game.getCurrentPlayer()]) {
            game.step(new PlayerAI().getNextTurn(game));
            updateInterface();
        }
    }
    // Создание всех кнопок кроме поля
    void createButton(String name, String imageName, int x, int y) {
        buttonImages.put(name, new Image(imageName));
        ImageView iv = new ImageView(buttonImages.get(name));
        buttonImageViews.put(name, iv);
        iv.setTranslateX(x);
        iv.setTranslateY(y);
        root.getChildren().add(iv);
    }

    // Инициализация графики и событий
    @Override
    public void start(Stage primaryStage) throws Exception{
        root = new StackPane();

        buttonImages.put("imageX", new Image("x.png"));
        buttonImages.put("imageO", new Image("o.png"));
        buttonImages.put("imageN", new Image("n.png"));

        //createButton("newGame", "new_game.png", 0, -150);

        createButton("title", "title.png", 0, -200);

        createButton("playerX", "human.png", -100, -150);
        createButton("playerO", "computer.png", 100, -150);

        createButton("turn", "x.png", 100, 120);

        createButton("computerTurn", "computer_turn.png", -50, 120);
        createButton("humanTurn", "human_turn.png", -50, 120);
        createButton("win", "win.png", -50, 120);
        createButton("draw", "draw.png", -50, 120);
        createButton("newGame", "new_game.png", 0, 180);

        buttonImageViews.get("computerTurn").setOnMouseClicked(t -> computerTurnPress());
        buttonImageViews.get("win").setOnMouseClicked(t -> newGamePress());
        buttonImageViews.get("draw").setOnMouseClicked(t -> newGamePress());
        buttonImageViews.get("newGame").setOnMouseClicked(t -> newGamePress());

        buttonImageViews.get("playerX").setOnMouseClicked(t -> changePlayerPress(0));
        buttonImageViews.get("playerO").setOnMouseClicked(t -> changePlayerPress(1));



        createField();

        scene = new Scene(root, 450, 450);

        primaryStage.setTitle("XOGame");
        primaryStage.setScene(scene);
        primaryStage.getIcons().add(buttonImages.get("imageX"));
        primaryStage.show();
        System.out.println("Графический интерфейс запущен");

        run();
    }

    public static void main(String[] args) {
        launch(args);
    }
}
