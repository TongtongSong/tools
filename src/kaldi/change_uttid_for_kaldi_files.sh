suffix="-rvb"
tmpdir=$(mktemp -d tmp-XXXXX)
dir=/home/songtongtong/data/features/English/fbank_80/gigaspeech_1000h-rvb

for x in feats.scp text utt2num_frames wav.scp utt2spk;do
  cat $dir/$x|cut -d ' ' -f1 |awk -v suffix=$suffix '{print($0suffix)}'> $tmpdir/uttid
  cat $dir/$x|cut -d ' ' -f2- > $tmpdir/content
  paste -d ' ' $tmpdir/uttid $tmpdir/content > $tmpdir/tmp
  mv $tmpdir/tmp $dir/$x
done
utils/utt2spk_to_spk2utt.pl $dir/utt2spk > $dir/spk2utt
rm -r $tmpdir
