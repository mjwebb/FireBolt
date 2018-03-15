<div style="border: 1px solid green; padding: 20px; margin: 20px;">
<p>Test module view</p>
<p>
module setting: <cfoutput>[#FB().getSetting("modules.testModule.setting")#]</cfoutput><br />
injected setting: <cfoutput>[#FB().getObject("sampleModule@testModule").getTestSetting()#]</cfoutput>
</p>
<!--- <cfdump var="#FB().getConfig()#"> --->
</div>