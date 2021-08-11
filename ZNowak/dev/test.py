import timeit

# py = timeit.timeit('''slow.filter_texts(nlp, texts)''', 
#                    setup=
# """
# import spacy, slow
# nlp = spacy.load("en_core_web_sm")
# texts = ["Boy likes to run","Girl was happy"]
# """, number=1000)

# cy = timeit.timeit('''slower.filter_texts(nlp, texts)''', 
#                    setup=
# """
# import spacy, slower
# nlp = spacy.load("en_core_web_sm")
# texts = ["Boy likes to run","Girl was happy"]
# """, number=1000)




code1 = '''experiment.filter_texts1(nlp, texts)'''
code2= '''experiment.filter_texts2(nlp, texts)'''
code3 = '''experiment.filter_texts3(nlp, texts)'''
code4 = '''experiment.filter_texts4(nlp, texts)'''

up1 = """
import spacy, experiment
nlp = spacy.load("en_core_web_sm")
texts = ["Boy likes to run","Girl was happy"]
"""
up2 = """
import spacy, experiment
nlp = spacy.load("en_core_web_lg")
texts = ["Boy likes to run","Girl was happy"]
"""

# py11 = timeit.timeit(code1, setup=up1, number=100)
# py21 = timeit.timeit(code2, setup=up1, number=100)
# py31 = timeit.timeit(code3, setup=up1, number=100)
# py41 = timeit.timeit(code4, setup=up1, number=100)
# py12 = timeit.timeit(code1, setup=up2, number=100)
# py22 = timeit.timeit(code2, setup=up2, number=100)
# py32 = timeit.timeit(code3, setup=up2, number=100)
# py42 = timeit.timeit(code4, setup=up2, number=100)


# print(py11, py21, py31, py41, py12, py22, py32, py42)

pysm = timeit.timeit(code1, setup=up1, number=1000)
pylg = timeit.timeit(code1, setup=up2, number=1000)

print(pysm, pylg)