component{

	variables.FireBolt;
	variables.eventListeners = {};
	variables.configService;

	/**
	* @hint constructor
	* **/
	public eventService function init(framework FireBolt=application.FireBolt){
		variables.FireBolt = arguments.FireBolt;
		variables.FireBolt.registerMethods("trigger,addListener,removeListener,listenerExists,getListeners", this);
		variables.configService = new configService("eventListeners");
		addConfigListeners();
		return this;
	}

	/**
	* @hint add listeners defined in our config file
	* **/
	public void function addConfigListeners(){
		local.config = variables.configService.getConfig();
		for(local.item in local.config){
			structAppend(local.item, {
				async = false
			}, false);
			for(local.eventName in listToArray(local.item.event)){
				addListener(trim(local.eventName), local.item.listener, local.item.async);
			}
		}
	}

	/**
	* @hint adds a listener
	* **/
	public boolean function addListener(
		required string eventName, 
		required string listener, 
		boolean async=false){

		if(!listenerExists(arguments.eventName, arguments.listener)){
			if(!structKeyExists(variables.eventListeners, arguments.eventName)){
				variables.eventListeners[arguments.eventName] = [];
			}
			arrayAppend(variables.eventListeners[arguments.eventName], {
				target = arguments.listener,
				async = arguments.async
			});
		}
		return false;
	}

	/**
	* @hint removes a listener or an entire event
	* **/
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
	* **/
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
	* **/
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
	* **/
	public any function trigger(
		required string eventName, 
		struct args={}){
		
		local.listeners = getListeners(arguments.eventName);
		for(local.listener in local.listeners){
			// fire our event for our listener
			despatch(arguments.eventName, local.listener.target, arguments.args, local.listener.async)
		}
	}

	/**
	* @hint despatch an event
	* **/
	public any function despatch(
		required string eventName, 
		required string target, 
		struct args={}, 
		boolean async=false){

	}


}