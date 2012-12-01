/* ClientData table */

CREATE TABLE `ClientData` (                                
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`applicationId` int(11) NOT NULL,
	`time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp of client creation',                    
	`lastActivity` timestamp NOT NULL DEFAULT 0,
	/*`metaData` blob NOT NULL COMMENT 'Contains anything the application need to store',*/
	`metaDataSerialized` text COMMENT 'Contains anything the application need to store',
	PRIMARY KEY (`id`)                                            
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
 
