build_inplace:
	python3 setup.py build_ext --inplace

build_dist:
	python3 -m build

clean:
	rm -rf build/
	rm -rf dist/
	rm -rf tenforce.egg-info/
	rm -f tenforce/*.c
	rm -f tenforce/*.so
	rm -f tenforce/*.dll

upload:
	python3 -m twine --no-color upload -u ${PYPI_USERNAME} -p ${PYPI_PASSWORD} --non-interactive --disable-progress-bar dist/*