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
	echo "adding user $(IPY_USER) ..."
	if [ $(HAS_USER) -eq 0 ]; then useradd -m -s /bin/rbash $(IPY_USER); fi

build: build-client build-server

build-libs:
	echo "building server libs ..."
	pip uninstall ipython
	git submodule init
	git submodule update
	cd ipython; git pull origin master; python ./setup.py install
	cd ipy-mkmq; git pull origin master; python ./setup.py install
	./install-dependencies.sh

build-client:
	echo "No client to build"

build-server: build-libs add-user

deploy: deploy-client deploy-server

deploy-libs:
	echo "deploying server libs ..."
	mkdir -p $(SERVICE_DIR)/notebook
	mkdir -p $(SERVICE_DIR)/notebook/images
	mkdir -p $(SERVICE_DIR)/notebook/tmp
	mkdir -p $(SERVICE_DIR)/notebook/lib
	mkdir -p $(SERVICE_DIR)/notebook/cache
	cp ipy-mkmq/R/* $(SERVICE_DIR)/notebook/lib/.

deploy-client: build-client
	echo "No client to deploy"

deploy-scripts:
	echo "deploying server scripts ..."
	mkdir -p $(SERVICE_DIR)
	cp service/start_service $(SERVICE_DIR)/start_service
	cp service/stop_service $(SERVICE_DIR)/stop_service
	chmod +x $(SERVICE_DIR)/start_service
	chmod +x $(SERVICE_DIR)/stop_service

deploy-server: build-server deploy-libs deploy-scripts deploy-docs
	echo "deploying service ..."
	mkdir -p $(SERVICE_DIR)/ipython
	mkdir -p $(SERVICE_DIR)/log
	chown -R $(IPY_USER):$(IPY_USER) $(SERVICE_DIR)/ipython
	chown -R $(IPY_USER):$(IPY_USER) $(SERVICE_DIR)/notebook
	chown -R $(IPY_USER):$(IPY_USER) $(SERVICE_DIR)/log

deploy-docs:
	echo "deploying docs ..."
	mkdir -p $(DOC_DIR)
	cp -R doc/* $(DOC_DIR)/.
	cp ipy-mkmq/README.md $(DOC_DIR)/ipy-mkmq.README

test: test-server test-scripts test-client

test-client:
	echo "No client to test"

test-scripts:
	echo "No scripts to test"

test-server:
	echo "No server test exists"
