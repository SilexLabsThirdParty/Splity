<?php

$config = '<xml>
	<db>
		<dbHost>../SLDialog.sqlite2</dbHost>
	 	<!--
		<dbHost>localhost</dbHost>
		<dbPort></dbPort>
		<dbUser>root</dbUser>
		<dbPassword>root</dbPassword>
		<dbName>splity</dbName>
		-->
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
		 		<name>thumblist</name>
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
