using System;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace UserCollectionLib.Tests
{
    using System.Threading.Tasks;
    using Key = Tuple<UserType, string>;

    // Покрытие тестами небольшое, но проверяет самые важные моменты
    [TestClass()]
    public class UserCollectionTests
    {
        
        [TestMethod()]
        public void AddAndTryGetValue_AddingElements_Checking()
        {
            UserCollection<UserType, string, string> c = new UserCollection<UserType, string, string>();
            string value1, value2, value3, value4;
            Key k1 = new Key(new UserType(1, "xyz"), "Mike");
            Key k2 = new Key(new UserType(2, "qwer"), "Jake");

            c.Add(k1, "Employee");
            c.Add(k2, "Superman");
            bool res1 = c.TryGetValue(k1, out value1);
            bool res2 = c.TryGetValue(k2, out value2);
            bool res3 = c.TryGetValue(new Key(new UserType(3, "qwer"), "Jake"), out value3);
            bool res4 = c.TryGetValue(new Key(new UserType(2, "qwer"), "JakeХ"), out value4);

            Assert.AreEqual("Employee", value1);
            Assert.AreEqual("Superman", value2);
            Assert.AreEqual(null, value3);
            Assert.AreEqual(null, value4);
            Assert.IsTrue(res1);
            Assert.IsTrue(res2);
            Assert.IsFalse(res3);
            Assert.IsFalse(res4);
        }

        [TestMethod()]
        public void Add_AddingEquelKeysElements_ThrowsException()
        {
            UserCollection<UserType, string, string> c = new UserCollection<UserType, string, string>();
            bool hasException = false;

            c.Add(new Key(new UserType(1, "xyz"), "Mike"), "Employee");
            try
            {
                c.Add(new Key(new UserType(1, "xyz"), "Mike"), "Superman");
            }
            catch (ArgumentOutOfRangeException e)
            {
                hasException = true;
            }

            Assert.IsTrue(hasException);
        }

        [TestMethod()]
        public void Add_AddingByNullKeyParts_ThrowsException()
        {
            UserCollection<UserType, string, string> c = new UserCollection<UserType, string, string>();
            bool hasException1 = false, hasException2 = false;

            try
            {
                c.Add(new Key(new UserType(1, null), "Mike"), "Superman");
            }
            catch (Exception e)
            {
                hasException1 = true;
            }
            try
            {
                c.Add(new Key(new UserType(1, "xyz"), null), "Superman");
            }
            catch (Exception e)
            {
                hasException2 = true;
            }

            Assert.IsTrue(hasException1);
            Assert.IsTrue(hasException2);
        }

        [TestMethod()]
        public void Remove_Adding3Remove1_Expected2AndNoElement()
        {
            UserCollection<UserType, string, string> c = new UserCollection<UserType, string, string>();
            Key k = new Key(new UserType(3, "a"), "Mike");

            c.Add(new Key(new UserType(1, "a"), "Mike"), "Employee");
            c.Add(new Key(new UserType(2, "a"), "Mike"), "Employee");
            c.Add(k, "Employee");
            c.Remove(k);

            Assert.AreEqual(2, c.Count);
            Assert.IsFalse(c.ContainsKey(k));
        }

        [TestMethod()]
        public void ClearAndContainssKey_Adding2Remove1_ExpectedNothing()
        {
            UserCollection<UserType, string, string> c = new UserCollection<UserType, string, string>();
            Key k1 = new Key(new UserType(1, "a"), "Mike");
            Key k2 = new Key(new UserType(2, "b"), "Mike");
            Key k3 = new Key(new UserType(2, "b"), "Jane");
            c.Add(k1, "Employee");
            c.Add(k2, "Manager");
            c.Add(k3, "Looser");

            c.Clear();

            Assert.AreEqual(0, c.Count);
            Assert.IsFalse(c.ContainsKey(k1));
            Assert.IsFalse(c.ContainsKey(k2));
            Assert.IsFalse(c.ContainsKey(k3));
        }

        [TestMethod()]
        public void ValuesById_Adding3AndSearch_Ok()
        {
            UserCollection<UserType, string, string> c = new UserCollection<UserType, string, string>();
            Key k1 = new Key(new UserType(1, "a"), "Mike");
            Key k2 = new Key(new UserType(2, "b"), "Mike");
            Key k3 = new Key(new UserType(2, "b"), "Jane");
            c.Add(k1, "Employee");
            c.Add(k2, "Manager");
            c.Add(k3, "Looser");

            var d0 = c.SearchById(new UserType(999, "a"));
            var d1 = c.SearchById(new UserType(1, "a"));
            var d2 = c.SearchById(new UserType(2, "b"));

            Assert.AreEqual(0, d0.Count);
            Assert.AreEqual(1, d1.Count);
            Assert.AreEqual(2, d2.Count);
            Assert.AreEqual("Employee", d1["Mike"]);
            Assert.AreEqual("Manager", d2["Mike"]);
            Assert.AreEqual("Looser", d2["Jane"]);
        }

        [TestMethod()]
        public void ValuesByName_Adding3AndSearch_Ok()
        {
            UserCollection<UserType, string, string> c = new UserCollection<UserType, string, string>();
            Key k1 = new Key(new UserType(1, "a"), "Mike");
            Key k2 = new Key(new UserType(2, "b"), "Mike");
            Key k3 = new Key(new UserType(2, "b"), "Jane");
            c.Add(k1, "Employee");
            c.Add(k2, "Manager");
            c.Add(k3, "Looser");

            var d1 = c.SearchByName("Jane");
            var d2 = c.SearchByName("Mike");
            
            Assert.AreEqual(1, d1.Count);
            Assert.AreEqual(2, d2.Count);
            Assert.AreEqual("Employee", d2[new UserType(1, "a")]);
            Assert.AreEqual("Manager", d2[new UserType(2, "b")]);
            Assert.AreEqual("Looser", d1[new UserType(2, "b")]);
        }
        [TestMethod()]
        public void Concurrency_AddRemoveSearshByName_OkAndNoExceptions()
        {
            UserCollection<int, int, int> c = new UserCollection<int, int, int>();

            Parallel.For(0, 1000, (i) =>
            {
                try
                {
                    Tuple<int, int> k1 = new Tuple<int, int>(-1, i);
                    Tuple<int, int> k2 = new Tuple<int, int>(-2, i);
                    c.Add(k1, i);
                    c.Add(k2, i);
                    var d = c.SearchByName(i);
                    Assert.AreEqual(2, d.Count);
                    Assert.IsTrue(c.Remove(k1));
                    Assert.IsTrue(c.Remove(k2));
                    Assert.IsFalse(c.ContainsKey(k1));
                    Assert.IsFalse(c.ContainsKey(k2));
                }
                catch (Exception e)
                {
                    Assert.Fail(e.Message);
                }
            });
            Assert.AreEqual(0, c.Count);
        }
    }
}