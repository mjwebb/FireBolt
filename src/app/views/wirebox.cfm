

<!--- <cfdump var="#FB().wirebox#"> --->
<!--- <cfdump var="#FB().getConfigService().getConfigObject()#"> --->

<!--- <cfdump var="#FB().wirebox#"> --->

<cfset t1 = FB().wirebox.getInstance("test.wbtest1")>
<cfset t2 = FB().wirebox.getInstance("test.wbtest2")>


<br/><br />
<cfoutput>#t1.hello()#<br /></cfoutput>
<cfoutput>#t2.hello()#</cfoutput>



<cfset t3 = FB().wirebox.getInstance("testModule.sampleModule")>