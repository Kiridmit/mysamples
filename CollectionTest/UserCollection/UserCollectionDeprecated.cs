using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;

namespace UserCollectionLib
{
    // Попытка использовать стандартную коллекцию за основу
    // !Deprecated
    public class UserCollectionDeprecated<TKeyId, TKeyName, TValue> : IDictionary<Tuple<TKeyId, TKeyName>, TValue>
    {
        //private System.Threading.ReaderWriterLockSlim locker = new System.Threading.ReaderWriterLockSlim();

        private Dictionary<Tuple<TKeyId, TKeyName>, TValue> dict;
        private Dictionary<TKeyId, List<TValue>> cacheId;
        private Dictionary<TKeyName, List<TValue>> cacheName;

        // Поля IDictionary<Tuple<TKeyId, TKeyName>, TValue>
        public ICollection<Tuple<TKeyId, TKeyName>> Keys { get { return dict.Keys; } }
        public ICollection<TValue> Values{ get{ return dict.Values; } }
        public int Count { get { return dict.Count; } }
        public bool IsReadOnly { get { return false; } }

        /// <summary>
        /// Конструктор с выбором первоначального размера внутренних словарей
        /// </summary>
        /// <param name="size">Начальный размер внутреннего словаря</param>
        public UserCollectionDeprecated(int size = 0)
        {
            dict = new Dictionary<Tuple<TKeyId, TKeyName>, TValue>(size);
            cacheId = new Dictionary<TKeyId, List<TValue>>();
            cacheName = new Dictionary<TKeyName, List<TValue>>();
        }

        /// <summary>
        /// Добавляет указанный ключ и значение в коллекцию
        /// </summary>
        /// <param name="key">Ключ</param>
        /// <param name="value">Значение</param>
        public void Add(Tuple<TKeyId, TKeyName> key, TValue value)
        {
            dict.Add(key, value); // TODO: error?
            // Запись в индекс
            if (cacheId.ContainsKey(key.Item1))
                cacheId[key.Item1].Add(value);
            else
                cacheId[key.Item1] = new List<TValue>() { value };
            if (cacheName.ContainsKey(key.Item2))
                cacheName[key.Item2].Add(value);
            else
                cacheName[key.Item2] = new List<TValue>() { value };

        }

        /// <summary>
        /// Удаляет значение с указанным ключом из коллекции
        /// </summary>
        /// <param name="key">Ключ</param>
        /// <returns>Успешность удаления</returns>
        public bool Remove(Tuple<TKeyId, TKeyName> key)
        {
            // Удаление, если элемент есть
            if (dict.ContainsKey(key))
            {
                TValue value = dict[key];
                // Очистка индексов
                if (cacheId[key.Item1].Count <= 1)
                    cacheId.Remove(key.Item1);
                else
                    cacheId[key.Item1].Remove(value);
                if (cacheName[key.Item2].Count <= 1)
                    cacheName.Remove(key.Item2);
                else
                    cacheName[key.Item2].Remove(value);
                // Удаление из основного словаря
                dict.Remove(key);
                // Успешное удаление
                return true;
            }
            // Удаления не произошло
            return false;
        }

        /// <summary>
        /// Удаляет все ключи и значения из коллекции
        /// </summary>
        public void Clear()
        {
            dict.Clear();
            cacheId.Clear();
            cacheName.Clear();
        }


        /// <summary>
        /// Получение всех элементов коллекции, с выбранным Id ключа
        /// </summary>
        /// <param name="id">Id ключа</param>
        /// <returns>Массив элементов'</returns>
        public TValue[] ValuesById(TKeyId id)
        {
            return cacheId[id].ToArray();
        }

        /// <summary>
        /// Получение всех элементов коллекции, с выбранным Name ключа
        /// </summary>
        /// <param name="id">Id ключа</param>
        /// <returns>Массив элементов'</returns>
        public TValue[] ValuesByName(TKeyName name)
        {
            return cacheName[name].ToArray();
        }

        // Прочая реализация IDictionary

        /// <summary>
        /// Элемент коллекции
        /// </summary>
        /// <param name="key"></param>
        /// <returns>Возвращаемый элемент</returns>
        public TValue this[Tuple<TKeyId, TKeyName> key]
        {
            set{ Add(key, value); }
            get { return dict[key]; }
        }

        public IEnumerator GetEnumerator()
        {
            return dict.GetEnumerator();
        }

        public bool ContainsKey(Tuple<TKeyId, TKeyName> key)
        {
            return dict.ContainsKey(key);
        }

        public bool TryGetValue(Tuple<TKeyId, TKeyName> key, out TValue value)
        {
            return dict.TryGetValue(key, out value);
        }

        public void Add(KeyValuePair<Tuple<TKeyId, TKeyName>, TValue> item)
        {
            dict.Add(item.Key, item.Value);
        }

        public bool Contains(KeyValuePair<Tuple<TKeyId, TKeyName>, TValue> item)
        {
            return dict.Contains(item);
        }

        public void CopyTo(KeyValuePair<Tuple<TKeyId, TKeyName>, TValue>[] array, int arrayIndex)
        {
            ((IDictionary<Tuple<TKeyId, TKeyName>, TValue>)dict).CopyTo(array, arrayIndex);
        }

        public bool Remove(KeyValuePair<Tuple<TKeyId, TKeyName>, TValue> item)
        {
            return Remove(item.Key); // ??
        }

        IEnumerator<KeyValuePair<Tuple<TKeyId, TKeyName>, TValue>> IEnumerable<KeyValuePair<Tuple<TKeyId, TKeyName>, TValue>>.GetEnumerator()
        {
            return dict.GetEnumerator();
        }
    }
}
