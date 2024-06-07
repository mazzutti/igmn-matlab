namespace ModelSRP
{
    public class Ref<T> where T : struct
    {
        public Ref() { }
        public Ref(T val) => value = val;
        public T value;
    }
}
