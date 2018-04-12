<div style="border: 1px solid blue; padding: 20px; margin: 20px;">

Hello World - <a href="/test/">Test</a> - <a href="/secure/">Secure</a>

<!--- <cfdump var="#FB().getFactoryService().getCache()#"> --->

<cfoutput>#view("nested.view", data)#</cfoutput>
<!--- <cfdump var="#data#"> --->
<cfdump var="#FB().getAllConcerns()#">


<!---<cfdump var="#FB().getFactoryService().getModulePaths()#"> --->
<br />	
<cfset d = FB().getObject("sampleModule@testModule")>

<!--- <cfdump var="#getMetaData(data.controller)#"> --->
<!--- <cfdump var="#d.getFB()#"> --->

<!--- <cfset FB().after("testModule.sampleModule", "hello", "testModule.sampleModule.testAfterConcern")> --->

<cfoutput>#d.hello(getRequestHandler())#<br /></cfoutput>
<cfoutput>circular dependancy: #d.getSampleDep().world()#<br /></cfoutput>
<cfoutput>#d.AOPTestTarget()#</cfoutput>



<!--- <cfdump var="#FB().getAOPService().getAllConcerns()#"> --->
<!--- <cfdump var="#FB().getFactoryService().getAliases()#"> --->

<cfoutput><p>User name: #getData("user").getFullName()# - #getData("user2").getFullName()#</p></cfoutput>

<!--- <cfdump var="#FB().getObject("UserService")#"> --->



<cfset x = FB().getObject("transientWithArg@testModule", {
	req: getRequestHandler()
})>
<p>transient module: <cfoutput>#x.hello()#</cfoutput></p>
<!--- <cfdump var="#x#"> --->
<p>
Environment variable: <cfoutput>[#FB().getSetting("env.test")#]</cfoutput>
</p>
<!--- <cfdump var="#FB().getSetting("env")#">
<cfset system = CreateObject("java", "java.lang.System")>
<cfdump var="#system.getProperties()#"> --->
<!--- <cfdump var="#requestHandler().getRoute()#"> --->
<!--- <cfdump var="#FB().getAllConcerns()#"> --->

<!--- <cfdump var="#requestHandler().getContext()#"> --->

<!--- <cfdump var="#FB().getRouteService().getControllerRoutes()#"> --->


</div>