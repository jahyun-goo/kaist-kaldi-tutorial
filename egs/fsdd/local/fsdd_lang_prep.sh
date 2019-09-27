#!/bin/bash

if [ $# -ne 1 ]; then
	echo ""
	exit 1;
fi

dir=$PWD
dict_path=$(pwd)/$1
mkdir -p $dict_path
cd $dict_path


### Manually create lexicon.txt (phonetic dictionary)
echo "Create lexicon.txt"

echo "!SIL sil" > temp.txt
echo "<UNK> spn" >> temp.txt
echo "zero z ih r ow" >> temp.txt
echo "zero z iy r ow" >> temp.txt
echo "one w ah n" >> temp.txt
echo "one hh w ah n" >> temp.txt
echo "two t uw" >> temp.txt
echo "three th r iy" >> temp.txt
echo "four f ao r" >> temp.txt
echo "five f ay v" >> temp.txt
echo "six s ih k s" >> temp.txt
echo "seven s eh v ah n" >> temp.txt
echo "eight ey t" >> temp.txt
echo "nine n ay n" >> temp.txt

sort -u temp.txt > lexicon.txt


### Word lists

echo "Create words.txt"
tail -12 lexicon.txt | awk '{print $1}' > temp.txt
sort -u temp.txt > words.txt


### phone lists

echo "Create nonsilence_phones.txt"
tail -12 lexicon.txt | awk '{for (i=2; i<=NF; ++i) print $i}' > temp.txt
sort -u temp.txt > nonsilence_phones.txt

echo "Create silence_phones.txt"
echo "sil" > silence_phones.txt
echo "spn" >> silence_phones.txt

echo "Create optional_silence.txt"
echo "sil" > optional_silence.txt



### Done
rm temp.txt
cd $dir

echo "lang preparation done."
