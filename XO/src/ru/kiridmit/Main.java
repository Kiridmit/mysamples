package ru.kiridmit;

import java.util.Scanner;

/**
 * Класс выбора типа игры
 */
public class Main {
    // Выбор графического варианта интерфейса (true)
    public static boolean chooseGraphicInterface() {
        String interfaceType;
        while (true) try {
            System.out.print("Введите тип интерфейса(c - console, g - graphic): ");
            interfaceType = new Scanner(System.in).next("c|g");
            break;
        } catch (Exception e) {
            System.out.println("Ошибка ввода");
        }
        return interfaceType.equalsIgnoreCase("c") ? false : true;
    }
    // Точка входа
    public static void main(String[] args) {
        boolean isGraphic = chooseGraphicInterface();
        if (isGraphic) {
            GraphicViewController.main(args);
        } else {
            ConsoleViewController c = new ConsoleViewController();
            c.run();
        }
    }
}
