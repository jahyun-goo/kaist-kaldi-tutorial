export KALDI_ROOT=`pwd`/../..
[ -f $KALDI_ROOT/tools/env.sh ] && . $KALDI_ROOT/tools/env.sh
export SRILM=$KALDI_ROOT/tools/srilm
export PATH=$PWD/utils/:$KALDI_ROOT/tools/openfst/bin:$SRILM/bin/i686-m64:$PWD:$PATH
[ ! -f $KALDI_ROOT/tools/config/common_path.sh ] && echo >&2 "The standard file $KALDI_ROOT/tools/config/common_path.sh is not present -> Exit!" && exit 1
. $KALDI_ROOT/tools/config/common_path.sh
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:$KALDI_ROOT/src/lib:$KALDI_ROOT/tools/openfst/lib:$SRILM/lib/i686-m64
export LC_ALL=C
