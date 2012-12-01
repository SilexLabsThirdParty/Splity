<?php

$config = '<xml>
	<db>
	 	<!-- Data base host name 
		<dbHost>../SLDialog.sqlite2</dbHost>
		-->
	 	<!-- Data base host name -->
		<dbHost>localhost</dbHost>

	 	<!-- Data base port -->
		<dbPort></dbPort>

	 	<!-- Data base user name -->
		<dbUser>root</dbUser>

	 	<!-- Data base password -->
		<dbPassword>root</dbPassword>

	 	<!-- Data base name -->
		<dbName>splity</dbName>
	</db>
	<polling>
	 	<!-- total time allowed to hold the client in the long polling in MS (milli seconds) -->
	 	<longPollingDuration>5000</longPollingDuration>
	
	 	<!-- duration of the sleep which is executed in the long polling loop in MS (milli seconds) -->
	 	<longPollingSleepDuration>100</longPollingSleepDuration>
	</polling>
	<timeout>
	 	<!-- total time after which a client is considered as IDLE in MS (milli seconds) -->
	 	<clientTimeOut>2000</clientTimeOut>
	
	 	<!-- total time after which an application is considered as IDLE in MS (milli seconds) -->
	 	<applicaitonTimeOut>20000</applicaitonTimeOut>
	
	 	<!-- total time after which a message is considered as useless in MS (milli seconds) -->
	 	<messageTimeOut>4000</messageTimeOut>
	</timeout>
	<splity>
	 	<functionalities>
		 	<functionality>
		 		<name>thumbs</name>
		 		<maxUsage>1</maxUsage>
		 	</functionality>
		 	<functionality>
		 		<name>remote</name>
		 		<maxUsage>1</maxUsage>
		 	</functionality>
		 	<functionality>
		 		<name>display</name>
		 	</functionality>
	 	</functionalities>
	</splity>
</xml>'

?>
