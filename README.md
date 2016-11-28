# coldfusion-smartystreets
Coldfusion/CFML wrapper for the Smarty Streets REST API, https://smartystreets.com

https://smartystreets.com/docs/cloud/us-street-api

Tested and built on Adobe Coldfusion 2016, limited testing on Lucee 5
usage
 - smartystreetsAPI = createObject("component",smartystreetsAPI).init(authid,authtoken);
 - Save or cache that in your dependency injector, or any other method for storing beans