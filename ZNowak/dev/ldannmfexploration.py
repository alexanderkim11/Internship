# -*- coding: utf-8 -*-
"""
Created on Fri Jul 30 17:38:28 2021

@author: znowak
"""


import spacy
import gensim


from sklearn.feature_extraction.text import TfidfVectorizer, CountVectorizer
from sklearn.decomposition import NMF, LatentDirichletAllocation

from gensim import models
from gensim.utils import simple_preprocess
from gensim import corpora
import numpy as np

documents = ["The Saudis are preparing a report that will acknowledge that", 
             "Saudi journalist Jamal Khashoggi's death was the result of an", 
             "interrogation that went wrong, one that was intended to lead", 
             "to his abduction from Turkey, according to two sources."]




# Create the Dictionary and Corpus
mydict = corpora.Dictionary([simple_preprocess(line) for line in documents])
corpus = [mydict.doc2bow(simple_preprocess(line)) for line in documents]

# Show the Word Weights in Corpus
#for doc in corpus:
#    print([[mydict[id], freq] for id, freq in doc])

# [['first', 1], ['is', 1], ['line', 1], ['the', 1], ['this', 1]]
# [['is', 1], ['the', 1], ['this', 1], ['second', 1], ['sentence', 1]]
# [['this', 1], ['document', 1], ['third', 1]]

# Create the TF-IDF model
tfidf_vectorizer = TfidfVectorizer(max_features=1000,
                                   stop_words='english',
                                   smooth_idf=True)

tfidf_sci = tfidf_vectorizer.fit_transform(documents)
tfidf_gen = models.TfidfModel(corpus, smartirs='tfc')




# Show the TF-IDF weights
for doc in tfidf_gen[corpus]:
    print([[mydict[id], np.around(freq, decimals=2)] for id, freq in doc])
   
    
   
print("SciKit Learn")
feature_names = tfidf_vectorizer.get_feature_names()
print(feature_names)
print(list(tfidf_sci.toarray())) 
sneakysneak = np.array(
 [[0. , 0. , 0.5, 0. , 0. , 0. , 0. , 0. , 0. , 0. , 0.5, 0.5, 0. , 0. , 0.5, 0. , 0. , 0. , 0. ], 
  [0. , 0. , 0. , 0.40824829, 0. ,0. , 0.40824829, 0.40824829, 0.40824829, 0., 0.        , 0.        , 0.40824829, 0.40824829, 0., 0.        , 0.        , 0.        , 0.        ], 
  [0.       , 0.       , 0.       , 0.       , 0.4472136, 0.4472136, 0.   , 0.       , 0.       , 0.4472136, 0.       , 0.       ,0.       , 0.       , 0.       , 0.       , 0.       , 0.4472136, 0.4472136], 
  [0.5, 0.5, 0. , 0. , 0. , 0. , 0. , 0. , 0. , 0. , 0. , 0. , 0. , 0. , 0. , 0.5, 0.5, 0. , 0. ]]   
 )


for idx in range(len(documents)):
    doc = idx
    feature_index = tfidf_sci[doc,:].nonzero()[1]
    tfidf_scores = zip(feature_index, [tfidf_sci[doc, x] for x in feature_index])
    print(idx)
    for w, s in [(feature_names[i], s) for (i, s) in tfidf_scores]:
        print(w, s)
        
from time import time
import matplotlib.pyplot as plt
def plot_top_words(model, feature_names, n_top_words, title):
    fig, axes = plt.subplots(2, 5, figsize=(30, 15), sharex=True)
    axes = axes.flatten()
    for topic_idx, topic in enumerate(model.components_):
        top_features_ind = topic.argsort()[:-n_top_words - 1:-1]
        top_features = [feature_names[i] for i in top_features_ind]
        weights = topic[top_features_ind]

        ax = axes[topic_idx]
        ax.barh(top_features, weights, height=0.7)
        ax.set_title(f'Topic {topic_idx +1}',
                     fontdict={'fontsize': 30})
        ax.invert_yaxis()
        ax.tick_params(axis='both', which='major', labelsize=20)
        for i in 'top right left'.split():
            ax.spines[i].set_visible(False)
        fig.suptitle(title, fontsize=40)

    plt.subplots_adjust(top=0.90, bottom=0.05, wspace=0.90, hspace=0.3)
    plt.show()

t0 = time()
nmf = NMF(n_components=5, random_state=1,
          alpha=.1, l1_ratio=.5).fit(sneakysneak)
print("done in %0.3fs." % (time() - t0))


tfidf_feature_names = tfidf_vectorizer.get_feature_names()
plot_top_words(nmf, tfidf_feature_names, 3,
               'Topics in NMF model (Frobenius norm)')