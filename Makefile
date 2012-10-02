TARGET = /kb/deployment
SERVICE = analysis_book
SERVICE_DIR = $(TARGET)/services/$(SERVICE)
IPY_USER = ipython
HAS_USER := $(shell grep -c '^$(IPY_USER):' /etc/passwd)

all: deploy

deploy: deploy-services

deploy-services:
	git submodule init
	git submodule update
	if [ $(HAS_USER) -eq 0 ]; then useradd -m -s /bin/rbash $(IPY_USER); fi
	cd ipy-qmqc; python ./setup.py install
	R CMD BATCH install-matr.R
	./install-service.sh $(SERVICE_DIR) $(IPY_USER)
	if [ ! -d $(SERVICE_DIR)/doc ]; then mkdir $(SERVICE_DIR)/doc; fi
	cp -R doc/* $(SERVICE_DIR)/doc/.
	cp matR/README $(SERVICE_DIR)/doc/matR.README
	cp ipy-qmqc/README.md $(SERVICE_DIR)/doc/ipy-qmqc.README
