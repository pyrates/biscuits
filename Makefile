compile:
	cython -3 biscuits.pyx
	python setup.py build_ext --inplace

test:
	py.test -v

release: compile test
	rm -rf dist/ build/ *.egg-info
	python setup.py sdist upload
