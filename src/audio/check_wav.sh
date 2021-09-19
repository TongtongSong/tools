wav_list=$1
SAMPLE_RATE=16000
CHANNELS=1
SAMPLE_ENCODING=16
wrong_wav_file=wrong_wav
[ -f $wrong_wav_file ] && rm $wrong_wav_file
for x in `cat $wav_list`;do
    name=`basename $x`
    sample_rate=`soxi $x| grep "Sample Rate"|awk '{print($4)}'`
    channels=`soxi $x| grep "Channels"|awk '{print($3)}'`
    sample_encoding=`soxi $x| grep "Sample Encoding"|awk '{print($3)}'|cut -d'-' -f1`
    if [[ $channels != $CHANNELS ]];then echo "$name channels is $channels";fi
    if [[ $sample_rate != $SAMPLE_RATE ]];then echo "$name sample rate is $sample_rate";fi
    if [[ $sample_encoding != $SAMPLE_ENCODING ]];then echo "$name sample encoding is $sample_encoding";fi
done >> $wrong_wav_file
cat $wrong_wav_file|awk '{print($1)}'|uniq > tmp;mv tmp $wrong_wav_file
grep -w -F -f $wrong_wav_file $wav_list > tmp; mv tmp $wrong_wav_file


