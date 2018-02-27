<cfdump var="#FB().getRouteService().getControllerCache()#">
<!---
<cfdump var="#requestHandler().getContext()#">

<cfset r = duplicate(requestHandler().getRoute())>
<cfset structDelete(r, "history")>
<cfdump var="#r#">


<cfset c = new controllers.index(requestHandler(), FB())>
<cfdump var="#getMetaData(c)#">

<cfdump var="#listToArray(requestHandler().getContext().path, "/")#">
--->