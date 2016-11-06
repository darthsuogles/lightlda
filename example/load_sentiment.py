import pandas as pd
from pathlib import Path
from collections import Counter

mapr_path_base = Path("/mapr/mapr-dev/home/philip/semi_sup_hack")
dataset_path = mapr_path_base / 'all.blosck.msgpack'
df = pd.read_msgpack(str(dataset_path))

tok_cntr = Counter()
toks_cols = [col for col in df.columns if col.startswith("tok")]
for _, elems in df.iterrows():
    for col in toks_cols:
        tok_cntr.update(elems[col])

idx2tok = dict(enumerate([tok for tok, freq in tok_cntr.items() if freq > 23]))
tok2idx = dict(zip(tok2idx.values(), tok2idx.keys()))
#print(tok_cntr.most_common(100))

with (mapr_path_base / 'sentiment.vocab').open('w') as fout:
    fout.write('\n'.join(tok2idx.values()))

with (mapr_path_base / 'sentiment.docword').open('w') as fout:
    doc_idx = 0
    for _, elems in df.iterrows():
        for col in toks_cols:
            doc_idx += 1
            _cntr = Counter(elems[col])
            tok_freq_list = sorted([(tok2idx[tok], freq) 
                                    for tok, freq in _cntr.items()
                                    if tok in tok2idx])
            for tok_idx, freq in tok_freq_list:
                fout.write("{} {} {}\n".format(doc_idx, tok_idx, freq))
