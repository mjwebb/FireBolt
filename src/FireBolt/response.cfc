/**
* @transient true
*/
component{
	
	variables.FireBolt = "";
	
	this.types = {
		HTML:	"text/html",
		JSON:	"application/json",
		XML:	"application/xml",
		JS:		"application/javascript",
		GIF:	"image/gif",
		JPEG:	"image/jpeg",
		PNG:	"image/png",
		SVG:	"image/svg+xml",
		PDF:	"application/pdf"
	};

	this.codes = {
		OK:				200,
		CREATED:		201,
		ACCEPTED:		202,
		NOCONTENT:		204,
		RESETCONTENT:	205,
		PATIRALCONTENT:	206,
		MOVEDPERM:		301,
		FOUND:			302,
		BADREQUEST:		400,
		UNAUTHORISED:	401,
		FORBIDDEN:		403,
		NOTFOUND:		404,
		INVALIDMETHOD:	405,
		TIMEOUT:		408,
		ERROR:			500,
		NOTIMPLEMENTED:	501,
		UNAVAILABLE:	503
	};

	variables.statusText = {
		s200: "OK",
		s201: "Created",
		s202: "Accepted",
		s204: "No content",
		s205: "Reset content",
		s206: "Partial content",
		s301: "Moved permanently",
		s302: "Found",
		s400: "Bad request",
		s401: "Unauthorised",
		s403: "Forbidden",
		s404: "Not found",
		s405: "Method not allowed",
		s408: "Request timeout",
		s500: "Internal server error",
		s501: "Not implemented",
		s503: "Service unavailable"
	};

	variables.response = {
		body: "",
		length: 0,
		type: this.types.HTML,
		status: this.codes.OK,
		statusText: "",
		encoding: "utf-8"
	};

	variables.requestData = {};


	/**
	* @hint constructor
	*/
	public response function init(){
		//variables.FireBolt = arguments.FireBolt;
		return this;
	}

	

	/**
	* @hint attempt to detect a response content type
	*/
	public response function autoType(){
		// check for common 'types'
		if(isJSON(variables.response.body) 
			AND NOT isNUmeric(variables.response.body)){

			setType(this.types.JSON);

		}else if(isXMLDoc(variables.response.body) 
			OR isXmlRoot(variables.response.body) 
			OR isXmlNode(variables.response.body)){

			setType(this.types.XML);

		}else if(isSimpleValue(variables.response.body) 
			OR isNumeric(variables.response.body)){

			setType(this.types.HTML);

		}
		return this; // return this for chaining
	}

	/**
	* @hint attempt to detect the status text from the status code
	*/
	public response function autoStatusText(){
		local.key = "s" & getStatus();
		if(structKeyExists(variables.statusText, local.key)){
			setStatusText(variables.statusText[local.key]);
		}
		return this; // return this for chaining
	}	

	/**
	* @hint set a response content type
	*/
	public response function setType(string responseType){
		variables.response.type = arguments.responseType;
		return this; // return this for chaining
	}

	/**
	* @hint set a response encoding
	*/
	public response function setEncoding(string responseEncoding){
		variables.response.encoding = arguments.responseEncoding;
		return this; // return this for chaining
	}

	/**
	* @hint set a response status code
	*/
	public response function setStatus(numeric responseStatusCode){
		variables.response.status = arguments.responseStatusCode;
		return this; // return this for chaining
	}

	/**
	* @hint set a response status text
	*/
	public response function setStatusText(string responseStatusText){
		variables.response.statusText = arguments.responseStatusText;
		return this; // return this for chaining
	}

	/**
	* @hint set our response body
	*/
	public response function setBody(any bodyContent, boolean detectType=true){
		// check for converting to json of from XML objects
		if(isStruct(arguments.bodyContent) 
			OR isArray(arguments.bodyContent)){

			arguments.bodyContent = serializeJSON(arguments.bodyContent);

		}else if(isXMLDoc(arguments.bodyContent) 
			OR isXmlRoot(arguments.bodyContent) 
			OR isXmlNode(arguments.bodyContent)){

			arguments.bodyContent = ToString(arguments.bodyContent);
			
		}else if(isQuery(arguments.bodyContent)){
			// TODO: convert a query into a JSON string
		}

		// set our response body
		variables.response.body = arguments.bodyContent;

		// attempt to detect the content type
		if(arguments.detectType){
			autoType();
		}

		// determine the length of the repsonse
		if(isBinary(variables.response.body)){
			setLength(arrayLen(variables.response.body));
		}else{
			setLength(arrayLen(toBinary(toBase64(variables.response.body))));
		}


		return this; // return this for chaining
	}

	/**
	* @hint set our response length
	*/
	public response function setLength(numeric responseLength){
		variables.response.length = arguments.responseLength;
		return this; // return this for chaining
	}

	/**
	* @hint return our response struct
	*/
	public struct function get(){
		return variables.response;
	}

	/**
	* @hint return our response status code
	*/
	public numeric function getStatus(){
		return variables.response.status;
	}

	/**
	* @hint return our response status code
	*/
	public string function getStatusText(){
		return variables.response.statusText;
	}

	/**
	* @hint return our response type
	*/
	public string function getType(){
		return variables.response.type;
	}

	/**
	* @hint return our response body
	*/
	public any function getBody(){
		return variables.response.body;
	}

	/**
	* @hint return our response encoding
	*/
	public string function getEncoding(){
		return variables.response.encoding;
	}

	/**
	* @hint return our response length
	*/
	public numeric function getLength(){
		return variables.response.length;
	}


	/**
	* @hint return our request data
	*/
	public any function getRequestData(string key=""){
		if(!len(arguments.key)){
			return variables.requestData;
		}else{
			if(structKeyExists(variables.requestData, arguments.key)){
				return variables.requestData[arguments.key];
			}
		}
		return ""; // key not found
	}

	/**
	* @hint sets our request data
	*/
	public void function setRequestData(string key="", any value){
		variables.requestData[arguments.key] = arguments.value;
	}
	

}