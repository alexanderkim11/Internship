import cor2np
import os
from glob import glob
nouns = cor2np.read_lines()
cwd = os.getcwd()
files = glob(cwd + "\\scripts\\*.txt")
files = ["scripts\\"+os.path.basename(x) for x in files]

files = [bytes(file, 'utf-8') for file in files]
filenames = files[:3]
print(filenames)

mat = cor2np.corpus_to_array(filenames, nouns)
print(mat)