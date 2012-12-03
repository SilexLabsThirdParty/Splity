package splity.server;


import php.io.File;
import php.FileSystem;
import php.io.Path;
import php.Sys;

class Log
{
	static inline var LOG_FILE_PATH:String = "../splity.log";
	public static function trace(str) 
	{
		if (FileSystem.exists(LOG_FILE_PATH))
		{
			var output = File.getContent(LOG_FILE_PATH)+ "\n" + Date.now()+" - "+str;
			File.saveContent(LOG_FILE_PATH, output);
		}
	}
}