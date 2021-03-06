

MEMAD_LANGS = de en fi fr nl sv


#-------------------------------------------------------------------
# models for the MeMAD project
#-------------------------------------------------------------------


memad-multi-train:
	${MAKE} SRCLANGS="${MEMAD_LANGS}" TRGLANGS="${MEMAD_LANGS}" MODELTYPE=transformer data
	${MAKE} SRCLANGS="${MEMAD_LANGS}" TRGLANGS="${MEMAD_LANGS}" MODELTYPE=transformer \
		WALLTIME=72 HPC_MEM=8g HPC_CORES=1 HPC_DISK=1500 train.submit-multigpu

%-memad-multi:
	${MAKE} SRCLANGS="${MEMAD_LANGS}" TRGLANGS="${MEMAD_LANGS}" MODELTYPE=transformer data
	${MAKE} SRCLANGS="${MEMAD_LANGS}" TRGLANGS="${MEMAD_LANGS}" MODELTYPE=transformer \
		${@:-memad-multi=}



memad2en:
	${MAKE} LANGS="${MEMAD_LANGS}" PIVOT=en all2pivot


memad-fiensv:
	${MAKE} SRCLANGS=sv TRGLANGS=fi traindata-spm
	${MAKE} SRCLANGS=sv TRGLANGS=fi devdata-spm
	${MAKE} SRCLANGS=sv TRGLANGS=fi wordalign-spm
	${MAKE} SRCLANGS=sv TRGLANGS=fi WALLTIME=72 HPC_MEM=4g HPC_CORES=1 train-spm.submit-multigpu
	${MAKE} SRCLANGS=sv TRGLANGS=fi reverse-data-spm
	${MAKE} SRCLANGS=fi TRGLANGS=sv WALLTIME=72 HPC_MEM=4g HPC_CORES=1 train-spm.submit-multigpu
	${MAKE} SRCLANGS=en TRGLANGS=fi traindata-spm
	${MAKE} SRCLANGS=en TRGLANGS=fi devdata-spm
	${MAKE} SRCLANGS=en TRGLANGS=fi wordalign-spm
	${MAKE} SRCLANGS=en TRGLANGS=fi WALLTIME=72 HPC_MEM=4g HPC_CORES=1 train-spm.submit-multigpu
	${MAKE} SRCLANGS=en TRGLANGS=fi reverse-data-spm
	${MAKE} SRCLANGS=fi TRGLANGS=en WALLTIME=72 HPC_MEM=4g HPC_CORES=1 train-spm.submit-multigpu

memad250-fiensv:
	${MAKE} CONTEXT_SIZE=250 memad-fiensv_doc

memad-fiensv_doc:
	${MAKE} SRCLANGS=sv TRGLANGS=fi traindata-doc
	${MAKE} SRCLANGS=sv TRGLANGS=fi devdata-doc
	${MAKE} SRCLANGS=sv TRGLANGS=fi WALLTIME=72 HPC_MEM=8g MARIAN_WORKSPACE=20000 HPC_CORES=1 train-doc.submit-multigpu
	${MAKE} SRCLANGS=sv TRGLANGS=fi reverse-data-doc
	${MAKE} SRCLANGS=fi TRGLANGS=sv WALLTIME=72 HPC_MEM=8g MARIAN_WORKSPACE=20000 HPC_CORES=1 train-doc.submit-multigpu
	${MAKE} SRCLANGS=en TRGLANGS=fi traindata-doc
	${MAKE} SRCLANGS=en TRGLANGS=fi devdata-doc
	${MAKE} SRCLANGS=en TRGLANGS=fi WALLTIME=72 HPC_MEM=4g HPC_CORES=1 train-doc.submit-multigpu
	${MAKE} SRCLANGS=en TRGLANGS=fi reverse-data-doc
	${MAKE} SRCLANGS=fi TRGLANGS=en WALLTIME=72 HPC_MEM=4g HPC_CORES=1 train-doc.submit-multigpu

memad-fiensv_more:
	${MAKE} SRCLANGS=sv TRGLANGS=fi traindata-doc
	${MAKE} SRCLANGS=sv TRGLANGS=fi devdata-doc
	${MAKE} SRCLANGS=sv TRGLANGS=fi WALLTIME=72 HPC_MEM=8g MARIAN_WORKSPACE=20000 HPC_CORES=1 train-doc.submit-multigpu
	${MAKE} SRCLANGS=sv TRGLANGS=fi reverse-data-doc
	${MAKE} SRCLANGS=fi TRGLANGS=sv WALLTIME=72 HPC_MEM=8g MARIAN_WORKSPACE=20000 HPC_CORES=1 train-doc.submit-multigpu
	${MAKE} CONTEXT_SIZE=500 memad-fiensv_doc


memad:
	for s in fi en sv de fr nl; do \
	  for t in en fi sv de fr nl; do \
	    if [ "$$s" != "$$t" ]; then \
	      if ! grep -q 'stalled ${MARIAN_EARLY_STOPPING} times' ${WORKHOME}/$$s-$$t/${DATASET}.*.valid${NR.log}; then\
	        ${MAKE} SRCLANGS=$$s TRGLANGS=$$t bilingual-dynamic; \
	      fi \
	    fi \
	  done \
	done

#	        ${MAKE} SRCLANGS=$$s TRGLANGS=$$t data; \
#	        ${MAKE} SRCLANGS=$$s TRGLANGS=$$t HPC_CORES=1 HPC_MEM=4g train.submit-multigpu; \



fiensv_bpe:
	${MAKE} SRCLANGS=fi TRGLANGS=sv traindata-bpe 
	${MAKE} SRCLANGS=fi TRGLANGS=sv devdata-bpe
	${MAKE} SRCLANGS=fi TRGLANGS=sv wordalign-bpe
	${MAKE} SRCLANGS=fi TRGLANGS=sv WALLTIME=72 HPC_MEM=4g HPC_CORES=1 train-bpe.submit-multigpu
	${MAKE} SRCLANGS=fi TRGLANGS=en traindata-bpe 
	${MAKE} SRCLANGS=fi TRGLANGS=en devdata-bpe
	${MAKE} SRCLANGS=fi TRGLANGS=en wordalign-bpe
	${MAKE} SRCLANGS=fi TRGLANGS=en WALLTIME=72 HPC_MEM=4g HPC_CORES=1 train-bpe.submit-multigpu


fiensv_spm:
	${MAKE} SRCLANGS=fi TRGLANGS=sv traindata-spm 
	${MAKE} SRCLANGS=fi TRGLANGS=sv devdata-spm
	${MAKE} SRCLANGS=fi TRGLANGS=sv wordalign-spm
	${MAKE} SRCLANGS=fi TRGLANGS=sv WALLTIME=72 HPC_MEM=4g HPC_CORES=1 train-spm.submit-multigpu
	${MAKE} SRCLANGS=fi TRGLANGS=en traindata-spm 
	${MAKE} SRCLANGS=fi TRGLANGS=en devdata-spm
	${MAKE} SRCLANGS=fi TRGLANGS=en wordalign-spm
	${MAKE} SRCLANGS=fi TRGLANGS=en WALLTIME=72 HPC_MEM=4g HPC_CORES=1 train-spm.submit-multigpu

fifr_spm:
	${MAKE} SRCLANGS=fr TRGLANGS=fi traindata-spm 
	${MAKE} SRCLANGS=fr TRGLANGS=fi devdata-spm
	${MAKE} SRCLANGS=fr TRGLANGS=fi wordalign-spm
	${MAKE} SRCLANGS=fr TRGLANGS=fi WALLTIME=72 HPC_MEM=4g HPC_CORES=1 train-spm.submit-multigpu
	${MAKE} SRCLANGS=fr TRGLANGS=fi reverse-data-spm
	${MAKE} SRCLANGS=fi TRGLANGS=fr WALLTIME=72 HPC_MEM=4g HPC_CORES=1 train-spm.submit-multigpu

fifr_doc:
	${MAKE} SRCLANGS=fr TRGLANGS=fi traindata-doc
	${MAKE} SRCLANGS=fr TRGLANGS=fi devdata-doc
	${MAKE} SRCLANGS=fr TRGLANGS=fi WALLTIME=72 HPC_MEM=8g MARIAN_WORKSPACE=20000 HPC_CORES=1 train-doc.submit-multigpu
	${MAKE} SRCLANGS=fr TRGLANGS=fi reverse-data-doc
	${MAKE} SRCLANGS=fi TRGLANGS=fr WALLTIME=72 HPC_MEM=8g MARIAN_WORKSPACE=20000 HPC_CORES=1 train-doc.submit-multigpu


fide_spm:
	${MAKE} SRCLANGS=de TRGLANGS=fi traindata-spm 
	${MAKE} SRCLANGS=de TRGLANGS=fi devdata-spm
	${MAKE} SRCLANGS=de TRGLANGS=fi wordalign-spm
	${MAKE} SRCLANGS=de TRGLANGS=fi WALLTIME=72 HPC_MEM=4g HPC_CORES=1 train-spm.submit-multigpu
	${MAKE} SRCLANGS=de TRGLANGS=fi reverse-data-spm
	${MAKE} SRCLANGS=fi TRGLANGS=de WALLTIME=72 HPC_MEM=4g HPC_CORES=1 train-spm.submit-multigpu



memad_spm:
	for s in fi en sv de fr nl; do \
	  for t in en fi sv de fr nl; do \
	    if [ "$$s" != "$$t" ]; then \
	      if ! grep -q 'stalled ${MARIAN_EARLY_STOPPING} times' ${WORKHOME}/$$s-$$t/*.valid${NR.log}; then\
	          ${MAKE} SRCLANGS=$$s TRGLANGS=$$t traindata-spm; \
	          ${MAKE} SRCLANGS=$$s TRGLANGS=$$t devdata-spm; \
	          ${MAKE} SRCLANGS=$$s TRGLANGS=$$t wordalign-spm; \
	          ${MAKE} SRCLANGS=$$s TRGLANGS=$$t HPC_CORES=1 HPC_MEM=4g train-spm.submit-multigpu; \
	      fi \
	    fi \
	  done \
	done


memad_doc:
	for s in fi en sv; do \
	  for t in en fi sv; do \
	    if [ "$$s" != "$$t" ]; then \
	      if ! grep -q 'stalled ${MARIAN_EARLY_STOPPING} times' ${WORKHOME}/$$s-$$t/*.valid${NR.log}; then\
	          ${MAKE} SRCLANGS=$$s TRGLANGS=$$t traindata-doc; \
	          ${MAKE} SRCLANGS=$$s TRGLANGS=$$t devdata-doc; \
	          ${MAKE} SRCLANGS=$$s TRGLANGS=$$t HPC_CORES=1 HPC_MEM=4g MODELTYPE=transformer train-doc.submit-multigpu; \
	      fi \
	    fi \
	  done \
	done

memad_docalign:
	for s in fi en sv; do \
	  for t in en fi sv; do \
	    if [ "$$s" != "$$t" ]; then \
	      if ! grep -q 'stalled ${MARIAN_EARLY_STOPPING} times' ${WORKHOME}/$$s-$$t/*.valid${NR.log}; then\
	          ${MAKE} SRCLANGS=$$s TRGLANGS=$$t traindata-doc; \
	          ${MAKE} SRCLANGS=$$s TRGLANGS=$$t devdata-doc; \
	          ${MAKE} SRCLANGS=$$s TRGLANGS=$$t HPC_CORES=1 HPC_MEM=4g train-doc.submit-multigpu; \
	      fi \
	    fi \
	  done \
	done



enfisv:
	${MAKE} SRCLANGS="en fi sv" TRGLANGS="en fi sv" traindata devdata wordalign
	${MAKE} SRCLANGS="en fi sv" TRGLANGS="en fi sv" HPC_MEM=4g WALLTIME=72 HPC_CORES=1 train.submit-multigpu



en-fiet:
	${MAKE} SRCLANGS="en" TRGLANGS="et fi" traindata devdata
	${MAKE} SRCLANGS="en" TRGLANGS="et fi" HPC_MEM=4g HPC_CORES=1 train.submit-multigpu
	${MAKE} TRGLANGS="en" SRCLANGS="et fi" traindata devdata
	${MAKE} TRGLANGS="en" SRCLANGS="et fi" HPC_MEM=4g HPC_CORES=1 train.submit-multigpu



memad-multi1:
	for s in "${SCANDINAVIAN}" "en fr" "et hu fi" "${WESTGERMANIC}" "ca es fr ga it la oc pt_br pt"; do \
	      ${MAKE} SRCLANGS="$$s" TRGLANGS="$$s" traindata devdata; \
	      ${MAKE} SRCLANGS="$$s" TRGLANGS="$$s" HPC_MEM=4g HPC_CORES=1 train.submit-multigpu; \
	done
	for s in "${SCANDINAVIAN}" "en fr" "et hu fi" "${WESTGERMANIC}" "ca es fr ga it la oc pt_br pt"; do \
	  for t in "${SCANDINAVIAN}" "en fr" "et hu fi" "${WESTGERMANIC}" "ca es fr ga it la oc pt_br pt"; do \
	    if [ "$$s" != "$$t" ]; then \
	      ${MAKE} SRCLANGS="$$s" TRGLANGS="$$t" traindata devdata; \
	      ${MAKE} SRCLANGS="$$s" TRGLANGS="$$t" HPC_MEM=4g HPC_CORES=1 train.submit-multigpu; \
	    fi \
	  done \
	done

memad-multi2:
	for s in "en fr" "et hu fi" "${WESTGERMANIC}" "ca es fr ga it la oc pt_br pt"; do \
	  for t in "${SCANDINAVIAN}" "en fr" "et hu fi" "${WESTGERMANIC}" "ca es fr ga it la oc pt_br pt"; do \
	    if [ "$$s" != "$$t" ]; then \
	      ${MAKE} SRCLANGS="$$s" TRGLANGS="$$t" traindata devdata; \
	      ${MAKE} SRCLANGS="$$s" TRGLANGS="$$t" HPC_MEM=4g HPC_CORES=1 train.submit-multigpu; \
	    fi \
	  done \
	done

memad-multi3:
	for s in "${SCANDINAVIAN}" "${WESTGERMANIC}" "ca es fr ga it la oc pt_br pt"; do \
	      ${MAKE} SRCLANGS="$$s" TRGLANGS="en" traindata devdata; \
	      ${MAKE} SRCLANGS="$$s" TRGLANGS="en" HPC_MEM=4g HPC_CORES=1 train.submit-multigpu; \
	      ${MAKE} SRCLANGS="en" TRGLANGS="$$s" traindata devdata; \
	      ${MAKE} SRCLANGS="en" TRGLANGS="$$s" HPC_MEM=4g HPC_CORES=1 train.submit-multigpu; \
	done
	${MAKE} SRCLANGS="en" TRGLANGS="fr" traindata devdata
	${MAKE} SRCLANGS="en" TRGLANGS="fr" HPC_MEM=4g HPC_CORES=1 train.submit-multigpu
	${MAKE} SRCLANGS="fr" TRGLANGS="en" traindata devdata
	${MAKE} SRCLANGS="fr" TRGLANGS="en" HPC_MEM=4g HPC_CORES=1 train.submit-multigpu





memad-fi:
	for l in en sv de fr; do \
	  ${MAKE} SRCLANGS=$$l TRGLANGS=fi traindata devdata; \
	  ${MAKE} SRCLANGS=$$l TRGLANGS=fi HPC_MEM=4g HPC_CORES=1 train.submit-multigpu; \
	  ${MAKE} TRGLANGS=$$l SRCLANGS=fi traindata devdata; \
	  ${MAKE} TRGLANGS=$$l SRCLANGS=fi HPC_MEM=4g HPC_CORES=1 train.submit-multigpu; \
	done

