TARGET ?= /kb/deployment
SERVICE = analysis_book
SERVICE_DIR = $(TARGET)/services/$(SERVICE)

all:
	git submodule init
	git submodule update

deploy: deploy-services

deploy-services:
	cd ipy-qmqc; python ./setup.py install
	R CMD BATCH install-matr.R
	mkdir -p $(SERVICE_DIR)/log
	mkdir -p $(SERVICE_DIR)/doc
	mkdir -p $(SERVICE_DIR)/ipython
	mkdir -p $(SERVICE_DIR)/notebook
	cp matR/README $(SERVICE_DIR)/doc/matR.README
	cp ipy-qmqc/README.md $(SERVICE_DIR)/doc/ipy-qmqc.README
