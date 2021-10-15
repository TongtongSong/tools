wav=$1
min_amp=400
max_amp=1000
dist=$(echo "$max_amp-$min_amp"|bc)
amp=$(($RANDOM%($dist+1)+$min_amp))
echo $wav $amp
new_wav=$(echo $wav|sed 's|\.wav|_new.wav|')
python /home/songtongtong/data/tools/src/audio/vol/adjust_vol.py  $wav $new_wav $amp
mv $new_wav $wav