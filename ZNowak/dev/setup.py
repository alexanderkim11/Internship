from distutils.core import setup
from Cython.Build import cythonize
import numpy
setup(ext_modules = cythonize('helper.pyx', gdb_debug=True),
      include_dirs=[numpy.get_include()],
     )