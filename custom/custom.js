/*
Placeholder for custom user javascript

mainly to be overridden in profile/static/custom/custom.js

This will always be an empty file in IPython
*/

// hide header and toolbar-buttons
setTimeout(function(){document.getElementById("header").style.display="none";}, 200);
var mtb = document.getElementById("maintoolbar");
if (mtb) {
    mtb.style.display="none";
}

// hide built-in dashboard
var tabdiv = document.getElementById("tabs");
if (tabdiv) {
    tabdiv.style.display="none";
}

// receive messages sent from other frames
window.addEventListener("message", receiveMessage, false);
function receiveMessage(event) {
    // parse the data into an object
    var data = event.data;
    data.data = data.data.replace(/##/g, "\\'").replace(/!!/g, '"');
    eval(data.data);
};
