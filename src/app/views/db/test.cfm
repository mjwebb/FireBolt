

<h2>DB</h2>
<!--- 
<cfdump var="#getData('user2')#"> --->

<cfset local.insp = FB().getObject("dbInspector@db")>

<!--- <cfdump var="#serializeJSON(insp.inspectTable("test", "tbl_test"))#"> --->

<!--- <cfdump var="#getApplicationMetadata()#">  --->

<cfset local.testGateway = FB().getObject("testGateway")>
<!--- <cfdump var="#local.testGateway.getConfig()#"> --->
<!--- <cfoutput>#FB().getSetting("modules.db.dsn")#</cfoutput> --->

<!---
<cfset local.q = local.testGateway.from("tbl_test")
	.where("test_id = 1")
	.select("")>


<cfset local.testBean = FB().getObject("testBean")>
<cfset local.testBean.setTest("wagga")>
<cfoutput>#local.testBean.isDirty()#</cfoutput>
--->

<!---
<cfset local.t = getTickCount()>
<cfset local.qb = local.testGateway.qb().from("tbl_test")>
<!--- <cfset local.q = local.qb.from("tbl_test").get(options:{datasource=FB().getSetting("modules.db.dsn")})> --->
<cfset local.q = local.testGateway.executeQB(local.qb)>
<cfoutput>#getTickCount() - local.t#<br /></cfoutput>

<cfdump var="#local.q#">
--->
<br />

<cfset local.t = getTickCount()>
<cfset local.q = local.testGateway.getAll()>
<cfoutput>#getTickCount() - local.t#<br /></cfoutput>
<cfoutput>#local.q.recordCount#<br /></cfoutput>

<!--- <cfset local.t = getTickCount()>
<cfset local.q = local.testGateway.get(2)>
<cfoutput>#getTickCount() - local.t#<br /></cfoutput>
<cfoutput>#local.q.recordCount#<br /></cfoutput> --->

<cfset local.t = getTickCount()>
<cfset local.q = local.testGateway.get(2)>
<cfoutput>#getTickCount() - local.t#<br /></cfoutput>
<cfoutput>#local.q.recordCount#<br /></cfoutput>


<cfdump var="#local.q#">


<cfset p = {pk: 2}>
<cfdump var="#local.testGateway.processParams(p)#">
<cfscript>
if(isStruct(p)){
	for(local.key in p){
		local.value = p[local.key];
		
		if((isStruct(local.value) AND NOT structKeyExists(local.value, "cfsqltype")) OR isSimpleValue(local.value)){
			if(local.testGateway.isColumnDefined(local.key)){
				if(isStruct(local.value)){
					local.value.cfsqltype = local.testGateway.getColumn(local.key).cfSQLDataType;
				}else{
					local.value = {
						value: local.value,
						cfsqltype: local.testGateway.getColumn(local.key).cfSQLDataType
					};
				}
			}else if(local.key IS "pk"){
				writeOutput("lkh");
				if(isStruct(local.value)){
					local.value.cfsqltype = local.testGateway.getConfig().pk.cfSQLDataType;
					writeOutput("lkh");
				}else{
					writeOutput("lkh");
					p[local.key] = {
						value: local.value,
						cfsqltype: local.testGateway.getConfig().pk.cfSQLDataType
					};
					writeDump(local.value);
				}
			}
		}
	}
}
</cfscript>