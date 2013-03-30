## Splity Gallery

This is a demo of Splity.
https://github.com/SilexLabsThirdParty/Splity

Installation:

* Install Haxe with the Brix library
* Intall SLDialog in ../SLDialog/ - see http://sourceforge.net/projects/php-polling/
   => use the svn https://php-polling.svn.sourceforge.net/svnroot/php-polling 
* build demo/SplityGallery/build.hxml (run: "haxe build.hxml")

Status

2013-02-22
Tested and working on:
-iOS 6+
-Android 4 +
-Windows 8 (Phone)

Issues on:
-Windows Surface: arrows are not always working

## Functionnal specifications

Sorry, this is in French...

* Au démarrage, appli invisible.
* Au démarrage, gallery connect ‡ serveur splity
	- appli ‡ 3 mode determinée par résolution écran (type de device ?)
		- desktop : affiche maximum de fonctionnalité (mode par défualt)
		- tablette : mode desktop + demande fonctionnalité thumb
		- telephone : mode desktop + demande fonctionnalité suivant/precedent
	- un css différent est appliqué ‡ chaque mode.	
	
* quand connect, genere ID metadata, demande liste des fonctionnalités (tous mode)
* qaund liste fonctionnalité reÁu :
	- mode desktop : affiche toutes les fonctionnalité qui ne sont pas au max
	- mode tablette : demande fonctionnalité thumb
	- mode telephone : demande fonctionnalité suivant/precedant
	
* quand demande fonctionnalité reÁu : 
	- si telephone/tablette affiche bonne fonctionnalité
	- si desktop, masque fonnctionnalité au max.
		
* après démarrage.
* quand un lien est cliqué (lien brix) par utilisateur dans une des applis :
	- appli envoi méthode sur serveur splity avec nom de page
	- serveur splity dispatch evenement changement de page sur toutes les applis
	- toutes les autres appli ouvre pages dans onstatus
	
* appli ferme
* deconnecte auprès du serveur splitty
* dans deconnect callback : 
	- si desktop, check si doit récuperer fonctionnalité
	
