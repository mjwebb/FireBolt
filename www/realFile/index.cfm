<cfset controller = application.FireBolt.getController()>

<!--- <cfset x = createObject("component", "controllers.index")>
<cfoutput>#structKeyExists(x, "init")#</cfoutput>
<cfdump var="#getMetaData(x.init)#"> --->

<cfscript>
controller.addBreadCrumb("home", "/");
controller.setTitle("HELLO WORLD");

controller.addView("testForm");

controller.addMetaData("description", "goes in here");
controller.addMetaData("description", "like this");
controller.addMetaData("dc.title", controller.getTitle());

</cfscript>

<cfset controller.addContent("Hello from a real physical page - #now()#")>
<cfset controller.layout()>
<cfoutput>#controller.respond()#</cfoutput>
<!--- <cfcontent reset="true"><cfoutput>#controller.output().layout()#</cfoutput> --->