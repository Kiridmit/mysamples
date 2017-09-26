package ru.kiridmit;

import java.util.ArrayList;
import java.util.Random;

/**
 * Класс игрока - AI
 */
public class PlayerAI implements Playable {
    // Получить следующий ход
    public int getNextTurn(Game game){
        ArrayList<Integer> turns = new ArrayList<>();
        int maxState = -2; // Стоимость лучшего хода (-1,0,1)
        for (int cell = 0; cell < 9; cell++) {
            if (game.isCellEmpty(cell)) {
                game.makeMove(cell);
                int newState = getRating(game);
                game.field[cell] = -1;
                // Определение лучшего хода
                if (maxState < newState) turns.clear();
                if (maxState <= newState) {
                    maxState = newState;
                    turns.add(cell);
                }
            }
        }
        // Добавляем случайности равноценным вариантам
        Random rand = new Random();
        rand.setSeed(System.currentTimeMillis());
        int turn = turns.get(rand.nextInt(turns.size()));
        return turn;
    }
    // Получить наихудшее предсказание на текущую ситуацию
    private int getRating(Game game) {
        if (game.isWin()) return 1; // Выигрыш
        if (game.step == 8) return 0; // Ничья
        int maxState = -2; // Стоимость лучшего хода (-1,0,1)
        // Ходим во все пустые клетки
        game.step++;
        for (int cell = 0; cell < 9; cell++) {
            if (game.isCellEmpty(cell)) {
                game.makeMove(cell);
                int newState = getRating(game);
                game.field[cell] = -1;
                // Определение лучшего хода
                if (maxState < newState) {
                    maxState = newState;
                    // Не искать после выигрышной позиции
                    if (maxState == 1) break;
                }
            }
        }
        game.step--;
        return -maxState;
    }
}
