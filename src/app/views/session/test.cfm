<!--- <cfdump var="#data.session#"> --->
<!--- <cfdump var="#FB().getMapping("SessionService@common")#"> --->
<!--- <cfdump var="#rc().requestData#"> --->
<cfparam name="form.token" default="">

<h2>Sesssion</h2>
<cfoutput>
Target Origin: #securityService.targetOrigin()#<br />
Is Same Origin: #securityService.isSameOrigin()#<br />
Valid CSRF Token: #securityService.verifyCSRFToken(form.token)#<br />
Session Cookie Exists: #sessionService.sessionCookieExists()#<br />
Sesssion Token: #sessionService.getSessionToken()#<br />
Has Session: #sessionService.hasSession()#<br />
Session Duration: #sessionService.duration()#<br />
Session 'test' Value: #sessionService.get("test")#<br />
</cfoutput>

<!--- <cfdump var="#cgi#"> --->
<h2>Cache</h2>
<cfoutput>
Cache Count: #cacheCount()#<br />
</cfoutput>


<!--- <cfset data.session.set("test", "wagga")> --->

<!--- <cfdump var="#data.session.sessionCookieExists()#"> --->
<!---  --->

<!--- <cfset data.session.clearAll()> --->

<!--- <cfdump var="#sessionService.getSession()#"> --->

<!--- <cfdump var="#cacheGetAllIDs()#"> --->
