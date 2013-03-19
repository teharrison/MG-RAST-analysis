/*
Placeholder for custom user javascript

mainly to be overridden in profile/static/js/custom.js

This will always be an empty file in IPython
*/

// hide header and toolbar-buttons
setTimeout(function(){document.getElementById("header").style.display="none";}, 200);
document.getElementById("maintoolbar").style.display="none";

// receive messages sent from other frames
window.addEventListener("message", receiveMessage, false);
function receiveMessage(event) {
    // parse the data into an object
    var data = event.data;
    data.data = data.data.replace(/##/g, "\\'").replace(/!!/g, '"');
    eval(data.data);
};
