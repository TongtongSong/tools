
_clean(){
  tools_dir=/Work20/2020/songtongtong/data/tools/src/text/text_clean
  local text=$1
  local has_key=$2
  echo process $text
  tmpdir=$(mktemp -d tmp-XXXXX)
  if $has_key;then
      cat $text |cut -d' ' -f1 >  $tmpdir/uttid
      cat $text |cut -d' ' -f2- >  $tmpdir/text_only
  else
      cat $text > $tmpdir/text_only
  fi
  python2 $tools_dir/quan2ban.py $tmpdir/text_only $tmpdir/sen_ban
  cat $tmpdir/sen_ban|sed "s|’|'|g" > tmp;mv tmp $tmpdir/sen_ban
  cat $tmpdir/sen_ban |tr [A-Z] [a-z] |sed 's/\*\*/ /g' >$tmpdir/sen_1
  cat $tmpdir/sen_1 |perl $tools_dir/zh-char-seg.pl >$tmpdir/sen_2
  cat $tmpdir/sen_2 |perl $tools_dir/tokenizer.perl -a -no-escape >$tmpdir/sen_3
  cat $tmpdir/sen_3 | perl $tools_dir/fix_seg.pl >$tmpdir/sen_4
  cat $tmpdir/sen_4 | python  $tools_dir/rm_biaodian.py >$tmpdir/sen_5
  if $has_key;then
      paste -d ' ' $tmpdir/uttid $tmpdir/sen_5 > $text
  else
      mv $tmpdir/sen_5 $text
  fi
  rm -r $tmpdir
}

input=$1
has_key=$2
_clean $input $has_key
