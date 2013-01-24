TARGET ?= /kb/deployment
DEPLOY_RUNTIME ?= /kb/runtime
SERVICE = analysis_book
SERVICE_DIR = $(TARGET)/services/$(SERVICE)
DOC_DIR = $(SERVICE_DIR)/webroot
IPY_USER = ipython
HAS_USER := $(shell grep -c '^$(IPY_USER):' /etc/passwd)

default:
	echo "everything look good?"

add-user:
	if [ $(HAS_USER) -eq 0 ]; then useradd -m -s /bin/rbash $(IPY_USER); fi

build: build-client build-server

build-libs:
	git submodule init
	git submodule update
	cd ipy-qmqc; git pull origin master; python ./setup.py install
	./install-dependencies.sh

build-client:
	echo "No client to build"

build-server: build-libs add-user

deploy: deploy-client deploy-server

deploy-libs: build-libs add-user
	mkdir -p $(SERVICE_DIR)/notebook
	mkdir $(SERVICE_DIR)/notebook/images
	mkdir $(SERVICE_DIR)/notebook/tmp
	mkdir $(SERVICE_DIR)/notebook/lib
	mkdir $(SERVICE_DIR)/notebook/cache
	cp ipy-qmqc/R/* $(SERVICE_DIR)/notebook/lib/.

deploy-client:
	echo "No client to install"

deploy-scripts:
	mkdir -p $(SERVICE_DIR)
	cp service/start_service $(SERVICE_DIR)/start_service
	cp service/stop_service $(SERVICE_DIR)/stop_service
	chmod +x $(SERVICE_DIR)/start_service
	chmod +x $(SERVICE_DIR)/stop_service

deploy-server: deploy-libs deploy-scripts deploy-docs
	mkdir -p $(SERVICE_DIR)/ipython
	mkdir -p $(SERVICE_DIR)/log
	chown -R $(IPY_USER):$(IPY_USER) $(SERVICE_DIR)/ipython
	chown -R $(IPY_USER):$(IPY_USER) $(SERVICE_DIR)/notebook
	chown -R $(IPY_USER):$(IPY_USER) $(SERVICE_DIR)/log

deploy-docs:
	mkdir -p $(DOC_DIR)
	cp -R doc/* $(DOC_DIR)/.
	cp ipy-qmqc/README.md $(DOC_DIR)/ipy-qmqc.README

test: test-server test-scripts test-client

test-client:
	echo "No client to test"

test-scripts:
	echo "No scripts to test"

test-server:
	echo "No server test exists"
