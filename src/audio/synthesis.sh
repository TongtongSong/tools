train_data=/Work20/2020/songtongtong/data/corpus/iflytek_ai_competition/bird_voice_recognition-seg-syn/data/train # 数据集的训练集路径
train_step=/Work20/2020/songtongtong/data/corpus/iflytek_ai_competition/bird_voice_recognition-seg-syn/data/train-tmp  # 不存在的路径，用来保存中间生成的文件，最好和训练集同一路径

input=$1
main_left_random=1   # 主音量增加区间 1 - 2
main_right_random=2
main_increse_step=0.1  # 随机数选取时候的增量

associate_left_random=0.01   # 副音量减小区间 0.01 - 0.2
associate_right_random=0.3
associate_increse_step=0.01  # 随机数选取时候的增量
cut_length=500    #需要切割的文件夹数量
zero=0
for class in `cat $input`; do
    # y="B013"
    number=`ls -l $train_data/$class| grep "^-" | wc -l`
    # echo "$y   $number"
    echo $number
    echo $$cut_length
    if [ $number -lt $cut_length ];then
        # echo "y=$y,   $number
        new_fold=${train_step}/${class}_tmp
        # echo "new_fold = $new_fold"
        mkdir -p $new_fold
        # exit
        remain=`expr $cut_length - $number`
        number_for=`expr $remain / $number`
        number_left=`expr $remain % $number`
        wav_id=0
        # echo "number = $number, number_for = $number_for, number_left = $number_left"
        while [ $number_for -gt $zero ];do
            for main_wav in $train_data/$class/*;do
                # path="${x}/${y}/"
                # echo "path = $path"
                main_wav_path=$main_wav
                main_wav=`echo $main_wav | awk -F "/" '{print $(NF)}'`
                xx=`ls $train_data | shuf -n 1`
                # echo $x
                yy=`ls $train_data/$xx | shuf -n 1`
                associate_wav=$train_data/$xx/$yy
                # echo "xx = $xx"
                # echo "main_wav = $main_wav, associate_wav = $associate_wav"
                # len=`soxi $associate_wav | grep "Duration" | awk -F " " '{print $3}' | sed 's|00:|''|'`
                # echo "len = $len"
                main_multiple=`seq $main_left_random $main_increse_step $main_right_random | shuf | head -n1`
                # echo "main_multiple = $main_multiple"
                associate_multiple=`seq $associate_left_random $associate_increse_step $associate_right_random | shuf | head -n1`
                # echo "associate_multiple = $associate_multiple"
                main_wav_name=`echo $main_wav | sed 's|.wav||g'`
                # echo "main_wav_name = $main_wav_name"
                new_wav="${new_fold}/${main_wav_name}__${wav_id}.wav"
                # echo "new_wav = $new_wav"
                main_tmp="${new_fold}/${main_wav_name}_tmp.wav"
                # echo "main_tmp = $main_tmp"
                sox -v $main_multiple $main_wav_path $main_tmp
                associate_wav_name=`echo $associate_wav | sed 's|.wav||g'`
                associate_tmp="${associate_wav_name}_tmp.wav"
                # echo "associate_tmp = $associate_tmp"
                sox -v $associate_multiple $associate_wav $associate_tmp

                main_length=`soxi -D $main_tmp`
                associate_length=`soxi -D $associate_tmp`
                if [ $(echo "$associate_length > $main_length"|bc) = 1 ]; then
                    dir=`dirname $associate_tmp`
                    name=`basename $associate_tmp|sed 's|.wav||'`
                    tmp=$dir/${name}_tmp.wav
                    sox $associate_tmp $tmp trim 0 =$main_length
                    sox -m $main_tmp $tmp $new_wav
                    rm -r $main_tmp $tmp $associate_tmp
                else
                    sox -m $main_tmp $associate_tmp $new_wav
                    rm -r $main_tmp $associate_tmp
                fi
            done
            let number_for--
            let wav_id++
            # echo "number_for = $number_for, wav_id = $wav_id"
        done
        # echo "----------------------------------------------------------"
        # echo "number_left = $number_left"
        while [ $number_left -gt $zero ];
        do
            main_wav=`ls $train_data/$class | shuf -n 1`
            main_wav_path=$train_data/$class/$main_wav
            xx=`ls $train_data | shuf -n 1`
            # echo $x
            yy=`ls $train_data/$xx | shuf -n 1`
            associate_wav=$train_data/$xx/$yy
            # echo "main_wav = $main_wav, associate_wav = $associate_wav"
            main_multiple=`seq $main_left_random $main_increse_step $main_right_random | shuf | head -n1`
            # echo "main_multiple = $main_multiple"
            associate_multiple=`seq $associate_left_random $associate_increse_step $associate_right_random | shuf | head -n1`
            # echo "associate_multiple = $associate_multiple"
            main_wav_name=`echo $main_wav | sed 's|.wav||g'`
            # echo "main_wav_name = $main_wav_name"
            new_wav="${new_fold}/${main_wav_name}__${wav_id}.wav"
            # echo "new_wav = $new_wav"
            main_tmp="${new_fold}/${main_wav_name}_tmp.wav"
            # echo "main_tmp = $main_tmp"
            sox -v $main_multiple $main_wav_path $main_tmp
            associate_wav_name=`echo $associate_wav | sed 's|.wav||g'`
            associate_tmp="${associate_wav_name}_tmp.wav"
            # echo "associate_tmp = $associate_tmp"

            sox -v $associate_multiple $associate_wav $associate_tmp

            main_length=`soxi -D $main_tmp`

            associate_length=`soxi -D $associate_tmp`
            if [ $(echo "$associate_length > $main_length"|bc) = 1 ]; then
                dir=`dirname $associate_tmp`
                name=`basename $associate_tmp|sed 's|.wav||'`
                tmp=$dir/${name}_tmp.wav
                sox $associate_tmp $tmp trim 0 =$main_length
                sox -m $main_tmp $tmp $new_wav
                rm -r $main_tmp $tmp $associate_tmp
            else
                sox -m $main_tmp $associate_tmp $new_wav
                rm -r $main_tmp $associate_tmp
            fi


            # let number_left--
            # echo "------number_left = $number_left"
            nn=`ls $new_fold | wc -l`
            # echo "nn = $nn"
            if [ $nn -eq $remain ];then
                number_left=0
            fi
        done

        # 将生成的文件mv到该去的地方
        mv $new_fold/* $train_data/$class
        rm -rf $new_fold
    fi
done

