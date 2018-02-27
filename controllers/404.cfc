component output="false" extends="FireBolt.controller" {

	/**	
	*/
	public function do404(){
		//writeDump(requestHandler().getRoute());
		addContent("<p>PAGE NOT FOUND</p>");
		addView("debug");
		layout();
	}

	
}