# encoding=utf-8
import re
import sys

text_in = sys.argv[1]

def remove_puncts(file, punctuations_to_keep=["'"]):
    
    #punctuations = ["·","ɣ","ɸ","θ","μ","—","/",":"]
    punctuations = []
    with open(file, 'r', encoding='utf-8') as f:
        for line in f.readlines():
            line = line.strip()
            uttid = line.split(' ')[0]
            text = ' '.join(line.split(' ')[1:]) #1
            res = re.findall(r'[^A-Za-z0-9\u4e00-\u9fa5\s]', text)
            punctuations += res

    punctuations = set(punctuations)
    for p in punctuations_to_keep:
        # punctuations.remove('\'')  
        if p in punctuations:
            punctuations.remove(p)    
            punctuations = list(punctuations)


    punctuations = ''.join(punctuations).replace(']', '\]').replace('[', '\[').replace('-', '\-')
    punctuations = '[' + punctuations + ']'
    #print(punctuations)
    
    with open(file, 'r', encoding='utf-8') as f:
        for line in f.readlines():
            line = line.strip()
            uttid = line.split(' ')[0]
            line = line.lower()
            # print('uttid:',uttid)
            text = ' '.join(line.split(' ')[1:])
            
            # print('text1:',text)
            if punctuations!="[]":
               text = re.sub(punctuations, ' ', text)
            # print('text0:',text)
            text = re.sub(r'\s{2,}', ' ', uttid + ' ' + text)

            text = re.sub(r'\s$', '', text)
            # print('text2:',text)
            print(text)
    
remove_puncts(text_in)