#
tools=/home/songtongtong/data/tools
cn_wav_scp=$1
cn_text=$2
en_wav_scp=$3
en_text=$4
SAMPLE_RATE=16000
TOTAL_NUM=2
SLIENCE_MIN=0.1
SLIENCE_MAX=0.5

ce_dst_text=new_data/ce/text
ce_dst_wavs_dir=new_data/ce/wavs
mkdir -p $ce_dst_wavs_dir

ec_dst_text=new_data/ec/text
ec_dst_wavs_dir=new_data/ec/wavs
mkdir -p $ec_dst_wavs_dir

cec_dst_text=new_data/cec/text
cec_dst_wavs_dir=new_data/cec/wavs
mkdir -p $cec_dst_wavs_dir

ece_dst_text=new_data/ece/text
ece_dst_wavs_dir=new_data/ece/wavs
mkdir -p $ece_dst_wavs_dir

cece_dst_text=new_data/cece/text
cece_dst_wavs_dir=new_data/cece/wavs
mkdir -p $cece_dst_wavs_dir

ecec_dst_text=new_data/ecec/text
ecec_dst_wavs_dir=new_data/ecec/wavs
mkdir -p $ecec_dst_wavs_dir

_process_audio(){
  local dst_path=$1
  local first_path=$2
  local second_path=$3
  local slience_time=$4
  local tmp_dir=$5

  audio_type=$(echo $first_path|awk -F'.' '{print($NF)}')
  if [ "$audio_type" == "flac" ]; then
      tmp_wav=$tmp_dir/${first_uttid}.wav
      sox $first_path -t wav $tmp_wav
      first_path=$tmp_wav
  fi

  audio_type=$(echo $second_path|awk -F'.' '{print($NF)}')
  if [ "$audio_type" == "flac" ]; then
      tmp_wav=$tmp_dir/${second_uttid}.wav
      sox $second_path -t wav $tmp_wav
      second_path=$tmp_wav
  fi

  first_vol=$(python $tools/src/audio/vol/get_vol.py  $first_path)
  second_vol=$(python $tools/src/audio/vol/get_vol.py  $second_path)

  flag=$(echo "$first_vol > $second_vol"|bc)
  if [ $flag == 1 ];then
      new_first_path=$(echo $tmp_dir/${RANDOM}.wav)
      python $tools/src/audio/vol/adjust_vol.py $first_path $new_first_path $second_vol
      first_path=$new_first_path
  else
      new_second_path=$(echo $tmp_dir/${RANDOM}.wav)
      python $tools/src/audio/vol/adjust_vol.py $second_path $new_second_path $first_vol
      second_path=$new_second_path
  fi

  # make slience wav
  slience_wav=$tmp_dir/${RANDOM}.wav
  sox -n -r $SAMPLE_RATE $slience_wav trim 0.0 $slience_time

  # paste wav
  temp_wav=$(echo $tmp_dir/${RANDOM}.wav)
  sox $first_path $slience_wav $temp_wav
  sox $temp_wav $second_path $dst_path
  rm $temp_wav $slience_wav
}

# cn-en
tmpdir=$(mktemp -d tmp-XXXXX)
idx=1
[ -f $ce_dst_text ] && rm $ce_dst_text
while [ $idx -le $TOTAL_NUM ]; do
    first_scp=$(cat $cn_wav_scp |shuf -n 1)
    second_scp=$(cat $en_wav_scp |shuf -n 1)
    first_path=$(echo $first_scp|cut -d ' ' -f2)
    second_path=$(echo $second_scp|cut -d ' ' -f2)
    first_uttid=$(echo $first_scp|cut -d ' ' -f1)
    second_uttid=$(echo $second_scp|cut -d ' ' -f1)
    slience_time1=$(echo "scale=1;(${RANDOM}%11)*($SLIENCE_MAX - $SLIENCE_MIN) + $SLIENCE_MIN" | bc -l)
    name=${first_uttid}-${slience_time1}-${second_uttid}
    dst_audio_path=$ce_dst_wavs_dir/${name}.wav
    _process_audio $dst_audio_path $first_path $second_path $slience_time1 $tmpdir

    #text
    first_text=$(grep $first_uttid $cn_text)
    second_text=$(grep $second_uttid $en_text)
    first_content=$(echo $first_text|cut -d ' ' -f 2-)
    second_content=$(echo $second_text|cut -d ' ' -f 2-)
    echo "$name $first_content $second_content" >> $ce_dst_text

    echo $dst_audio_path
    echo "$name $first_content $second_content"

    ((idx+=1))
done
rm -r $tmpdir

# en-cn
tmpdir=$(mktemp -d tmp-XXXXX)
idx=1
[ -f $ec_dst_text ] && rm $ec_dst_text
while [ $idx -le $TOTAL_NUM ]; do
    first_scp=$(cat $en_wav_scp |shuf -n 1)
    second_scp=$(cat $cn_wav_scp |shuf -n 1)
    first_path=$(echo $first_scp|cut -d ' ' -f2)
    second_path=$(echo $second_scp|cut -d ' ' -f2)
    first_uttid=$(echo $first_scp|cut -d ' ' -f1)
    second_uttid=$(echo $second_scp|cut -d ' ' -f1)
    slience_time1=$(echo "scale=1;(${RANDOM}%11)*($SLIENCE_MAX - $SLIENCE_MIN) + $SLIENCE_MIN" | bc -l)
    name=${first_uttid}-${slience_time1}-${second_uttid}
    dst_audio_path=$ec_dst_wavs_dir/${name}.wav
    _process_audio $dst_audio_path $first_path $second_path $slience_time1 $tmpdir

    #text
    first_text=$(grep $first_uttid $en_text)
    second_text=$(grep $second_uttid $cn_text)
    first_content=$(echo $first_text|cut -d ' ' -f 2-)
    second_content=$(echo $second_text|cut -d ' ' -f 2-)
    echo "$name $first_content $second_content"  >> $ec_dst_text

    echo $dst_audio_path
    echo "$name $first_content $second_content"

    ((idx+=1))
done
rm -r $tmpdir

# cn-en-cn
tmpdir=$(mktemp -d tmp-XXXXX)
idx=1
[ -f $cec_dst_text ] && rm $cec_dst_text
while [ $idx -le $TOTAL_NUM ]; do
    first_scp=$(cat $cn_wav_scp |shuf -n 1)
    second_scp=$(cat $en_wav_scp |shuf -n 1)
    first_path=$(echo $first_scp|cut -d ' ' -f2)
    second_path=$(echo $second_scp|cut -d ' ' -f2)
    first_uttid=$(echo $first_scp|cut -d ' ' -f1)
    second_uttid=$(echo $second_scp|cut -d ' ' -f1)
    slience_time1=$(echo "scale=1;(${RANDOM}%11)*($SLIENCE_MAX - $SLIENCE_MIN) + $SLIENCE_MIN" | bc -l)
    name=${first_uttid}-${slience_time1}-${second_uttid}
    dst_path=$cec_dst_wavs_dir/${name}.wav
    _process_audio $dst_path $first_path $second_path $slience_time1 $tmpdir

    third_scp=$(cat $cn_wav_scp |shuf -n 1)
    third_uttid=$(echo $third_scp|cut -d ' ' -f1)
    third_path=$(echo $third_scp|cut -d ' ' -f2)
    slience_time2=$(echo "scale=1;(${RANDOM}%11)*($SLIENCE_MAX - $SLIENCE_MIN) + $SLIENCE_MIN" | bc -l)
    name2=${first_uttid}-${slience_time1}-${second_uttid}-${slience_time2}-${third_uttid}
    dst_audio_path2=$cec_dst_wavs_dir/${name2}.wav
    _process_audio $dst_audio_path2 $dst_path $third_path $slience_time2 $tmpdir

    #text
    first_text=$(grep $first_uttid $cn_text)
    second_text=$(grep $second_uttid $en_text)
    third_text=$(grep $third_uttid $cn_text)
    first_content=$(echo $first_text|cut -d ' ' -f 2-)
    second_content=$(echo $second_text|cut -d ' ' -f 2-)
    third_content=$(echo $third_text|cut -d ' ' -f 2-)
    echo "$name2 $first_content $second_content $third_content" >> $cec_dst_text

    echo $dst_audio_path2
    echo "$name2 $first_content $second_content $third_content"

    rm $dst_path

    ((idx+=1))
done
rm -r $tmpdir

# en-cn-en
tmpdir=$(mktemp -d tmp-XXXXX)
idx=1
[ -f $ece_dst_text ] && rm $ece_dst_text
while [ $idx -le $TOTAL_NUM ]; do
    first_scp=$(cat $en_wav_scp |shuf -n 1)
    second_scp=$(cat $cn_wav_scp |shuf -n 1)
    first_path=$(echo $first_scp|cut -d ' ' -f2)
    second_path=$(echo $second_scp|cut -d ' ' -f2)
    first_uttid=$(echo $first_scp|cut -d ' ' -f1)
    second_uttid=$(echo $second_scp|cut -d ' ' -f1)
    slience_time1=$(echo "scale=1;(${RANDOM}%11)*($SLIENCE_MAX - $SLIENCE_MIN) + $SLIENCE_MIN" | bc -l)
    name=${first_uttid}-${slience_time1}-${second_uttid}
    dst_path=$ece_dst_wavs_dir/${name}.wav
    _process_audio $dst_path $first_path $second_path $slience_time1 $tmpdir

    third_scp=$(cat $en_wav_scp |shuf -n 1)
    third_uttid=$(echo $third_scp|cut -d ' ' -f1)
    third_path=$(echo $third_scp|cut -d ' ' -f2)
    slience_time2=$(echo "scale=1;(${RANDOM}%11)*($SLIENCE_MAX - $SLIENCE_MIN) + $SLIENCE_MIN" | bc -l)
    name2=${first_uttid}-${slience_time1}-${second_uttid}-${slience_time2}-${third_uttid}
    dst_audio_path2=$ece_dst_wavs_dir/${name2}.wav
    _process_audio $dst_audio_path2 $dst_path $third_path $slience_time2 $tmpdir

    #text
    first_text=$(grep $first_uttid $en_text)
    second_text=$(grep $second_uttid $cn_text)
    third_text=$(grep $third_uttid $en_text)
    first_content=$(echo $first_text|cut -d ' ' -f 2-)
    second_content=$(echo $second_text|cut -d ' ' -f 2-)
    third_content=$(echo $third_text|cut -d ' ' -f 2-)
    echo "$name2 $first_content $second_content $third_content" >> $ece_dst_text

    echo $dst_audio_path2
    echo "$name2 $first_content $second_content $third_content"

    rm $dst_path

    ((idx+=1))
done
rm -r $tmpdir

# en-cn-en-cn
tmpdir=$(mktemp -d tmp-XXXXX)
idx=1
while [ $idx -le $TOTAL_NUM ]; do
    first_scp=$(cat $en_wav_scp |shuf -n 1)
    second_scp=$(cat $cn_wav_scp |shuf -n 1)
    first_path=$(echo $first_scp|cut -d ' ' -f2)
    second_path=$(echo $second_scp|cut -d ' ' -f2)
    first_uttid=$(echo $first_scp|cut -d ' ' -f1)
    second_uttid=$(echo $second_scp|cut -d ' ' -f1)
    slience_time1=$(echo "scale=1;(${RANDOM}%11)*($SLIENCE_MAX - $SLIENCE_MIN) + $SLIENCE_MIN" | bc -l)
    name=${first_uttid}-${slience_time1}-${second_uttid}
    dst_path=$ecec_dst_wavs_dir/${name}.wav
    _process_audio $dst_path $first_path $second_path $slience_time1 $tmpdir

    third_scp=$(cat $en_wav_scp |shuf -n 1)
    third_uttid=$(echo $third_scp|cut -d ' ' -f1)
    third_path=$(echo $third_scp|cut -d ' ' -f2)
    slience_time2=$(echo "scale=1;(${RANDOM}%11)*($SLIENCE_MAX - $SLIENCE_MIN) + $SLIENCE_MIN" | bc -l)
    name2=${first_uttid}-${slience_time1}-${second_uttid}-${slience_time2}-${third_uttid}
    dst_path2=$ecec_dst_wavs_dir/${name2}.wav
    _process_audio $dst_path2 $dst_path $third_path $slience_time2 $tmpdir

    fourth_scp=$(cat $cn_wav_scp |shuf -n 1)
    fourth_uttid=$(echo $fourth_scp|cut -d ' ' -f1)
    fourth_path=$(echo $fourth_scp|cut -d ' ' -f2)
    slience_time3=$(echo "scale=1;(${RANDOM}%11)*($SLIENCE_MAX - $SLIENCE_MIN) + $SLIENCE_MIN" | bc -l)
    name3=${first_uttid}-${slience_time1}-${second_uttid}-${slience_time2}-${third_uttid}-${slience_time3}-${fourth_uttid}
    dst_audio_path3=$ecec_dst_wavs_dir/${name3}.wav
    _process_audio $dst_audio_path3 $dst_path2 $fourth_path $slience_time3 $tmpdir

    #text
    first_text=$(grep $first_uttid $en_text)
    second_text=$(grep $second_uttid $cn_text)
    third_text=$(grep $third_uttid $en_text)
    fourth_text=$(grep $fourth_uttid $cn_text)

    first_content=$(echo $first_text|cut -d ' ' -f 2-)
    second_content=$(echo $second_text|cut -d ' ' -f 2-)
    third_content=$(echo $third_text|cut -d ' ' -f 2-)
    fourth_content=$(echo $fourth_text|cut -d ' ' -f 2-)
    echo "$name3 $first_content $second_content $third_content $fourth_content" >> $ecec_dst_text

    echo $dst_audio_path3
    echo "$name3 $first_content $second_content $third_content $fourth_content"
    rm $dst_path $dst_path2
    ((idx+=1))
done
rm -r $tmpdir

# cn-en-cn-en
tmpdir=$(mktemp -d tmp-XXXXX)
idx=1
while [ $idx -le $TOTAL_NUM ]; do
    first_scp=$(cat $cn_wav_scp |shuf -n 1)
    second_scp=$(cat $en_wav_scp |shuf -n 1)
    first_path=$(echo $first_scp|cut -d ' ' -f2)
    second_path=$(echo $second_scp|cut -d ' ' -f2)
    first_uttid=$(echo $first_scp|cut -d ' ' -f1)
    second_uttid=$(echo $second_scp|cut -d ' ' -f1)
    slience_time1=$(echo "scale=1;(${RANDOM}%11)*($SLIENCE_MAX - $SLIENCE_MIN) + $SLIENCE_MIN" | bc -l)
    name=${first_uttid}-${slience_time1}-${second_uttid}
    dst_path=$cece_dst_wavs_dir/${name}.wav
    _process_audio $dst_path $first_path $second_path $slience_time1 $tmpdir

    third_scp=$(cat $cn_wav_scp |shuf -n 1)
    third_uttid=$(echo $third_scp|cut -d ' ' -f1)
    third_path=$(echo $third_scp|cut -d ' ' -f2)
    slience_time2=$(echo "scale=1;(${RANDOM}%11)*($SLIENCE_MAX - $SLIENCE_MIN) + $SLIENCE_MIN" | bc -l)
    name2=${first_uttid}-${slience_time1}-${second_uttid}-${slience_time2}-${third_uttid}
    dst_path2=$cece_dst_wavs_dir/${name2}.wav
    _process_audio $dst_path2 $dst_path $third_path $slience_time2 $tmpdir

    fourth_scp=$(cat $en_wav_scp |shuf -n 1)
    fourth_uttid=$(echo $fourth_scp|cut -d ' ' -f1)
    fourth_path=$(echo $fourth_scp|cut -d ' ' -f2)
    slience_time3=$(echo "scale=1;(${RANDOM}%11)*($SLIENCE_MAX - $SLIENCE_MIN) + $SLIENCE_MIN" | bc -l)
    name3=${first_uttid}-${slience_time1}-${second_uttid}-${slience_time2}-${third_uttid}-${slience_time3}-${fourth_uttid}
    dst_audio_path3=$cece_dst_wavs_dir/${name3}.wav
    _process_audio $dst_audio_path3 $dst_path2 $fourth_path $slience_time3 $tmpdir

    #text
    first_text=$(grep $first_uttid $cn_text)
    second_text=$(grep $second_uttid $en_text)
    third_text=$(grep $third_uttid $cn_text)
    fourth_text=$(grep $fourth_uttid $en_text)

    first_content=$(echo $first_text|cut -d ' ' -f 2-)
    second_content=$(echo $second_text|cut -d ' ' -f 2-)
    third_content=$(echo $third_text|cut -d ' ' -f 2-)
    fourth_content=$(echo $fourth_text|cut -d ' ' -f 2-)
    echo "$name3 $first_content $second_content $third_content $fourth_content" >> $cece_dst_text

    echo $dst_audio_path3
    echo "$name3 $first_content $second_content $third_content $fourth_content"
    rm $dst_path $dst_path2
    ((idx+=1))
done
rm -r $tmpdir