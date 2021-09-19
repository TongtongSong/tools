import argparse
import re
import sentencepiece as spm

def get_parser():
    parser = argparse.ArgumentParser(
        description='convert raw text to tokenized text',
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('--trans_type',
                        '-t',
                        type=str,
                        default="zh",
                        choices=["zh", "en", "cs"],
                        help="""Transcript type. 
                             zh: only Chinese dataset
                             en: only English dataset
                             cs: code-switch dataset, and use bpe to tokenize English words
                             """)
    parser.add_argument('--bpe_model',
                        '-b',
                        type=str,
                        default='',
                        help="""Bpe model to tokenize English words""")
    parser.add_argument('text',
                        type=str,
                        default=False,
                        nargs='?',
                        help='input text')

    return parser


def main():
    parser = get_parser()
    args = parser.parse_args()

    with open(args.text, 'r', encoding='utf-8') as f:
        for line in f.readlines():
            line = formatText(line)
            #print('format:',line)
            if args.trans_type == 'zh':
                print(line)
            elif args.trans_type == 'en':
                assert args.bpe_model != "", "please specify the bpe model"
                sp = spm.SentencePieceProcessor()
                sp.Load(args.bpe_model)
                uttid = line.split(' ')[0]
                content = ' '.join([w.lower() for w in line.split(' ')[1:]])
                res = ' '.join(sp.EncodeAsPieces(content))
                line = uttid + ' ' + res
                print(line)
            elif args.trans_type == 'cs':
                assert args.bpe_model != "", "please specify the bpe model"
                sp = spm.SentencePieceProcessor()
                sp.Load(args.bpe_model)
                uttid = line.split(' ')[0]
                new_line = uttid + ' '
                for w in line.split(' ')[1:]:
                    if not u'\u4e00' <= w <= u'\u9fa5':
                        w = w.lower()
                        w = ' '.join(sp.EncodeAsPieces(w)) 
                    new_line += (w + ' ')
                print(new_line.rstrip())



def formatText(line, has_uttid=True):
    line = line.strip()
    if has_uttid:
        uttid = line.split(' ')[0]
        text = ' '.join(line.split(' ')[1:])
    else:
        text = ' '.join(line.split(' ')[0:])
    pattern = re.compile(r'([\u4e00-\u9fa5])([a-zA-Z])')
    text, _ = pattern.subn(r'\1 \2', text)
    #print('text2:',text)
    pattern = re.compile(r'([\u4e00-\u9fa5])([\u4e00-\u9fa5])')
    text, _ = pattern.subn(r'\1 \2', text)
    pattern = re.compile(r'([\u4e00-\u9fa5])([\u4e00-\u9fa5])')
    text, _ = pattern.subn(r'\1 \2', text)
    pattern = re.compile(r'([a-zA-Z])([\u4e00-\u9fa5])')
    text, _ = pattern.subn(r'\1 \2', text)
    #print('text3:',text)
    text = re.sub(r'\s{2,}', ' ', text)
    if has_uttid:
        return uttid + ' ' + text
    return text


if __name__ == '__main__':
    main()
