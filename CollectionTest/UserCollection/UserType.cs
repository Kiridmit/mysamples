
namespace UserCollectionLib
{
    /// <summary>
    /// Пользовательский тип, для использования в качестве части ключа
    /// </summary>
    public class UserType
    {
        public int id1;
        public string id2;

        public UserType(int id1, string id2)
        {
            this.id1 = id1;
            this.id2 = id2;
        }

        public override int GetHashCode()
        {
            return id1.GetHashCode() & id2.GetHashCode();
        }

        public override bool Equals(object o)
        {
            if (o is UserType)
            {
                UserType obj = (UserType)o;
                return id1 == obj.id1 && id2 == obj.id2;
            }
            else return false;
        }
    }
}
