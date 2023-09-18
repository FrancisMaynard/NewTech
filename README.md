FRANCIS MAYNARD - PROBLEMATIQUE 1

Fonctionnement de l'infrastructure :

Avant de démarrer la première étape de création de client et de ses serveurs, il y a quelques étapes de vérifications avant que l'infrastructure puisse s'exécuter au complet. 
Je vérifie tout d'abord si la personne qui exécute le script PowerShell. Si elle n'est pas les accès administrateur, l'exécution du script s'arrêtera. Cela amène une sécurité à l'exécution du script.

Ensuite, l'infrastructure vérifiera qu'il a bien reçu le nom du nouveau client en argument lorque l'adminisrateur a exécuter la commande pwsh.exe. Aucune validation n'est faite (accent, poncutation, etc.). Si ce n'est pas le cas, l'administrateur sera averti et le script cessera d'être exécuté.

Finalement, l'infrastructure s'assure que le client que je souhaite créer n'a pas déjà été créé avec deux variables utilisant la commande 'Test-Path'. Une variable est utilsée pour le chemin d'accès au dossier Config ($newConfigClientExists) et l'autre pour le chemin d'accès du dossier NewTech ($newTechClientExists). Chacune de ces deux variables me retourneront un booléen. Afin que le script puisse continuer d'exécuter, les deux variables devront être 'false', sans quoi l'administrateur sera averti que le client existe déjà et le script cessera d'être exécuté.

Une fois les vérifications terminées, voici les étapes de l'infrastructure :

1. Création d'un dossier avec le nom du client dans le dossier Config qui contiendra tous les fichiers de configurations et les *playbook* à son provisionning

2. Création d'un Vagrantfile  à l'aide d'un *template* contenant les spécifications de 3 VM :
    - Site Web static
    - Serveur HTTP roulant PHP
    - Serveur PostgreSQL
Chacune de ses VM ont leur propre adresse IP qui est pré-déterminée par le fichier *next.txt*. Les VM prennent l'adresse IP inscrit dans le fichier et les deux prochaines suites à celle-ci. La troisième suite sera la nouvelle adresse IP inscrite dans le fichier lors de la création du prochain client.
3. Le nom du client ainsi que les trois adresses IP qui seront utilisées pour les VM seront inscrites en section automatiquement dans un fichier *hosts* à l'intérieur du dossier Config.
    - Si le fichier n'existe pas ($hostsExists) suite à la commande Dir, le fichier *hosts* sera créé avant d'inscrire les informations inscrites plus haut

4. Un *prompt* demandera si les entrées *newClient.com* et *api.newClient.com* doivent fonctionner sur l'hôte
    - Si la réponse est oui, les deux adresses IP pour *newClient.com* (Site Web statique) et *api.newClient.com* (Serveur HTTP) sont inscrites dans le fichier *hosts* de __Windows__ (Chemin d'accès étant le "C:\Windows\System32\drivers\etc\hosts")

5. Création des fichiers YML à l'aide de leur template qui permettront d'installer le site web static, le serveur Apache ainsi que le serveur PostgreSQL

6. Création d'un fichier .sh qui servira à la création de clés ssh pour les trois VM à l'aide de son propre template

7. Création du fichier playbook.sh à l'aide de son template

8. Création du fichier $newClient.sh qui contiendra le contenu de tous les fichiers .sh pour pouvoir exécuter une seule commande ansible-playbook

Éléments non automatisables :
-Création des 3 serveurs pour le client
-Connection sur PostgreSQL via le serveur d'API (HTTP + PHP)