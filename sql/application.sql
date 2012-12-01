/* ApplicationData table */

CREATE TABLE `ApplicationData` (
	`id` int(11) NOT NULL auto_increment,
	`name` varchar(1024) NOT NULL default '' COMMENT 'Application name',
	`instanceName` varchar(1024) NOT NULL default '' COMMENT 'Application instance name',                                    
	`time` timestamp NOT NULL default CURRENT_TIMESTAMP COMMENT 'Timestamp of application initialization',                    
	`lastActivity` timestamp NOT NULL DEFAULT 0,
	/*`metaData` blob NOT NULL COMMENT 'Contains anything the application need to store',*/
	`metaDataSerialized` text COMMENT 'Contains anything the application need to store',
	PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
