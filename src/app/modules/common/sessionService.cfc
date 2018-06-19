component accessors="true"{

	property name="sessionLength" default="#createTimeSpan(0,0,20,0)#";
	property name="cookieName" default="___ga_sc";
	property name="securityService" inject="securityService@common";
	variables.isLazy = true;

	/**
	* @hint constructor
	*/
	public any function init(
		any securityService,
		numeric sessionLength=createTimespan(0,0,20,0),
		boolean isLazy=true,
		string cookieName="__ga_sc"){
		variables.sessionLength = arguments.sessionLength;
		variables.isLazy = arguments.isLazy;
		variables.cookieName =  arguments.cookieName;
		return this;
	}

	/**
	* @hint returns true if a session cookie is defined
	*/
	public boolean function sessionCookieExists(){
		return structKeyExists(cookie, variables.cookieName);
	}

	/**
	* @hint returns our session cookie value
	*/
	public string function getSessionToken(){
		if(sessionCookieExists()){
			return cookie[variables.cookieName];
		}else{
			return "";
		}
	}

	/**
	* @hint sets our session identifier cookie
	*/
	public void function setSessionToken(string sessionID){
		cookie[variables.cookieName] = {
			path: "/",
			value: arguments.sessionID,
			httponly: true
		};
	}

	/**
	* @hint creates a token that is used to identify a session
	*/
	public string function generateSessionToken(){
		return hash(createUUID(), "SHA-384", "UTF-8");
	}

	/**
	* @hint returns a struct used to hold session data
	*/
	public struct function getEmptySession(){
		return {
			data: {},
			timestamp: now()
		};
	}

	/**
	* @hint sets a session value
	*/
	public void function set(string key, any value){
		local.sess = getSession();
		if(isNull(local.sess)){
			local.sess = getEmptySession();
		}
		local.sess.data[arguments.key] = arguments.value;
		putSession(local.sess);	
	}


	/**
	* @hint gets a session value
	*/
	public any function get(string key){
		local.sess = getSession();
		if(!isNull(local.sess) 
			AND structKeyExists(local.sess, "data")
			AND structKeyExists(local.sess.data, arguments.key)){

			return local.sess.data[arguments.key];
		}
		return;
		//throw("Session is not defined");
	}

	/**
	* @hint gets a session struct
	*/
	public any function getSession(string token=""){
		if(!len(arguments.token)) arguments.token = getSessionToken();
		if(len(arguments.token)){
			lock name="sess-#arguments.token#" timeout="10"{
				return cacheGet(arguments.token);
			}
		}
		return;
		//throw("Session is not defined");
	}

	/**
	* @hint save a session struct to cache
	*/
	public any function putSession(struct sess){
		local.token = getSessionToken();
		if(!len(local.token)){
			local.token = generateSessionToken();
			setSessionToken(local.token);
		}
		lock name="sess-#local.token#" timeout="10"{
			cachePut(local.token, arguments.sess, variables.sessionLength, variables.sessionLength);
		}
	}

	/**
	* @hint gets a session struct
	*/
	public any function keepAlive(){
		local.token = getSessionToken();
		if(len(local.token)){
			local.sess = getSession();
			if(!isNull(local.sess)){
				local.sess.timestamp = now();
				putSession(local.sess);
			}
		}
	}

	/**
	* @hint clears values for a given session token, or the current session
	*/
	public void function clear(string token=""){
		if(!len(arguments.token)) arguments.token = getSessionToken();
		if(len(arguments.token)){
			cacheRemove(arguments.token, false);	
		}
	}

}