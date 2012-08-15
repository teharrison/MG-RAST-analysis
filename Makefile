TARGET = /kb/deployment
SERVICE = analysis_book
SERVICE_DIR = $(TARGET)/services/$(SERVICE)
IPY_USER = ipython

all:
	git submodule init
	git submodule update
	useradd -m -s /bin/rbash $(IPY_USER)

deploy: deploy-services

deploy-services:
	cd ipy-qmqc; python ./setup.py install
	R CMD BATCH install-matr.R
	./install-service.sh $(SERVICE_DIR) $(IPY_USER)
	mkdir -p $(SERVICE_DIR)/doc
	cp matR/README $(SERVICE_DIR)/doc/matR.README
	cp ipy-qmqc/README.md $(SERVICE_DIR)/doc/ipy-qmqc.README
