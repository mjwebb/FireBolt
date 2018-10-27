

<h2>DB</h2>
<!--- 
<cfdump var="#getData('user2')#"> --->

<cfset local.db = FB().getObject("db@db")>

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
<cfset local.t = getTickCount()>
<cfset local.testBean = local.db.bean("test", 1)>
<cfoutput>BEAN ID: #local.testBean.getID()#<br /></cfoutput>
<cfoutput>GET: #getTickCount() - local.t#ms<br /></cfoutput>
<cfset local.testBean.setName("Dave Wagga")>
<cfset local.testBean.setStartDate(now())>
<cfset local.testBean.setBool(!local.testBean.getBool())>
<!--- <cfdump var="#local.testBean.getSnapshot(true)#" label="prev"> --->
<!--- <cfdump var="#local.testBean.getSnapshot()#" label="updated"> --->


<cfset local.t = getTickCount()>
<cfset local.db.save(local.testBean)>
<cfoutput>SAVE: #getTickCount() - local.t#ms<br /></cfoutput>

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

<cfset local.t = getTickCount()>
<cfset local.q = local.testGateway.getAll()>
<cfoutput>GET ALL: #getTickCount() - local.t#ms<br /></cfoutput>
<cfoutput>#local.q.recordCount#<br /></cfoutput>

<cfdump var="#local.q#">

<!--- <cfset local.t = getTickCount()>
<cfset local.q = local.testGateway.get(2)>
<cfoutput>#getTickCount() - local.t#<br /></cfoutput>
<cfoutput>#local.q.recordCount#<br /></cfoutput> --->

<cfset local.t = getTickCount()>
<cfset local.q = local.testGateway.get(6)>
<cfoutput>GET: #getTickCount() - local.t#ms<br /></cfoutput>
<cfoutput>#local.q.recordCount#<br /></cfoutput>


<!--- <cfdump var="#local.q#"> --->

