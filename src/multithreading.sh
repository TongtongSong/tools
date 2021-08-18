#!/bin/bash
nj=10
input_file=$1
#wav_scp=$2

_cp(){
    local input=$1
    for x in `cat $input`;do
        dir=`dirname $x|sed 's|bird_voice_recognition-seg|bird_voice_recognition-seg-syn|'`
        [ ! -d $dir ] && mkdir -p $dir
        cp $x $dir
        echo finish $x
    done
}

tmpdir=$(mktemp -d tmp-XXXXX)

split --additional-suffix .slice -d -n l/$nj $input_file $tmpdir/tmp_

for slice in `ls $tmpdir/tmp_*.slice`; do
{
  . tools/synthesis.sh $slice
#  _cp $slice
}&
done
wait

rm -r $tmpdir
echo "finish"
