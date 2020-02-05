OUT=results.txt

default:
	javac *.java

build-tests: help.py
	python help.py $(OUT) > test.sh
	chmod +x test.sh

test: build-tests
	./test.sh

clean:
	rm -rf *~

dist:
	jar cvf jmmplus.jar *.java
