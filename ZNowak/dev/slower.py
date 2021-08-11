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

    """
    res = []
    for text in texts:
        doc = nlp(text)
        res.append([(token.text, token.pos_) for token in doc if token.pos_ == "NOUN"])
    return res

