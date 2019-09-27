#!/bin/bash

. ./path.sh


# Preset options

stage=0
nj=1
fsdd_url=https://github.com/Jakobovski/free-spoken-digit-dataset
fsdd_dir=~/Downloads/free-spoken-digit-dataset
mfcc_dir=mfcc

. utils/parse_options.sh
# option ends

set -euo pipefail


if [ $stage -le 0 ]; then
	echo ""
	echo "===== PREPARING ACOUSIC DATA ====="
	echo ""

	[ ! -d $fsdd_dir ] && git clone $fsdd_url $fsdd_dir
	local/fsdd_data_prep.sh $fsdd_dir/recordings --per-speaker
fi

if [ $stage -le 1 ]; then
	echo ""
	echo "===== FEATURE EXTRACTION ====="
	echo ""

	mkdir -p conf
	echo "--use-energy=false" > conf/mfcc.conf
	echo "--sample-frequency=8000" >> conf/mfcc.conf
	echo "--high-freq=3800" >> conf/mfcc.conf

	mkdir -p $mfcc_dir
	for part in train test; do
		steps/make_mfcc.sh --nj $nj data/$part exp/make_mfcc/$part $mfcc_dir
		steps/compute_cmvn_stats.sh data/$part exp/make_mfcc/$part $mfcc_dir
	done
fi

if [ $stage -le 2 ]; then
	echo ""
	echo "===== PREPARING LINGUISTIC DATA ====="
	echo ""

	local/fsdd_lang_prep.sh data/local/dict
	utils/prepare_lang.sh data/local/dict "<UNK>" data/local/lang data/lang
fi

if [ $stage -le 3 ]; then
	echo ""
	echo "===== PREPARING LANGUAGE MODEL ====="
	echo ""

	mkdir -p data/local/tmp
	ngram-count -order 1 \
		-write-vocab data/local/tmp/vocab-full.txt \
		-wbdiscount -text data/local/dict/words.txt \
		-lm data/local/tmp/lm.arpa

	arpa2fst --disambig-symbol=#0 \
		--read-symbol-table=data/lang/words.txt \
		data/local/tmp/lm.arpa data/lang/G.fst
fi

if [ $stage -le 4 ]; then
	echo ""
	echo "===== MONOPHONE MODEL TRAINING ====="
	echo ""

	steps/train_mono.sh --nj $nj \
		data/train data/lang exp/mono
fi

if [ $stage -le 5 ]; then
	echo ""
	echo "===== MONOPHONE MODEL DECODING ====="
	echo ""

	utils/mkgraph.sh data/lang exp/mono exp/mono/graph
	steps/decode.sh --nj $nj \
		exp/mono/graph data/test exp/mono/decode
fi

if [ $stage -le 6 ]; then
	echo ""
	echo "===== MONOPHONE MODEL ALIGNMENT ====="
	echo ""

	steps/align_si.sh --nj $nj \
		data/train data/lang exp/mono exp/mono_ali
fi

if [ $stage -le 7 ]; then
	echo ""
	echo "===== TRIPHONE MODEL (1st pass) TRAINING ====="
	echo ""

	steps/train_deltas.sh 500 2000 \
		data/train data/lang exp/mono_ali exp/tri1
fi

if [ $stage -le 8 ]; then
	echo ""
	echo "===== TRIPHONE MODEL (1st pass) DECODING ====="
	echo ""

	utils/mkgraph.sh data/lang exp/tri1 exp/tri1/graph
	steps/decode.sh --nj $nj \
		exp/tri1/graph data/test exp/tri1/decode
fi

echo ""
echo "===== DONE ====="
echo "If you want to do with other setting from scratch,"
echo " erase all files."
echo "e.g. : rm -rf data/ exp/ mfcc/"
echo ""

