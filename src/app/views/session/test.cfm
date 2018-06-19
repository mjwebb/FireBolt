<!--- <cfdump var="#data.session#"> --->

<cfdump var="#data.session.sessionCookieExists()#">

<cfset data.session.set("test", "wagga")>

<cfdump var="#data.session.sessionCookieExists()#">
<!--- <cfset data.session.clear()> --->

<cfdump var="#data.session.getSessionToken()#">
<cfdump var="#data.session.get("test")#">
<cfdump var="#data.session.getSession()#">

<cfoutput>#cacheCount()#</cfoutput>
