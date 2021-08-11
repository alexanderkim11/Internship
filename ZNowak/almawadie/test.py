import tools
import os
from glob import glob

nouns = tools.read_lines()
cwd = os.getcwd()
files = glob(cwd + "\\scripts\\*.txt")
files = ["scripts\\"+os.path.basename(x) for x in files]

files = [bytes(file, 'utf-8') for file in files]
filenames = files[:5]
print(filenames)

#mat = tools.corpus_to_array(filenames, nouns)
#print(mat)

lst = tools.doc_to_list(filenames, nouns)
print(lst)