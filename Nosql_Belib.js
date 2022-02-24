//1. Quelles sont les stations qui sont fermees au service commercial?
db.station.findOne();
db.station.find({"Ouverture_au_service":"Non"},
                {_id:0}
);

//2. Y-a-t-il une station dans la rue Baroy Leroy 13eme, et si elle est ouverte
//   au service?
db.localisation_station.findOne();
db.localisation_station.find({"Intitulé_de_la_voie" : "Rue Baron Leroy",
                              "Code_postal":75013},
                             {"_id":0, "ID_Emplacement" : 1 }
);
db.station.find({"Ref_location" : "19"},
                {"Ouverture_au_service":1,_id:0});
db.Jointure_localisation_station.findOne();
//3. Quelles sont les informations(ID,Type de connecteuretc) des bornes oc-
//   cupees ?
db.borne.findOne();
db.borne.find({ "Statut_de_disponibilité" : "Occupé"},
              {"_id":0,"ID_Borne":1,"Type_de_contacteur":1}
);
                
//4. Quels sont les noms des stations qui ont des bornes CHAdeMO à Paris?

db.Jointure_station_borne_localisation.findOne();              
db.Jointure_station_borne_localisation.find({"Sta_borne":{$elemMatch:{"Type_de_contacteur":"CHAdeMO"}}},
                                            {"_id":0,"Nom_de_station":1});

//5. Quel est le code postal de la station 72 RUE DE ROME?
db.Jointure_localisation_station.findOne();
db.Jointure_localisation_station.find({"local_sta":{$elemMatch:{"Nom_de_station" : "72 RUE DE ROME"}}},
                                      {"_id":0,"Code_postal":1,}
);

//6. Quels sont les noms des stations qui se situent dans l'arrondissement 13?
db.Jointure_localisation_station.findOne();
db.Jointure_localisation_station.find({"Code_postal":75013},
                                      {"_id":0,"local_sta.Nom_de_station":1}
);

//7.SELECT Nom-de-station FROM station sta INNER JOIN borne br ON
db.Jointure_station_borne_localisation.findOne();
db.Jointure_station_borne_localisation.find({"Sta_borne":{$elemMatch:{"Statut_de_disponibilité" : "Hors communication"}},
                                             "sta_bor_local":{$elemMatch:{"Code_postal" : 75013}}},
                                            {"_id":0,"Nom_de_station":1}
);

//9.Quelles sont les stations qui contiennent des bornes avec des c^ables-attachées?
db.Jointure_station_borne_localisation.findOne ();
db.Jointure_station_borne_localisation.find({"Sta_borne":{$elemMatch:{"Présence_cable_attaché" : "Oui"}}},
                                            {"_id":0,"Nom_de_station":1,"sta_bor_local.N_de_la_voie":1,
                                             "sta_bor_local.Intitulé_de_la_voie":1})
                                             
//10. Quels sont les stations qui contiennent des bornes hors communication?  
db.Jointure_station_borne_localisation.findOne();  
db.Jointure_station_borne_localisation.find({"Sta_borne":{$elemMatch:{"Statut_de_disponibilité" : "Hors communication"}}},
                                            {"_id":0,"ID_Station":1,"Nom_de_station":1,}); 
//11. Ou se situe la station du "Berbier de Mets"?           
db.Jointure_localisation_station.findOne();   
db.Jointure_localisation_station.find({"local_sta":{$elemMatch:{"Nom_de_station" : "Berbier du Mets"}}},
                                      {"N_de_la_voie":1,"Intitulé_de_la_voie":1, "Code_postal":1,"Ville":1,"Pays":1});        
//12. Combien y-a-t-il de bornes dans chaque station?
db.borne.aggregate([{$group:{"_id":"$RefStation",
                             count:{$sum:1}}}
                   ]);

//13. Quels sont les différents types de connecteurs de notre réseau BELIB?
db.borne.aggregate([{$group:{"_id":"$Type_de_contacteur"}}
                   ]);      
                   
//14.Combien de connecteurs y-a-t-il de chaque Type dans l'ensemble de bornes
db.borne.findOne();
db.borne.aggregate([{$group:{"_id":"$Type_de_contacteur",
                             Nbre_de_chaque_type:{$sum:1}}}
                   ]);
//15.Quels sont les différents typre de disponibilites des bornes ? 
db.borne.aggregate([{$group:{"_id":"$Statut_de_disponibilité"}}]);    

//16. Quels sont les types de connecteurs des bornes qui ont le cable attaché ?          
db.borne.aggregate([{$match:{"Présence_cable_attaché" : "Oui"}},
                    {$group:{"_id":"$Type_de_contacteur"}}
]);

//17.Combien de stations y-a-t-il dans chaque arrandissement? et quel est l'arrandissement qui contient le plus de stations?

db.VUE_distribution_des_stations.find().sort({"Nbre_de_station":-1});                               
//18.Quels sont les arrondissement dont le nombre de stations est supérieur au
//nombre moyen de stations par arrandissement ?
db.VUE_distribution_des_stations.aggregate({"$group":{_id: 'Nbre_de_station',avg:{"$avg":"$Nbre_de_station"}}});
db.VUE_distribution_des_stations.find({"Nbre_de_station":{$gt:3.6364}});

//19. Dans quel satation, on a le plus de bornes disponibles?
db.VUE_la_disponibilité_de_chaque_station.find();
db.VUE_la_disponibilité_de_chaque_station.aggregate({"$group":{_id: 'Nbre_de_borne_dispo',max:{"$max":"$Nbre_de_borne_dispo"}}});
db.VUE_la_disponibilité_de_chaque_station.find({"Nbre_de_borne_dispo":3});

//Requetes de mise à jours de la base BELIB
//1.Le reseau Belib veut etablir une station a Nanterre Universite(8 Allee de
//l'universite,92000).
db.localisation_station.findOne();
db.localisation_station.insert({ 
    "ID_Emplacement" : "80", 
    "N_de_la_voie" : "8", 
    "Intitulé_de_la_voie" : "Allée de l'université", 
    "Code_postal" : 92000.0, 
    "Ville" : "Nanterre", 
    "Pays" : "France"
});

//2. Ajout d'une nouvelle station dans la borne station :
//INSERT INTO station VALUES (80,"Nanterre Universite", "Non","BELIB","80");
db.station.findOne();
db.station.insert({ 
    "ID_Station" : "80", 
    "Nom_de_station" : "Nanterre Université", 
    "Ouverture_au_service" : "Non", 
    "Nom_du_réseau" : "BELIB", 
    "Ref_location" : "80"
})

//3. Ajouter 2 bornes dans une station
db.borne.findOne();
db.borne.insert({ 
    "ID_Borne" : "FR*V93*EBELI*100*1*1", 
    "Type_de_contacteur" : "T2", 
    "Statut_de_disponibilité" : "En construction", 
    "Présence_cable_attaché" : "Oui", 
    "RefStation" : 80.0
});
db.borne.insert({ 
    "ID_Borne" : "FR*V93*EBELI*100*1*1", 
    "Type_de_contacteur" : "E/F", 
    "Statut_de_disponibilité" : "En construction", 
    "Présence_cable_attaché" : "Oui", 
    "RefStation" : 80.0
});
//4.Lors de la saisie de l'identiant des deux bornes de la nouvelle station
//de Nanterre, le technicien a comis une erreur par rapport au numero de
//departement 92,nous allons donc la corriger avec la requ^ete suivante:
//Borne T2 :
db.borne.update({"ID_Borne":"FR*V93*EBELI*100*1*1","RefStation":"80"},
                {$set:{"ID_Borne":"FR*V92*EBELI*100*1*1",
                       "Présence_cable_attaché":"Non"}});
//Borne E/F :
db.borne.update({"ID_Borne":"FR*V93*EBELI*100*1*2","RefStation":"80"},
                {$set:{"ID_Borne":"FR*V92*EBELI*100*1*2",
                       "Présence_cable_attaché":"Non"}});
                       
//5.Une fois que la station est mise en place, nous allons modier le statut de
//disponibilite des bornes (avec sous-requ^etes).
db.station.find({"Nom_de_station":"Nanterre Université"},{"ID_Station":1});
db.borne.update({"RefStation":"80"},
                {$set:{"Statut_de_disponibilité":"disponible"}});          
  
//6. Laisser la nouvelle station qu'on a creee ouverte au public.    
db.station.update({"Nom_de_station":"Nanterre Université"},
                  {$set:{"Ouverture_au_service":"Oui"}});    
//7. Mise a jour des trois bornes de la station "avenue iena" (passser du statut
//   Hors connexion a statut disponible).  
db.station.find({"Nom_de_station":"Paris - avenue iena"},{"ID_Station":1});
db.borne.update({"RefStation":9},
                {$set:{"Statut_de_disponibilité":"disponible"}});   
//8.Changer le type de chargeur de la borne CHAdeMo de la station "Rue de
//  la Convention" an de satisfaire la demande des clients.             
db.station.find({"Nom_de_station":"Rue de La Convention"},{"ID_Station":1});
db.borne.update({"RefStation":12,"ID_Borne":"%3"},
                {$set:{"Type_de_contacteur":"T2","Présence_cable_attaché":"Non"}}); 

//9.a. Changer le statut de disponibilite des bornes de la station qui se situe
//a 227 AVENUE GAMBETTA (avec sous-requ^etes) 
db.Jointure_localisation_station.findOne();
db.Jointure_localisation_station.find({"N_de_la_voie":"227","Intitulé_de_la_voie":"AVENUE GAMBETTA"},
                                      {"local_sta.ID_Station":1});
db.borne.update({"RefStation":11},
                {$set:{"Statut_de_disponibilité":"Hors communication"}})         
                                             
//9 b) Changer le statut de disponibilite des bornes de la station qui se situe
//a 55 RUE MONGE (avec sous-requ^etes) UPDATE borne.
db.Jointure_localisation_station.find({"N_de_la_voie":"55","Intitulé_de_la_voie":"RUE MONGE"},
                                      {"local_sta.ID_Station":1});
db.borne.update({"RefStation":13},
                {$set:{"Statut_de_disponibilité":"Hors communication"}});      
//9.c) Mise a jour des statuts des deux stations.  
db.Jointure_localisation_station.find({$or:[{"Intitulé_de_la_voie":"RUE MONGE"},
                                            {"Intitulé_de_la_voie":"AVENUE GAMBETTA"}]},
                                      {"local_sta.ID_Station":1})     
db.station.update({"ID_Station":{$in:[11,13]}},
                  {$set:{"Ouverture_au_service":"Non"}});         