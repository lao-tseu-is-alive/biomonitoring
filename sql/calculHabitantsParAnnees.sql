
SELECT idadresse,
       date_part('year',dateextraction) as annee,
       round(avg(ch_histo_nbr_habi_par_adr.nbrhabitants)) as nbrhabitants,
       gal.geom
INTO nbrhabitants_par_adresse_annee
FROM ch_histo_nbr_habi_par_adr
LEFT OUTER JOIN goeland_addresse_lausanne gal on ch_histo_nbr_habi_par_adr.idadresse = gal.idaddress
WHERE code = 'H'
GROUP BY date_part('year',dateextraction),idadresse,gal.geom
ORDER BY 3,2 ASC;

SELECT COUNT(DISTINCT  idadresse), SUM(nbrhabitants),
       date_part('year',dateextraction) as annee,
       min(nbrhabitants),max(nbrhabitants),
       round(avg(ch_histo_nbr_habi_par_adr.nbrhabitants)) as nbrhabitants
FROM ch_histo_nbr_habi_par_adr
WHERE code = 'H' AND nbrhabitants > 0
GROUP BY date_part('year',dateextraction);

SELECT COUNT(DISTINCT  idadresse), SUM(nbrhabitants),
       date_part('year',dateextraction) as annee,
       min(nbrhabitants),max(nbrhabitants),
       round(avg(ch_histo_nbr_habi_par_adr.nbrhabitants)) as nbrhabitants
FROM ch_histo_nbr_habi_par_adr
WHERE code = 'H' AND nbrhabitants > 0
GROUP BY date_part('year',dateextraction);

SELECT COUNT(*),main_lidar_category,main_lidar_category_2015
FROM grid_10m
WHERE main_lidar_category_2015 != main_lidar_category
GROUP BY main_lidar_category, main_lidar_category_2015
ORDER BY 3,2;



WITH liste_date AS (
SELECT DISTINCT date_trunc('day',CHS.datehistorisation) AS dateh
FROM ch_histo_nbr_habi_par_adr CHS
WHERE CHS.datehistorisation IS NOT NULL
), liste_date_adresse AS (
SELECT GOA.idaddress AS id_adresse, liste_date.dateh AS dateh
FROM liste_date, goeland_addresse_lausanne GOA
)
SELECT     liste_date_adresse.dateh AS dateh
        ,liste_date_adresse.id_adresse AS id_adresse
        ,CHS.NbrHabitants AS nbr_habitants
INTO
FROM liste_date_adresse
LEFT OUTER JOIN ch_histo_nbr_habi_par_adr CHS ON        CHS.IdAdresse=liste_date_adresse.id_adresse
                                            AND    date_trunc('day',CHS.datehistorisation)=liste_date_adresse.dateh
ORDER BY 2, 1;

SELECT round(surf_verte_public::numeric, 2), round(surf_verte_prive::numeric, 2) FROM grid_1m
WHERE surf_verte_prive > 0
AND surf_verte_public > 0

SELECT * FROM goeland_addresse_lausanne
WHERE nbrlogements = 0 and nbrhabitants > 0
