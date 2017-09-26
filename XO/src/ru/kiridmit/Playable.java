package ru.kiridmit;

/**
 * Интерфейс для консольного варианта игры
 */
public interface Playable {
    // Получить следующий ход
    int getNextTurn(Game game);
}
