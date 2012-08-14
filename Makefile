TARGET ?= /kb/deployment
SERVICE = analysis_book
SERVICE_DIR = $(TARGET)/services/$(SERVICE)

all:

deploy: deploy-services

deploy-services:
	cd ipy-qmqc
	python ./setup.py install
	cd ..
	R CMD BATCH install-matr.R
	mkdir -p $(SERVICE_DIR)/doc
	cp matR/README $(SERVICE_DIR)/doc/matR.README
	cp ipy-qmqc/README.md $(SERVICE_DIR)/doc/ipy-qmqc.README
