#!/usr/bin/env bash
path_list=$1
col=$2
if [ $# != 2 ];then
  echo "Usage: $0 <path-list> <col>"
  echo "col is the column of the wav path in path-list"
  echo "$0 wav.scp 1"
  exit 1;
fi

awk -v n=$col '{print $n}' $path_list| xargs soxi -D > time_count_list
echo $(echo $(echo -n `cat time_count_list | awk '{print $1}'`| tr ' ' '+')|bc) "(s)"
rm time_count_list

# cat utt2num_frames |shuf -n 20000|awk 'BEGIN{SUM=0}{SUM+=$2}END{print(SUM/360000)}'