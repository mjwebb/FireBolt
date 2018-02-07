Hello World - <a href="/test/">Test</a>

<cfoutput>#view("nested.view", data)#</cfoutput>
<!--- <cfdump var="#data#"> --->
<!--- <cfdump var="#FB().getAllConcerns()#"> --->
<cfoutput>#expandPath("/testModule/")#</cfoutput>
<cfset d = FB().getObject(name:"testModule.sampleModule")>
<!--- <cfdump var="#getMetaData(d)#">
<cfdump var="#d.getFB()#"> --->


<!--- <cfset FB().after("testModule.sampleModule", "hello", "testModule.sampleModule.testAfterConcern")> --->

<cfoutput>#d.hello(requestHandler())#</cfoutput>

<!--- <cfdump var="#requestHandler().getRoute()#"> --->