using System;
using System.Collections.Generic;

namespace UserCollectionLib
{
    // Класс-коллекция для хранения элементов, имеющих уникальный составной ключ [Id, Name].
    // Реализован минимальный функционал для наполнения и модификации коллекции,
    // а также методы для эффективного по скорости получения элементов по их Id ИЛИ Name.
    // Решено не поддерживать стандартные интерфейсы коллекций, 
    // из-за усложнения реализации потокобезопасности.
    public class UserCollection<TKeyId, TKeyName, TValue> //  : IDictionary<Tuple<TKeyId, TKeyName>, TValue>
    {
        private System.Threading.ReaderWriterLockSlim locker;
        private Dictionary<TKeyId, Dictionary<TKeyName, TValue>> _indexById;
        private Dictionary<TKeyName, Dictionary<TKeyId, TValue>> _indexByName;
        private int _count;

        /// <summary>
        /// Конструктор по умолчанию
        /// </summary>
        public UserCollection()
        {
            locker = new System.Threading.ReaderWriterLockSlim();
            _indexById = new Dictionary<TKeyId, Dictionary<TKeyName, TValue>>();
            _indexByName = new Dictionary<TKeyName, Dictionary<TKeyId, TValue>>();
        }

        /// <summary>
        /// Возвращает число пар ключ-значение, содаржащихся в словаре
        /// </summary>
        public int Count { get { return _count; } }

        /// <summary>
        /// Добавляет указанный ключ и значение в коллекцию
        /// </summary>
        /// <param name="key">Ключ</param>
        /// <param name="value">Значение</param>
        public void Add(Tuple<TKeyId, TKeyName> key, TValue value)
        {
            try
            {
                locker.EnterWriteLock();

                // Получение и внутреннего словаря по Name из индекса по Id
                Dictionary<TKeyName, TValue> elementsByName;
                if (!_indexById.TryGetValue(key.Item1, out elementsByName))
                {
                    elementsByName = new Dictionary<TKeyName, TValue>();
                    _indexById.Add(key.Item1, elementsByName);
                }
                // Проверка элемента в словаре
                if (elementsByName.ContainsKey(key.Item2))
                    throw new ArgumentOutOfRangeException("key", "Элемент с данным ключом уже существует");

                // Получение и внутреннего словаря по Id из индекса по Name
                Dictionary<TKeyId, TValue> elementsById;
                if (!_indexByName.TryGetValue(key.Item2, out elementsById))
                {
                    elementsById = new Dictionary<TKeyId, TValue>();
                    _indexByName.Add(key.Item2, elementsById);
                }
                // Проверка элемента в словаре
                if (elementsById.ContainsKey(key.Item1))
                    throw new ArgumentOutOfRangeException("key", "Элемент с данным ключом уже существует");

                // Вставка элемента в индексы
                elementsById.Add(key.Item1, value);
                elementsByName.Add(key.Item2, value);

                _count++;
            } 
            finally
            {
                locker.ExitWriteLock();
            }
        }

        /// <summary>
        /// Удаляет значение с указанным ключом из коллекции
        /// </summary>
        /// <param name="key">Ключ</param>
        /// <returns>Значение true, удалён элемент с указанным ключом; 
        /// в противном случае — значение false</returns>
        public bool Remove(Tuple<TKeyId, TKeyName> key)
        {
            try
            {
                locker.EnterUpgradeableReadLock();

                // Получение и внутреннего словаря по Name из индекса по Id
                Dictionary<TKeyName, TValue> elementsByName;
                if (!_indexById.TryGetValue(key.Item1, out elementsByName))
                    return false;

                // Получение и внутреннего словаря по Id из индекса по Name
                Dictionary<TKeyId, TValue> elementsById;
                if (!_indexByName.TryGetValue(key.Item2, out elementsById))
                    return false;

                try
                {
                    locker.EnterWriteLock();

                    // Очистка или удаление внутренних словарей 
                    if (elementsByName.Count > 1)
                        elementsByName.Remove(key.Item2);
                    else
                        _indexById.Remove(key.Item1);

                    if (elementsById.Count > 1)
                        elementsById.Remove(key.Item1);
                    else
                        _indexByName.Remove(key.Item2);

                    _count--;
                    return true;
                }
                finally
                {
                    locker.ExitWriteLock();
                }
            }
            finally
            {
                locker.ExitUpgradeableReadLock();
            }
        }

        /// <summary>
        /// Удаляет все ключи и значения из коллекции
        /// </summary>
        public void Clear()
        {
            try
            {
                locker.EnterWriteLock();

                _indexById.Clear();
                _indexByName.Clear();
                _count = 0;
            }
            finally
            {
                locker.ExitWriteLock();
            }
        }

        /// <summary>
        /// Получить элемент, по заданному ключу
        /// </summary>
        /// <param name="key">Ключ</param>
        /// <param name="value">Возвращаемое значение, связанное с указанном ключом, 
        /// если он найден; в противном случае — значение по умолчанию для данного типа параметра value. 
        /// Этот параметр передается неинициализированным.</param>
        /// <returns>Значение true, получен элемент с указанным ключом; 
        /// в противном случае — значение false</returns>
        public bool TryGetValue(Tuple<TKeyId, TKeyName> key, out TValue value)
        {
            try
            {
                locker.EnterReadLock();

                // Проверяем индекс по ключу
                Dictionary<TKeyName, TValue> elementsByName;
                if (!_indexById.TryGetValue(key.Item1, out elementsByName))
                {
                    value = default(TValue);
                    return false;
                }

                // Возвращаем элемент, если есть
                if (elementsByName.TryGetValue(key.Item2, out value))
                    return true;

                return false;
            }
            finally
            {
                locker.ExitReadLock();
            }
        }

        /// <summary>
        /// Проверить наличие элемента, по заданному ключу
        /// </summary>
        /// <param name="key">Ключ</param>
        /// <returns>Значение true, содержится элемент с указанным ключом; 
        /// в противном случае — значение false</returns>
        public bool ContainsKey(Tuple<TKeyId, TKeyName> key)
        {
            try
            {
                locker.EnterReadLock();

                // Проверяем индекс по ключу
                Dictionary<TKeyName, TValue> elementsByName;
                if (!_indexById.TryGetValue(key.Item1, out elementsByName))
                    return false;

                // Проверяем внутренний словарь
                if (elementsByName.ContainsKey(key.Item2))
                    return true;
                return false;
            }
            finally
            {
                locker.ExitReadLock();
            }
        }

        /// <summary>
        /// Получить элементы, имеющие заданный Id
        /// </summary>
        /// <param name="id">Id</param>
        /// <returns>Словарь элементов с ключами Name</returns>
        public IDictionary<TKeyName, TValue> SearchById(TKeyId id)
        {
            try
            {
                locker.EnterReadLock();

                Dictionary<TKeyName, TValue> elementsByName;
                if (!_indexById.TryGetValue(id, out elementsByName))
                    return new Dictionary<TKeyName, TValue>();
                // Возвращаем копию
                return new Dictionary<TKeyName, TValue>(elementsByName);
            }
            finally
            {
                locker.ExitReadLock();
            }
        }

        /// <summary>
        /// Получить элементы, имеющие заданный Name
        /// </summary>
        /// <param name="name">Name</param>
        /// <returns>Словарь элементов с ключами их Id</returns>
        public IDictionary<TKeyId, TValue> SearchByName(TKeyName name)
        {
            try
            {
                locker.EnterReadLock();
                Dictionary<TKeyId, TValue> elementsById;
                if (!_indexByName.TryGetValue(name, out elementsById))
                    return new Dictionary<TKeyId, TValue>();
                // Возвращаем копию
                return new Dictionary<TKeyId, TValue>(elementsById);
            }
            finally
            {
                locker.ExitReadLock();
            }
        }
    }
}
