tools=/home/songtongtong/data/tools
cn_wav_scp=$1
cn_text=$2
en_wav_scp=$3
en_text=$4
modes=$5  # "ce ec cec ece cece ecec"
dst_data_dir=$6
TOTAL_NUM=100
log_interval=10
SLIENCE_MIN=0.1
SLIENCE_MAX=0.5

_process_audio(){
  local dst_path=$1
  local first_path=$2
  local second_path=$3
  local tmp_dir=$4
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
      new_first_path=$tmp_dir/${RANDOM}.wav
      python $tools/src/audio/vol/adjust_vol.py $first_path $new_first_path $second_vol
      first_path=$new_first_path
  else
      new_second_path=$tmp_dir/${RANDOM}.wav
      python $tools/src/audio/vol/adjust_vol.py $second_path $new_second_path $first_vol
      second_path=$new_second_path
  fi

  # make slience wav
  slience_time=$(echo "scale=1;(${RANDOM}%11)*($SLIENCE_MAX - $SLIENCE_MIN) + $SLIENCE_MIN" | bc -l)
  slience_wav=$tmpdir/${RANDOM}.wav
  sox -n -r 16000 $slience_wav trim 0.0 $slience_time

  # paste wav
  temp_wav=$tmp_dir/${RANDOM}.wav
  sox $first_path $slience_wav $temp_wav
  sox $temp_wav $second_path $dst_path

  rm $temp_wav $slience_wav
}

_add_start_and_end_slience(){
  local dst_wav_path=$1
  slience_time_s=$(echo "scale=1;(${RANDOM}%11)*($SLIENCE_MAX - $SLIENCE_MIN) + $SLIENCE_MIN" | bc -l)
  slience_wav_s=$tmpdir/${RANDOM}.wav
  sox -n -r 16000 $slience_wav_s trim 0.0 $slience_time_s

  slience_time_e=$(echo "scale=1;(${RANDOM}%11)*($SLIENCE_MAX - $SLIENCE_MIN) + $SLIENCE_MIN" | bc -l)
  slience_wav_e=$tmpdir/${RANDOM}.wav
  sox -n -r 16000 $slience_wav_e trim 0.0 $slience_time_e

  temp_wav1=$tmpdir/${RANDOM}.wav
  temp_wav2=$tmpdir/${RANDOM}.wav
  sox $slience_wav_s $dst_wav_path $temp_wav1
  sox $temp_wav1 $slience_wav_e $temp_wav2
  mv $temp_wav2 $dst_wav_path
}
_paste_two(){

  local first=$1
  local second=$2
  local mode=$3
  local total_num=$4

  tmpdir=$(mktemp -d ${mode}-tmp-XXXXX)
  dst_wavs_dir=$dst_data_dir/$mode/wavs
  dst_text=$dst_data_dir/$mode/text
  [ -f $dst_text ] && rm $dst_text
  mkdir -p $dst_wavs_dir

  first_wav_scp=$(eval echo \$${first}_wav_scp)
  first_text=$(eval echo \$${first}_text)

  second_wav_scp=$(eval echo \$${second}_wav_scp)
  second_text=$(eval echo \$${second}_text)

  idx=1
  while [ $idx -le $total_num ]; do
       # audio
      first_scp=$(cat $first_wav_scp |shuf -n 1)
      first_uttid=$(echo $first_scp|cut -d ' ' -f1)
      first_path=$(echo $first_scp|cut -d ' ' -f2)
      first_content=$(grep -w -F $first_uttid $first_text|cut -d ' ' -f 2-)

      second_scp=$(cat $second_wav_scp |shuf -n 1)
      second_uttid=$(echo $second_scp|cut -d ' ' -f1)
      second_path=$(echo $second_scp|cut -d ' ' -f2)
      second_content=$(grep -w -F $second_uttid $second_text|cut -d ' ' -f 2-)

      name1="${first_uttid}=${second_uttid}"
      dst_audio_path1=$dst_wavs_dir/${name1}.wav
#      _process_audio $dst_audio_path1 $first_path $second_path $tmpdir
#
#      #echo "add start and end slience"
#      _add_start_and_end_slience $dst_audio_path1

      python paste.py 16000 $SLIENCE_MIN $SLIENCE_MAX $first_path $second_path $dst_audio_path1

      # text
      first_content=$(grep -w -F $first_uttid $first_text|cut -d ' ' -f 2-)
      second_content=$(grep -w -F $second_uttid $second_text|cut -d ' ' -f 2-)
      echo "$name1 $first_content $second_content" >> $dst_text

      # show
#      echo $dst_audio_path1
#      echo "$name1 $first_content $second_content"
      if [ $(($idx%$log_interval)) -eq 0 ];then
        echo $mode $idx
      fi

      ((idx+=1))
  done
  rm -r $tmpdir
}

_paste_three(){
  local first=$1
  local second=$2
  local third=$3
  local mode=$4
  local total_num=$5

  tmpdir=$(mktemp -d ${mode}-tmp-XXXXX)
  dst_text=$dst_data_dir/$mode/text
  dst_wavs_dir=$dst_data_dir/$mode/wavs
  [ -f $dst_text ] && rm $dst_text
  mkdir -p $dst_wavs_dir

  first_wav_scp=$(eval echo \$${first}_wav_scp)
  first_text=$(eval echo \$${first}_text)

  second_wav_scp=$(eval echo \$${second}_wav_scp)
  second_text=$(eval echo \$${second}_text)

  third_wav_scp=$(eval echo \$${third}_wav_scp)
  third_text=$(eval echo \$${third}_text)

  idx=1
  while [ $idx -le $total_num ]; do
      # audio
      first_scp=$(cat $first_wav_scp |shuf -n 1)
      first_uttid=$(echo $first_scp|cut -d ' ' -f1)
      first_path=$(echo $first_scp|cut -d ' ' -f2)
      first_content=$(grep -w -F $first_uttid $first_text|cut -d ' ' -f 2-)

      second_scp=$(cat $second_wav_scp |shuf -n 1)
      second_uttid=$(echo $second_scp|cut -d ' ' -f1)
      second_path=$(echo $second_scp|cut -d ' ' -f2)
      second_content=$(grep -w -F $second_uttid $second_text|cut -d ' ' -f 2-)

      third_scp=$(cat $third_wav_scp |shuf -n 1)
      third_uttid=$(echo $third_scp|cut -d ' ' -f1)
      third_path=$(echo $third_scp|cut -d ' ' -f2)
      third_content=$(grep -w -F $third_uttid $third_text|cut -d ' ' -f 2-)

#      name1="${first_uttid}=${second_uttid}"
#      dst_audio_path1=$dst_wavs_dir/${name1}.wav
#      _process_audio $dst_audio_path1 $first_path $second_path $tmpdir
#
      name2="${first_uttid}=${second_uttid}=${third_uttid}"
      dst_audio_path2=$dst_wavs_dir/${name2}.wav
#      _process_audio $dst_audio_path2 $dst_audio_path1 $third_path $tmpdir
#
#      #echo "add start and end slience"
#      _add_start_and_end_slience $dst_audio_path2

      python paste.py 16000 $SLIENCE_MIN $SLIENCE_MAX $first_path $second_path $third_path $dst_audio_path2

      #text
      echo "$name2 $first_content $second_content $third_content" >> $dst_text

      # show
#      echo $dst_audio_path2
#      echo "$name2 $first_content $second_content $third_content"
      if [ $(($idx%$log_interval)) -eq 0 ];then
        echo $mode $idx
      fi
      #rm $dst_audio_path1
      ((idx+=1))
  done
  rm -r $tmpdir
}

_paste_four(){
  local first=$1
  local second=$2
  local third=$3
  local fourth=$4
  local mode=$5
  local total_num=$6

  tmpdir=$(mktemp -d ${mode}-tmp-XXXXX)
  dst_text=$dst_data_dir/$mode/text
  dst_wavs_dir=$dst_data_dir/$mode/wavs
  [ -f $dst_text ] && rm $dst_text
  mkdir -p $dst_wavs_dir

  first_wav_scp=$(eval echo \$${first}_wav_scp)
  first_text=$(eval echo \$${first}_text)

  second_wav_scp=$(eval echo \$${second}_wav_scp)
  second_text=$(eval echo \$${second}_text)

  third_wav_scp=$(eval echo \$${third}_wav_scp)
  third_text=$(eval echo \$${third}_text)

  fourth_wav_scp=$(eval echo \$${fourth}_wav_scp)
  fourth_text=$(eval echo \$${fourth}_text)

  idx=1
  while [ $idx -le $total_num ]; do
      # audio
      first_scp=$(cat $first_wav_scp |shuf -n 1)
      first_uttid=$(echo $first_scp|cut -d ' ' -f1)
      first_path=$(echo $first_scp|cut -d ' ' -f2)
      first_content=$(grep -w -F $first_uttid $first_text|cut -d ' ' -f 2-)

      second_scp=$(cat $second_wav_scp |shuf -n 1)
      second_uttid=$(echo $second_scp|cut -d ' ' -f1)
      second_path=$(echo $second_scp|cut -d ' ' -f2)
      second_content=$(grep -w -F $second_uttid $second_text|cut -d ' ' -f 2-)

      third_scp=$(cat $third_wav_scp |shuf -n 1)
      third_uttid=$(echo $third_scp|cut -d ' ' -f1)
      third_path=$(echo $third_scp|cut -d ' ' -f2)
      third_content=$(grep -w -F $third_uttid $third_text|cut -d ' ' -f 2-)

      fourth_scp=$(cat $fourth_wav_scp |shuf -n 1)
      fourth_uttid=$(echo $fourth_scp|cut -d ' ' -f1)
      fourth_path=$(echo $fourth_scp|cut -d ' ' -f2)
      fourth_content=$(grep -w -F $fourth_uttid $fourth_text|cut -d ' ' -f 2-)
#      #
#      name1="${first_uttid}=${second_uttid}"
#      dst_audio_path1=$dst_wavs_dir/${name1}.wav
#      _process_audio $dst_audio_path1 $first_path $second_path $tmpdir
#
#      name2="${first_uttid}=${second_uttid}=${third_uttid}"
#      dst_audio_path2=$dst_wavs_dir/${name2}.wav
#      _process_audio $dst_audio_path2 $dst_audio_path1 $third_path $tmpdir
#
      name3="${first_uttid}=${second_uttid}=${third_uttid}=${fourth_uttid}"
      dst_audio_path3=$dst_wavs_dir/${name3}.wav
#      _process_audio $dst_audio_path3 $dst_audio_path2 $fourth_path $tmpdir
#
#      #echo "add start and end slience"
#      _add_start_and_end_slience $dst_audio_path3

      python paste.py 16000 $SLIENCE_MIN $SLIENCE_MAX $first_path $second_path $third_path $fourth_path $dst_audio_path3

      # text
      echo "$name3 $first_content $second_content $third_content $fourth_content" >> $dst_text

      # show
#      echo $dst_audio_path3
#      echo "$name3 $first_content $second_content $third_content $fourth_content"
      if [ $(($idx%$log_interval)) -eq 0 ];then
        echo $mode $idx
      fi
      #rm $dst_audio_path1 $dst_audio_path2
      ((idx+=1))
  done
  rm -r $tmpdir
}

_paste(){
  local mode=$1
  local total_num=$2
  num=$(echo ${#mode})
  if [ $num -eq 2 ];then
      if [ "$mode" = "ce" ];then
          _paste_two cn en $mode $total_num
      else
          _paste_two en cn $mode $total_num
      fi
  elif [ $num -eq 3 ];then
      if [ "$mode" = "cec" ];then
          _paste_three cn en cn $mode $total_num
      else
          _paste_three en cn en $mode $total_num
      fi
  else
      if [ "$mode" = "cece" ];then
          _paste_four cn en cn en $mode $total_num
      else
          _paste_four en cn en cn $mode $total_num
      fi
  fi
}
echo $(date)
for mode in $modes;do
  {
    echo $mode
    _paste $mode $TOTAL_NUM
  }&
done
wait
echo $(date)
echo "Done."
