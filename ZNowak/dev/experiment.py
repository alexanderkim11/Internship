# -*- coding: utf-8 -*-
"""
Created on Fri Jul 30 15:21:19 2021

@author: znowak
"""

def filter_texts(nlp, texts):
    """
    
    Parameters
    ----------
    nlp : spacy model
        ex: spacy.load("en_core_web_sm")
        
    texts : string list
        A list of documents in the form of strings

    Returns
    -------
    res : string list
        A list of documents with only their nouns remaing
        \, 

    """
    return None


def filter_texts1(nlp, texts):
    res = []
    for doc in nlp.pipe(texts, disable=["ner", "lemmatizer", "parser", "senter"]):
        # Do something with the doc here
        res.append([(token.text, token.pos_) for token in doc if token.pos_ == "NOUN"])
        #res.append([])
    return res


def filter_texts2(nlp, texts):
    res = []
    for doc in nlp.pipe(texts):
        # Do something with the doc here
        res.append([(token.text, token.pos_) for token in doc if token.pos_ == "NOUN"])
        #res.append([])
    return res


def filter_texts3(nlp, texts):
    res = []
    for text in texts:
        doc = nlp(text, disable=["ner", "lemmatizer", "parser", "senter"])
        # Do something with the doc here
        res.append([(token.text, token.pos_) for token in doc if token.pos_ == "NOUN"])
        #res.append([])
    return res


def filter_texts4(nlp, texts):
    res = []
    for text in texts:
        doc = nlp(text)
        # Do something with the doc here
        res.append([(token.text, token.pos_) for token in doc if token.pos_ == "NOUN"])
        #res.append([])
    return res
