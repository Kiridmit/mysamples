using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Collections;

namespace UserCollection
{
    class GoodUserCollection<TElement> : IEnumerable, IEnumerator
    {
        readonly TElement[] elements = new TElement[4];

        // Индексатор
        public TElement this[int index]
        {
            get { return elements[index]; }
            set { elements[index] = value; }
        }

        // Маркер текущего элемента
        int position = -1;

        // Реализация интерфейса итератора IEnumerator:

        bool IEnumerator.MoveNext()
        {
            if (position < elements.Length - 1)
            {
                position++;
                return true;
            }
            ((IEnumerator)this).Reset();
            return false;
        }

        void IEnumerator.Reset()
        {
            position = -1;
        }

        object IEnumerator.Current
        {
            get { return elements[position]; }
        }

        // Реализация интерфейса IEnumerable:

        IEnumerator IEnumerable.GetEnumerator()
        {
            return (IEnumerator)this;
        }
    }
}
