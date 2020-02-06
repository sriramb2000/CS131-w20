// This is a dummy implementation, useful for
// deducing the overhead of the testing framework.
class NullState implements State {
    private long[] value;
    NullState(int length) { value = new long[length]; }
    public int size() { return value.length; }
    public long[] current() { return value; }
    public void swap(int i, int j) { }
    public long sum() {
	long osum = 0;
	for (int i = 0; i < value.length; ++i)
	    osum += value[i];
	return osum;
    }
}
