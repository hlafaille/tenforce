from distutils.core import setup
from Cython.Build import cythonize

setup(
    name='tenforce',
    ext_modules=cythonize(["tenforce/enforcer.pyx", "tenforce/members.pxd", "tenforce/parser.pxd", "tenforce/autocast.pxd"]),
    package_data={
        "tenforce": ["py.typed", "enforcer.pyi"]
    }
)
