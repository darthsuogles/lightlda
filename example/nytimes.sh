#!/bin/bash

_script_dir_="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root=${_script_dir_}
echo $root
bin=$root/../bin
#dir=$root/data/nytimes
dir=${HOME}/local/data/nytimes

(mkdir -p $dir && cd $_

 # 1. Download the data
 if [ ! -f docword.nytimes.txt ]; then
     wget https://archive.ics.uci.edu/ml/machine-learning-databases/bag-of-words/docword.nytimes.txt.gz     
     gunzip docword.nytimes.txt.gz
 fi
 [ -f vocab.nytimes.txt ] || \
     wget https://archive.ics.uci.edu/ml/machine-learning-databases/bag-of-words/vocab.nytimes.txt

 set -ex
 # 2. UCI format to libsvm format
 python3 $root/text2libsvm.py \
         $dir/docword.nytimes.txt \
         $dir/vocab.nytimes.txt \
         $dir/nytimes.libsvm \
         $dir/nytimes.word_id.dict

 # 3. libsvm format to binary format
 $bin/dump_binary $dir/nytimes.libsvm $dir/nytimes.word_id.dict $dir 0

 # 4. Run LightLDA 
 LD_LIBRARY_PATH=${_script_dir_}/../multiverso/third_party/lib $bin/lightlda \
     -num_vocabs 111400 \
     -num_topics 1000 \
     -num_iterations 100 \
     -alpha 0.1 \
     -beta 0.01 \
     -mh_steps 2 \
     -num_local_workers 1 \
     -num_blocks 1 \
     -max_num_document 300000 \
     -input_dir $dir \
     -data_capacity 800
)
