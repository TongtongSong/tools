########################################
# cut audio by slide window
# Author: Tongtong Song
# Data: 2021.8.18 20:10
# Last modified: 2021.8.18 20:10
# run like:
#  . cut.sh wav_list
#########################################
wav_list=$1

win_len=3   # slide window size(s)
min_len=3   # minimum cut length(s)
max_len=5   # maximum cut length
cut_len=7    #minimum length to cut,
            # is length bigger than this the wav will be cut
discard_len=3 # if last length less than this,
              # the last wav will be discarded
rgcutlf=$(echo "$max_len-$min_len"|bc)

for wav in `cat $wav_list`;do
{
    length=`soxi -D $wav|awk '{print(int($0))}'`
    remain_length=$length
    [ $length -gt $cut_len ] && echo "Start to cut $wav $length"
    path=${wav//".wav"/""}
    start=0
    while [ $remain_length -gt 0 ];do
    {
        [ $discard_len -ge $remain_length ] && break
        cut_length=$(($RANDOM%($rgcutlf+1)+$min_len))
        end=$(($start+$cut_length))
        [ $cut_length -gt $remain_length ] && end=$length
        start=`echo $start|awk '{printf("%05d\n",$0)}'`
        end=`echo $end|awk '{printf("%05d\n",$0)}'`
        sub_wav="${path}_${start}_${end}.wav"
        sox $wav $sub_wav trim $start =$end
        echo "Generate $sub_wav"
        start=$(echo "$start+$win_len"|bc)
        remain_length=$(echo "$length-$start"|bc)
    }
    done
    #rm $wav
}
done
