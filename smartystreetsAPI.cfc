component hint="https://smartystreets.com/docs/cloud/best-practices"{
	
	//usage
	//smartystreetsAPI = createObject("component",smartystreetsAPI).init(authid,authtoken);
	//Save or cache that in your dependency injector, or any other method for storing beans
	function init(authid,authtoken){
		variables.authid = authid;
		variables.authtoken = authtoken;
		//Basic Endpoint for validating addresses
		variables.streetAPI = {endpoint="https://us-street.api.smartystreets.com/street-address",host="us-street.api.smartystreets.com"};
		//City/ZIP API to get 
		variables.zipcodeAPI = {endpoint="https://us-zipcode.api.smartystreets.com/lookup",host="us-zipcode.api.smartystreets.com"};
		//Fuzzy validation for oddly formatted addresses
		variables.extractAPI = {endpoint="https://us-extract.api.smartystreets.com",host="us-extract.api.smartystreets.com"};
		//Download Zipcode Latest API
		variables.downloadZipcodeAPI = {endpoint="https://download.api.smartystreets.com/addons/zipcodes/latest.zip",host=""}
		return this;
	}

	//Starts off the HTTP Request, does minimal logic
	//Functions pass in a variables.{{ENDPOINT}}
	private function buildHTTPrequest(endpoint){
		var httpRequestObject = new http();
		httpRequestObject.setMethod("get");
		httpRequestObject.setURL(endpoint.endpoint);
		httpRequestObject.addParam(type="URL",name="auth-id",value=variables.authid);
		httpRequestObject.addParam(type="URL",name="auth-token",value=variables.authtoken);
		httpRequestObject.addParam(type="header",name="Content-Type",value="application/json");
		if(len(endpoint.host)){
			httpRequestObject.addParam(type="header",name="Host",value=endpoint.host);
		}
		return httpRequestObject;
	}
	
	//Sends the final object, and returns the entire response object back after deserializing the json.
	//I am making a choice to leave error handling up to calling code, and handling none of it here.
	//This isn't the best choice, as I should do some error handling here, but unclear what
	private function sendHTTPrequest(httpRequestObject){
		var httpResponse = httpRequestObject.send().getPrefix();
		//Adobe Coldfusion does not allow you to edit the struct from http.send(), but Lucee does
		//Adobe Coldfusion also does not allow you to structcopy() it.
		//So the solution is to do a loop and copy all variables yourself
		var newHttpResponse = structNew();
		for(var key in httpResponse){
			structInsert(newHttpResponse,key,httpResponse[key],true);
		}
		if(structKeyExists(newHttpResponse,"Filecontent") && isSimpleValue(newHttpResponse.filecontent) &&  isJSON(trim(newHttpResponse.filecontent))){
			var fileContent = deserializeJSON(newHttpResponse.fileContent);
			structInsert(newHttpResponse, "Filecontent", fileContent, true);
		}
		return newHttpResponse;
	}
	
	//Calling code should probably specify what params they are passing in for brevity, order is based on smartystreets docs
	//Example smartystreetsAPI.lookup(street="123 Fake St", city="Fake Town",state="UT",zipcode="12345")
	function streetaddress(input_id="",street="",street2="",secondary="",city="",state="",zipcode="",lastline="",addressee="",urbanization="",match="strict",candidates=1) hint="https://smartystreets.com/docs/cloud/us-street-api" {
		var httpRequestObject = buildHTTPRequest(variables.streetAPI);
		for(var key in arguments){
			if(len(trim(arguments[key]))){
				httpRequestObject.addParam(type="URL",name=lcase(key),value=arguments[key]);
			}
		}
		return sendHTTPrequest(httpRequestObject);
	}
	
	//I assume that the addressArray is serialized before going into this function
	//The reason for this is because CF's built serializer will mess up zipcodes and any other field that is detected as a numeric
	//You should use a custom serializer for CF, there are a variety, CFDOCS.org recommends one
	//Look at SmartyStreets docs to understand how to structure the data
	//Key names need to be lower case. I use struct["keyname"] as opposed to struct.keyname
	function bulkStreetAddress(serializedAddressArray,match="") hint="https://smartystreets.com/docs/cloud/us-street-api"{
		var httpRequestObject = buildHTTPRequest(variables.streetAPI);
		httpRequestObject.setMethod("post");
		httpRequestObject.addParam(type="body", value="#serializedAddressArray#");
		if(len(trim(match))){
			httpRequestObject.addParam(type="header",name="match",value=match);
		}
		return sendHTTPrequest(httpRequestObject);
	}
	
	
	function lookup(city="",state="",zipcode="",input_id="") hint="https://smartystreets.com/docs/cloud/us-zipcode-api" {
		var httpRequestObject = buildHTTPRequest(variables.zipcodeAPI);
		for(var key in arguments){
			if(len(trim(arguments[key]))){
				httpRequestObject.addParam(type="URL",name=lcase(key),value=arguments[key]);
			}
		}
		return sendHTTPrequest(httpRequestObject);
	}

	function downloadZipCodeLatest() hint="https://account.smartystreets.com/##tools" {
		var httpRequestObject = buildHTTPRequest(variables.downloadZipcodeAPI);
		httpRequestObject.setgetasbinary("yes");
		return sendHTTPrequest(httpRequestObject);
		//To access Zip object
		//response = smartyStreetsAPI.downloadZipCodeLatest().Filecontent;
		//fileWrite("C:\path\to\write\test.zip",response);
	}
	
}