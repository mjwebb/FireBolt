component accessors="true"{

	property name="sessionService" inject="sessionService@common";

	/**
	* @hint constructor
	*/
	public any function init(){
		return this;
	}


	/**
	* @hint generate a new CSRF token and save it to our session state
	*/
	public string function generateCSRFToken(string key="CSRFToken", boolean forceNew=false){
		local.token = sessionService.get(arguments.key);
		if(isNull(local.token) OR arguments.forceNew){
			local.token = sessionService.generateToken();
			sessionService.set(arguments.key, local.token);
		}
		return local.token;
	}


	/**
	* @hint verify a given CSRF token against the value held in session
	*/
	public boolean function verifyCSRFToken(string token, string key="CSRFToken"){
		if(arguments.token IS sessionService.get(arguments.key)){
			return true;
		}
		return false;
	}


	/**
	* @hint check headers to attempt to verify that a request is from the same origin as the application
	*/
	public boolean function isSameOrigin(){
		local.headers = getHttpRequestData().headers;
		local.host = targetOrigin();

		local.headersToCheck = ["Origin","Referer"];

		for(local.headerTest in local.headersToCheck){
			if(structKeyExists(local.headers, local.headerTest)){
				if(local.headers[local.headerTest] CONTAINS local.host){
					return true;
				}else{
					return false
				}
			}	
		}
		
		return false;
	}

	/**
	* @hint determine our target origin
	*/
	public string function targetOrigin(){
		local.headers = getHttpRequestData().headers;

		local.host = "";

		if(structKeyExists(local.headers, "X-Forwarded-Host")){
			local.host = local.headers["X-Forwarded-Host"];
		}else if(structKeyExists(local.headers, "Host")){
			local.host = local.headers["Host"];
		}else if(structKeyExists(cgi, "HTTP_HOST")){
			local.host = cgi.HTTP_HOST;
		}

		return local.host;
	}
		

}