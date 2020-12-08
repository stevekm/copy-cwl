export SHELL:=/bin/bash
.ONESHELL:
UNAME:=$(shell uname)

# ~~~~~ Install Dependencies ~~~~~ #
export PATH:=$(CURDIR)/conda/bin:$(PATH)
unexport PYTHONPATH
unexport PYTHONHOME

ifeq ($(UNAME), Darwin)
CONDASH:=Miniconda3-4.5.4-MacOSX-x86_64.sh
endif

ifeq ($(UNAME), Linux)
CONDASH:=Miniconda3-4.5.4-Linux-x86_64.sh
endif

CONDAURL:=https://repo.continuum.io/miniconda/$(CONDASH)

conda:
	@echo ">>> Setting up conda..."
	@wget "$(CONDAURL)" && \
	bash "$(CONDASH)" -b -p conda && \
	rm -f "$(CONDASH)"

install: conda
	conda install -y \
	conda-forge::jq=1.5
	pip install \
	cwltool==2.0.20200126090152 \
	cwlref-runner==1.0

# make the input JSON file for running the CWL
FILE:=file.txt
INPUT_JSON:=input.json
$(INPUT_JSON):
	jq -n --arg filepath "$(FILE)" '{ "input_file": {"class": "File", "path": $$filepath}}' > $(INPUT_JSON)
.PHONY:$(INPUT_JSON)

# locations for running the CWL workflow
CWL:=$(CURDIR)/copy.cwl
TMP_DIR:=$(CURDIR)/tmp/
OUTPUT_DIR:=$(CURDIR)/output/
CACHE_DIR:=$(CURDIR)/cache/
# run the CWL workflow
run: $(INPUT_JSON)
	cwl-runner \
	--tmpdir-prefix $(TMP_DIR) \
	--outdir $(OUTPUT_DIR) \
	--cachedir $(CACHE_DIR) \
	--copy-outputs \
	--preserve-environment PATH \
	$(CWL) $(INPUT_JSON)
