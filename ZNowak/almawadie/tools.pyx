# cython: infer_types=True
# distutils: language = c++
# cython: language_level=3


from __future__ import print_function
cimport cython

# Cython memory pool for memory management
from cymem.cymem cimport Pool

# C string management
from libc.string cimport memcpy           # C string copy function
from libc.stdint cimport uint32_t         # C unsigned 32-bit integer type
import string
from libc.string cimport strlen

# Cython Hash table and fast counter
from preshed.maps cimport PreshMap        # Hash table
from preshed.counter cimport count_t      # Count type (equivalent to C int64_t)
from preshed.counter cimport PreshCounter # Fast counter

# spaCy C functions and types
from spacy.strings cimport hash_utf8      # Hash function (using MurmurHash2)
from spacy.typedefs cimport hash_t        # Hash type (equivalent to C uint64_t)
from spacy.strings cimport Utf8Str        # C char array/pointer
from spacy.strings cimport decode_Utf8Str # C char array/pointer to Python string function

# file management
from libc.stdio cimport FILE, SEEK_END, SEEK_SET    # C constants for file
from libc.stdio cimport fclose, fopen, fread        # C function to open and read file
from libc.stdio cimport ftell, fgets, fseek         # C function to iterate over lines

# array management
from libc.stdlib cimport malloc, free, calloc       # Memory to create arrays (used for C int*)
import numpy as np                                  # Python array
cimport numpy as np                                 # Python array type in Cython



def read_lines():
    cdef:
        int    i                   # Loop counter
        char   line[100]           # Buffer to read each line
        int    line_count          # Total number of lines
        int    line_length         # Length of a single line
        FILE* txt                  # File of interest
        
    # Open the file
    txt = fopen("en-lexicon.txt", "r")
    
    # Clear output parameter
    arr = []
    
    # Get the count of lines in the file
    line_count = 94258


    # Read each line from file and deep-copy in the array.
    for i in range(line_count):
        # Read the current line.
        fgets(line, sizeof(line), txt);
        line_length = strlen(line)
        if line[line_length-3] == b'N':     # line has the form "ALUMINUM NNP" or "AREA NN"
            if line[line_length-4] != b' ':
                temp = line[:line_length-5]
                arr.append(temp)
            #if line[line_length-4] == b' ':  # line has the form "ALUMINUM NNP"
            #    temp = line[:line_length-4]
            #    arr.append(temp)
            #else:                           # line has the form "AREA NN"
            #    temp = line[:line_length-5]
            #    arr.append(temp)
        
    fclose(txt)
    return arr
	
def read_file(filename):
    cdef:
        FILE* txt                   # File of interest
        char* contents              # Buffer to read the file into

    # Open the file
    p = fopen(filename, "r")
    
    # get the length of the file
    fseek(p, 0, SEEK_END)
    file_size = ftell(p)
    fseek(p, 0, SEEK_SET)
    
    # allocate memory for reading in the file
    contents = <char*>malloc(file_size*sizeof(char))
    if contents is NULL:
        return []
    
    # read entire file into the struct
    fread(contents, 1, file_size, p)
    # close the file once it's read into the char array
    fclose(p)
    
    # convert to a Python string list object
    temp = <bytes>contents
    free(contents)
    punc = string.punctuation.encode()  # Encode the punctuation into bytes (as opposed to latin)
    temp = temp.translate(None, punc)   # Remove the punctuation from file string
    return temp.lower().split()         # Return a list of segmented lowercased words


cdef PreshMap inverted_index = PreshMap(initial_size=1024) 
# What is the inverted index?
# It is a mapping from the hashed words to an array corresponding to
# a document area where the term frequency is stored
# Ex:
# str1 = "Hello Zach, Hello Alex"
# str2 = "Zach is happy"
# inverted_index =  <hash>     str1     str2
#                   "Hello"  [  2    ,   0   ]
#                   "Zach"   [  1    ,   1   ]
#                   "Alex"   [  1    ,   0   ]
#                   "is"     [  0    ,   1   ]
#                   "happy"  [  0    ,   1   ]

cdef PreshMap nounmap = PreshMap(initial_size=1024)
# What is the nounmap?
# It is the mapping of the hashed string to the char* string
# Ex:
# nouns = ["cat", "car", "craddle"]
# nounmap =  <actual hash>    word
#              1234         "cat"
#              5678         "car"
#              9012         "craddle"



cdef void _insert_in_inverted_index(char* utf8_string, int length, int file_id, int num_files):
    cdef:
        hash_t key          # hashed string value
        Utf8Str* temp       # variable to determine if string is a noun
        int* value          # an array to store all term frequency per document
                            # (a list could've been used but PreshMap required the type be void *)
    
    key = hash_utf8(utf8_string, length)
    temp = <Utf8Str*>nounmap.get(key)
    if temp is not NULL: 
        value = <int*>inverted_index.get(key)
        if value is not NULL: # Update
            value[file_id] = value[file_id] + 1 #increment that files frequency for that term
            return
            
        value = <int*> calloc(num_files, sizeof(int))
        if value is NULL:
            return
        value[file_id] = 1 # initialize that files frequency for that term
        inverted_index.set(key, value)

cdef void _insert_in_nounmap(char* utf8_string, int length):
    cdef:
        hash_t key      #hashed string value
        Utf8Str* value  #variable to store the string
        
    key = hash_utf8(utf8_string, length)
    value = <Utf8Str*>nounmap.get(key)
    if value is not NULL:
        return
    value = _allocate(nounmap.mem, <unsigned char*>utf8_string, length)
    nounmap.set(key, value)

cdef Utf8Str* _allocate(Pool mem, const unsigned char* chars, uint32_t length) except *:
    cdef:
        int n_length_bytes
        int i
        Utf8Str* string = <Utf8Str*>mem.alloc(1, sizeof(Utf8Str))
        uint32_t ulength = length

    if length < sizeof(string.s):
        string.s[0] = <unsigned char>length
        memcpy(&string.s[1], chars, length)
        return string
    elif length < 255:
        string.p = <unsigned char*>mem.alloc(length + 1, sizeof(unsigned char))
        string.p[0] = length
        memcpy(&string.p[1], chars, length)
        return string
    else:
        i = 0
        n_length_bytes = (length // 255) + 1
        string.p = <unsigned char*>mem.alloc(length + n_length_bytes, sizeof(unsigned char))
        for i in range(n_length_bytes-1):
            string.p[i] = 255
        string.p[n_length_bytes-1] = length % 255
        memcpy(&string.p[n_length_bytes], chars, length)
    return string

cdef unicode get_unicode(hash_t wordhash):
    utf8str = <Utf8Str*>nounmap.get(wordhash)
    if utf8str is NULL:
        raise KeyError(f'{wordhash} not in hash table')
    else:
        return decode_Utf8Str(utf8str)

def GET_SIGNED_NUMPY_TYPE():
    cdef int tmp
    return np.asarray(<int[:1]>(&tmp)).dtype    
    
def doc_to_list(list filenames, list nouns):
    cdef:

        int i, j, k, num_files
        list res
        hash_t key          # hashed string value
        Utf8Str* temp       # variable to determine if string is a noun
    

    # Populate the nounhash
    num_files = len(filenames)
    for k in range(len(nouns)):
        noun = nouns[k]
        _insert_in_nounmap(noun.lower(), len(noun))

    # Populate the res list
    res = []
    for i in range(num_files):
        found_nouns = []
        # Open the file and convert to a list of words
        words = read_file(filenames[i])
        num_words = len(words)
        for j in range(num_words):
            word = words[j]
            key = hash_utf8(word, len(word))
            temp = <Utf8Str*>nounmap.get(key)
            if temp is not NULL: 
                found_nouns.append(word)
        res.append(found_nouns)
    return res
    
def corpus_to_array(list filenames, list nouns):
    cdef:
        hash_t wordhash
        int i, j, k, freq, num_files
        list bow
    
    # Populate the nounhash
    num_files = len(filenames)
    for k in range(len(nouns)):
        noun = nouns[k]
        _insert_in_nounmap(noun.lower(), len(noun))

    # Populate the inverted index
    for i in range(num_files):
        # Open the file and convert to a list of words
        words = read_file(filenames[i])
        for word in words:
            _insert_in_inverted_index(word.lower(), len(word), i, num_files)
        

    print("DONE")
    #Create Numpy Matrix
    cdef np.ndarray[np.int_t, ndim=2] h = np.zeros([num_files, len(inverted_index)], dtype=GET_SIGNED_NUMPY_TYPE())

    cdef int* value
    for i, key in enumerate(inverted_index.keys()):
        value = <int*>inverted_index.get(key)
        for j in range(num_files):
            h[j,i] = value[j]
            #print(get_unicode(key), value[j])
            value[j] = 0 # "Frees the memory"
        #print(get_unicode(key),res)
    print(h.shape[0],h.shape[1])
    return h

    
    