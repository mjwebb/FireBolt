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
		string cookieName="___ga_sc"){
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
	* @hint returns our session token with a session_ prefix
	*/
	public string function getCacheToken(){
		local.token = getSessionToken();
		if(len(local.token)){
			return "session_" & local.token;
		}
		return "";
	}

	/**
	* @hint sets our session identifier cookie
	*/
	public void function setSessionCookie(string sessionID){
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
			start: now(),
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
		if(!len(arguments.token)) arguments.token = getCacheToken();
		if(len(arguments.token)){
			lock name="#arguments.token#" timeout="10"{
				return cacheGet(arguments.token);
			}
		}
		return;
		//throw("Session is not defined");
	}

	/**
	* @hint returns true if an active session exists for a given token
	*/
	public boolean function hasSession(string token=""){
		local.sess = getSession(arguments.token);
		return !isNull(local.sess);
	}

	/**
	* @hint save a session struct to cache
	*/
	public any function putSession(struct sess){
		local.token = getCacheToken();
		if(!len(local.token)){
			local.newToken = generateSessionToken();
			setSessionCookie(local.newToken);
			local.token = getCacheToken();
		}
		lock name="#local.token#" timeout="10"{
			cachePut(local.token, arguments.sess, 0, variables.sessionLength);
		}
	}

	/**
	* @hint gets a session struct
	*/
	public any function keepAlive(){
		local.token = getCacheToken();

		if(len(local.token) OR !variables.isLazy){
			local.sess = getSession();

			if(isNull(local.sess) AND !variables.isLazy){
				local.sess = getEmptySession();
			}

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
		if(!len(arguments.token)) arguments.token = getCacheToken();
		if(len(arguments.token)){
			cacheRemove(arguments.token, false);
		}
	}

	/**
	* @hint clears all 
	*/
	public void function clearAll(){
		local.ids = cacheGetAllIDs();
		for(local.id in local.ids){
			if(left(local.id, 8) IS "session_"){
				lock name="#local.id#" timeout="10"{
					cacheRemove(local.id, false);
				}
			}
		}
	}

	/**
	* @hint returns the number of seconds that a session has been active for 
	*/
	public numeric function duration(){
		local.sess = getSession();
		if(!isNull(local.sess)){
			return dateDiff("s", local.sess.start, now());
		}
		return 0;
	}

}