
segments=$2
wav_scp=$1
while read line;do
    uttid=`echo $line|awk '{print($1)}'`
    wavid=`echo $line|awk '{print($2)}'`
    start=`echo $line|awk '{print($3)}'`
    end=`echo $line|awk '{print($4)}'`
    wav=`grep $wavid $wav_scp|awk '{print($2)}'`
    dir=`dirname $wav|sed 's|GigaSpeech|GigaSpeech-seg|'` # modify yourself
    [ ! -d $dir ] && mkdir -p $dir
    new_wav=`echo $wav|sed 's|GigaSpeech|GigaSpeech-seg|'|\
        awk -v dir=$dir -v uttid=$uttid  '{print(dir"/"uttid".wav")}'` # modify yourself
    echo $uttid $start $end
    sox $wav $new_wav trim $start =$end
done < $segments