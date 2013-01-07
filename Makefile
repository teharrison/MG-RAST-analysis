TARGET ?= /kb/deployment
SERVICE = analysis_book
SERVICE_DIR = $(TARGET)/services/$(SERVICE)
IPY_USER = ipython
HAS_USER := $(shell grep -c '^$(IPY_USER):' /etc/passwd)

all:
	git submodule init
	git submodule update
	cd ipy-qmqc; git pull; python ./setup.py install
	if [ $(HAS_USER) -eq 0 ]; then useradd -m -s /bin/rbash $(IPY_USER); fi
	./install-dependencies.sh $(SERVICE_DIR) $(IPY_USER)

deploy:
	./install-service.sh $(SERVICE_DIR) $(IPY_USER)
	if [ ! -d $(SERVICE_DIR)/doc ]; then mkdir $(SERVICE_DIR)/doc; fi
	cp -R doc/* $(SERVICE_DIR)/doc/.
	cp ipy-qmqc/README.md $(SERVICE_DIR)/doc/ipy-qmqc.README
