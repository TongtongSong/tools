import re
import sys


#!/bin/env python
import sys
import re

if len(sys.argv) != 1:
    print >>sys.stderr,"%s < in > out"%(__file__)
    sys.exit(1)

for line in sys.stdin:
    # 中文的正则匹配式
    zh_patt = u'[\u4e00-\u9fa5]'
    # 英文的正则匹配式
    en_patt = u'[A-Za-z]'

    src_word_list = []
    for word in line.strip().split(' '):
        if re.findall(zh_patt, word):
            src_word_list.append(word)    
        elif re.findall(en_patt, word):
            src_word_list.append(word)
    if src_word_list:
        string = ' '.join(src_word_list)
        print (string)
