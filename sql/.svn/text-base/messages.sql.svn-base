/* MessageData table */

CREATE TABLE `MessageData` (                                       
	`id` int(11) unsigned NOT NULL AUTO_INCREMENT,                
	`clientId` int(11),                     
	`applicationId` int(11) NOT NULL DEFAULT '0',                       
	`time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,  
	`type` text NOT NULL default '' COMMENT 'Code for the message type',
	/*`metaData` blob COMMENT 'Addional data for the message (e.g. chat post content)',*/
	`metaDataSerialized` text COMMENT 'Addional data for the message (e.g. chat post content)',
	PRIMARY KEY (`id`)                                            
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
