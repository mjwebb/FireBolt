

<cfset qb = FB().getObject("QueryBuilder@qb")>

<cfdump var="#qb#">
<cfdump var="#FB().getListeners()#">


<!--- <cftry> --->

	<!--- <cfset q = qb.from("users").get("forename,surname,email")>
	<cfdump var="#q#"> --->
	<!--- <cfcatch>
		FAIL
	</cfcatch>
</cftry> --->