<?php

interface sys_db_ResultSet {
	function getFieldsNames();
	function getFloatResult($n);
	function getIntResult($n);
	function getResult($n);
	function results();
	function next();
	function hasNext();
	//;
	//;
}
