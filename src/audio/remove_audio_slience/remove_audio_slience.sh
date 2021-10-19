########################################
# remove audio slience
# must run under the dir of your scripts
# Author: Tongtong Song
# Data: 2021.8.18 11:50
# Last modified: 2021.10.19 10:40
#########################################
if [ $# != 4 ] ; then
    echo "USAGE: $0 wav_dir text_grid_dir keep_slience suffix"
    echo " e.g.: $0 aishell/data_aishell/wavs aishell 0.1 -no-slience-0.1"
    exit 1;
fi

dir=$1
txt_grid_dir=$2
keep_slience=$3
suffix=$4
mkdir -p $txt_grid_dir
nj=16
tmpdir=$(mktemp -d tmp-XXXXX)
[ -d $dir ] && find $dir -iname "*.wav" > $tmpdir/wav_list && input=$tmpdir/wav_list
dir_name=$(echo $dir|awk -F'/' '{print($NF)}')

# your JOB
_remove_audio_slience(){
  local wav_path=$1
  local dir_name=$2
  for wav in $(cat $wav_path);do
  {
      name=$(echo $wav|awk -F '/' '{print $NF}')
      echo $wav
      ./praat_nogui --run annotate_silences.praat $wav $txt_grid_dir/${name}.TextGrid 100 0.0 -25.0 0.1 0.1 silence sound
      time=$(python3 readTextGrid.py $txt_grid_dir/${name}.TextGrid)
      start=$(echo $time|cut -d' ' -f1)
      end=$(echo $time|cut -d' ' -f2)
      echo $name $start $end
      new_wav=$(echo $wav|sed 's|'$dir_name'|'${dir_name}"$suffix"'|') ## modify yourself
      new_dir=$(dirname $new_wav)
      [ ! -d $new_dir ] && mkdir -p $new_dir
      if [ `echo "$keep_slience > $start"|bc` -eq 1 ];then
        start=0
      else
        start=$(echo "$start-$keep_slience" | bc)
      fi
      wav_len=$(soxi -D $wav)
      new_end=$(echo "$end+$keep_slience" | bc)
      if [ `echo "$new_end > $wav_len"|bc` -eq 1 ];then
        end=$wav_len
      else
        end=$new_end
      fi
      sox $wav $new_wav trim $start =$end
  };done
}

# multithread
split --additional-suffix .slice -d -n l/$nj $input $tmpdir/tmp_
for slice in $(ls $tmpdir/tmp_*.slice); do
{
  _remove_audio_slience $slice $dir_name
}&
done
wait

rm -r $tmpdir
#rm -r $txt_grid_dir
echo "Successfully running your JOBs by $nj threads"