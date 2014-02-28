package com.reesta.match3.model
{

/**
 * Singleton
 * @author Marko Ristic
 */


import starling.events.EventDispatcher;

public class ModelLocator extends EventDispatcher
{
	public var gameModel:GameModel = new GameModel();

	private static var _instance:ModelLocator;
	
	public static function get instance():ModelLocator
	{
		return initialize();
	}
	
	public static function initialize():ModelLocator
	{
		if (_instance == null){
			_instance = new ModelLocator();
		}
		return _instance;
	}
	
	public function ModelLocator()
	{
		super();
		if( _instance != null ) throw new Error( "Error:ModelLocator already initialised." );
		if( _instance == null ) _instance = this;
	}
	
}

}

