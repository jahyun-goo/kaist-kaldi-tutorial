# This is the top-level Makefile for Kaldi.
# Also see kaldi.mk which supplies options and some rules
# used by the Makefiles in the subdirectories.

SHELL := /bin/bash


SUBDIRS = base matrix util feat tree gmm transform \
          fstext hmm lm decoder lat cudamatrix \
          bin fstbin gmmbin fgmmbin featbin \
          latbin lmbin

MEMTESTDIRS = base matrix util feat tree gmm transform \
          fstext hmm lm decoder lat \
          bin fstbin gmmbin fgmmbin featbin \
          latbin lmbin

CUDAMEMTESTDIR = cudamatrix

SUBDIRS_LIB = $(filter-out %bin, $(SUBDIRS))

KALDI_SONAME ?= libkaldi.so

# Optional subdirectories
EXT_SUBDIRS = # python-kaldi-decoding
EXT_SUBDIRS_LIB = $(filter-out %bin, $(EXT_SUBDIRS))

include kaldi.mk

# Reset the default goal, so that the all target will become default
.DEFAULT_GOAL :=
all:
	$(MAKE) checkversion
	$(MAKE) kaldi.mk
	$(MAKE) mklibdir
	$(MAKE) subdirs
	-echo Done

subdirs: $(SUBDIRS)

mklibdir:
	test -d $(KALDILIBDIR) || mkdir $(KALDILIBDIR)

#I don't want to call rm -rf
rmlibdir:
ifneq ($(KALDILIBDIR), )
	-rm $(KALDILIBDIR)/*{.so,.a,.o}
	-rmdir $(KALDILIBDIR)
else
	@true
endif

.PHONY: checkversion
checkversion:
ifeq ($(shell ./configure --version),$(CONFIGURE_VERSION))
	@echo "The version of configure script matches kaldi.mk version. Good."
else
	@echo ""
	@echo "The kaldi.mk file was generated using a different version of configure script. Please rerun the configure again"
	@test -f ./kaldi.mk && echo  "Hint: Previous configure command line: " && head -n 2 ./kaldi.mk | grep configure | sed 's/^# *//g'
	@echo ""
	@false
endif

biglib: $(SUBDIRS_LIB)
ifeq ($(KALDI_FLAVOR), dynamic)
ifeq ($(shell uname), Darwin)
	$(CXX) -dynamiclib -o $(KALDILIBDIR)/libkaldi.dylib -install_name @rpath/libkaldi.dylib -framework Accelerate $(LDFLAGS) $(SUBDIRS_LIB:=/*.dylib)
else
ifeq ($(shell uname), Linux)
	#$(warning the following command will probably fail, in that case add -fPIC to your CXXFLAGS and remake all)
	$(CXX) -shared -o $(KALDILIBDIR)/$(KALDI_SONAME) -Wl,-soname=$(KALDI_SONAME),--whole-archive  $(SUBDIRS_LIB:=/kaldi-*.a) $(LDLIBS) -Wl,--no-whole-archive
else
	$(error Dynamic libraries not supported on this platform. Run configure with --static flag. )
endif
endif
endif

biglibext: $(EXT_SUBDIRS_LIB)
ifeq ($(KALDI_FLAVOR), dynamic)
ifeq ($(shell uname), Darwin)
	$(CXX) -dynamiclib -o $(KALDILIBDIR)/libkaldi_ext.dylib -install_name @rpath/libkaldi_ext.dylib -framework Accelerate $(LDFLAGS) $(EXT_SUBDIRS_LIB:=/*.dylib)
else
ifeq ($(shell uname), Linux)
	#$(warning The following command will probably fail, in that case add -fPIC to your CXXFLAGS and remake all.)
	$(CXX) -shared -o $(KALDILIBDIR)/libkaldi_ext.so -Wl,-soname=libkaldi_ext.so,--whole-archive  $(EXT_SUBDIRS_LIB:=/kaldi-*.a) -Wl,--no-whole-archive
else
	$(error Dynamic libraries not supported on this platform. Run configure with --static flag. )
endif
endif
endif

kaldi.mk:
	@[ -f kaldi.mk ] || { echo "kaldi.mk does not exist; you have to run ./configure"; exit 1; }

# Compile optional stuff
ext: ext_depend $(SUBDIRS) $(EXT_SUBDIRS)
	-echo Done

check_portaudio:
	@[ -d ../tools/portaudio ] || ( cd ../tools;  ./install_portaudio.sh )

clean: rmlibdir
	-for x in $(SUBDIRS) $(EXT_SUBDIRS); do $(MAKE) -C $$x clean; done

distclean: clean
	-for x in $(SUBDIRS) $(EXT_SUBDIRS); do $(MAKE) -C $$x distclean; done

test: $(addsuffix /test, $(SUBDIRS_LIB))

ext_test: $(addsuffix /test, $(EXT_SUBDIRS_LIB))

# Define an implicit rule, expands to e.g.:
#  base/test: base
#     $(MAKE) -C base test
%/test: % mklibdir
	$(MAKE) -C $< test

cudavalgrind:
	-for x in $(CUDAMEMTESTDIR); do $(MAKE) -C $$x valgrind || { echo "valgrind on $$x failed"; exit 1; }; done

valgrind:
	-for x in $(MEMTESTDIRS); do $(MAKE) -C $$x valgrind || { echo "valgrind on $$x failed"; exit 1; }; done

base/.depend.mk:
	$(MAKE) depend

depend: $(addsuffix /depend, $(SUBDIRS))

%/depend:
	$(MAKE) -C $(dir $@) depend


ext_depend: check_portaudio
	-for x in $(EXT_SUBDIRS); do $(MAKE) -C $$x depend; done


.PHONY: $(SUBDIRS)
$(SUBDIRS) : mklibdir
	$(MAKE) -C $@

.PHONY: $(EXT_SUBDIRS)
$(EXT_SUBDIRS) : mklibdir ext_depend
	$(MAKE) -C $@


### Dependency list ###
# this is necessary for correct parallel compilation
#1)The tools depend on all the libraries
bin fstbin gmmbin fgmmbin featbin latbin lmbin: \
 base matrix util feat tree gmm transform fstext hmm \
 lm decoder lat cudamatrix

#2)The libraries have inter-dependencies
base: base/.depend.mk
matrix: base
util: base matrix
feat: base matrix util gmm transform tree
tree: base util matrix
gmm: base util matrix tree
transform: base util matrix gmm tree
fstext: base util matrix tree
hmm: base tree matrix util
lm: base util matrix fstext
decoder: base util matrix gmm hmm tree transform lat
lat: base util hmm tree matrix
cudamatrix: base util matrix
