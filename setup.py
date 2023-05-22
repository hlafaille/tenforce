from distutils.core import setup
from Cython.Build import cythonize

setup(
    name='Tenforce',
    ext_modules=cythonize(["tenforce/parser.pyx", "tenforce/enforcer.pyx"])
)
