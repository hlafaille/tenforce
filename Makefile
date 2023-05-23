build:
	python3 -m build

clean:
	rm -rf build/
	rm -rf dist/
	rm -f tenforce/*.c
	rm -f tenforce/*.so
	rm -f tenforce/*.dll