KBNB: KBase IPython notebook service

`make deploy-server` deploys the ipython notebook server
`make deploy-client` deploys the web page 'analysis_builder.html' containing the UI and dashboard for running notebooks.

client config files:
1. (nginx) conf/nginx.cfg is used by Makefile - for configuring nginx 
2. (javascript) Retina/js/config.js is used by Retina javascript library - for ipython dashboard/builder page

server config files:
1. (bash) conf/ipython-cfg.sh is used by start_service and init-kbnb.sh - for starting ipython service
2. (python) ipy-mkmq/ipyMKMQ/config.py is used by python library - for setting KBase APIs in ipython environment
