using System;
using System.Collections.Generic;
using UserCollectionLib;

namespace UserCollectionDemo
{
    class main
    {
        static void Main(string[] args)
        {
            // Пример использования коллекции с идентификатором 
            // в виде пользовательского типа UserType

            Console.WriteLine("Cоздаём и наполняем коллекцию:");
            var collection = new UserCollection<UserType, string, string>();
            // Пользовательские Id
            var id1 = new UserType(1, "a");
            var id2 = new UserType(2, "b");
            var id3 = new UserType(3, "c");
            // Набор ключей
            var k1 = new Tuple<UserType, string>(id1, "Mike");
            var k2 = new Tuple<UserType, string>(id2, "Mike");
            var k3 = new Tuple<UserType, string>(id2, "Jane");
            var k4 = new Tuple<UserType, string>(id3, "Max");
            // Добавляем элементы по ключам
            collection.Add(k1, "Employee");
            collection.Add(k2, "Manager");
            collection.Add(k3, "Looser");
            collection.Add(k4, "Looser");
            Console.WriteLine("Элементов в коллекции: " + collection.Count);

            Console.WriteLine("Поиск по Id = [2, b]:");
            var elementsByName = collection.SearchById(id2);
            foreach (KeyValuePair<string, string> x in elementsByName) {
                Console.WriteLine("[" + x.Key + "] = " + x.Value);
            }

            Console.WriteLine("Поиск по Name = [Mike]:");
            var elementsById = collection.SearchByName("Mike");
            foreach (KeyValuePair<UserType, string> x in elementsById)
            {
                Console.WriteLine("[" + x.Key.id1 + ", " + x.Key.id2 + "] = " + x.Value);
            }

            Console.WriteLine("Получение значения по составному ключу = [[3,c],Max]:");
            string element;
            if (collection.TryGetValue(k4, out element))
                Console.WriteLine("[[3,c],Max] = " + element);
            else
                Console.WriteLine("Элемент с ключом [[3,c],Max] не найден");

            Console.WriteLine("Удаление элемента по составному ключу = [[3,c],Max]:");
            if (collection.Remove(k4))
                Console.WriteLine("Удаление прошло успешно"); 
            else
                Console.WriteLine("Удаление прошло неуспешно ");
            if (collection.TryGetValue(k4, out element))
                Console.WriteLine("[[3,c],Max] = " + element);
            else
                Console.WriteLine("Элемент с ключом [[3,c],Max] не найден");

            // Более подробно с работой этих и других функций 
            // можно ознакомиться в описании к ним и в тестах

            if (System.Diagnostics.Debugger.IsAttached)
                Console.ReadLine();
        }
    }
}
