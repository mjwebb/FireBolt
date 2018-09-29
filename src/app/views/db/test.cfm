

<h2>DB</h2>
<!--- 
<cfdump var="#getData('user2')#"> --->

<cfset local.insp = FB().getObject("dbInspector@db")>

<!--- <cfdump var="#insp.inspectTable("test", "tbl_test")#"> --->

<!--- <cfdump var="#getApplicationMetadata()#">  --->

<cfset local.gateway = FB().getObject("testGateway")>
<!--- <cfdump var="#local.gateway#">
<cfoutput>#FB().getSetting("modules.db.dsn")#</cfoutput> --->


<cfset local.q = local.gateway.selectFrom("tbl_test")
	.where("test_id = 1")
	.cols("")>

<!--- <cfdump var="#local.gateway.toSQL(q)#"> --->


<cfset local.testBean = FB().getObject("testBean")>
<cfset local.testBean.setTest("wagga")>
<!--- <cfdump var="#local.testBean.getConfig()#"> --->
<cfoutput>#local.testBean.isDirty()#</cfoutput>
<!--- <cfoutput>#local.testBean.getPK()#</cfoutput> --->