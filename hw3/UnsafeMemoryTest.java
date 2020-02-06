import java.lang.management.ManagementFactory;

class UnsafeMemoryTest {
    public static void main(String args[]) {
	if (args.length != 4)
	    usage(null);
	try {
	    var nThreads = (int) argInt (args[1], 1, Integer.MAX_VALUE);
	    var nTransitions = argInt (args[2], 0, Long.MAX_VALUE);
	    var nValues = (int) argInt (args[3], 0, Integer.MAX_VALUE);
	    State s;
	    if (args[0].equals("Null"))
		s = new NullState(nValues);
	    else if (args[0].equals("Synchronized"))
		s = new SynchronizedState(nValues);
	    else if (args[0].equals("Unsynchronized"))
	    	s = new UnsynchronizedState(nValues);
	    else if (args[0].equals("AcmeSafe"))
	    	s = new AcmeSafeState(nValues);
	    else
		throw new Exception(args[0]);
	    double[] avgs = dowork(nThreads, nTransitions, s);
	    test(s, avgs);
	    System.exit (0);
	} catch (Exception e) {
	    usage(e);
	}
    }

    private static void usage(Exception e) {
	if (e != null)
	    System.err.println(e);
	System.err.println("Usage: model nthreads ntransitions nvalues\n");
	System.exit (1);
    }

    private static long argInt(String s, long min, long max) {
	var n = Long.parseLong(s);
	if (min <= n && n <= max)
	    return n;
	throw new NumberFormatException(s);
    }

    private static double[] dowork(int nThreads, long nTransitions, State s)
      throws InterruptedException {
	var test = new SwapTest[nThreads];
	var t = new Thread[nThreads];
	var bean = ManagementFactory.getThreadMXBean();
	bean.setThreadCpuTimeEnabled(true);
	for (var i = 0; i < nThreads; i++) {
	    var threadTransitions =
		(nTransitions / nThreads
		 + (i < nTransitions % nThreads ? 1 : 0));
	    test[i] = new SwapTest (threadTransitions, s, bean);
	    t[i] = new Thread (test[i]);
	}
	var realtimeStart = System.nanoTime();
	for (var i = 0; i < nThreads; i++)
	    t[i].start ();
	for (var i = 0; i < nThreads; i++)
	    t[i].join ();
	var realtimeEnd = System.nanoTime();
	long realtime = realtimeEnd - realtimeStart, cputime = 0;
	for (var i = 0; i < nThreads; i++)
	    cputime += test[i].cpuTime();
	double dTransitions = nTransitions;
	System.out.format("Total time %g s real, %g s CPU\n",
			  realtime / 1e9, cputime / 1e9);
	//	System.out.format("Average swap time %g ns real, %g ns CPU\n",
	// System.out.format("%g, %g\n",
	// 		  realtime / dTransitions * nThreads,
	// 		  cputime / dTransitions);
	double[] avgs = {realtime / dTransitions * nThreads, cputime / dTransitions};
	return avgs;
    }

    private static void test(State output, double[] avgs) {
	long osum = output.sum();
	System.out.format("%g, %g, %d\n",
			  avgs[0],
			  avgs[1],
			  osum);
    }

    private static void error(String s, long i, long j) {
	System.err.format("%s (%d != %d)\n", s, i, j);
	System.exit(1);
    }
}
