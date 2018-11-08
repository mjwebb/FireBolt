component{
	include "_testSchema.cfm";
	this.definition.joins = [{
		table: "tbl_relation",
		on: "relation_id",
		from: "relationID",
		cols: "relationName, relationBody, relationName AS testAS"
	}];
	this.definition.manyTomany = [{
		
	}];
	this.definition.specialColumns = [];
}