Saison cyclable estivale à Québec ☀️❄️
================================================================================


À Québec, la __saison cyclable estivale__ se déroule du `1 mai` au `31 octobre`. En gros, pendant ce temps, le stationnement dans les bandes cyclables est interdit et les piste cyclables sont déneigées et nettoyées. Dans les faits, les gens font du vélo toute l'année à Québec, mais ne jouissent que de 6 mois où les infrastructures sont officiellement ouvertures.

À l'aide des __données météorologiques historiques__, je tente de trouver la période optimale d'ouverture du réseau cyclable estival. Devrait-il ouvert le 15 avril ? Le 1er avril ? Devrait-il fermé le 15 octobre ? Le 15 novembre ? Le 1er décembre ? 

__Mon but__ : fournir les bases d'une analyse rigoureuse pour prendre une décision basée sur la science quant à l'ouverture officielle de la saison cyclable estivale.

> __Disclaimer #1__ : Je suis biaisé et je fais du vélo toute l'année. J'aimerais donc que les résultats montrent qu'on peut ouvrir le réseau estival bien avant la date actuelle, et le fermer bien après. Néanmoins, je laisserai les données parler et je me tiendrai loin de toute partisanerie.

> __Disclaimer #2__ : Cette analyse n'est nullement associée à la Ville de Québec.

Données
--------------------------------------------------------------------------------

J'ai utilisé les données climatiques historisques sur la période `1956-2020` à l'aéroport de Québec car c'était la station avec la plus grande historique de données.

Pour les biens de la cause, j'ai conservé que la période `1980-2020` pour les analyses.


Scenario pessimiste
--------------------------------------------------------------------------------


Dans ce scénario, on __fermerait__ le réseau avant d'avoir la première séquence de 3 jours consécutifs avec au moins 1 cm de neige accumulée au sol. 

On __ouvrirait__ au moment où il n'y aura aucune accumulation de neige dans les 15 jours suivants, avec un moment tampon de 10 jours pour nettoyer le réseau. 


Scenario optimiste
--------------------------------------------------------------------------------

Dans ce scénario, on __fermerait__ le réseau avant d'avoir la première séquence de 5 jours consécutifs avec au moins 3 cm de neige accumulée au sol. 

On __ouvrirait__ au moment où il n'y aura aucune accumulation supérieure à 2 cm de neige dans les 5 jours suivants, avec un moment tampon de 10 jours pour nettoyer le réseau. 


Résultats
--------------------------------------------------------------------------------

| Scéanario                         | Ouverture du réseau | Fermerture du réseau | Saison cyclable estivale |
|-----------------------------------|---------------------|----------------------|--------------------------|
| Actuel                            | __1er mai__         | __31 octobre__       | __183 jours__            |
| Scénario pessimiste (1980-1999)   | 27 avril            | 15 novembre          | 203 jours                |
| Scénario pessimiste (2000-2020)   | 22 avril            | 23 novembre          | 216 jours                |
| Scénario optimiste  (1980-1999)   | 25 avril            | 21 novembre          | 211 jours                |
| Scenario optimiste  (2000-2020)   | __17 avril__        | __29 novembre__      | __227 jours__            |



À venir
--------------------------------------------------------------------------------


+ Améliorer la méthode d'imputation de données manquantes pour la quantité de neige au sol
+ Tester différentes scénarios, analyser l'écart-type de la date d'ouverture et certains quantiles
+ Que ce passera-t-il dans un avenir rapproché (2030, 2050) selon différents scénarios de changements climatiques ?


___Enjoy !___