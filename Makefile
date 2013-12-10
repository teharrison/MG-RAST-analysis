TARGET ?= /kb/deployment
DEPLOY_RUNTIME ?= /kb/runtime
SERVICE = analysis_book
SERVICE_DIR = $(TARGET)/services/$(SERVICE)
DOC_DIR = $(SERVICE_DIR)/webroot
IPY_USER = ipython
HAS_USER := $(shell grep -c '^$(IPY_USER):' /etc/passwd)

default:
	echo "nothing to do for default make"

uninstall: clean
	-rm -rf $(SERVICE_DIR)
	-rm -rf /mnt/notebook

clean:
	./clean-ipython.sh
	-rm -rf ipython
	-rm -rf Retina
	-rm -rf ipy-mkmq

build: build-client build-server

build-client:
	echo "building client libs ..."
	-rm -rf Retina
	git submodule init Retina
	git submodule update Retina
	cd Retina; git pull -q origin master

build-server: build-libs add-user

build-libs:
	echo "building server libs ..."
	./clean-ipython.sh
	-rm -rf ipython
	git submodule init ipython
	git submodule update --recursive ipython
	cp custom/custom.js ipython/IPython/html/static/custom/custom.js
	cp custom/custom.css ipython/IPython/html/static/custom/custom.css
	#cp custom/notebook.html ipython/IPython/html/templates/notebook.html
	echo "gitdir: ../../../../../.git/modules/ipython/modules/IPython/html/static/components" > ipython/IPython/html/static/components/.git
	cd ipython; python ./setup.py install
	-rm -rf ipy-mkmq
	git submodule init ipy-mkmq
	git submodule update ipy-mkmq
	cd ipy-mkmq; git pull -q origin master; python ./setup.py install

add-user:
	echo "adding user $(IPY_USER) ..."
	if [ $(HAS_USER) -eq 0 ]; then useradd -m -s /bin/rbash $(IPY_USER); fi

deploy: deploy-client deploy-server

deploy-client: build-client
	echo "deploying client ..."
	-rm -rf $(SERVICE_DIR)/www
	mkdir -p $(SERVICE_DIR)/www
	cp Retina/analysis_builder.html $(SERVICE_DIR)/www/index.html
	cp -R Retina/css $(SERVICE_DIR)/www/.
	cp -R Retina/data $(SERVICE_DIR)/www/.
	cp -R Retina/fonts $(SERVICE_DIR)/www/.
	cp -R Retina/images $(SERVICE_DIR)/www/.
	cp -R Retina/js $(SERVICE_DIR)/www/.
	cp -R Retina/renderers $(SERVICE_DIR)/www/.
	cp -R Retina/widgets $(SERVICE_DIR)/www/.
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
	test/test_web.sh localhost/index.html client

test-scripts:
	echo "No scripts to test"

test-service:
	echo "testing service ..."
	test/test_web.sh localhost:7051 service
