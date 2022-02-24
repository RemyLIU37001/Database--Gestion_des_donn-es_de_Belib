#Groupe de Ziyi LIU, Feriel SAADA, Damya BOUKHEMAL

##Les requetes simples:
#1. Pour savoir les informations(ID,Type de contacteur) des bornes occupées.
SELECT * FROM borne WHERE Statut_de_disponibilité = "Occupé";

#1. Pour savoir les informations des borne hors communication.
SELECT * FROM borne WHERE Statut_de_disponibilité = "Hors communication";


#2. Quelles sont les stations qui ne sont pas ouvertes au services ?
SELECT * FROM station sta INNER JOIN localisation_station ls
ON sta.Ref_location = ls.ID_Emplacement
WHERE sta.Ouverture_au_service = "Non";
### Il n'y a pas de résultat car toutes les stations sont ouvertes au service.

#3. Quelles sont les stations qui contiennent des bornes avec des cables-attachées?
SELECT Nom_de_station,N_de_la_voie,Intitulé_de_la_voie,Code_postal FROM station sta 
INNER JOIN borne br ON sta.ID_Station = br.RefStation
INNER JOIN localisation_station ls ON ls.ID_Emplacement = sta.Ref_location
WHERE br.`Présence_cable_attaché`= "Oui";

#4. Pour savoir le code postal de la station 72 RUE DE ROME
SELECT Code_postal FROM 
station sta INNER JOIN localisation_station ls
ON sta.Ref_location = ls.ID_Emplacement
WHERE Nom_de_station = "72 RUE DE ROME";

#5. Pour savoir les nom des station qui se situent dans l'arrondissement 13.
SELECT Nom_de_station FROM 
station sta INNER JOIN localisation_station ls
ON sta.Ref_location = ls.ID_Emplacement
WHERE Code_postal = 75013;

#6. Pour savoir les staion qui on les borne Hors communication dans l'arrondissement 13.
SELECT Nom_de_station FROM station sta 
INNER JOIN borne br ON sta.ID_Station = br.RefStation
INNER JOIN localisation_station ls ON ls.ID_Emplacement = sta.Ref_location
WHERE Statut_de_disponibilité = "Hors communication" AND Code_postal = 75013
GROUP BY Nom_de_station;

#7.Pour savoir les nom des station qui ont des bornes CHAdeMO à Paris.
SELECT Nom_de_station FROM station sta 
INNER JOIN borne br ON sta.ID_Station = br.RefStation
INNER JOIN localisation_station ls ON ls.ID_Emplacement = sta.Ref_location
WHERE Type_de_contacteur = "CHAdeMO"
GROUP BY Nom_de_station;

#8. Pour savoir si la borne de E/F, il n'y a pas du cable attaché, si non affichier le indentification de la borne.
SELECT ID_Borne FROM borne 
WHERE Type_de_contacteur = "E/F" AND Présence_cable_attaché = "Oui";

#9. Pour savoir les type de borne qui ont le cable attaché.
SELECT Type_de_contacteur FROM borne 
WHERE Présence_cable_attaché = "Oui"
GROUP BY Type_de_contacteur;






##Les reauetes avec des fonctions d'agrégation :

#1. Il y a combien de genre de type de connecteur ?
SELECT Type_de_contacteur, COUNT(*) AS Nbre_de_chaque_type FROM borne 
GROUP BY Type_de_contacteur;
###Il y a 5 types de contacteurs, il sont : CHAdeMO,Combo, E/F, T2 et T3, dans les 5 genres de contacteurs, le contacteus
###de E/F a le plus de contacteurs 115, et dans toutes les station, nous avons justement 23 contacteurs de Combo.


#2. Il y a combien de genre de type de statut pour les borne ?
SELECT Statut_de_disponibilité FROM borne GROUP BY Statut_de_disponibilité;

#3. Quel sont les station qui ont les borne qui sont hors communication?
SELECT ID_Station,Nom_de_station FROM station sta 
INNER JOIN borne br ON sta.ID_Station = br.RefStation
INNER JOIN localisation_station ls ON ls.ID_Emplacement = sta.Ref_location
WHERE Statut_de_disponibilité = "Hors communication"
GROUP BY Nom_de_station;

#4. La station qui se situe dans la rue Baron Leroy,75013?
SELECT ID_Station,Nom_de_station,Ouverture_au_service FROM station 
WHERE Ref_location IN (SELECT ID_Emplacement FROM localisation_station 
                       WHERE Intitulé_de_la_voie = "Rue Baron Leroy" AND Code_postal = 75013);

#5. Il y a combiens de bornes dans chaque station?
SELECT RefStation, COUNT(*) AS Nbre_de_borne FROM borne GROUP BY RefStation;
###Nous pouvons savoir que dans chaque station a 3 borne.
                       
#6. Dans quel station tout les bornes sont en type E/F?
SELECT ID_Station,Nom_de_station,COUNT(*)AS Nbre_de_EF FROM station sta
INNER JOIN borne br ON br.RefStation = sta.ID_Station
WHERE Type_de_contacteur LIKE "E/F" 
GROUP BY ID_Station
HAVING Nbre_de_EF >2;


#7. La distribution des stations par les arrondissement et dans quel arrondissement il y a le plus de station?
CREATE VIEW distribution_des_stations AS 
SELECT Code_postal, COUNT(*) AS Nbre_de_station 
FROM station sta INNER JOIN localisation_station ls 
ON sta.Ref_location = ls.ID_Emplacement
GROUP BY Code_postal;

SELECT Code_postal,Nbre_de_station
FROM distribution_des_stations 
WHERE Nbre_de_station = (
                         SELECT MAX(Nbre_de_station) FROM distribution_des_stations);
#8. Quels sont les arrondissement dont le total des station est supérieur au total moyen par station ?
SELECT Code_postal FROM distribution_des_stations 
WHERE Nbre_de_station > (SELECT AVG(Nbre_de_station)
FROM distribution_des_stations);



###Par la vue, nous pouvons savoir la distribution des station dans chaque arrondissement, et dans 16ème arrondissement
###Il y a le plus de la station, 8 stations.

#9. Dans quel satation, on a le plus de bornes disponibilités ?
CREATE VIEW La_dispobibilité_de_chauqe_station AS 
SELECT ID_Station,Nom_de_station,N_de_la_voie,Intitulé_de_la_voie,COUNT(*) AS Nbre_de_borne_dispo FROM borne br 
INNER JOIN station sta ON br.RefStation = sta.ID_Station
INNER JOIN localisation_station ls ON sta.Ref_location = ls.ID_Emplacement
WHERE br.`Statut_de_disponibilité` = "Disponible"
GROUP BY ID_Station;

SELECT * FROM La_dispobibilité_de_chauqe_station
WHERE Nbre_de_borne_dispo = (SELECT MAX(Nbre_de_borne_dispo)FROM La_dispobibilité_de_chauqe_station);

#10. Est-ce qu'il y a des emplacement qui a plus de 3 borne?
CREATE VIEW Nbre_de_borne_par_emplacement AS 
SELECT Id_Emplacement,N_de_la_voie, Intitulé_de_la_voie,COUNT(*) AS Nbre_de_borne
FROM borne br 
INNER JOIN station sta ON br.RefStation = sta.ID_Station
INNER JOIN localisation_station ls ON ls.ID_Emplacement = sta.Ref_location
GROUP BY br.RefStation;

SELECT * FROM nbre_de_borne_par_emplacement WHERE Nbre_de_borne > 3;
## Il n'y a pas des emplacements qui ont plus de 3 borne.

#11. Est ce qu'il existe des stations ont des bornes disponibles dans l'arrondissement 8, si oui affichier l'adresse ?
SELECT Id_station, Nom_de_station,N_de_la_voie,Intitulé_de_la_voie,code_postal,COUNT(Id_Borne) AS Nbre_de_borne
FROM borne br 
INNER JOIN station sta ON br.RefStation = sta.ID_Station
INNER JOIN localisation_station ls ON ls.ID_Emplacement = sta.Ref_location
WHERE ls.Code_postal LIKE "%08" AND br.`Statut_de_diponibilié` = "Disponible"
GROUP BY Id_station;
## À 8ème arrondissement, il y a 2 station qui ont les bornes disponibles ans les 2 stations RUEPIERRE CHARRON et
##AV DUTUIT, et pour la première station, il y a 3 bornes disponibles et pour la deuxième, il y a 2 bornes disponibles.

#12. Pour faciliter les technicien savent les indices de l'usage de chaque borne et chercher les bornes en panne, nous 
##devons créer un utilisateur pour eux.
CREATE USER Technicien;
GRANT SELECT ON balib.* To Technicien;

##Mise à jour :
##a)
#1. Le réseau Belib veut établir une station à nanterre université(8 Allée de l'université,92000).
INSERT INTO localisation_station VALUES 
("80","8","Allée de l'université",92000,"Nanterre","France");
#2.
INSERT INTO station VALUES 
(80,"Nanterre Université", "Non","BELIB","80");
#3. En concernant la demande des étudiants et des professeurs, Belib veux mettre 2 borne dans la station Nanterre Université.
#   borne1 : FR*V93*EBELI*100*1*1, T2,En construction, Oui,80
#   borne2 : FR*V93*EBELI*100*1*2, E/F,En construction, Oui,80
INSERT INTO borne VALUES 
("FR*V93*EBELI*100*1*1","T2","En construction", "Oui",80);
#4.
INSERT INTO borne VALUES 
("FR*V93*EBELI*100*1*2","E/F","En construction", "Oui",80);

##b)
##À cause de la négligence d'un emploiyé, il a mis fautes sur le ID_Borne et la présence cable attaché des 2 
##bornes de la station Nanterre Université,donc nous devons le corriger.
#1.
UPDATE borne 
SET ID_Borne = "FR*V92*EBELI*100*1*1",Présence_cable_attaché = "Non"
WHERE ID_Borne ="FR*V93*EBELI*100*1*1" AND RefStation =80;
#2.
UPDATE borne 
SET ID_Borne = "FR*V92*EBELI*100*1*2",Présence_cable_attaché = "Non"
WHERE ID_Borne ="FR*V93*EBELI*100*1*2" AND RefStation =80;
#3. Maintenant la construction de la station Nanterre Université est bien fait, on vas changer sons statut,et la 
#statut des bornes.
UPDATE borne 
SET Statut_de_disponibilité = "disponible"
WHERE RefStation = (SELECT ID_Station FROM station WHERE Nom_de_station ="Nanterre Université");
#4.
UPDATE station 
SET Ouverture_au_service = "Oui"
WHERE Nom_de_station = "Nanterre Université";

#5. Le technicien a déjà réparé les 3 borne de la station Paris - avenue iena,maintenant, les 3 borne sont disponible.
UPDATE borne 
SET Statut_de_disponibilité = "Disponible"
WHERE RefStation IN (SELECT ID_Station FROM station WHERE Nom_de_station ="Paris - avenue iena");

#6. En concernant la demande de contacteur T2 augemente dans la station Rue de La Convention, l'entreprise veux changer
# la 3ème borne CHAdeMO par T2.
UPDATE borne 
SET Type_de_contacteur = "T2", Présence_cable_attaché = "Non"
WHERE RefStation IN (SELECT ID_Station FROM station WHERE Nom_de_station ="Rue de La Convention")
AND ID_Borne LIKE "%3";


#7. À cause des travaux dans la rue, les stations qui se situeNT à 227,AVENUE GAMBETTA et 55 RUE MONGE est en panne
#tout les bornes sont Hor communication.
UPDATE borne 
SET Statut_de_disponibilité ="Hors communication"
WHERE RefStation IN (
                     SELECT ID_Station FROM station sta
							INNER JOIN localisation_station ls 
							ON ls.ID_Emplacement = sta.Ref_location
							WHERE N_de_la_voie = "227" AND Intitulé_de_la_voie = "AVENUE GAMBETTA"
							);
UPDATE borne 
SET Statut_de_disponibilité ="Hors communication"
WHERE RefStation IN (
                     SELECT ID_Station FROM station sta
							INNER JOIN localisation_station ls 
							ON ls.ID_Emplacement = sta.Ref_location
							WHERE N_de_la_voie = "55" AND Intitulé_de_la_voie = "RUE MONGE"
							);
UPDATE station 
SET Ouverture_au_service = "Non"
WHERE ID_Station IN (SELECT ID_Station FROM station sta
                     INNER  JOIN localisation_station ls ON ls.ID_Emplacement = sta.Ref_location
                     WHERE Intitulé_de_la_voie = "RUE MONGE" OR Intitulé_de_la_voie = "AVENUE GAMBETTA" );
                     
clients