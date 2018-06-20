<!--- <cfdump var="#data.session#"> --->
<!--- <cfdump var="#FB().getMapping("SessionService@common")#"> --->


<cfdump var="#data.session.sessionCookieExists()#">

<!--- <cfset data.session.set("test", "wagga")> --->

<!--- <cfdump var="#data.session.sessionCookieExists()#"> --->
<!---  --->

<!--- <cfset data.session.clearAll()> --->

<cfdump var="#data.session.getSessionToken()#">
<cfdump var="#data.session.get("test")#">
<cfdump var="#data.session.getSession()#">
<cfoutput>#cacheCount()#</cfoutput>
<cfdump var="#data.session.hasSession()#">
<cfdump var="#data.session.duration()#">
<cfdump var="#cacheGetAllIDs()#">
