package ru.kiridmit;

import java.util.Scanner;


/**
 * Класс консольного варианта управления и отображения игры
 */
public class ConsoleViewController {
    Playable[] players = new Playable[2];
    Game game;

    // Начало игры, главный цикл
    void run() {
        System.out.println("Добро пожаловть в игру XO");
        configPlayers();
        // Цикл из нескольких партий
        while(true) {
            System.out.println("НОВАЯ ПАРТИЯ");
            game = new Game();
            // Основной игровой цикл
            while(game.isPlay()) {
                updateInterface();
                int nextTurn = players[game.getCurrentPlayer()].getNextTurn(game);
                if(!game.step(nextTurn)) {
                    System.out.println("Поле занято или отсутствует, попробуйте снова");
                }
            }
            while (true) try {
                System.out.print("Ещё партию?(y,n): ");
                String s = new Scanner(System.in).next("y|n");
                if (s.equalsIgnoreCase("y") ) {
                    break;
                } else {
                    return;
                }
            } catch (Exception e) {
                System.out.println("Ошибка ввода");
            }
        }
    }

    // Выбор типов игроков
    void configPlayers() {
        for (int i = 0; i < 2; i++) {
            while (true) try {
                System.out.print("Введите тип " + (i + 1) + " игрока(h - human, c - computer): ");
                String playerType = new Scanner(System.in).next("h|c");
                players[i] = (playerType.equalsIgnoreCase("h")) ? new PlayerHuman() : new PlayerAI();
                break;
            } catch (Exception e) {
                System.out.println("Ошибка ввода");
            }
        }
    }

    // Вывод текущих игровых данных
    void updateInterface() {
        System.out.println("Игровое поле:");
        int count = 0;
        int size = 3;
        for (int i = 0; i < size; i++) {
            for (int j = 0; j < size; j++) {
                if (game.field[count] == -1){
                    System.out.print(j+i*3);
                } else if (game.field[count] == 0){
                    System.out.print("X");
                } else if (game.field[count] == 1){
                    System.out.print("O");
                }
                System.out.print(" ");
                count++;
            }
            System.out.println();
        }
        int state = game.getState();
        if(state == -1) {
            System.out.println("Ход игрока " + (game.getCurrentPlayer() == 0 ? "X" : "O") + ".");
        } else if (state == 0) {
            System.out.println("Игра завершена: ничья");
        } else if (state == 1) {
            System.out.println("Игрок " + (game.getCurrentPlayer() == 0 ? "X" : "O") + " выиграл ");
        }
    }
}
