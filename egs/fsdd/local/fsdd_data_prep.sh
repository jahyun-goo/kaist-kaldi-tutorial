#!/bin/bash


per_utt=true
fsdd_path=$1
shift

# Check the option
if [ "$1" = "--per-speaker" ]; then
	per_utt=false
	shift
elif [ $# -ge 1 ]; then
	echo "$0 needs path to FSDD recording directory as 1st argument."
	echo "e.g. : $0 /path/to/fsdd/recordings [--per-speaker]"
	exit 1
fi

# Check the directory
if [ ! -f $fsdd_path/0_jackson_0.wav ]; then
	echo "No .wav files in $fsdd_path."
	exit 1;
fi


### Creation of ...
# wav.scp : <utterance-id> <path-to-audio-file>
# utt2spk : <utterance-id> <speaker-id>
# text    : <utterance-id> <text-transcription>

mkdir -p data/{train,test}
rm -f data/{train,test}/{wav.scp,utt2spk,text}

text_arr=("zero" "one" "two" "three" "four" \
          "five" "six" "seven" "eight" "nine")


# if per_utt=true:  utt-id(0:24)=test, utt-id(25:49)=train
# if per_utt=false: jackson     =test, theo&nicolas =train

dataset=test
for spk_id in jackson theo nicolas; do
	for digit in {0..9}; do
		$per_utt && dataset=test

		for utt in {0..49}; do
			if [ $utt -eq 25 ]; then
				$per_utt && dataset=train
			fi

			utt_id=${spk_id}_${digit}_${utt}
			wav_id=${fsdd_path}/${digit}_${spk_id}_${utt}.wav
			
			echo "$utt_id $wav_id" >> data/$dataset/wav.scp
			echo "$utt_id $spk_id" >> data/$dataset/utt2spk
			echo "$utt_id ${text_arr[$digit]}" >> data/$dataset/text
		done
	done
	! $per_utt && dataset=train
done


# Fix those files to Kaldi style
utils/validate_data_dir.sh data/train
utils/fix_data_dir.sh data/train

utils/validate_data_dir.sh data/test
utils/fix_data_dir.sh data/test


echo "data preparation done."
