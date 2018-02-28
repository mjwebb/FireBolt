Hello World - <a href="/test/">Test</a> - <a href="/secure/">Secure</a>

<cfoutput>#view("nested.view", data)#</cfoutput>
<!--- <cfdump var="#data#"> --->
<!--- <cfdump var="#FB().getAllConcerns()#"> --->

<!--- <cfdump var="#data#">
<cfdump var="#FB().getFactoryService().getModulePaths()#"> --->
<br />	
<cfset d = FB().getObject("sampleModule@testModule")>

<!--- <cfdump var="#getMetaData(data.controller)#"> --->
<!--- <cfdump var="#d.getFB()#"> --->

<!--- <cfset FB().after("testModule.sampleModule", "hello", "testModule.sampleModule.testAfterConcern")> --->

<cfoutput>#d.hello(requestHandler())#</cfoutput>
<cfoutput>#d.AOPTestTarget()#</cfoutput>

<!--- <cfdump var="#FB().getFactoryService().getAliases()#"> --->


<cfset x = FB().getObject("transientWithArg@testModule", {
	req: requestHandler()
})>

<!--- <cfdump var="#x#"> --->
<cfoutput>[#FB().getSetting("env.test")#]</cfoutput>
<!--- <cfdump var="#FB().getSetting("env")#">
<cfset system = CreateObject("java", "java.lang.System")>
<cfdump var="#system.getProperties()#"> --->
<!--- <cfdump var="#requestHandler().getRoute()#"> --->
<!--- <cfdump var="#FB().getAllConcerns()#"> --->

<!--- <cfdump var="#requestHandler().getContext()#"> --->

<!--- <cfdump var="#FB().getRouteService().getControllerRoutes()#"> --->
