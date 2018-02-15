Hello World - <a href="/test/">Test</a> - <a href="/secure/">Secure</a>

<cfoutput>#view("nested.view", data)#</cfoutput>
<!--- <cfdump var="#data#"> --->
<!--- <cfdump var="#FB().getAllConcerns()#"> --->
<cfoutput>#expandPath("/testModule/")#</cfoutput>
<cfset d = FB().getObject("sampleModule@testModule")>
<!--- <cfdump var="#getMetaData(d)#">
<cfdump var="#d.getFB()#"> --->


<!--- <cfset FB().after("testModule.sampleModule", "hello", "testModule.sampleModule.testAfterConcern")> --->

<cfoutput>#d.hello(requestHandler())#</cfoutput>
<cfoutput>#d.AOPTestTarget()#</cfoutput>

<!--- <cfdump var="#FB().getFactoryService().getAliases()#"> --->

<cfset x = FB().getObject("transientWithArg@testModule", {
		req: requestHandler()
	})>
<!--- <cfdump var="#x#"> --->

<!--- <cfdump var="#requestHandler().getRoute()#"> --->
<!--- <cfdump var="#FB().getAllConcerns()#"> --->