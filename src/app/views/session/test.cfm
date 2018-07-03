<!--- <cfdump var="#data.session#"> --->
<!--- <cfdump var="#FB().getMapping("SessionService@common")#"> --->
<cfdump var="#rc().requestData#">

<cfset local.sec = FB().getObject("securityService@common")>
<cfoutput>Target Origin: #local.sec.targetOrigin()#<br />Is Same Origin: #local.sec.isSameOrigin()#</cfoutput>

<!--- <cfdump var="#cgi#"> --->

<cfparam name="form.token" default="">
<cfoutput><br />Valid CSRF Token: #local.sec.verifyCSRFToken(form.token)#</cfoutput>



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
