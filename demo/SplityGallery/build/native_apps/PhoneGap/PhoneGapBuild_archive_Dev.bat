ECHO OFF
ECHO.
SET target=Dev
SET config_file=config.xml
SET input_files_path=../assets/icons ../assets/splashScreens ../assets/icons/icon_114.png ../assets/splashScreens/Default.png config.xml index.html ../../../bin/app.js ../../../bin/app.css ../../../bin/assets
SET output_file_path=PhoneGapBuild_%target%.zip

cls

ECHO preparing %config_file% file...
copy PhoneGap_config_%target%.xml %config_file%
ECHO.

ECHO copying index file...
copy ..\..\..\bin\index-js.html index.html
ECHO.

ECHO Removing %output_file_path%...
del %output_file_path% /Q /S

ECHO.

ECHO Creating archive %output_file_path%...
C:\"Program Files"\7-Zip\7z.exe a -tzip %output_file_path% %input_files_path%
ECHO.

ECHO Removing %config_file% ...
del %config_file% /Q /S
del index.html /Q /S
ECHO.

ECHO Compression complete
ECHO.
