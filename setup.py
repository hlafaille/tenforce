from distutils.core import setup
from Cython.Build import cythonize

# todo add  "embedsignature.format" directive, set it to python when new Cython release comes out
setup(
    name='tenforce',
    ext_modules=cythonize(["tenforce/enforcer.pyx"])
)
