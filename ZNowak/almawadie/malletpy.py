import subprocess
import os
current_dir = os.getcwd()

str3 = r"mallet-2.0.8\bin\mallet import-dir --input mallet-2.0.8\sample-data\web\en\ --output web.mallet --keep-sequence --remove-stopwords"
#subprocess.call(str3, shell=True, cwd=current_dir)
#mallet-2.0.8\bin\mallet train-topics --input web.mallet --num-topics 10 --output-topic-keys testing.txt --num-top-words 10 --output-doc-topics doctopics.txt

def mallet(num_topics, directory):
    str1 = f"mallet-2.0.8\\bin\\mallet import-dir --input {directory} --output web3.mallet --keep-sequence --remove-stopwords"
    print(str1)
    print(str3)
    str2 = f"mallet-2.0.8\\bin\\mallet train-topics --input web3.mallet --num-topics {num_topics} --output-topic-keys testing2.txt --num-top-words 20 --output-doc-topics doctopics2.txt"
    subprocess.call(str1, shell=True, cwd=current_dir)
    subprocess.call(str2, shell=True, cwd=current_dir)

mallet(10, r"scripts")