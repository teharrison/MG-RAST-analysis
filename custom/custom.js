/*
Placeholder for custom user javascript

mainly to be overridden in profile/static/js/custom.js

This will always be an empty file in IPython
*/

// hide header and toolbar-buttons
jQuery('div#header').toggle();
IPython.toolbar.toggle();
IPython.layout_manager.do_resize();

// receive messages sent from other frames
window.addEventListener("message", receiveMessage, false);
function receiveMessage(event) {
    // parse the data into an object
    var data = event.data;
    data.data = data.data.replace(/##/g, "\\'").replace(/!!/g, '"');
    eval(data.data);
};
