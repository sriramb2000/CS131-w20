class UnsynchronizedState implements State {
    private long[] value;

    UnsynchronizedState(int length) { value = new long[length]; }

    public int size() { return value.length; }

    public long[] current() { return value; }

    public void swap(int i, int j) {
	value[i]--;
	value[j]++;
    }

    public long sum() {
	long osum = 0;
	for (int i = 0; i < value.length; ++i)
	    osum += value[i];
	return osum;
    }
    
}
