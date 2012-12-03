package splity.server.functionality;


/** 
 * This class represents a client
 */
#if php

class FunctionalityData extends php.db.Object 
#else
class FunctionalityData
#end
{
	/**
	 * convert into a structure which can be serialized for client / server communication
	 */
	public function toDataModel():FunctionalityDataModel
	{
		return {id:id, name:name, maxUsage:maxUsage};
	}
	/**
	 * convert from the model
	 */
	public function fromDataModel(dataModel:FunctionalityDataModel)
	{
		id = dataModel.id;
		name = dataModel.name;
		maxUsage = dataModel.maxUsage;
	}
	
	/**
	 * id in the DB
	 */
    public var id : Int;
    public var name:String;
    public var maxUsage:Null<Int>;
    
#if php
	public static var TABLE_NAME:String = "SplityFunctionality";	
	public static var LINK_TABLE_NAME:String = "SplityFunctionalityUsage";	
    /**
     * SPOD manager
     * @see	http://haxe.org/doc/neko/spod
     */
    public static var manager = new FunctionalityDataManager();
#end
}


/**
 * structure which can be serialized for client / server communication
 */
typedef FunctionalityDataModel = 
{
	/**
	 * id in the DB
	 */
    public var id : Int;
    public var name:String;
    public var maxUsage:Null<Int>;
}
