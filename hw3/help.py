import sys

OUTPUT_FILE = "data.csv"

if(len(sys.argv) == 2):
    OUTPUT_FILE = sys.argv[1]
elif (len(sys.argv) > 2):
    print("Usage: python help.py [Filename]")
    exit()

classes = ["Synchronized", "Unsynchronized", "AcmeSafe"]
states = [5, 50, 100]
threads = [1, 8, 20, 40]

print("echo \"Type, State, #Threads, Swap Avg Real (ns), Swap Avg CPU (ns), Mismatch\" > " + OUTPUT_FILE)

for c in classes:
    for s in states:
        for t in threads:
            tmp = c + ", " + str(s) + ", " + str(t) + ", "
            print("echo -n \"" + tmp + "\" >> " + OUTPUT_FILE)
            print("time timeout 3600 java UnsafeMemoryTest "+ c + " " + str(t) + " 100000000 " + str(s) + " | awk 'NR==2' >> " + OUTPUT_FILE)
        
