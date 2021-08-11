# -*- coding: utf-8 -*-
"""
Created on Fri Jul 30 19:54:04 2021

@author: znowak
"""
import time
import spacy
from spacy.matcher import Matcher
nlp = spacy.load("en_core_web_sm")
matcher = Matcher(nlp.vocab)
# Add match ID "GetNoun" with no callback and one pattern
pattern = [{"POS": "NOUN"}]
matcher.add("GetNoun", [pattern])


def filter_doc1(doc):
    return " ".join([token.text for token in doc if token.pos_ == "NOUN"])


def filter_doc2(doc):
    # x2 slower than filter_doc1
    matches = matcher(doc)
    res = ""
    for match_id, start, end in matches:
        #string_id = nlp.vocab.strings[match_id]  # Get string representation
        span = doc[start:end]  # The matched span
        res += span.text + " "
    return res
        
    
def filter_doc3(doc):
    # REQUIRES PIPELINE TO HAVE PARSER
    # x4 slower than filter_doc1 
    nouns = doc.noun_chunks
    return " ".join([noun.text for noun in nouns])


# main
nlp2 = spacy.load("en_core_web_sm")
import os
import glob
import glob
os.chdir("C:\\Users\\znowak\\Documents\\Projects\\testNLP")
current_movies = glob.glob("scripts/*.txt")
train_data = []

for filename in current_movies:
    with open(filename, "r") as f:
        train_data.append(f.read())
        f.close()
        
texts = train_data[:3]

def filter_texts1(nlp, texts):
    res = []
    t0 = time.time_ns()
    for doc in nlp.pipe(texts, disable=["ner", "lemmatizer","parser", "senter"]):
        res.append(filter_doc1(doc))
    print(time.time_ns() - t0)
    return res


#NLTK
import nltk
def filter_texts2(texts):
    res = []
    t0 = time.time_ns()
    for txt in texts:
        res.append([word for (word, pos) in nltk.pos_tag(nltk.word_tokenize(txt)) if pos[0] == 'N'])        
    print(time.time_ns() - t0)
    return res


def filter_texts3(texts):
    t0 = time.time_ns()
    res = [[word for (word, pos) in nltk.pos_tag(nltk.word_tokenize(txt)) if pos[0] == 'N'] for txt in texts]
    print(time.time_ns() - t0)
    return res


from pattern.en import parser
from pattern.text import find_keywords
def filter_texts4(texts):
    res = []
    t0 = time.time_ns()
    for txt in texts:
        v = find_keywords(txt, parser, top=10)
        res.append(v)
    print(time.time_ns() - t0)
    return res    
    
from nltk.corpus import stopwords
stop_words = stopwords.words('english')


filter_texts4(texts)

filter_texts1(nlp2, texts)
filter_texts2(texts)
filter_texts3(texts)
