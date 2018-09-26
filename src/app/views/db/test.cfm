

<h2>DB</h2>
<!--- 
<cfdump var="#getData('user2')#"> --->

<cfset insp = FB().getObject("dbInspector@db")>
<cfdump var="#insp.inspectTable("test", "tbl_test")#">
