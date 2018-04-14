<h2>AOP Concerns</h2>
<cfdump var="#FB().getAllConcerns()#">

<h2>Event Listeners</h2>
<cfdump var="#FB().getListeners()#">

<h2>Controller Routes</h2>
<cfdump var="#FB().getRouteService().getControllerRoutes()#">
<!---
<cfdump var="#requestHandler().getContext()#">

<cfset r = duplicate(requestHandler().getRoute())>
<cfset structDelete(r, "history")>
<cfdump var="#r#">


<cfset c = new controllers.index(requestHandler(), FB())>
<cfdump var="#getMetaData(c)#">

<cfdump var="#listToArray(requestHandler().getContext().path, "/")#">
--->
