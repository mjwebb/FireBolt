/**
* Event listeners can be defined here
* They are configured in the form of:
* {
* 	"event": 	string - the name of the event being listened for
* 	"listener":	string - the method to call when the event is triggered descrbed as either
* 				dot notation (modulePath.moduleName.methodName) or an alias path (moduleName@modulePath.methodName)
* 	"async":	boolean (defaults to false) - flag as to whether or not the listener runs asynchronously or not
* 	"isFireAndForget": boolean (defaults to false) - if true, listener is asynchronous and the request does not wait
* 				for the listener to finish processing before continuing
* }
* <p>* 	
* Example:	
* {
* 	"event": "req.beforeProcess",
* 	"listener": "sampleModule@testModule.intercept,
* 	"async": false,
* 	"isFireAndForget": false
* }
* <p>
* These can also be defined in the FireBolt onApplicationStart handler using a DSL syntax.
* They can also be defined within module config.cfc as either JSON syntax or DSL syntax within the configure() method.
* <p>* 
* FireBolt events are:
* =========================
* FireBolt.loaded
* FireBolt.error
* FireBolt.missingTemplate
* session.start
* session.end
* req.start
* req.beforeProcess
* req.afterProcess
* req.routeNotFound
*/

component{

	this.config = [];

}
