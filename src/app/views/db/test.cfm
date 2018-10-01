

<h2>DB</h2>
<!--- 
<cfdump var="#getData('user2')#"> --->

<cfset local.insp = FB().getObject("dbInspector@db")>

<!--- <cfdump var="#insp.inspectTable("test", "tbl_test")#"> --->

<!--- <cfdump var="#getApplicationMetadata()#">  --->

<cfset local.testGateway = FB().getObject("testGateway")>
<!--- <cfdump var="#local.gateway#">
<cfoutput>#FB().getSetting("modules.db.dsn")#</cfoutput> --->

<!---
<cfset local.q = local.testGateway.from("tbl_test")
	.where("test_id = 1")
	.select("")>


<cfset local.testBean = FB().getObject("testBean")>
<cfset local.testBean.setTest("wagga")>
<cfoutput>#local.testBean.isDirty()#</cfoutput>
--->

<cfset local.qb = local.testGateway.qb()>
<cfset local.q = local.qb.from("tbl_test").get(options:{datasource=FB().getSetting("modules.db.dsn")})>

<br />

<cfset local.t = getTickCount()>
<cfset local.q = local.testGateway.getAll()>
<cfoutput>#getTickCount() - local.t#<br /></cfoutput>
<cfoutput>#local.q.recordCount#<br /></cfoutput>

<cfset local.t = getTickCount()>
<cfset local.q = local.testGateway.get(2)>
<cfoutput>#getTickCount() - local.t#<br /></cfoutput>
<cfoutput>#local.q.recordCount#<br /></cfoutput>