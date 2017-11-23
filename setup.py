"""Fast and tasty cookies handling."""
from pathlib import Path
from setuptools import setup, Extension

with Path(__file__).parent.joinpath('README.md').open(encoding='utf-8') as f:
    long_description = f.read()

VERSION = (0, 1, 0)

setup(
    name='biscuits',
    version='.'.join(map(str, VERSION)),
    description=__doc__,
    long_description=long_description,
    author='Pyrates',
    author_email='yohan.boniface@data.gouv.fr',
    url='https://github.com/pyrates/biscuits',
    classifiers=[
        'License :: OSI Approved :: MIT License',
        'Intended Audience :: Developers',
        'Programming Language :: Python :: 3',
        'Operating System :: POSIX',
        'Operating System :: MacOS :: MacOS X',
        'Environment :: Web Environment',
        'Development Status :: 4 - Beta',
    ],
    platforms=['POSIX'],
    license='MIT',
    ext_modules=[
        Extension(
            'biscuits',
            ['biscuits.c'],
            extra_compile_args=['-O3']  # Max optimization when compiling.
        )
    ],
    provides=['biscuits'],
    include_package_data=True
)
