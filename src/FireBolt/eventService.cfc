component accessors="true"{

	property FireBolt;

	variables.eventListeners = {};
	variables.configService = "";

	/**
	* @hint constructor
	*/
	public eventService function init(framework FireBolt){
		setFireBolt(arguments.FireBolt);
		getFireBolt().registerMethods("trigger,addListeners,addListener,removeListener,listenerExists,getListeners", this);
		variables.configService = new configService("eventListeners");
		addConfigListeners();
		return this;
	}

	/**
	* @hint add listeners defined in our config file
	*/
	public void function addConfigListeners(){
		local.config = variables.configService.getConfig();
		addListeners(local.config);
	}

	/**
	* @hint adds listener from an array of configuration structs
	*/
	public void function addListeners(array listeners){
		for(local.item in arguments.listeners){
			structAppend(local.item, {
				async: false,
				isFireAndForget: false
			}, false);
			for(local.eventName in listToArray(local.item.event)){
				addListener(trim(local.eventName), local.item.listener, local.item.async, local.item.isFireAndForget);
			}
		}
	}

	/**
	* @hint adds a listener
	*/
	public boolean function addListener(
		required string eventName, 
		required string listener, 
		boolean async=false,
		boolean isFireAndForget=false){

		if(!listenerExists(arguments.eventName, arguments.listener)){
			if(!structKeyExists(variables.eventListeners, arguments.eventName)){
				variables.eventListeners[arguments.eventName] = [];
			}
			arrayAppend(variables.eventListeners[arguments.eventName], {
				target: arguments.listener,
				async: arguments.async,
				isFireAndForget: arguments.isFireAndForget
			});
		}
		return false;
	}

	/**
	* @hint removes a listener or an entire event
	*/
	public void function removeListener(
		string eventName="", 
		string listener=""){

		if(len(arguments.eventName)){
			if(len(arguments.listener)){
				// we have an event name AND a listener
				local.attachedListeners = variables.eventListeners[arguments.eventName];
				for(local.i=1; local.i LTE arrayLen(local.attachedListeners); local.i = local.i + 1){
					if(local.attachedListeners[local.i].target IS arguments.listener){
						arrayDeleteAt(local.attachedListeners, local.i);
						break;
					}
				}
			}else{
				// we are removing an entire event
				structDelete(variables.eventListeners, arguments.eventName);
			}
		}else if(len(arguments.listener)){
			// we are removing all instances of a listener
			for(local.eventName in structKeyArray(variables.eventListeners)){
				local.attachedListeners = variables.eventListeners[local.eventName];
				for(local.i=1; local.i LTE arrayLen(local.attachedListeners); local.i = local.i + 1){
					if(local.attachedListeners[local.i].target IS arguments.listener){
						arrayDeleteAt(local.attachedListeners, local.i);
						local.i = local.i - 1;
					}
				}
				if(!arrayLen(local.attachedListeners)){
					structDelete(variables.eventListeners, local.eventName);
				}
			}
		}
	}


	/**
	* @hint checks for the existence of a listener
	*/
	public boolean function listenerExists(
		required string eventName, 
		required string listener){

		if(structKeyExists(variables.eventListeners, arguments.eventName)){
			for(local.l in variables.eventListeners[arguments.eventName]){
				if(local.l.target IS arguments.listener){
					return true;
				}
			}
		}
		return false;
	}

	/**
	* @hint returns our current listeners
	*/
	public any function getListeners(string eventName=""){
		if(!len(arguments.eventName)){
			return variables.eventListeners;
		}

		if(structKeyExists(variables.eventListeners, arguments.eventName)){
			return variables.eventListeners[arguments.eventName];
		}

		return [];
	}

	/**
	* @hint trigger an event
	*/
	public any function trigger(
		required string eventName, 
		struct args={},
		numeric timout=1){
		
		local.listeners = getListeners(arguments.eventName);

		local.currentThreadName = createObject("java", "java.lang.Thread").currentThread().getName();
		local.syncThreads = "";
		local.i = 0;
		local.threadUUID = createUUID();


		for(local.listener in local.listeners){
			// fire our event for our listener

			local.i = local.i + 1;

			// for some reason our arguments get destroyed on multiple event handlers for the same event
			// by converting this to a local scope within our loop of listeners we prevent this... not sure why...
			local.eventArgs = {};
			for(local.arg in arguments.args){
				local.eventArgs[local.arg] = arguments.args[local.arg];
			}


			if(local.listener.async){

				local.threadName = "e_" & local.currentThreadName & "_" & local.threadUUID & "_" & local.i;
				if(!local.listener.isFireAndForget){
					local.syncThreads = listAppend(local.syncThreads, local.threadName);
				}
				
				thread action="run" 
					name=local.threadName
					eventName=arguments.eventName
					listener=local.listener 
					args=local.eventArgs{
					despatch(attributes.eventName, attributes.listener.target, attributes.args);
				}

			}else{
				despatch(arguments.eventName, local.listener.target, local.eventArgs);
			}

		}

		if(len(local.syncThreads)){
			thread action="join" 
				name="#local.syncThreads#" 
				timeout="#arguments.timeout*1000#";
		}
		


	}

	/**
	* @hint despatch an event
	*/
	public any function despatch(
		required string eventName, 
		required string target, 
		struct args={}){


		local.method = listLast(arguments.target, ".");
		local.objectName = left(arguments.target, len(arguments.target)-len(local.method)-1);

		local.object = getFireBolt().getObject(local.objectName);

		//local.object[local.method](argumentCollection:arguments.args);
		invoke(local.object, local.method, arguments.args);

	}


}