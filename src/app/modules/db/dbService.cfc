component accessors="true"{

	property name="FB" inject="framework";
	
	/**
	* @hint constructor
	*/
	public function init(any db){
		variables.db = arguments.db;
		return this;
	}

	/**
	* @hint returns the gateway object for our root
	*/
	public any function getGateway(){
		if(!structKeyExists(variables, "Gateway")){
			variables.Gateway =  db.gateway(rootName()); //getFB().getObject(rootName() & "Gateway");
		}
		return variables.Gateway;
	}

	/**
	* @hint determines our root name from our metadata name
	*/
	public string function rootName(){
		local.root = listLast(getMetaData(this).name, ".");
		if(right(local.root, 4) IS "Bean"){
			local.root = mid(local.root, 1, len(local.root) - 4);
		}else{
			local.r7 = right(local.root, 7);
			if(local.r7 IS "Gateway" OR local.r7 IS "Service"){
				local.root = mid(local.root, 1, len(local.root) - 7);
			}
		}
		return local.root;
	}


	/**
	* @hint save our given bean
	*/
	public any function save(any bean){

		local.config = getGateway().getConfig();

		if(arguments.bean.getID()){
			// UPDATE
			local.dec = getGateway().update();
			for(local.col in local.config.cols){
				if(!structKeyExists(local.col, "pk") OR !local.col.pk){
					local.dec.set(local.col.name, arguments.bean.get(local.col.name));
				}
			}

			local.dec.where(local.config.pk.name & "= :pk")
				.withParam("pk", arguments.bean.getID())
				.go();

		}else{
			// INSERT
			local.dec = getGateway().insert();
			for(local.col in local.config.cols){
				if(!structKeyExists(local.col, "pk") OR !local.col.pk){
					local.dec.set(local.col.name, arguments.bean.get(local.col.name));
				}
			}
			local.result = local.dec.go();

			local.id = getGateway().getInsertID(local.result);
			arguments.bean.setID(local.id);
		}

		// check for many-to-many data
		saveLinkedData(arguments.bean);
		
		

		return arguments.bean;
	}


	/**
	* @hint save our given bean
	*/
	public any function saveLinkedData(any bean){
		local.linkedDataToSave = arguments.bean.getLinkedSaveData();
		for(local.linkedKey in local.linkedDataToSave){

			local.linkedConfig = arguments.bean.getConfig().getManyToMany(local.linkedKey);
			if(isStruct(local.linkedConfig)){
				local.linkedData = local.linkedDataToSave[local.linkedKey];

				local.relatedGateway = db.gateway(local.linkedConfig.model); //getFB().getObject(local.linkedConfig.model & "Gateway");
				local.relatedPK = local.relatedGateway.getConfigReader().getPK();
				
				if(!structKeyExists(local.linkedConfig, "FK1")){
					local.linkedConfig.FK1 = replaceNoCase(arguments.bean.getPK(), "_id", "ID");
				}
				if(!structKeyExists(local.linkedConfig, "FK2")){
					local.linkedConfig.FK2 = replaceNoCase(local.relatedPK, "_id", "ID");
				}

				local.params = {
					FK1: {
						value: arguments.bean.getID(),
						cfsqltype: arguments.bean.getConfig().getConfig().pk.cfSQLDataType

					}
				}

				local.sqlDELETE = "DELETE FROM #local.linkedConfig.intermediary# WHERE #local.linkedConfig.FK1# = :FK1";
				local.sqlINSERT = "";
				if(arrayLen(local.linkedData)){
					local.sqlINSERT = "INSERT INTO #local.linkedConfig.intermediary# (#local.linkedConfig.FK1#, #local.linkedConfig.FK2#) SELECT :FK1 AS #local.linkedConfig.FK1#, #local.relatedPK# FROM #local.relatedGateway.getConfigReader().table()# WHERE #local.relatedPK# IN (:linked)";
					local.params.linked = {
						value: arrayToList(local.linkedData),
						cfsqltype: local.relatedGateway.getConfigReader().getConfig().pk.cfSQLDataType,
						list: true
					}
				}

				variables.Gateway.runQuery(local.sqlDELETE & chr(13) & chr(10) & local.sqlINSERT, local.params);
			}
		}
	}

	

	/**
	* @hint delete our given bean
	*/
	public any function delete(any bean){
		
	}

	/**
	* @hint gets linked data from a defined many-to-many relationship
	*/
	public any function getLinked(any bean, string manyToManyName, boolean forceRead=false, string condition="", struct params={}){
		local.linkedConfig = arguments.bean.getConfig().getManyToMany(arguments.manyToManyName);
		if(isBoolean(local.linkedConfig)){
			throw(message="Many To Many relationship '#arguments.manyToManyName#' is not defined", type="DB Service");
		}

		if(arguments.bean.isLinkedDataDefined(arguments.manyToManyName) AND !arguments.forceRead){
			return arguments.bean.getLinkedData(arguments.manyToManyName);
		}

		local.relatedGateway = db.gateway(local.linkedConfig.model); //getFB().getObject(local.linkedConfig.model & "Gateway");
		local.relatedPK = local.relatedGateway.getConfigReader().getPK();

		// query parameters
		local.params = {
			FK1: {
				value: arguments.bean.getID(),
				cfsqltype: arguments.bean.getConfig().getConfig().pk.cfSQLDataType
			}
		}

		if(!structKeyExists(local.linkedConfig, "FK1")){
			local.linkedConfig.FK1 = replaceNoCase(arguments.bean.getPK(), "_id", "ID");
		}
		if(!structKeyExists(local.linkedConfig, "FK2")){
			local.linkedConfig.FK2 = replaceNoCase(local.relatedPK, "_id", "ID");
		}

		// build our query
		local.def = local.relatedGateway.from();
		local.where = "#local.relatedPK# IN (SELECT #local.linkedConfig.FK2# FROM #local.linkedConfig.intermediary# WHERE #local.linkedConfig.FK1# = :FK1)";
		if(len(arguments.condition)){
			local.where = local.where & " AND " & arguments.condition;
		}
		local.def.where(local.where);

		// merge params
		structAppend(local.params, arguments.params);
		local.def.withParams(local.params);

		// order
		if(structKeyExists(local.linkedConfig, "order")){
			local.def.orderBy(local.linkedConfig.order);
		}

		// execute our query
		local.q =local.def.get();

		// save data into our bean
		arguments.bean.setLinkedData(arguments.manyToManyName, local.q);

		return arguments.bean.getLinkedData(arguments.manyToManyName);
	}

	public any function setLinked(any bean, string manyToManyName, array data=[]){
		arguments.bean.setLinkedSaveData(arguments.manyToManyName, arguments.data);
	}


}