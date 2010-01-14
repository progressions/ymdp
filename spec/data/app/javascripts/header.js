
/*
LOCAL NAMESPACES/CONSTANTS
*/

YAHOO.constants.base_url = "http://<%= @server %>.otherinbox.com/";
YAHOO.constants.controller_url = "http://<%= @server %>.otherinbox.com/ymdp";

YAHOO.oib.page_loaded = false;

YAHOO.namespace("<%= @view %>");

document.observe("dom:loaded", YAHOO.oib.init);
