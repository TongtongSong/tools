ori_wav_scp=$1
IFS_OLD=$IFS
IFS=$'\n'
for x in $(cat $ori_wav_scp);do
    uttid=$(echo $x|cut -d ' ' -f1)
    wav_path=$(echo $x|cut -d ' ' -f2)
    dur=$(soxi -D $wav_path)
    echo "$uttid $dur"
done
IFS=$IFS_OLD