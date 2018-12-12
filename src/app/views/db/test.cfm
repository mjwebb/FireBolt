

<h2>DB</h2>
<!--- 
<cfdump var="#getData('user2')#"> --->

<cfset local.db = FB().getObject("db@db")>

<!--- <cfset local.insp = FB().getObject("dbInspector@db")>
<cfset local.schema = local.insp.inspectTable("test", "tbl_category")>
<cfset local.def = local.insp.buildDefinition(local.schema)>
<cfoutput><pre>#encodeForHTML(local.def)#</pre></cfoutput> --->
<!--- 
<cfset local.dbConfig = local.insp.buildSchema("test")>
<cfset fileWrite("/app/config/db-default.cfc", local.dbConfig)>
<pre><cfoutput>#local.dbConfig#</cfoutput></pre>
 --->
<!--- build a new model --->
<!--- <cfset local.insp.buildModel("test", "category", "tbl_category", FB().getSetting('paths.models'))> --->


<!--- <cfdump var="#deserializeJSON(local.js)#"> --->

<!--- <cfdump var="#getApplicationMetadata()#">  --->

<cfset local.testGateway = local.db.gateway("test")>
<cfset local.testService = local.db.service("test")>
<!--- <cfdump var="#local.testGateway.getConfig()#"> --->


<!---
<cfset local.q = local.testGateway.from("tbl_test")
	.where("test_id = 1")
	.select("")>


<cfset local.testBean = FB().getObject("testBean")>
<cfset local.testBean.setTest("wagga")>
<cfoutput>#local.testBean.isDirty()#</cfoutput>
--->
<cfset local.testBean = local.db.bean("test")>
<!--- <cfdump var="#local.testBean.getConfig().getConfig()#">
<cfdump var="#local.testBean.getConfig().buildInstance()#">
 --->
<cfdump var="#local.testBean.getSnapShot()#">



<!--- ============================== --->
<!--- GET BEAN --->
<cfset local.t = getTickCount()>
<cfset local.testBean = local.db.bean("test", 1)>
<cfoutput>BEAN ID: #local.testBean.getID()#<br /></cfoutput>
<cfoutput>GET: #getTickCount() - local.t#ms<br /></cfoutput>
<cfset local.testBean.setName("Dave Wagga")>
<cfset local.testBean.setStartDate(now())>
<cfset local.testBean.setBool(!local.testBean.getBool())>
<!--- <cfdump var="#local.testBean.getSnapshot(true)#" label="prev"> --->
<!--- <cfdump var="#local.testBean.getSnapshot()#" label="updated"> --->


<!--- <cfset local.testBean.setLinkedSaveData("categories", [1])> --->
<!--- <cfset local.testService.setLinked(local.testBean, "categories", [2])> --->
<!--- <cfset local.testBean.setLinkedSaveData("categories", [1,2,4])> --->


<!--- ============================== --->
<!--- SAVE --->
<cfset local.t = getTickCount()>
<cfset local.db.save(local.testBean)>
<cfoutput>SAVE: #getTickCount() - local.t#ms<br /></cfoutput>
<cfdump var="#local.testBean.getLinked("categories")#">




<!--- ============================== --->
<!--- SAVE NEW --->
<cfset local.t = getTickCount()>
<cfset local.testBean = local.db.bean("test")>
<cfoutput>BEAN ID: #local.testBean.getID()#<br /></cfoutput>
<cfoutput>#getTickCount() - local.t#ms<br /></cfoutput>
<cfset local.testBean.setName("Waggag")>
<!--- <cfset local.db.save(local.testBean)> --->
<cfoutput>INSERT ID: #local.testBean.getID()#<br /></cfoutput>




<!---
<cfset local.t = getTickCount()>
<cfset local.qb = local.testGateway.qb().from("tbl_test")>
<!--- <cfset local.q = local.qb.from("tbl_test").get(options:{datasource=FB().getSetting("modules.db.dsn")})> --->
<cfset local.q = local.testGateway.executeQB(local.qb)>
<cfoutput>#getTickCount() - local.t#<br /></cfoutput>

<cfdump var="#local.q#">
--->
<br />


<!--- ============================== --->
<!--- GET ALL --->
<cfset local.t = getTickCount()>
<cfset local.q = local.testGateway.getAll()>
<cfoutput>GET ALL: #getTickCount() - local.t#ms<br /></cfoutput>
<cfoutput>#local.q.recordCount#<br /></cfoutput>

<cfdump var="#local.q#">

<!--- <cfset local.t = getTickCount()>
<cfset local.q = local.testGateway.get(2)>
<cfoutput>#getTickCount() - local.t#<br /></cfoutput>
<cfoutput>#local.q.recordCount#<br /></cfoutput> --->


<!--- ============================== --->
<!--- GET --->
<cfset local.t = getTickCount()>
<cfset local.q = local.testGateway.get(4)>
<cfoutput>GET: #getTickCount() - local.t#ms<br /></cfoutput>
<cfoutput>#local.q.recordCount#<br /></cfoutput>


<!--- <cfdump var="#local.q#"> --->

<!--- <cfdump var="#local.db.getSchema()#"> --->

<!--- ============================== --->
<!--- DELETE --->
<!--- <cfset local.db.delete(local.testBean)> --->