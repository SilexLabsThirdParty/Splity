ECHO OFF
ECHO.
ECHO generating iOS version via Air, which might take a few minutes...
CALL adt -package -target ipa-debug-interpreter -connect -provisioning-profile ../test1.mobileprovision -storetype pkcs12 -keystore ../iphone_dev.p12 -storepass Elektron69! ../../../bin/native_apps/iOS_Air.ipa Air_config.xml -C ../assets icons splashScreens -C ../assets/splashScreens Default.png Default@2x.png Default-Portrait.png Default-Portrait@2x.png -C ../../../bin app.swf app.css assets
ECHO compilation complete
ECHO.
ECHO uninstalling application...
CALL adt -uninstallApp -platform ios -appid fr.intermedia-paris.test1
ECHO.
ECHO installing application (needs Air 3.4+)...
CALL adt -installApp -platform ios -package ../../../bin/native_apps/iOS_Air.ipa
ECHO installation complete
ECHO.
