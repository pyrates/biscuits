compile:
	cython -3 biscuits.pyx
	python setup.py build_ext --inplace
develop:
	pip install -e .
test:
	py.test -v

release: compile test
	rm -rf dist/ build/ *.egg-info
	python setup.py sdist
	twine upload dist/*
