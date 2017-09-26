package ru.kiridmit;

import java.util.InputMismatchException;
import java.util.Scanner;

/**
 * Класс консольного живого игрока
 */
public class PlayerHuman implements Playable {
    // Получить следующий ход
    public int getNextTurn(Game game){
        while (true) try {
            Scanner in = new Scanner(System.in);
            System.out.print("Введите позицию для хода (0-8): ");
            byte cell = in.nextByte();
            if (cell >= 0 && cell < 9 && game.isCellEmpty(cell)) {
                return cell;
            } else {
                System.out.println("Поле занято или отсутствует, попробуйте снова");
            }

        } catch (InputMismatchException e) {
            System.out.println("Попробуйте снова.");
        }
    }
}
