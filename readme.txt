## Splity

Multi-screen made easy

Splity is an API which allows developpers to easily split applications functionalities between several devices. 

It is a specialization of SLDialog, a Silex Labs project. And Splity is lisenced like SLDialog.
It is developped in Haxe and Brix, and can be compiled cross-platform with Cocktail and NME.
It is an application developped during a Hackathon by Intermedia Paris

## Key functionalities

* Find the devices (same local network, geoloc, ...)
* Share functionalities between the clients and apps (roles, split the app)
* share screens (video capture, real time, ...) - not yet implemented

## Links

Splity
https://github.com/SilexLabsThirdParty/Splity

SLDialog
http://sourceforge.net/projects/php-polling/
use the svn https://php-polling.svn.sourceforge.net/svnroot/php-polling 

Silex Labs
http://silexlabs.org/

Intermedia Paris
http://www.intermedia-paris.fr/

## Usage

See the sample: the Splity gallery in demo/

Installation:

* Install Haxe with the Brix library
* Intall SLDialog in ../SLDialog/ - see http://sourceforge.net/projects/php-polling/
* build demo/SplityGallery/build.hxml (run: "haxe build.hxml")

## Changes made to SLDialog

This is what was added to SLDialog in order to make Splity, an API specialized in multi-screen apps, not just messaging.

* onStatus event, dispatched when someone has taken a functionnality
	SPLITY
	{
	}

* Method to list all functionnalities available for this app. The list comes from the config.php file. And usage is the number of apps which have taken this functionnality.

	This method is implemented in src/splity/client/SplityAPI.hx and in src/splity/server/Splity.hx
	The client side methods calls the server side method with haxe remoting.

	getFunctionalities()
	[
		{
			name
			usage
			maxUsage
			clients
			{
				...
			}
		}
	]

* Method to take a functionnality. The server may refuse and return false.

	This method is implemented in src/splity/client/SplityAPI.hx and in src/splity/server/Splity.hx
	The client side methods calls the server side method with haxe remoting.

	requestFunctionality(name)
	bool



