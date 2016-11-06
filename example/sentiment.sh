#!/bin/bash

_script_dir_="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root=${_script_dir_}
echo $root
bin=$root/../bin
dir=${HOME}/local/data/sentiment

(mkdir -p $dir && cd $_

 cp -f /mapr/mapr-dev/home/philip/semi_sup_hack/sentiment.docword ${dir}/.
 cp -f /mapr/mapr-dev/home/philip/semi_sup_hack/sentiment.vocab ${dir}/.

 set -ex

 # 2. UCI format to libsvm format
 [ -f $dir/sentiment.word_id.dict ] || (
     python3 $root/text2libsvm.py \
             $dir/sentiment.train.docword \
             $dir/sentiment.train.vocab \
             $dir/sentiment.libsvm \
             $dir/sentiment.word_id.dict
     
     # 3. libsvm format to binary format
     $bin/dump_binary $dir/sentiment.libsvm $dir/sentiment.word_id.dict $dir 0
 )

 # 4. Run LightLDA 
 #LD_LIBRARY_PATH=${_script_dir_}/../multiverso/third_party/lib 
 module load openmpi
 export LD_LIBRARY_PATH=${OPENMPI_ROOT}/lib:${ZMQ_ROOT}/lib
 $bin/lightlda \
     -num_vocabs 35243 \
     -num_topics 1000 \
     -num_iterations 3000 \
     -alpha 0.1 \
     -beta 0.01 \
     -mh_steps 2 \
     -num_local_workers 8 \
     -num_blocks 1 \
     -max_num_document 300000 \
     -input_dir $dir \
     -data_capacity 800
)
