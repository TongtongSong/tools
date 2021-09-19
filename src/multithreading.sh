#!/bin/bash
nj=4
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

_flac_to_wav(){
  local input=$1

  for item in `cat $input`;do
  {
    wav_path=`echo $item|sed 's|.flac|.wav|'|sed 's|Share|songtongtong/data/corpus|'`
    echo $wav_path
    dir=`dirname $wav_path`
    [ ! -d $dir ] && mkdir -p $dir
    sox $item -t wav $wav_path
  }
  done
}
bpe_dir=/home/songtongtong/data/tools/src/text/bpe
_bpe(){
  local text_path_list=$1
  for x in `cat $text_path_list`;do
      if [[ $x == *backup* ]];then
          echo "$x pass"
      else
          echo "process $x"
          dir=`dirname $x`
          cat $x|cut -d ' ' -f1 > $dir/uttid
          cat $x|cut -d ' ' -f2- > $dir/text_only
          python2 $bpe_dir/apply_bpe.py -l en \
              -i $dir/text_only -o $dir/tmp -c $bpe_dir/model/en.5000.codes
          paste -d ' ' $dir/uttid $dir/tmp > $dir/text_bpe
          rm $dir/tmp $dir/uttid $dir/text_only
      fi
  done
}

tmpdir=$(mktemp -d tmp-XXXXX)

split --additional-suffix .slice -d -n l/$nj $input_file $tmpdir/tmp_

for slice in `ls $tmpdir/tmp_*.slice`; do
{
  _bpe $slice
#  . tools/synthesis.sh $slice
#  _cp $slice
#  _flac_to_wav $slice
}&
done
wait

rm -r $tmpdir
echo "finish"
