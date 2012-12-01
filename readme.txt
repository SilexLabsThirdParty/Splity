

SLDialog
http://sourceforge.net/projects/php-polling/

Splity test server
http://169.254.240.203:8888/Splity/www/

Gallery Splity 

- Au dÈmarrage, appli invisible.
- Au dÈmarrage, gallery connect ‡ serveur splity
	- appli ‡ 3 mode determinÈe par rÈsolution Ècran (type de device ?)
		- desktop : affiche maximum de fonctionnalitÈ (mode par dÈfualt)
		- tablette : mode desktop + demande fonctionnalitÈ thumb
		- telephone : mode desktop + demande fonctionnalitÈ suivant/precedent
	- un css diffÈrent est appliquÈ ‡ chaque mode.	
	
- quand connect, genere ID metadata, demande liste des fonctionnalitÈs (tous mode)
- qaund liste fonctionnalitÈ reÁu :
	- mode desktop : affiche toutes les fonctionnalitÈ qui ne sont pas au max
	- mode tablette : demande fonctionnalitÈ thumb
	- mode telephone : demande fonctionnalitÈ suivant/precedant
	
- quand demande fonctionnalitÈ reÁu : 
	- si telephone/tablette affiche bonne fonctionnalitÈ
	- si desktop, masque fonnctionnalitÈ au max.
		
- aprËs dÈmarrage.
- quand un lien est cliquÈ (lien brix) par utilisateur dans une des applis :
	- appli envoi mÈthode sur serveur splity avec nom de page
	- serveur splity dispatch evenement changement de page sur toutes les applis
	- toutes les autres appli ouvre pages dans onstatus
	
- appli ferme
- deconnecte auprËs du serveur splitty
- dans deconnect callback : 
	- si desktop, check si doit rÈcuperer fonctionnalitÈ
	



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

requestFunctionality(name)
bool

onStatus
SPLITY
{
}


lex to do
- server local
- functionalities server side
- deconnect clients
- web socket

