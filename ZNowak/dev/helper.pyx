# cython: infer_types=True
# distutils: language = c++
# cython: language_level=3
from __future__ import print_function
cimport cython
from cpython cimport array
import array


# Cython memory pool for memory management
from cymem.cymem cimport Pool

# C string management
from libc.string cimport memcpy           # C string copy function
from libc.stdint cimport uint32_t         # C unsigned 32-bit integer type

# Cython Hash table and fast counter
from preshed.maps cimport PreshMap        # Hash table
from preshed.counter cimport count_t      # Count type (equivalent to C int64_t)
from preshed.counter cimport PreshCounter # Fast counter

# spaCy C functions and types
from spacy.strings cimport hash_utf8      # Hash function (using MurmurHash2)
from spacy.typedefs cimport hash_t        # Hash type (equivalent to C uint64_t)
from spacy.strings cimport Utf8Str        # C char array/pointer
from spacy.strings cimport decode_Utf8Str # C char array/pointer to Python string function

from libc.stdio cimport FILE, fopen, fseek, fclose, SEEK_END, SEEK_SET, ftell, fread
from libc.stdlib cimport malloc, free, calloc
import string

import numpy as np
cimport numpy as np

def read_file(filename):
    cdef FILE* txt                  # File of interest */
    cdef char* contents
    # Open the file
    p = fopen(filename, "r")
    # get the length of the file
    fseek(p, 0, SEEK_END)
    file_size = ftell(p)
    fseek(p, 0, SEEK_SET)
    # allocate memory for reading in the file
    contents = <char*>malloc(file_size*sizeof(char))
    if contents is NULL:
        print("NULL\n")
        return []
    # read entire file into the struct
    fread(contents, 1, file_size, p)
    # close the file once it's read into the char array
    fclose(p)
    temp = <bytes>contents
    free(contents)
    punc = string.punctuation.encode()
    temp = temp.translate(None, punc)
    return temp.lower().split()

cdef PreshMap hashmap = PreshMap(initial_size=1024) #Larger
cdef PreshMap nounmap = PreshMap(initial_size=1024) #Larger
cdef int num_files = 0


cdef void _insert_in_hashmap(char* utf8_string, int length, int file_id):
    cdef hash_t key = hash_utf8(utf8_string, length)
    cdef Utf8Str* temp = <Utf8Str*>nounmap.get(key)
    cdef int* value
    if temp is not NULL:
        value = <int*>hashmap.get(key)
        if value is not NULL: # Update
            value[file_id] += 1
            return
        value = <int*> calloc(num_files, sizeof(int))
        if value is NULL:
            print("NULL\n")
            return
        value[file_id] = 1
        hashmap.set(key, value)

cdef void _insert_in_nounmap(char* utf8_string, int length):
    cdef hash_t key = hash_utf8(utf8_string, length)
    cdef Utf8Str* value = <Utf8Str*>nounmap.get(key)
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
    
def corpus_to_array(list filenames, list nouns):
    cdef:
        hash_t wordhash
        int i, j, freq
        list bow
    
    # Create the nounhash
    num_files = len(filenames)
    for noun in nouns:
        _insert_in_nounmap(noun.lower(), len(noun))

    
    for i in range(num_files):
        # Open the file
        words = read_file(filenames[i])
        # Convert to a list of words
        print(filenames[i])
        for word in words:
            _insert_in_hashmap(word.lower(), len(word), i) 
            # Give the word and the file number
        


    #Create Numpy Matrix
    """
    cdef np.ndarray[np.int_t, ndim=2] h = np.zeros([num_files, len(hashmap)], dtype=GET_SIGNED_NUMPY_TYPE())
    # HAVE TO FIX THIS


    cdef int* value
    for i, key in enumerate(hashmap.keys()):

        value = <int*>hashmap.get(key)
        for j in range(num_files):
            h[j,i] = value[j]
            #print(get_unicode(key), value[j])
            value[j] = 0 # "Frees the memory"
        #print(get_unicode(key),res)
    return h

    """
    