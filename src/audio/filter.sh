ori_wav_scp=$1
ori_text=$2
dst_dir=$3
min_dur=$4
max_dur=$5
[ ! -d $dst_dir ] && mkdir -p $dst_dir
IFS_OLD=$IFS
IFS=$'\n'
for x in $(cat $ori_wav_scp);do
    uttid=$(echo $x|cut -d ' ' -f1)
    wav_path=$(echo $x|cut -d ' ' -f2)
    dur=$(soxi -D $wav_path)
    echo "$uttid $dur"
done > $dst_dir/utt2dur
IFS=$IFS_OLD
# filter
cat $dst_dir/utt2dur |awk -v max_dur=$max_dur -v min_dur=$min_dur \
      '{if($2<max_dur && $2>min_dur){print($1)}}' > $dst_dir/uttid.${min_dur}_${max_dur}

scp_name=$(basename $ori_wav_scp)
grep -w -F -f $dst_dir/uttid.${min_dur}_${max_dur} $ori_wav_scp > $dst_dir/$scp_name
text_name=$(basename $ori_text)
grep -w -F -f $dst_dir/uttid.${min_dur}_${max_dur} $ori_text > $dst_dir/$text_name

rm $dst_dir/utt2dur $dst_dir/uttid.${min_dur}_${max_dur}