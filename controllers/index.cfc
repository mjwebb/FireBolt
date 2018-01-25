component output="false" extends="FireBolt.controller" {

	/**	
	* **/
	public function get(){
		response().setBody("HELLO FROM CONTROLLER");

		/*
		local.t = FB().getModule("testModule.sampleModule");
		local.d = FB().getModule("testModule.dep");
		local.v = view("hello", {test: "hehre"});
		response().setBody(local.v & " " & local.t.hello()  & ' <a href="/test/">Test</a>');
		*/
		template().addBreadCrumb("home", "/");
		template().setTitle("HELLO WORLD");
		addView("hello", {test: "here"});
		addView("testForm");

		template().addMetaData("description", "goes in here");
		template().addMetaData("description", "like this");
		template().addMetaData("dc.title", template().getTitle());

		layout();
	}

	public function post(){
		template().addContent(rc().form.name);
		layout();			
	}

	/**
	* @verbs GET
	* **/
	public function test(string name, string surname){
		template().addBreadCrumb("home", "/");
		template().addBreadCrumb("test", "/test/");
		if(len(arguments.name)){
			template().addBreadCrumb(arguments.name, "/test/#arguments.name#/");
		}
		if(len(arguments.surname)){
			template().addBreadCrumb(arguments.surname, "/test/#arguments.name#/#arguments.surname#/");
		}
		template().setTitleFromBreadCrumbs();
		template().addContent("HELLO FROM TEST: #arguments.name# - [#arguments.surname#]"  & ' <a href="/">Home</a>  <a href="/test/dave/">Dave</a>')
		//template().addContent(stringDump(requestHandler().getRoute()));
		layout();
	}

	/**
	* **/
	public function wagga(){
		return "wagga";
	}


	
}