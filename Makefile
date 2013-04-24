TARGET ?= /kb/deployment
DEPLOY_RUNTIME ?= /kb/runtime
SERVICE = analysis_book
SERVICE_DIR = $(TARGET)/services/$(SERVICE)
DOC_DIR = $(SERVICE_DIR)/webroot
IPY_USER = ipython
HAS_USER := $(shell grep -c '^$(IPY_USER):' /etc/passwd)

default:
	echo "nothing to do for default make"

build: build-client build-server

build-client:
	echo "building client libs ..."
	-rm -rf Retina
	git submodule init Retina
	git submodule update Retina
	cd Retina; git pull origin master

build-server: build-libs add-user

build-libs:
	echo "building server libs ..."
	./clean-ipython.sh
	-rm -rf ipython
	git submodule init ipython
	git submodule update ipython
	cp custom/custom.js ipython/IPython/frontend/html/notebook/static/js/custom.js
	cp custom/custom.css ipython/IPython/frontend/html/notebook/static/css/custom.css
	cp custom/notebook.html ipython/IPython/frontend/html/notebook/templates/notebook.html
	cd ipython; python ./setup.py install
	-rm -rf ipy-mkmq
	git submodule init ipy-mkmq
	git submodule update ipy-mkmq
	cd ipy-mkmq; git pull origin master; python ./setup.py install
	./install-dependencies.sh

add-user:
	echo "adding user $(IPY_USER) ..."
	if [ $(HAS_USER) -eq 0 ]; then useradd -m -s /bin/rbash $(IPY_USER); fi

deploy: deploy-client deploy-server

deploy-client: build-client
	echo "deploying client ..."
	-rm -rf $(SERVICE_DIR)/www
	mkdir -p $(SERVICE_DIR)/www
	cp Retina/communities.html $(SERVICE_DIR)/www/.
	cp Retina/*_splash.html $(SERVICE_DIR)/www/.
	cp Retina/analysis_builder.html $(SERVICE_DIR)/www/.
	cp Retina/mgoverview.html $(SERVICE_DIR)/www/.
	cp Retina/wizard.html $(SERVICE_DIR)/www/.
	cp -R Retina/css $(SERVICE_DIR)/www/.
	cp -R Retina/data $(SERVICE_DIR)/www/.
	cp -R Retina/fonts $(SERVICE_DIR)/www/.
	cp -R Retina/images $(SERVICE_DIR)/www/.
	cp -R Retina/js $(SERVICE_DIR)/www/.
	cp -R Retina/renderers $(SERVICE_DIR)/www/.
	cp -R Retina/widgets $(SERVICE_DIR)/www/.
	-ln -s communities.html $(SERVICE_DIR)/www/index.html
	-ln -s analysis_builder_splash.html $(SERVICE_DIR)/www/nb_dashboard_splash.html
	cp conf/nginx.cfg /etc/nginx/sites-available/default
	echo "restarting nginx ..."
	/etc/init.d/nginx restart
	/etc/init.d/nginx force-reload

deploy-server: build-server deploy-libs deploy-scripts deploy-docs
	echo "deploying service ..."
	mkdir -p $(SERVICE_DIR)/ipython
	mkdir -p $(SERVICE_DIR)/log
	mkdir -p $(SERVICE_DIR)/conf
	cp conf/ipython-cfg.sh $(SERVICE_DIR)/conf/ipython-cfg.sh
	chown -R $(IPY_USER):$(IPY_USER) $(SERVICE_DIR)/ipython
	chown -R $(IPY_USER):$(IPY_USER) $(SERVICE_DIR)/notebook
	chown -R $(IPY_USER):$(IPY_USER) $(SERVICE_DIR)/log

deploy-libs:
	echo "deploying server libs ..."
	mkdir -p $(SERVICE_DIR)/notebook
	mkdir -p $(SERVICE_DIR)/notebook/images
	mkdir -p $(SERVICE_DIR)/notebook/tmp
	mkdir -p $(SERVICE_DIR)/notebook/lib
	mkdir -p $(SERVICE_DIR)/notebook/cache
	cp ipy-mkmq/R/* $(SERVICE_DIR)/notebook/lib/.

deploy-scripts:
	echo "deploying server scripts ..."
	mkdir -p $(SERVICE_DIR)
	cp service/start_service $(SERVICE_DIR)/start_service
	cp service/stop_service $(SERVICE_DIR)/stop_service
	chmod +x $(SERVICE_DIR)/start_service
	chmod +x $(SERVICE_DIR)/stop_service

deploy-docs:
	echo "deploying docs ..."
	mkdir -p $(DOC_DIR)
	cp -R doc/* $(DOC_DIR)/.
	cp ipy-mkmq/README.md $(DOC_DIR)/ipy-mkmq.README

test: test-scripts test-service test-client

test-client:
	echo "testing client ..."
	test/test_web.sh localhost/analysis_builder.html client

test-scripts:
	echo "No scripts to test"

test-service:
	echo "testing service ..."
	test/test_web.sh localhost:7051 service
