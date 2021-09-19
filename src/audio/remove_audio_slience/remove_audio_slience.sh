########################################
# remove audio slience
# must run under the dir of your scripts
# Author: Tongtong Song
# Data: 2021.8.18 11:50
# Last modified: 2021.8.18 11:50
# run like:
#  . remove_audio_slience.sh \
#    wav_list textgrid_for_cv
# or . remove_audio_slience.sh \
#    wav_dir textgrid_for_cv
#########################################

input=$1
txt_grid_dir=$2
mkdir -p $txt_grid_dir
nj=32
tmpdir=$(mktemp -d tmp-XXXXX)
[ -d $input ] && find $input -iname "*.wav" > $tmpdir/wav_list && input=$tmpdir/wav_list

# your JOB
_remove_audio_slience(){
  local wav_path=$1
  for wav in `cat $wav_path`;do
  {
      name=`echo $wav|awk -F '/' '{print $NF}'|cut -d'.' -f1`
      ./praat_nogui --run annotate_silences.praat $wav $txt_grid_dir/${name}.TextGrid 100 0.0 -25.0 0.1 0.1 silence sound
      time=`python3 readTextGrid.py $txt_grid_dir/${name}.TextGrid`
      start=`echo $time|cut -d' ' -f1`
      end=`echo $time|cut -d' ' -f2`
      echo $name $start $end
      new_wav=`echo $wav|sed 's|librispeech|librispeech-no-slience|'` ## modify yourself
      new_dir=`dirname $new_wav`
      [ ! -d $new_dir ] && mkdir -p $new_dir
      sox $wav $new_wav trim $start =$end
  };done
}

# multithread
split --additional-suffix .slice -d -n l/$nj $input $tmpdir/tmp_
for slice in `ls $tmpdir/tmp_*.slice`; do
{
  _remove_audio_slience $slice
}&
done
wait

rm -r $tmpdir
echo "Successfully running your JOBs by $nj threads"