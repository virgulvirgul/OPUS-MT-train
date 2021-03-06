# -*-makefile-*-


##----------------------------------------------
## BPE
##----------------------------------------------

bpe-models: ${BPESRCMODEL} ${BPETRGMODEL}

## source/target specific bpe
## - make sure to leave the language flags alone!
## - make sure that we do not delete the BPE code files
## if the BPE models already exist
## ---> do not create new ones and always keep the old ones
## ---> need to delete the old ones if we want to create new BPE models


# BPESRCMODEL = ${TRAIN_SRC}.bpe${SRCBPESIZE:000=}k-model
# BPETRGMODEL = ${TRAIN_TRG}.bpe${TRGBPESIZE:000=}k-model

## NEW: always use the same name for the BPE models
## --> avoid overwriting validation/test data with new segmentation models
##     if a new data set is used
BPESRCMODEL = ${WORKDIR}/train/${BPEMODELNAME}.src.bpe${SRCBPESIZE:000=}k-model
BPETRGMODEL = ${WORKDIR}/train/${BPEMODELNAME}.trg.bpe${TRGBPESIZE:000=}k-model


.PRECIOUS: ${BPESRCMODEL} ${BPETRGMODEL}

## we keep the dependency on LOCAL_TRAIN_SRC
## to make multi-threaded make calls behave properly
## --> otherwise there can be multiple threads writing to the same file!

${BPESRCMODEL}: ${LOCAL_TRAIN_SRC}
ifneq (${wildcard $@},)
	@echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	@echo "!!!!!!!! $@ already exists!"
	@echo "!!!!!!!! re-use the old one even if there is new training data"
	@echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
else
	mkdir -p ${dir $@}
ifeq (${USE_TARGET_LABELS},1)
	cut -f2- -d ' ' ${LOCAL_TRAIN_SRC} > ${LOCAL_TRAIN_SRC}.text
	python3 ${SNMTPATH}/learn_bpe.py -s $(SRCBPESIZE) < ${LOCAL_TRAIN_SRC}.text > $@
	rm -f ${LOCAL_TRAIN_SRC}.text
else
	python3 ${SNMTPATH}/learn_bpe.py -s $(SRCBPESIZE) < ${LOCAL_TRAIN_SRC} > $@
endif
endif

## no labels on the target language side
${BPETRGMODEL}: ${LOCAL_TRAIN_TRG}
ifneq (${wildcard $@},)
	@echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	@echo "!!!!!!!! $@ already exists!"
	@echo "!!!!!!!! re-use the old one even if there is new training data"
	@echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
else
	mkdir -p ${dir $@}
	python3 ${SNMTPATH}/learn_bpe.py -s $(TRGBPESIZE) < ${LOCAL_TRAIN_TRG} > $@
endif



%.src.bpe${SRCBPESIZE:000=}k: %.src ${BPESRCMODEL}
ifeq (${USE_TARGET_LABELS},1)
	cut -f1 -d ' ' $< > $<.labels
	cut -f2- -d ' ' $< > $<.txt
	python3 ${SNMTPATH}/apply_bpe.py -c $(word 2,$^) < $<.txt > $@.txt
	paste -d ' ' $<.labels $@.txt > $@
	rm -f $<.labels $<.txt $@.txt
else
	python3 ${SNMTPATH}/apply_bpe.py -c $(word 2,$^) < $< > $@
endif

%.trg.bpe${TRGBPESIZE:000=}k: %.trg ${BPETRGMODEL}
	python3 ${SNMTPATH}/apply_bpe.py -c $(word 2,$^) < $< > $@


## this places @@ markers in front of punctuations
## if they appear to the right of the segment boundary
## (useful if we use BPE without tokenization)
%.segfix: %
	perl -pe 's/(\P{P})\@\@ (\p{P})/$$1 \@\@$$2/g' < $< > $@



%.trg.txt: %.trg
	mkdir -p ${dir $@}
	mv $< $@

%.src.txt: %.src
	mkdir -p ${dir $@}
	mv $< $@

