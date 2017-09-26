package ru.kiridmit;

import com.sun.org.apache.xpath.internal.SourceTree;

/**
 * Класс модели текущего состояния игры
 */
public class Game {
    // Варианты выигрышных линий
    private static byte wins[][] = {{0,1,2},{3,4,5},{6,7,8},{0,3,6},{1,4,7},{2,5,8},{0,4,8},{2,4,6}};
    byte [] field  = new byte[]{-1, -1, -1, -1, -1, -1, -1, -1, -1}; // Поле
    int step = 0; // Номер хода

    // Совершить текущий ход
    boolean step(int nextTurn) {
        if (isCellEmpty(nextTurn)) {
            makeMove(nextTurn);
            if(isPlay()) {
                step++; // Переход хода если игра ещё продолжается
            }
        } else {
            return false;
        }
        return true;
    }

    // Состояние игры: -1 - идйт, 0 - ничья, 1 - выигрыш
    int getState() {
        if (isWin()) {
            return 1;
        } else if (isDraw()) {
            return 0;
        }
        return -1;
    }

    int getCurrentPlayer() {
        return step % 2;
    }

    // Сделать ход
    void makeMove(int cell) {
        //System.out.println("Hod: " + cell);
        field[cell] = (byte)(getCurrentPlayer());
    }

    // Пустая ли ячейка
    boolean isCellEmpty(int cell) {
        return field[cell] == -1;
    }

    // Проверка на выигрыш
    boolean isWin() {
        for (byte[] win : wins) {
            boolean isWin = true;
            for (byte cell : win) {
                if (field[cell] != getCurrentPlayer()) {
                    isWin = false;
                    break;
                }
            }
            if (isWin) {
                return true;
            }
        }
        return false;
    }

    // Проверка ничьи
    boolean isDraw() {
        return step == 9;
    }

    // Проверка продолжения игры
    boolean isPlay() {
        return getState() == -1;
    }

    // Сброс игры
    void newGame() {
        field = new byte[]{-1, -1, -1, -1, -1, -1, -1, -1, -1};
        step = 0;
    }

}
