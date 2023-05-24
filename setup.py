from distutils.core import setup
from Cython.Build import cythonize

setup(
    name='tenforce',
    ext_modules=cythonize(
        ["tenforce/lib/autocast.pyx", "tenforce/lib/members.pyx", "tenforce/lib/parser.pyx", "tenforce/enforcer.pyx"]),
    package_data={
        "tenforce": ["py.typed", "enforcer.pyi"]
    }
)
