component output="false" extends="FireBolt.controller" {

	/**	
	*/
	public function get(){
		setResponseBody("HELLO FROM CONTROLLER");

		/*
		local.t = FB().getModule("testModule.sampleModule");
		local.d = FB().getModule("testModule.dep");
		local.v = view("hello", {test: "hehre"});
		response().setBody(local.v & " " & local.t.hello()  & ' <a href="/test/">Test</a>');
		*/
		//setResponseBody(writeDump(this));
		//return;

		local.user = FB().getObject("UserService").getUser();
		local.user.setForeName("Joe");
		local.user.setSurName("Blogs");
		setData("user", local.user);

		local.user2 = FB().getObject("UserService").getUser();
		local.user2.setForeName("John");
		local.user2.setSurName("Smith");
		setData("user2", local.user2);

		
		addBreadCrumb("home", "/");
		setTitle("HELLO WORLD");
		addView("hello", {test: "here"});
		addView("testForm");

		addMetaData("description", "goes in here");
		addMetaData("description", "like this");
		addMetaData("dc.title", getTitle());



		layout();
	}

	
	public function post(){
		addContent(rc().form.name);
		layout();
	}

	
	public function onError(any exception, string eventName=""){
		addView("error", arguments);
		layout();
	}

	/**
	* @verbs GET
	*/
	public function test(string name="", string surname=""){
		addBreadCrumb("home", "/");
		addBreadCrumb("test", "/test/");
		if(len(arguments.name)){
			addBreadCrumb(arguments.name, "/test/#arguments.name#/");
		}
		if(len(arguments.surname)){
			addBreadCrumb(arguments.surname, "/test/#arguments.name#/#arguments.surname#/");
		}
		setTitleFromBreadCrumbs();
		addContent("HELLO FROM TEST: #arguments.name# - [#arguments.surname#]"  & ' <a href="/">Home</a>  <a href="/test/dave/">Dave</a>');
		//addView("wirebox", arguments);
		addView("qb", arguments);
		//addContent(stringDump(requestHandler().getContext()));
		layout();
	}

	/**
	* @verbs GET
	* @permissions adminUser
	*/
	public function secure(){
		addContent("SECURE PAGE");
		layout();
	}

	/**
	*/
	public function wagga(){
		return "wagga";
	}

	/**
	* @verbs GET
	*/
	public function debug(){
		addView("debug");
		layout();
	}
	
}